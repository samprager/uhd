/* -*- c++ -*- */
/*
 * Copyright 2016 <+YOU OR YOUR COMPANY+>.
 *
 * This is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this software; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */


#include <uhd/rfnoc/wavegen_block_ctrl.hpp>
#include <uhd/convert.hpp>
#include <uhd/utils/log.hpp>
#include <uhd/types/ranges.hpp>
#include <uhd/types/direction.hpp>
#include <uhd/types/stream_cmd.hpp>
#include <boost/lexical_cast.hpp>
#include <boost/bind.hpp>
// #include <boost/random.hpp>
// #include <boost/random/random_device.hpp>
#include <random>
#include <math.h>

using namespace uhd;
using namespace uhd::rfnoc;


class wavegen_block_ctrl_impl : public wavegen_block_ctrl
{
public:
    /* Timekeeper */
    static const boost::uint32_t SR_TIME_HI = 128;
    static const boost::uint32_t SR_TIME_LO = 129;
    static const boost::uint32_t SR_TIME_CTRL = 130;

    /*Timekeeper Commands */
    static const boost::uint32_t  CTRL_LATCH_TIME_NOW = (1 << 0);
    static const boost::uint32_t  CTRL_LATCH_TIME_PPS = (1 << 1);
    static const boost::uint32_t  CTRL_LATCH_TIME_SYNC = (1 << 2);

    /* Test Register */
    static const boost::uint32_t SR_TEST = 133;

    /* Wavegen */
    static const boost::uint32_t SR_CH_COUNTER_ADDR = 200;
    static const boost::uint32_t SR_CH_TUNING_COEF_ADDR = 201;
    static const boost::uint32_t SR_CH_FREQ_OFFSET_ADDR = 202;
    static const boost::uint32_t SR_AWG_CTRL_WORD_ADDR = 203;

    static const boost::uint32_t SR_PRF_INT_ADDR = 204;
    static const boost::uint32_t SR_PRF_FRAC_ADDR = 205;
    static const boost::uint32_t SR_ADC_SAMPLE_ADDR = 206;

    static const boost::uint32_t SR_RADAR_CTRL_POLICY = 207;
    static const boost::uint32_t SR_RADAR_CTRL_COMMAND = 208;
    static const boost::uint32_t SR_RADAR_CTRL_TIME_HI = 209;
    static const boost::uint32_t SR_RADAR_CTRL_TIME_LO = 210;
    static const boost::uint32_t SR_RADAR_CTRL_CLEAR_CMDS = 211;
    static const boost::uint32_t SR_AWG_RELOAD = 212;
    static const boost::uint32_t SR_AWG_RELOAD_LAST = 213;
    static const boost::uint32_t SR_RADAR_CTRL_MAXLEN = 214;

    /* Timekeeper readback registers */
    static const boost::uint32_t RB_VITA_TIME              = 0;
    static const boost::uint32_t RB_VITA_LASTPPS         = 1;
    static const boost::uint32_t RB_TEST                 = 2;

    /* Control readback registers */
    static const boost::uint32_t RB_AWG_LEN              = 5;
    static const boost::uint32_t RB_ADC_LEN              = 6;
    static const boost::uint32_t RB_AWG_CTRL             = 7;
    static const boost::uint32_t RB_AWG_PRF              = 8;
    static const boost::uint32_t RB_AWG_POLICY           = 9;
    static const boost::uint32_t RB_AWG_STATE            = 10;

     /* Constant settings values */
    static const boost::uint32_t CTRL_WORD_SEL_CHIRP = 0x00000010;
    static const boost::uint32_t CTRL_WORD_SEL_AWG = 0x00000310;

    /* SR_RADAR_CTRL_POLICY register key */
    // POLICY[0] : auto(0) or manual(1).
    // POLICY[1] : use cmd time(0) or forward cmd time(1)
    // POLICY[2] : do not send rx cmd (0) or send rx cmd1)

