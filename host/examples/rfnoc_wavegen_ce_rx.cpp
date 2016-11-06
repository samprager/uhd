//
// Copyright 2014 Ettus Research LLC
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

// This is a simple example for RFNoC apps written in UHD.
// It connects a wavegen source block to any other block on the
// crossbar (provided it has stream-through capabilities)
// and then streams the result to the host, writing it into a file.

#include <uhd/device3.hpp>
#include <uhd/utils/thread_priority.hpp>
#include <uhd/utils/safe_main.hpp>
#include <uhd/exception.hpp>
#include <uhd/rfnoc/block_ctrl.hpp>
#include <uhd/rfnoc/radio_ctrl.hpp>
//#include <uhd/rfnoc/null_block_ctrl.hpp>
#include <boost/program_options.hpp>
#include <boost/format.hpp>
#include <boost/thread.hpp>
#include <iostream>
#include <fstream>
#include <csignal>
#include <complex>

#include <uhd/rfnoc/wavegen_block_ctrl.hpp>

namespace po = boost::program_options;

static bool stop_signal_called = false;
void sig_int_handler(int){stop_signal_called = true;}


template<typename samp_type> void recv_to_file(
    uhd::rfnoc::wavegen_block_ctrl::sptr wavegen_ctrl,
    uhd::rx_streamer::sptr rx_stream,
    const std::string &file,
    size_t samps_per_buff,
    double prf,
    int num_pulses,
    unsigned long long num_requested_samples,
    double time_requested = 0.0,
    bool bw_summary = false,
    bool stats = false,
    bool continue_on_bad_packet = false
) {
    unsigned long long num_total_samps = 0;

    uhd::rx_metadata_t md;
    std::vector<samp_type> buff(samps_per_buff);
    std::ofstream outfile;
    if (not file.empty()) {
        outfile.open(file.c_str(), std::ofstream::binary);
    }
    bool overflow_message = true;

    //setup streaming
    uhd::stream_cmd_t stream_cmd((num_requested_samples == 0)?
        uhd::stream_cmd_t::STREAM_MODE_START_CONTINUOUS:
        uhd::stream_cmd_t::STREAM_MODE_NUM_SAMPS_AND_DONE
    );
    stream_cmd.num_samps = num_requested_samples;
    stream_cmd.stream_now = true;
    stream_cmd.time_spec = uhd::time_spec_t();
    std::cout << "Issuing start stream cmd" << std::endl;
    // This actually goes to the null source; the processing block
    // should propagate it.
    rx_stream->issue_stream_cmd(stream_cmd);
    std::cout << "Done" << std::endl;

    boost::system_time start = boost::get_system_time();
    unsigned long long ticks_requested = (long)(time_requested * (double)boost::posix_time::time_duration::ticks_per_second());
    boost::posix_time::time_duration ticks_diff;
    boost::system_time last_update = start;
    unsigned long long last_update_samps = 0;

    boost::posix_time::time_duration pulse_diff;
    boost::system_time last_pulse = start;
    int pulse_count = 0;

    while(
        not stop_signal_called
        and (num_requested_samples != num_total_samps or num_requested_samples == 0)
    ) {

        boost::system_time now = boost::get_system_time();

        pulse_diff = now - last_pulse;
        double pulse_diff_sec = (double)pulse_diff.total_microseconds() / 1000000.0;
        if (((pulse_count<num_pulses)||(num_requested_samples == 0))&&(pulse_diff_sec >= prf)) {
          wavegen_ctrl->send_pulse();
          std::cout << boost::format("\tpulse_count: %i/%i. pulse_diff: %f sec.") % pulse_count % num_pulses % pulse_diff_sec << std::endl;
          last_pulse = now;
          pulse_count++;
        }


        size_t num_rx_samps = rx_stream->recv(&buff.front(), buff.size(), md, 3.0);

        if (md.error_code == uhd::rx_metadata_t::ERROR_CODE_TIMEOUT) {
            std::cout << boost::format("Timeout while streaming") << std::endl;
            //break;
        }
        if (md.error_code == uhd::rx_metadata_t::ERROR_CODE_OVERFLOW){
            if (overflow_message){
                overflow_message = false;
                std::cerr << "Got an overflow indication. If writing to disk, your\n"
                             "write medium may not be able to keep up.\n";
            }
            continue;
        }
        if (md.error_code != uhd::rx_metadata_t::ERROR_CODE_NONE){
            std::string error = str(boost::format("Receiver error: %s") % md.strerror());
            if (continue_on_bad_packet){
                std::cerr << error << std::endl;
                continue;
            }
            else {
                throw std::runtime_error(error);
            }
        }
        num_total_samps += num_rx_samps;

        if (outfile.is_open()) {
            outfile.write((const char*)&buff.front(), num_rx_samps*sizeof(samp_type));
        }

        if (bw_summary) {
            last_update_samps += num_rx_samps;
            boost::posix_time::time_duration update_diff = now - last_update;
            if (update_diff.ticks() > boost::posix_time::time_duration::ticks_per_second()) {
                double t = (double)update_diff.ticks() / (double)boost::posix_time::time_duration::ticks_per_second();
                double r = (double)last_update_samps / t;
                std::cout << boost::format("\t%f Msps") % (r/1e6) << std::endl;
                last_update_samps = 0;
                last_update = now;
            }
        }


        ticks_diff = now - start;
        if (ticks_requested > 0){
            if ((unsigned long long)ticks_diff.ticks() > ticks_requested)
                break;
        }
    }

    stream_cmd.stream_mode = uhd::stream_cmd_t::STREAM_MODE_STOP_CONTINUOUS;
    std::cout << "Issuing stop stream cmd" << std::endl;
    rx_stream->issue_stream_cmd(stream_cmd);
    std::cout << "Done" << std::endl;

    if (outfile.is_open())
        outfile.close();

    if (stats){
        std::cout << std::endl;
        double t = (double)ticks_diff.ticks() / (double)boost::posix_time::time_duration::ticks_per_second();
        std::cout << boost::format("Received %d samples in %f seconds") % num_total_samps % t << std::endl;
        double r = (double)num_total_samps / t;
        std::cout << boost::format("%f Msps") % (r/1e6) << std::endl;
    }
}


