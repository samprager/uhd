#include <uhd/types/tune_request.hpp>
#include <uhd/utils/thread_priority.hpp>
#include <uhd/utils/safe_main.hpp>
#include <uhd/utils/static.hpp>
#include <uhd/usrp/multi_usrp.hpp>
#include <uhd/exception.hpp>
#include <boost/thread/thread.hpp>
#include <boost/program_options.hpp>
#include <boost/math/special_functions/round.hpp>
#include <boost/format.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/filesystem.hpp>
#include <boost/date_time/posix_time/posix_time.hpp>
#include <iostream>
#include <fstream>
#include <csignal>
#include <complex>
#include <sstream>

#include <math.h>
#include <fstream>
#include <string>

namespace po = boost::program_options;
using namespace std;

typedef float data_t;
typedef complex<data_t> samp_t;

static bool stop_signal_called = false;
void sig_int_handler(int){stop_signal_called = true;}

void process(
    vector<samp_t>& rx_buff
){
	ofstream myfile("impulse.csv");
	stringstream ss;
	float max_mag = 0;
	size_t max_index = 1e6;
	float phase = 0;
	for (size_t i = 0 ; i < rx_buff.size(); i++){
		ss << real(rx_buff.at(i));
		ss << ",";
		ss << imag(rx_buff.at(i));
	    myfile << ss.str() << endl;
		ss.str("");
		float mag = abs(rx_buff.at(i));
		if(mag > max_mag){
			max_mag = mag;
			max_index = i;
			phase = arg(rx_buff.at(i));
		}
	}
	cout << "max_index: " << max_index << ", phase: " << phase << endl;
	myfile.close();
}

void txrx(
    uhd::usrp::multi_usrp::sptr usrp,
    uhd::tx_streamer::sptr tx_stream,
	uhd::rx_streamer::sptr rx_stream
){

    size_t samps_per_buff = 10000;

	size_t position = size_t(samps_per_buff* 3/4) ;
	vector<samp_t> waveform(samps_per_buff, samp_t(0,0));
	waveform.at(position) = samp_t(1,0);

    // Prepare buffers for received samples and metadata
    uhd::rx_metadata_t rx_md;
    vector<samp_t> rx_buff(samps_per_buff);

    bool overflow_message = true;

    //setup streaming
    uhd::stream_cmd_t stream_cmd(uhd::stream_cmd_t::STREAM_MODE_NUM_SAMPS_AND_DONE);
    stream_cmd.num_samps = samps_per_buff;
    stream_cmd.stream_now = false;

	//setup the metadata flags
    uhd::tx_metadata_t tx_md;
    tx_md.start_of_burst = true;
    tx_md.end_of_burst   = false;
    tx_md.has_time_spec  = true;

    float samp_delay = 1;
    float rx_timeout = samp_delay*2;

    while(not stop_signal_called){
        uhd::time_spec_t cmd_time = usrp->get_time_now() + uhd::time_spec_t(samp_delay);
        stream_cmd.time_spec = cmd_time;
        tx_md.time_spec = cmd_time;
        //send the entire contents of the tx_buffer
        tx_stream->send(&waveform.front(), waveform.size(), tx_md);
        tx_md.start_of_burst = false;
        rx_stream->issue_stream_cmd(stream_cmd);
        size_t num_rx_samps = rx_stream->recv(&rx_buff.front(), samps_per_buff, rx_md, rx_timeout);

		process(rx_buff);

        if(num_rx_samps != samps_per_buff){
            cout << "ERROR: " << num_rx_samps << " != " << samps_per_buff << endl;
        }

        if (rx_md.error_code == uhd::rx_metadata_t::ERROR_CODE_TIMEOUT) {
            cout << boost::format("Timeout while streaming") << endl;
            break;
        }
        if (rx_md.error_code == uhd::rx_metadata_t::ERROR_CODE_OVERFLOW){
            if (overflow_message){
                overflow_message = false;
                cerr << boost::format("Overflow") % (usrp->get_rx_rate()*sizeof(samp_t)/1e6);
            }
            continue;
        }
        if (rx_md.error_code != uhd::rx_metadata_t::ERROR_CODE_NONE){
            throw runtime_error(str(boost::format(
                "Receiver error %s"
            ) % rx_md.strerror()));
        }
    }

    // Shut down receiver
    stream_cmd.stream_mode = uhd::stream_cmd_t::STREAM_MODE_STOP_CONTINUOUS;
    rx_stream->issue_stream_cmd(stream_cmd);

    //Shut down tx
    tx_md.end_of_burst = true;
    tx_stream->send("", 0, tx_md);
}