    static const boost::uint32_t RADAR_POLICY_AUTO = 0;
    static const boost::uint32_t RADAR_POLICY_MANUAL = (1 << 0);
    static const boost::uint32_t RADAR_POLICY_USE_TIME = 0;
    static const boost::uint32_t RADAR_POLICY_FWD_TIME = (1 << 1);
    static const boost::uint32_t RADAR_POLICY_NO_CMD = 0;
    static const boost::uint32_t RADAR_POLICY_FWD_CMD = (1 << 2);

    /*Waveform Data Upload Header Command Identifier */
    static const boost::uint16_t WAVEFORM_WRITE_CMD = 0x5744;

    static const boost::uint32_t DEFAULT_SPP = 64;

    UHD_RFNOC_BLOCK_CONSTRUCTOR(wavegen_block_ctrl),
        _item_type("sc16") // We only support sc16 in this block
    {
        wfrm_header.cmd = WAVEFORM_WRITE_CMD;
        // Fix so that upload id from previous program run is not repeated -- Causes FPGA to ignore waveform upload
        // boost::random_device rdev;
        // wfrm_header.id = rdev();
        std::random_device rdev;
        std::uniform_int_distribution<boost::uint16_t> rdist(0, 65535);
        boost::uint16_t rnum = (boost::uint16_t) rdist(rdev);
        wfrm_header.id = rnum;
        wfrm_header.ind = 0;
        wfrm_header.len = 0;
        // _tick_rate = 200e6;
        _tick_rate = 214.286e6; //ce_clock rate changed
        _spp = DEFAULT_SPP;
        set_time_now(0.0);
    }
    void register_loopback_self_test()
    {
        UHD_LOGGER_INFO("RFNOC") << "[RFNoC Wavegen] Performing register loopback test... ";
        size_t hash = size_t(time(NULL));
        for (size_t i = 0; i < 100; i++)
        {
            boost::hash_combine(hash, i);
            sr_write(SR_TEST, boost::uint32_t(hash));
            boost::uint32_t result = user_reg_read32(RB_TEST);
            if (result != boost::uint32_t(hash)) {
                UHD_LOGGER_INFO("RFNOC") << "fail";
                UHD_LOGGER_INFO("RFNOC") << boost::format("expected: %x result: %x") % boost::uint32_t(hash) % result;
                return; // exit on any failure
            }
        }
        UHD_LOGGER_INFO("RFNOC") << "pass" << std::endl;
    }

    void set_waveform(const std::vector<boost::uint32_t> &samples)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_waveform()" << std::endl;
        wfrm_header.cmd = WAVEFORM_WRITE_CMD;
        wfrm_header.ind = 0;
        wfrm_header.len = boost::uint16_t(samples.size());

        sr_write(SR_AWG_RELOAD, *((boost::uint32_t *)&wfrm_header+1));
        sr_write(SR_AWG_RELOAD, *((boost::uint32_t *)&wfrm_header));

        for (size_t i = 0; i < samples.size() - 1; i++) {
            sr_write(SR_AWG_RELOAD, samples[i]);
        }
        sr_write(SR_AWG_RELOAD_LAST, boost::uint32_t(samples.back()));

        /* Each waveform upload must have unique ID */
        wfrm_header.id ++;
    }


    void set_waveform(const std::vector<boost::uint32_t> &samples, int spp)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_waveform()" << std::endl;
        wfrm_header.cmd = WAVEFORM_WRITE_CMD;
        wfrm_header.ind = 0;
        wfrm_header.len = boost::uint16_t(samples.size());

        int round_pkts = (int)floor((double)samples.size() / spp);
        int partial_spp = (int)samples.size() % spp;

        for(int j=0; j<round_pkts;j++){
            sr_write(SR_AWG_RELOAD, *((boost::uint32_t *)&wfrm_header+1));
            sr_write(SR_AWG_RELOAD, *((boost::uint32_t *)&wfrm_header));
            for (int i = 0; i < spp - 1; i++) {
                sr_write(SR_AWG_RELOAD, samples[j*spp+i]);
            }
            sr_write(SR_AWG_RELOAD_LAST, samples[j*spp+spp-1]);
            wfrm_header.ind ++;
        }
        if(partial_spp > 0){
            sr_write(SR_AWG_RELOAD, *((boost::uint32_t *)&wfrm_header+1));
            sr_write(SR_AWG_RELOAD, *((boost::uint32_t *)&wfrm_header));
            for (int i = 0; i < partial_spp - 1; i++) {
                sr_write(SR_AWG_RELOAD, samples[round_pkts*spp+i]);
            }
            sr_write(SR_AWG_RELOAD_LAST, samples.back());
        }
        /* Each waveform upload must have unique ID */
        wfrm_header.id ++;
    }
    void issue_stream_cmd(const uhd::stream_cmd_t &stream_cmd, const size_t)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block_ctrl::issue_stream_cmd(). stream_mode:" << char(stream_cmd.stream_mode) << std::endl;

        //setup the mode to instruction flags
        typedef boost::tuple<bool, bool, bool, bool> inst_t;
        static const uhd::dict<stream_cmd_t::stream_mode_t, inst_t> mode_to_inst = boost::assign::map_list_of
                                                                //reload, chain, samps, stop
            (stream_cmd_t::STREAM_MODE_START_CONTINUOUS,   inst_t(true,  true,  false, false))
            (stream_cmd_t::STREAM_MODE_STOP_CONTINUOUS,    inst_t(false, false, false, true))
            (stream_cmd_t::STREAM_MODE_NUM_SAMPS_AND_DONE, inst_t(false, false, true,  false))
            (stream_cmd_t::STREAM_MODE_NUM_SAMPS_AND_MORE, inst_t(false, true,  true,  false))
        ;

        //setup the instruction flag values
        bool inst_reload, inst_chain, inst_samps, inst_stop;
        boost::tie(inst_reload, inst_chain, inst_samps, inst_stop) = mode_to_inst[stream_cmd.stream_mode];

        //calculate the word from flags and length
        boost::uint32_t cmd_word = 0;
        cmd_word |= boost::uint32_t((stream_cmd.stream_now)? 1 : 0) << 31;
        cmd_word |= boost::uint32_t((inst_chain)?            1 : 0) << 30;
        cmd_word |= boost::uint32_t((inst_reload)?           1 : 0) << 29;
        cmd_word |= boost::uint32_t((inst_stop)?             1 : 0) << 28;
        cmd_word |= (inst_samps)? stream_cmd.num_samps : ((inst_stop)? 0 : 1);

        //issue the stream command
        const boost::uint64_t ticks = (stream_cmd.stream_now)? 0 : stream_cmd.time_spec.to_ticks(get_rate());
        // sr_write(SR_RADAR_CTRL_COMMAND, cmd_word);
        // sr_write(SR_RADAR_CTRL_TIME_HI, boost::uint32_t(ticks >> 32));
        // sr_write(SR_RADAR_CTRL_TIME_LO, boost::uint32_t(ticks >> 0)); //latches the command

       // send_pulse();
    }

    void set_rate(double rate){
      _tick_rate = rate;
    }

    void send_pulse(){
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::send_pulse()" << std::endl;
        boost::uint32_t cmd_word_imm = 0x80000000;
        /* Start immediately */
        sr_write(SR_RADAR_CTRL_COMMAND, cmd_word_imm);
        /* Write TIME_LO register to initiate */
        sr_write(SR_RADAR_CTRL_TIME_LO, 0);
    }
    void send_pulse(const boost::uint64_t ticks){
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::send_pulse(ticks)" << std::endl;

        // //setup the instruction flag values
        // bool inst_reload, inst_chain, inst_samps, inst_stop;
        // boost::tie(inst_reload, inst_chain, inst_samps, inst_stop) = mode_to_inst[stream_cmd.stream_mode];
        //
        // //calculate the word from flags and length
        // boost::uint32_t cmd_word = 0;
        // cmd_word |= boost::uint32_t((stream_cmd.stream_now)? 1 : 0) << 31;
        // cmd_word |= boost::uint32_t((inst_chain)?            1 : 0) << 30;
        // cmd_word |= boost::uint32_t((inst_reload)?           1 : 0) << 29;
        // cmd_word |= boost::uint32_t((inst_stop)?             1 : 0) << 28;
        // cmd_word |= (inst_samps)? stream_cmd.num_samps : ((inst_stop)? 0 : 1);
        //issue the stream command
        // const boost::uint64_t ticks = (stream_cmd.stream_now)? 0 : stream_cmd.time_spec.to_ticks(get_rate());

        // Send timed command - Let Radar Pulse Controller handle the details
        boost::uint32_t cmd_word = 0;
        //issue the stream command
        sr_write(SR_RADAR_CTRL_COMMAND, cmd_word);
        sr_write(SR_RADAR_CTRL_TIME_HI, boost::uint32_t(ticks >> 32));
        sr_write(SR_RADAR_CTRL_TIME_LO, boost::uint32_t(ticks >> 0)); //latches the command
    }

    void send_pulses(const boost::uint64_t ticks, boost::uint32_t npulses){
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::send_pulses(ticks,npulses)" << std::endl;

        // //setup the instruction flag values
        // cmd word layout: send_imm, chain, reload, stop, npulses (28 bits)
        boost::uint32_t numlines = (npulses > 0x0FFFFFFF ) ? 0x0FFFFFFF : npulses;
        boost::uint32_t cmd_word = 0;
        cmd_word |= boost::uint32_t(1) << 30; // chain command
        cmd_word |= (numlines & 0x0FFFFFFF);
        //issue the stream command
        // const boost::uint64_t ticks = (stream_cmd.stream_now)? 0 : stream_cmd.time_spec.to_ticks(get_rate());

        //issue the stream command
        sr_write(SR_RADAR_CTRL_COMMAND, cmd_word);
        sr_write(SR_RADAR_CTRL_TIME_HI, boost::uint32_t(ticks >> 32));
        sr_write(SR_RADAR_CTRL_TIME_LO, boost::uint32_t(ticks >> 0)); //latches the command
    }
    void stop_pulses(){
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::stop_pulses()" << std::endl;
        boost::uint32_t cmd_word_imm = 0x90000000;
        /* Start immediately */
        sr_write(SR_RADAR_CTRL_COMMAND, cmd_word_imm);
        /* Write TIME_LO register to initiate */
        sr_write(SR_RADAR_CTRL_TIME_LO, 0);
    }
    void stop_pulses(const boost::uint64_t ticks){
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::stop_pulses(onst boost::uint64_t ticks)" << std::endl;
        boost::uint32_t cmd_word = 0x10000000;
        //issue the stream command
        sr_write(SR_RADAR_CTRL_COMMAND, cmd_word);
        sr_write(SR_RADAR_CTRL_TIME_HI, boost::uint32_t(ticks >> 32));
        sr_write(SR_RADAR_CTRL_TIME_LO, boost::uint32_t(ticks >> 0)); //latches the command
    }
    void set_ctrl_word(boost::uint32_t ctrl_word)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_ctrl_word()" << std::endl;
        sr_write(SR_AWG_CTRL_WORD_ADDR, ctrl_word);
    }

    void set_src_awg()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_ctrl_word()" << std::endl;
        sr_write(SR_AWG_CTRL_WORD_ADDR, CTRL_WORD_SEL_AWG);
    }
    void set_src_chirp()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_ctrl_word()" << std::endl;
        sr_write(SR_AWG_CTRL_WORD_ADDR, CTRL_WORD_SEL_CHIRP);
    }

    void set_policy(boost::uint32_t policy)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_policy()" << std::endl;
        sr_write(SR_RADAR_CTRL_POLICY, policy);
    }

    void set_policy_manual()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_policy_manual()" << std::endl;
        boost::uint32_t curr_policy = get_policy_word();
        curr_policy =  (curr_policy & 0xFFFFFFFE) + RADAR_POLICY_MANUAL;
        sr_write(SR_RADAR_CTRL_POLICY, curr_policy);
    }
    void set_policy_auto()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_policy_auto()" << std::endl;
        boost::uint32_t curr_policy = get_policy_word();
        curr_policy =  (curr_policy & 0xFFFFFFFE) + RADAR_POLICY_AUTO;
        sr_write(SR_RADAR_CTRL_POLICY, curr_policy);
    }
    void set_policy_use_time()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_policy_use_time()" << std::endl;
        boost::uint32_t curr_policy = get_policy_word();
        curr_policy =  (curr_policy & 0xFFFFFFFD) + RADAR_POLICY_USE_TIME;
        sr_write(SR_RADAR_CTRL_POLICY, curr_policy);
    }
    void set_policy_fwd_time()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_policy_fwd_time()" << std::endl;
        boost::uint32_t curr_policy = get_policy_word();
        curr_policy =  (curr_policy & 0xFFFFFFFD) + RADAR_POLICY_FWD_TIME;
        sr_write(SR_RADAR_CTRL_POLICY, curr_policy);
    }
    void set_policy_no_cmd()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_policy_no_cmd()" << std::endl;
        boost::uint32_t curr_policy = get_policy_word();
        curr_policy =  (curr_policy & 0xFFFFFFFB) + RADAR_POLICY_NO_CMD;
        sr_write(SR_RADAR_CTRL_POLICY, curr_policy);
    }
    void set_policy_fwd_cmd()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_policy_fwd_cmd()" << std::endl;
        boost::uint32_t curr_policy = get_policy_word();
        curr_policy =  (curr_policy & 0xFFFFFFFB) + RADAR_POLICY_FWD_CMD;
        sr_write(SR_RADAR_CTRL_POLICY, curr_policy);
    }

    void set_num_adc_samples(boost::uint32_t n)
    {
        boost::uint32_t sample_count = n-1;
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_num_adc_samples()" << std::endl;
        sr_write(SR_ADC_SAMPLE_ADDR, sample_count);
    }

    void set_rx_len(boost::uint32_t rx_len)
    {
        boost::uint32_t wfrm_len = get_waveform_len();
        if (rx_len < wfrm_len) {
            throw uhd::value_error(str(
                boost::format("wavegen_block: Requested rx length %d is less than waveform length %d.\n")
                % rx_len % wfrm_len
            ));
        }
        boost::uint32_t sample_count = rx_len-wfrm_len;
        if (sample_count>0) sample_count -= 1;
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_rx_len()" << std::endl;
        sr_write(SR_ADC_SAMPLE_ADDR, sample_count);
    }

    void set_prf_count(boost::uint64_t prf_count)
    {
        boost::uint32_t prf_count_int = boost::uint32_t(prf_count>>32);
        boost::uint32_t prf_count_frac = boost::uint32_t(prf_count);
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_prf_count()" << std::endl;
        sr_write(SR_PRF_INT_ADDR, prf_count_int);
        sr_write(SR_PRF_FRAC_ADDR, prf_count_frac);
    }

    void set_prf_count(boost::uint32_t prf_count_int, boost::uint32_t prf_count_frac)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_prf_count()" << std::endl;
        sr_write(SR_PRF_INT_ADDR, prf_count_int);
        sr_write(SR_PRF_FRAC_ADDR, prf_count_frac);
    }
    void set_chirp_counter(boost::uint32_t chirp_count)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_chirp_counter()" << std::endl;
        sr_write(SR_CH_COUNTER_ADDR, chirp_count);
    }
    void set_chirp_tuning_coef(boost::uint32_t tuning_coef)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_chirp_tuning_coef()" << std::endl;
        sr_write(SR_CH_TUNING_COEF_ADDR, tuning_coef);
    }
    void set_chirp_freq_offset(boost::uint32_t freq_offset)
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::set_chirp_freq_offset()" << std::endl;
        sr_write(SR_CH_FREQ_OFFSET_ADDR, freq_offset);
    }
    void setup_chirp(boost::uint32_t len, boost::uint32_t tuning_coef, boost::uint32_t freq_offset){
        set_chirp_counter(len-1);
        set_chirp_tuning_coef(tuning_coef);
        set_chirp_freq_offset(freq_offset);
    }

    void clear_commands()
    {
        UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::clear_commands()" << std::endl;
        sr_write(SR_RADAR_CTRL_CLEAR_CMDS, 1);
    }

    void set_time_now(const uhd::time_spec_t &time){
        const boost::uint64_t ticks = time.to_ticks(_tick_rate);
        sr_write(SR_TIME_HI, boost::uint32_t(ticks >> 32));
        sr_write(SR_TIME_LO, boost::uint32_t(ticks >> 0));
        sr_write(SR_TIME_CTRL, CTRL_LATCH_TIME_NOW);
    }

    void set_time_sync(const uhd::time_spec_t &time){
        const boost::uint64_t ticks = time.to_ticks(_tick_rate);
        sr_write(SR_TIME_HI, boost::uint32_t(ticks >> 32));
        sr_write(SR_TIME_LO, boost::uint32_t(ticks >> 0));
        sr_write(SR_TIME_CTRL, CTRL_LATCH_TIME_SYNC);
    }

    void set_time_next_pps(const uhd::time_spec_t &time)
    {
        const boost::uint64_t ticks = time.to_ticks(_tick_rate);
        sr_write(SR_TIME_HI, boost::uint32_t(ticks >> 32));
        sr_write(SR_TIME_LO, boost::uint32_t(ticks >> 0));
        sr_write(SR_TIME_CTRL, CTRL_LATCH_TIME_PPS);
    }
    void set_spp(int spp)
    {
        sr_write(SR_RADAR_CTRL_MAXLEN, boost::uint32_t(spp));
        _spp = spp;
    }

    boost::uint32_t get_ctrl_word()
    {
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_ctrl_word()";
        boost::uint32_t ctrl_word = boost::uint32_t(user_reg_read64(RB_AWG_CTRL));
      //  UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_ctrl_word() ctrl_word ==" << ctrl_word;
        UHD_ASSERT_THROW(ctrl_word);
        return ctrl_word;
    }
    std::string get_src()
    {
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_src()" << std::endl;
        boost::uint32_t ctrl_word = boost::uint32_t(user_reg_read64(RB_AWG_CTRL));
      //  UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_ctrl_word() ctrl_word ==" << ctrl_word << std::endl;
        UHD_ASSERT_THROW(ctrl_word);
        std::string src_str;
        boost::uint32_t mask = 0x00000003;
        boost::uint32_t ctrl_src = mask & (ctrl_word>>8);
        if (mask == ctrl_src) {
            src_str = "AWG";
        }
        else if (mask == (!ctrl_src)) {
            src_str = "CHIRP";
        }
        else {
            src_str = "UNKNOWN:" + boost::lexical_cast<std::string>(ctrl_src) + " DEFAULT CHIRP";
        }
        return src_str;
    }
    boost::uint32_t get_policy_word()
    {
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_policy_word()" << std::endl;
        boost::uint32_t policy = boost::uint32_t(user_reg_read64(RB_AWG_POLICY));
      //  UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_policy_word() policy ==" << policy << std::endl;
        //UHD_ASSERT_THROW(policy);
        UHD_ASSERT_THROW(1);
        return policy;
    }
    std::string get_policy()
    {
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_policy()" << std::endl;
        boost::uint32_t policy = boost::uint32_t(user_reg_read64(RB_AWG_POLICY));
      //  UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_policy() policy ==" << policy << std::endl;
        //UHD_ASSERT_THROW(policy);
        std::string policy_str;
        if (policy == RADAR_POLICY_AUTO) {
            policy_str = "AUTO";
            UHD_ASSERT_THROW(1);
        }
        else if (policy == RADAR_POLICY_MANUAL) {
            policy_str = "MANUAL";
            UHD_ASSERT_THROW(1);
        }
        else {
            policy_str = "UNKNOWN:" + boost::lexical_cast<std::string>(policy) + " DEFAULT MANUAL";
        }
        return policy_str;
    }

    boost::uint32_t get_num_adc_samples()
    {
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_num_adc_samples()" << std::endl;
        boost::uint32_t samples = boost::uint32_t(user_reg_read64(RB_ADC_LEN));
    //    UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_num_adc_samples() samples ==" << samples << std::endl;
        UHD_ASSERT_THROW(samples);
        return samples;
    }
    boost::uint32_t get_rx_len()
    {
    //    UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_rx_len()" << std::endl;
        boost::uint32_t adc_samples = get_num_adc_samples();
        boost::uint32_t wfrm_len = get_waveform_len();
        boost::uint32_t rx_len = adc_samples+wfrm_len;
    //    UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_rx_len() rx_len ==" << rx_len << std::endl;
     //   UHD_ASSERT_THROW(rx_len);
        return rx_len;
    }

    boost::uint32_t get_waveform_len()
    {
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_waveform_len()" << std::endl;
        boost::uint32_t len = boost::uint32_t(user_reg_read64(RB_AWG_LEN));
      //  UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_waveform_len() len ==" << len << std::endl;
       // UHD_ASSERT_THROW(len);
        return len;
    }

    boost::uint64_t get_prf_count()
    {
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_prf_count()" << std::endl;
        boost::uint64_t prf_count = boost::uint64_t(user_reg_read64(RB_AWG_PRF));
      //  UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_prf_count() prf_count ==" << prf_count << std::endl;
        UHD_ASSERT_THROW(prf_count);
        return prf_count;
    }
    boost::uint64_t get_state()
    {
    //    UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_state()" << std::endl;
        boost::uint64_t awg_state = boost::uint64_t(user_reg_read64(RB_AWG_STATE));
    //    UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_state() awg_state ==" << awg_state << std::endl;
        UHD_ASSERT_THROW(awg_state);
        return awg_state;
    }

    double get_rate(){
      return _tick_rate;
    }

    boost::uint64_t get_vita_time(){
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_vita_time()" << std::endl;
        boost::uint64_t vita_time = boost::uint64_t(user_reg_read64(RB_VITA_TIME));
    //    UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_vita_time() vita_time ==" << vita_time << std::endl;
        UHD_ASSERT_THROW(vita_time);
        return vita_time;
    }
    uhd::time_spec_t get_time_now(void)
    {
        const boost::uint64_t ticks = user_reg_read64(RB_VITA_TIME);
        return time_spec_t::from_ticks(ticks, _tick_rate);
    }
    uhd::time_spec_t get_time_last_pps(void)
    {
        const boost::uint64_t ticks = user_reg_read64(RB_VITA_LASTPPS);
        return time_spec_t::from_ticks(ticks, _tick_rate);
    }

    int get_spp()
    {
        return _spp;
    }

private:
    const std::string _item_type;
    double _tick_rate;
    int _spp;
    struct waveform_header {
        boost::uint16_t len;
        boost::uint16_t ind;
        boost::uint16_t id;
        boost::uint16_t cmd;
    }wfrm_header;
};

UHD_RFNOC_BLOCK_REGISTER(wavegen_block_ctrl,"wavegen");