void pretty_print_flow_graph(std::vector<std::string> blocks)
{
    std::string sep_str = "==>";
    std::cout << std::endl;
    // Line 1
    for (size_t n = 0; n < blocks.size(); n++) {
        const std::string name = blocks[n];
        std::cout << "+";
        for (size_t i = 0; i < name.size() + 2; i++) {
            std::cout << "-";
        }
        std::cout << "+";
        if (n == blocks.size() - 1) {
            break;
        }
        for (size_t i = 0; i < sep_str.size(); i++) {
            std::cout << " ";
        }
    }
    std::cout << std::endl;
    // Line 2
    for (size_t n = 0; n < blocks.size(); n++) {
        const std::string name = blocks[n];
        std::cout << "| " << name << " |";
        if (n == blocks.size() - 1) {
            break;
        }
        std::cout << sep_str;
    }
    std::cout << std::endl;
    // Line 3
    for (size_t n = 0; n < blocks.size(); n++) {
        const std::string name = blocks[n];
        std::cout << "+";
        for (size_t i = 0; i < name.size() + 2; i++) {
            std::cout << "-";
        }
        std::cout << "+";
        if (n == blocks.size() - 1) {
            break;
        }
        for (size_t i = 0; i < sep_str.size(); i++) {
            std::cout << " ";
        }
    }
    std::cout << std::endl << std::endl;
}