int UHD_SAFE_MAIN(int argc, char *argv[]){
    uhd::set_thread_priority_safe();

    //transmit variables to be set by po
    string args = "type=x300";
	string tx_ant = "TX/RX";
	string tx_subdev = "A:0";
	string rx_ant = "RX2";
	string rx_subdev = "B:0";

	string otw = "sc16";
	string cpu_format = "fc32";

    double samp_rate = 200e6;
	double rf_freq = 1e9;
	double tx_gain = 30;
	double rx_gain = 30;

    //create a usrp device
    cout << endl;
    cout << boost::format("Creating the usrp device with: %s...") % args << endl;
    uhd::usrp::multi_usrp::sptr usrp = uhd::usrp::multi_usrp::make(args);

    //Lock mboard clocks
    usrp->set_clock_source("internal");

    //always select the subdevice first, the channel mapping affects the other settings
    usrp->set_tx_subdev_spec(tx_subdev);
    usrp->set_rx_subdev_spec(rx_subdev);

    cout << boost::format("Using Device: %s") % usrp->get_pp_string() << endl;

	//set the sample rate
    cout << boost::format("Setting TX Rate: %f Msps...") % (samp_rate/1e6) << endl;
    usrp->set_tx_rate(samp_rate);
    cout << boost::format("Actual TX Rate: %f Msps...") % (usrp->get_tx_rate()/1e6) << endl << endl;

    cout << boost::format("Setting RX Rate: %f Msps...") % (samp_rate/1e6) << endl;
    usrp->set_rx_rate(samp_rate);
    cout << boost::format("Actual RX Rate: %f Msps...") % (usrp->get_rx_rate()/1e6) << endl << endl;

	//we will tune the frontends in X seconds from now
    float tune_delay = 1;
    uhd::time_spec_t cmd_time = usrp->get_time_now() + uhd::time_spec_t(tune_delay);

    //set the rf gain
    cout << boost::format("Setting TX Gain: %f dB...") % tx_gain << endl;
    usrp->set_tx_gain(tx_gain, 0);
    cout << boost::format("Actual TX Gain: %f dB...") % usrp->get_tx_gain(0) << endl << endl;

    //set the antenna
    usrp->set_tx_antenna(tx_ant, 0);

	//set the transmit center frequency
	cout << boost::format("Setting TX Freq: %f MHz...") % (rf_freq/1e6) << endl;
    uhd::tune_request_t tx_tune_request(rf_freq);
    tx_tune_request.args = uhd::device_addr_t("mode_n=integer");

    usrp->set_command_time(cmd_time);
    usrp->set_tx_freq(tx_tune_request, 0);
    cout << boost::format("Actual TX Freq: %f MHz...") % (usrp->get_tx_freq(0)/1e6) << endl << endl;
    usrp->clear_command_time();

    //set the receive rf gain
    cout << boost::format("Setting RX Gain: %f dB...") % rx_gain << endl;
    usrp->set_rx_gain(rx_gain, 0);
    cout << boost::format("Actual RX Gain: %f dB...") % usrp->get_rx_gain(0) << endl << endl;

    //set the receive center frequency
    cout << boost::format("Setting RX Freq: %f MHz...") % (rf_freq/1e6) << endl;
	uhd::tune_request_t rx_tune_request(rf_freq);
    rx_tune_request.args = uhd::device_addr_t("mode_n=integer");

    usrp->set_command_time(cmd_time);
    usrp->set_rx_freq(rx_tune_request, 0);
    cout << boost::format("Actual RX Freq: %f MHz...") % (usrp->get_rx_freq(0)/1e6) << endl << endl;
    usrp->clear_command_time();

    //set the receive antenna
    usrp->set_rx_antenna(rx_ant);

    //create a transmit streamer
    uhd::stream_args_t stream_args(cpu_format, otw);
    uhd::tx_streamer::sptr tx_stream = usrp->get_tx_stream(stream_args);

	//create a receive streamer
    uhd::stream_args_t rx_stream_args(cpu_format, otw);
    uhd::rx_streamer::sptr rx_stream = usrp->get_rx_stream(rx_stream_args);

    //Check Ref and LO Lock detect
    vector<string> tx_sensor_names, rx_sensor_names;
    tx_sensor_names = usrp->get_tx_sensor_names(0);
    if (find(tx_sensor_names.begin(), tx_sensor_names.end(), "lo_locked") != tx_sensor_names.end()) {
        uhd::sensor_value_t lo_locked = usrp->get_tx_sensor("lo_locked",0);
        cout << boost::format("Checking TX: %s ...") % lo_locked.to_pp_string() << endl;
        UHD_ASSERT_THROW(lo_locked.to_bool());
    }
    rx_sensor_names = usrp->get_rx_sensor_names(0);
    if (find(rx_sensor_names.begin(), rx_sensor_names.end(), "lo_locked") != rx_sensor_names.end()) {
        uhd::sensor_value_t lo_locked = usrp->get_rx_sensor("lo_locked",0);
        cout << boost::format("Checking RX: %s ...") % lo_locked.to_pp_string() << endl;
        UHD_ASSERT_THROW(lo_locked.to_bool());
    }

    signal(SIGINT, &sig_int_handler);
    cout << "Press Ctrl + C to stop streaming..." << endl;

    //reset usrp time to prepare for transmit/receive
    cout << boost::format("Setting device timestamp to 0...") << endl;
    usrp->set_time_now(uhd::time_spec_t(0.0));

    txrx(usrp, tx_stream, rx_stream);

    stop_signal_called = true;

    //finished
    cout << endl << "Done!" << endl << endl;
    return EXIT_SUCCESS;
}