///////////////////// MAIN ////////////////////////////////////////////////////
int UHD_SAFE_MAIN(int argc, char *argv[])
{
    uhd::set_thread_priority_safe();

    //variables to be set by po
    std::string args, file, format, ant, ref, wirefmt, streamargs,radio_args, awg_policy, awg_source, wavegenid, blockid, blockid2, blockid3, blockid4;
    size_t total_num_samps, spb, radio_id, radio_chan;
    double rate, total_time, setup_time, block_rate,awg_sample_len,awg_prf, freq, gain, bw;

    //setup the program options
    po::options_description desc("Allowed options");
    desc.add_options()
        ("help", "help message")
        ("args", po::value<std::string>(&args)->default_value("type=x300"), "multi uhd device address args")

        ("file", po::value<std::string>(&file)->default_value("usrp_samples.dat"), "name of the file to write binary samples to, set to stdout to print")
        ("null", "run without writing to file")

        ("nsamps", po::value<size_t>(&total_num_samps)->default_value(0), "total number of samples to receive")
        ("time", po::value<double>(&total_time)->default_value(0), "total number of seconds to receive")
        ("spb", po::value<size_t>(&spb)->default_value(10000), "samples per buffer")
        ("streamargs", po::value<std::string>(&streamargs)->default_value(""), "stream args")
        ("sizemap", "track packet size and display breakdown on exit")
        ("block_rate", po::value<double>(&block_rate)->default_value(200e6), "The clock rate of the processing block.")

        ("setup", po::value<double>(&setup_time)->default_value(1.0), "seconds of setup time")
        ("format", po::value<std::string>(&format)->default_value("sc16"), "File sample type: sc16, fc32, or fc64")
        ("progress", "periodically display short-term bandwidth")
        ("stats", "show average bandwidth on exit")
        ("continue", "don't abort on a bad packet")

        ("awglen", po::value<double>(&awg_sample_len)->default_value(64), "total number samples to load into waveform generator")
        ("policy", po::value<std::string>(&awg_policy)->default_value("manual"), "AWG Operational mode: manual or auto ")
        ("source", po::value<std::string>(&awg_source)->default_value("awg"), "AWG Source Select: awg or chirp ")
        ("prf", po::value<double>(&awg_prf)->default_value(1), "AWG Radar PRF in seconds")

        ("radio-id", po::value<size_t>(&radio_id)->default_value(0), "Radio ID to use (0 or 1).")
        ("radio-chan", po::value<size_t>(&radio_chan)->default_value(0), "Radio channel")
        ("radio-args", po::value<std::string>(&radio_args), "Radio channel")
        ("rate", po::value<double>(&rate)->default_value(200e6), "RX rate of the radio block")
        ("freq", po::value<double>(&freq)->default_value(100e6), "RF center frequency in Hz")
        ("gain", po::value<double>(&gain), "gain for the RF chain")
        ("ant", po::value<std::string>(&ant), "antenna selection")
        ("bw", po::value<double>(&bw), "analog frontend filter bandwidth in Hz")
        ("ref", po::value<std::string>(&ref), "reference source (internal, external, mimo)")
        ("skip-lo", "skip checking LO lock status")
        ("int-n", "tune USRP with integer-N tuning")


        ("wavegenid", po::value<std::string>(&wavegenid)->default_value("wavegen"), "The block ID for the null source.")
        ("blockid", po::value<std::string>(&blockid)->default_value("FIFO"), "The block ID for the processing block.")
        ("blockid2", po::value<std::string>(&blockid2)->default_value("DmaFIFO"), "Optional: The block ID for the 2nd processing block.")
        ("blockid3", po::value<std::string>(&blockid3)->default_value("FIFO_1"), "Optional: The block ID for the 3rd processing block.")
        ("blockid4", po::value<std::string>(&blockid4)->default_value("FIFO_2"), "Optional: The block ID for the 4th processing block.")
    ;
    po::variables_map vm;
    po::store(po::parse_command_line(argc, argv, desc), vm);
    po::notify(vm);

    //print the help message
    if (vm.count("help")){
        std::cout
            << boost::format("[RFNOC] Connect a Arbitrary Waveform Generator as source source to another (processing) block, and stream the result to file %s.") % desc
            << std::endl;
        return ~0;
    }

    bool bw_summary = vm.count("progress") > 0;
    bool stats = vm.count("stats") > 0;
    bool continue_on_bad_packet = vm.count("continue") > 0;
    if (vm.count("null") > 0) {
        file = "";
    }

    bool enable_size_map = vm.count("sizemap") > 0;
    bool continue_on_bad_packet = vm.count("continue") > 0;

    if (enable_size_map) {
        std::cout << "Packet size tracking enabled - will only recv one packet at a time!" << std::endl;
    }

    if (format != "sc16" and format != "fc32" and format != "fc64") {
        std::cout << "Invalid sample format: " << format << std::endl;
        return EXIT_FAILURE;
    }

    // Check settings
    if (not uhd::rfnoc::block_id_t::is_valid_block_id(wavegenid)) {
        std::cout << "Must specify a valid block ID for the null source." << std::endl;
        return ~0;
    }
    if (not uhd::rfnoc::block_id_t::is_valid_block_id(blockid)) {
        std::cout << "Must specify a valid block ID for the processing block." << std::endl;
        return ~0;
    }
    if (not blockid2.empty()) {
        if (not uhd::rfnoc::block_id_t::is_valid_block_id(blockid2)) {
            std::cout << "Invalid block ID for the 2nd processing block." << std::endl;
            return ~0;
        }
    }
    if (not blockid3.empty()) {
        if (not uhd::rfnoc::block_id_t::is_valid_block_id(blockid3)) {
            std::cout << "Invalid block ID for the 3rd processing block." << std::endl;
            return ~0;
        }
    }
    if (not blockid4.empty()) {
        if (not uhd::rfnoc::block_id_t::is_valid_block_id(blockid4)) {
            std::cout << "Invalid block ID for the 4th processing block." << std::endl;
            return ~0;
        }
    }

    // Set up SIGINT handler. For indefinite streaming, display info on how to stop.
    std::signal(SIGINT, &sig_int_handler);
    if (total_num_samps == 0) {
        std::cout << "Press Ctrl + C to stop streaming..." << std::endl;
    }

    /////////////////////////////////////////////////////////////////////////
    //////// 1. Setup a USRP device /////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    std::cout << std::endl;
    std::cout << boost::format("Creating the USRP device with: %s...") % args << std::endl;
    uhd::device3::sptr usrp = uhd::device3::make(args);
    // Create handle for radio object
    uhd::rfnoc::block_id_t radio_ctrl_id(0, "Radio", radio_id);
    // This next line will fail if the radio is not actually available
    uhd::rfnoc::radio_ctrl::sptr radio_ctrl = usrp->get_block_ctrl< uhd::rfnoc::radio_ctrl >(radio_ctrl_id);
    std::cout << "Using radio " << radio_id << ", channel " << radio_chan << std::endl;

    /************************************************************************
     * Set up radio
     ***********************************************************************/
    radio_ctrl->set_args(radio_args);
    if (vm.count("ref")) {
        std::cout << "TODO -- Need to implement API call to set clock source." << std::endl;
        //Lock mboard clocks TODO
        //usrp->set_clock_source(ref);
    }

    //set the sample rate
    if (rate <= 0.0){
        std::cerr << "Please specify a valid sample rate" << std::endl;
        return EXIT_FAILURE;
    }
    std::cout << boost::format("Setting RX Rate: %f Msps...") % (rate/1e6) << std::endl;
    radio_ctrl->set_rate(rate);
    std::cout << boost::format("Actual RX Rate: %f Msps...") % (radio_ctrl->get_rate()/1e6) << std::endl << std::endl;

    //set the center frequency
    if (vm.count("freq")) {
        std::cout << boost::format("Setting RX Freq: %f MHz...") % (freq/1e6) << std::endl;
        uhd::tune_request_t tune_request(freq);
        if (vm.count("int-n")) {
            //tune_request.args = uhd::device_addr_t("mode_n=integer"); TODO
        }
        radio_ctrl->set_rx_frequency(freq, radio_chan);
        std::cout << boost::format("Actual RX Freq: %f MHz...") % (radio_ctrl->get_rx_frequency(radio_chan)/1e6) << std::endl << std::endl;
    }

    //set the rf gain
    if (vm.count("gain")) {
        std::cout << boost::format("Setting RX Gain: %f dB...") % gain << std::endl;
        radio_ctrl->set_rx_gain(gain, radio_chan);
        std::cout << boost::format("Actual RX Gain: %f dB...") % radio_ctrl->get_rx_gain(radio_chan) << std::endl << std::endl;
    }

    //set the IF filter bandwidth
    if (vm.count("bw")) {
        //std::cout << boost::format("Setting RX Bandwidth: %f MHz...") % (bw/1e6) << std::endl;
        //radio_ctrl->set_rx_bandwidth(bw, radio_chan); // TODO
        //std::cout << boost::format("Actual RX Bandwidth: %f MHz...") % (radio_ctrl->get_rx_bandwidth(radio_chan)/1e6) << std::endl << std::endl;
    }

    //set the antenna
    if (vm.count("ant")) {
        radio_ctrl->set_rx_antenna(ant, radio_chan);
    }

    boost::this_thread::sleep(boost::posix_time::seconds(setup_time)); //allow for some setup time

    //check Ref and LO Lock detect
    if (not vm.count("skip-lo")){
        // TODO
        //check_locked_sensor(usrp->get_rx_sensor_names(0), "lo_locked", boost::bind(&uhd::usrp::multi_usrp::get_rx_sensor, usrp, _1, radio_id), setup_time);
        //if (ref == "external")
            //check_locked_sensor(usrp->get_mboard_sensor_names(0), "ref_locked", boost::bind(&uhd::usrp::multi_usrp::get_mboard_sensor, usrp, _1, radio_id), setup_time);
    }
    size_t spp = radio_ctrl->get_arg<int>("spp");

    /************************************************************************
     * Set up streaming
     ***********************************************************************/
    uhd::device_addr_t streamer_args(streamargs);


    // Reset device streaming state
    usrp->clear();
    uhd::rfnoc::graph::sptr rx_graph = usrp->create_graph("wavegen_graph");

    /////////////////////////////////////////////////////////////////////////
    //////// 2. Get block control objects ///////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    std::vector<std::string> blocks;

    // For the null source control, we want to use the subclassed access,
    // so we create a null_block_ctrl:
    uhd::rfnoc::wavegen_block_ctrl::sptr wavegen_ctrl;
    if (usrp->has_block<uhd::rfnoc::wavegen_block_ctrl>(wavegenid)) {
        wavegen_ctrl = usrp->get_block_ctrl<uhd::rfnoc::wavegen_block_ctrl>(wavegenid);
        blocks.push_back(wavegen_ctrl->get_block_id());
    } else {
        std::cout << "Error: Device has no wavegen block." << std::endl;
        return ~0;
    }

    // For the processing blocks, we don't care what type the block is,
    // so we make it a block_ctrl_base (default):
    uhd::rfnoc::block_ctrl_base::sptr proc_block_ctrl, proc_block_ctrl2, proc_block_ctrl3, proc_block_ctrl4;
    if (usrp->has_block(blockid)) {
        proc_block_ctrl = usrp->get_block_ctrl(blockid);
        blocks.push_back(proc_block_ctrl->get_block_id());
    }
    if (not blockid2.empty() and usrp->has_block(blockid2)) {
        proc_block_ctrl2 = usrp->get_block_ctrl(blockid2);
        blocks.push_back(proc_block_ctrl2->get_block_id());
    }
    if (not blockid3.empty() and usrp->has_block(blockid3)) {
        proc_block_ctrl3 = usrp->get_block_ctrl(blockid3);
        blocks.push_back(proc_block_ctrl3->get_block_id());
    }
    if (not blockid4.empty() and usrp->has_block(blockid4)) {
        proc_block_ctrl4 = usrp->get_block_ctrl(blockid4);
        blocks.push_back(proc_block_ctrl4->get_block_id());
    }

    blocks.push_back("HOST");
    pretty_print_flow_graph(blocks);

    /////////////////////////////////////////////////////////////////////////
    //////// 3. Set channel definitions /////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    uhd::device_addr_t streamer_args(streamargs);
    //
    // Here, we define that there is only 1 channel, and it points
    // to the final processing block.
    if (proc_block_ctrl4 and proc_block_ctrl3 and proc_block_ctrl2) {
        streamer_args["block_id"] = blockid4;
        spp = blk_ctrl->get_args().cast<size_t>("spp", spp);
    }
    else if (proc_block_ctrl3 and proc_block_ctrl2) {
        streamer_args["block_id"] = blockid3;
        spp = blk_ctrl->get_args().cast<size_t>("spp", spp);
    } else if (proc_block_ctrl2) {
        streamer_args["block_id"] = blockid2;
        spp = blk_ctrl->get_args().cast<size_t>("spp", spp);
    } else {
        streamer_args["block_id"] = radio_ctrl_id.to_string();
        streamer_args["block_port"] = str(boost::format("%d") % radio_chan);
    }

    wavegen_ctrl->set_rate(rate);

    std::cout << "Setting AWG Policy to Manual for Setup..."<<std::endl;
    wavegen_ctrl->set_policy_manual();
    std::string policy_str = wavegen_ctrl->get_policy();
    std::cout << "AWG Policy set to: "<<policy_str<<std::endl;

    std::cout << "Setting Src Ctrl"<<std::endl;
    if(awg_source == "awg"){
        wavegen_ctrl->set_src_awg();
    }
    else if (awg_source == "chirp") {
        wavegen_ctrl->set_src_chirp();
    }
    else {
        std::cout<<"Error: Invalid Source Selection: "<<awg_source<<std::endl;
        return ~0;
    }
    std::string src_str = wavegen_ctrl->get_src();
    std::cout << "Src Ctrl set to: "<<src_str<<std::endl;

    std::cout << "Uploading Waveform Samples: "<<std::endl;
    int num_awg_samples = (int)awg_sample_len;
    std::vector<boost::uint32_t> samples;
    for (int i=0;i<num_awg_samples;i++) {
        // samples.push_back(boost::uint32_t(i));
        //samples.push_back(boost::uint32_t(0xFEEDBEEF));
         samples.push_back(boost::uint32_t(0xFEED0000 + boost::uint16_t(i)));
        // samples.push_back(boost::uint32_t(0x1234ABCD));
      //  std::cout<<boost::format("sample %i: %02X\n") % i % samples[i] <<std::endl;
    }
    wavegen_ctrl->set_waveform(samples);
    wavegen_ctrl->set_chirp_counter(boost::uint32_t(num_awg_samples-1));

    std::cout << "Checking Uploaded Waveform Length"<<std::endl;
    boost::uint32_t wfrm_len = wavegen_ctrl->get_waveform_len();
    std::cout << "Uploaded Waveform Length set to: "<<wfrm_len<<std::endl;

    if((int)wfrm_len != num_awg_samples){
        std::cout<<"Error: read incorrect waveform len: "<<wfrm_len<<" Expected: "<<num_awg_samples<<std::endl;
        return ~0;
    }
    int num_pulses = (int)ceil((double)total_num_samps/awg_sample_len);

    boost::uint32_t total_rx_samples = num_awg_samples+32;
    wavegen_ctrl->set_rx_len(total_rx_samples);

    std::cout << "Checking Total RX sample Length"<<std::endl;
    boost::uint32_t total_rx_len = wavegen_ctrl->get_rx_len();
    std::cout << "Total RX Length set to: "<<total_rx_len<<std::endl;

    if(total_rx_len != total_rx_samples){
        std::cout<<"Error: read rx sample len: "<<total_rx_len<<" Expected: "<<total_rx_samples<<std::endl;
        return ~0;
    }

    std::cout << "Setting AWG PRF..."<<std::endl;
    boost::uint64_t prf_count = boost::uint64_t(rate*awg_prf);
    wavegen_ctrl->set_prf_count(prf_count);
    boost::uint64_t prf_read = wavegen_ctrl->get_prf_count();
    std::cout << "AWG PRF set to: "<<prf_read<<"("<< prf_read/rate <<" sec)"<<std::endl;

    if (awg_policy == "auto") {
        std::cout << "Setting AWG Policy to Auto..."<<std::endl;
        wavegen_ctrl->set_policy_auto();
        std::cout << "AWG Policy set to: "<<wavegen_ctrl->get_policy()<<std::endl;
    }

    /////////////////////////////////////////////////////////////////////////
    //////// 5. Connect blocks //////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    std::cout << "Connecting blocks..." << std::endl;
    if (proc_block_ctrl) {
        rx_graph->connect( // Yes, it's that easy!
                wavegen_ctrl->get_block_id(),
                proc_block_ctrl->get_block_id()
        );
        rx_graph->connect( // Yes, it's that easy!
                proc_block_ctrl->get_block_id(),uhd::rfnoc::ANY_PORT, radio_ctrl_id,radio_chan
        );
    }
    else {
        rx_graph->connect( // Yes, it's that easy!
                wavegen_ctrl->get_block_id(),uhd::rfnoc::ANY_PORT,
                radio_ctrl_id,radio_chan
        );
    }
    if (proc_block_ctrl2) {
        rx_graph->connect(
            radio_ctrl_id, radio_chan, proc_block_ctrl2->get_block_id(),uhd::rfnoc::ANY_PORT
        );
    }
    if (proc_block_ctrl3 and proc_block_ctrl2) {
        rx_graph->connect(
            proc_block_ctrl2->get_block_id(),
            proc_block_ctrl3->get_block_id()
        );
    }
    if (proc_block_ctrl4 and proc_block_ctrl3 and proc_block_ctrl2) {
        rx_graph->connect(
            proc_block_ctrl3->get_block_id(),
            proc_block_ctrl4->get_block_id()
        );
    }

    /////////////////////////////////////////////////////////////////////////
    //////// 6. Spawn receiver //////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    UHD_MSG(status) << "Samples per packet: " << spp << std::endl;
    uhd::stream_args_t stream_args(format, "sc16");
    stream_args.args = streamer_args;
    stream_args.args["spp"] = boost::lexical_cast<std::string>(spp);
    UHD_MSG(status) << "Using streamer args: " << stream_args.args.to_string() << std::endl;
    uhd::rx_streamer::sptr rx_stream = usrp->get_rx_stream(stream_args);

    if (total_num_samps == 0) {
        std::signal(SIGINT, &sig_int_handler);
        std::cout << "Press Ctrl + C to stop streaming..." << std::endl;
    }
    /////////////////////////////////////////////////////////////////////////
    //////// 6. Initiate Waveform Pulse //////////////////////////////////////////////
    /////////////////////////////////////////////////////////////////////////
    //wavegen_ctrl->send_pulse();

#define recv_to_file_args() \
        (wavegen_ctrl, rx_stream, file, spb, awg_prf, num_pulses, total_num_samps, total_time, bw_summary, stats, continue_on_bad_packet)
    //recv to file
    if (format == "fc64") recv_to_file<std::complex<double> >recv_to_file_args();
    else if (format == "fc32") recv_to_file<std::complex<float> >recv_to_file_args();
    else if (format == "sc16") recv_to_file<std::complex<short> >recv_to_file_args();
    else throw std::runtime_error("Unknown type sample type: " + format);

    // Finished!
    std::cout << std::endl << "Done!" << std::endl << std::endl;

    return EXIT_SUCCESS;
}
// vim: sw=4 expandtab:
