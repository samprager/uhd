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


#include <uhd/rfnoc/doppler_tracker_block_ctrl.hpp>
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


class doppler_tracker_block_ctrl_impl : public doppler_tracker_block_ctrl
{
public:
    static const boost::uint32_t SR_SUM_LEN = 192;
    static const boost::uint32_t SR_DIVISOR = 193;
    static const boost::uint32_t SR_THRESHOLD = 194;
    static const boost::uint32_t SR_OFFSET = 195;
    static const boost::uint32_t SR_CALIBRATE = 196;
    static const boost::uint32_t SR_ZC_SUM_LEN = 197;
    static const boost::uint32_t SR_ZC_REF_RATE = 198;


    /* Timekeeper readback registers */
    static const boost::uint32_t RB_SUM_LEN              = 0;
    static const boost::uint32_t RB_DIVISOR         = 1;
    static const boost::uint32_t RB_CYCLES_PER_SEC  = 2;
    static const boost::uint32_t RB_ZC                 = 3;
    static const boost::uint32_t RB_THRESH_OFFSET      = 4;
    static const boost::uint32_t RB_ZC_INST           = 5;
    static const boost::uint32_t RB_ZC_REF_RATE       = 6;


    static const boost::uint32_t DEFAULT_SPP = 64;

    UHD_RFNOC_BLOCK_CONSTRUCTOR(doppler_tracker_block_ctrl),
        _item_type("sc16") // We only support sc16 in this block
    {
        set_mavg_len(1);
        set_zcsum_len(1);
        set_zc_threshold(100,100);
        set_zc_offset(0,0);
        set_rate(125.0e6); //ce_clock rate changed
        // reference rate used in ZC block for calculating doppler frequency from ZC count (1e9 Hz) by default
    }
    void set_mavg_len(uint32_t val)
    {
      if (val > 255) {
          throw uhd::value_error(str(
              boost::format("dopplertracker_block: Requested moving avg length %d is greater than max allowed %d.\n")
              % val % 255
          ));
      }
      UHD_RFNOC_BLOCK_TRACE() << "dopplertracker_block::set_mavg_len()" << std::endl;
      sr_write(SR_SUM_LEN, val);
      sr_write(SR_DIVISOR, val);
    }
    void set_zc_threshold(int16_t i_val,int16_t q_val)
    {
      uint32_t iq_val = ((0x0000FFFF & i_val) << 16) + (0x0000FFFF & q_val);
      set_zc_threshold(iq_val);
    }
    void set_zc_threshold(uint32_t val)
    {
      sr_write(SR_THRESHOLD, val);
    }
    void set_zc_offset(int16_t i_val,int16_t q_val)
    {
      uint32_t iq_val = ((0x0000FFFF & i_val) << 16) + (0x0000FFFF & q_val);
      set_zc_offset(iq_val);
    }
    void set_zc_offset(int32_t val)
    {
      sr_write(SR_OFFSET, val);
    }
    void run_calibration(uint32_t len)
    {
      sr_write(SR_CALIBRATE, len);
    }
    void set_zcsum_len(uint32_t val)
    {
      if (val > 255) {
          throw uhd::value_error(str(
              boost::format("dopplertracker_block: Requested zc avg length %d is greater than max allowed %d.\n")
              % val % 255
          ));
      }
      UHD_RFNOC_BLOCK_TRACE() << "dopplertracker_block::set_zcsum_len()" << std::endl;
      sr_write(SR_ZC_SUM_LEN, val);
    }
    void set_rate(double rate){
      set_tick_rate(rate);
      set_zc_ref_rate(rate);
    }
    // only set sampling rate of radio
    void set_tick_rate(double rate){
      _tick_rate = rate;
    }
    // only set reference rate used in FPGA block for doppler calculation
    void set_zc_ref_rate(double rate){
      uint32_t rate32 = uint32_t(std::round(std::abs(rate)));
      sr_write(SR_ZC_REF_RATE, rate32);
      _zc_ref_rate = get_zc_ref_rate();
      if (_zc_ref_rate != rate)
        std::cerr<<"dopplertracker_block::set_zc_ref_rate() rate read from block: "<<_zc_ref_rate<<" does not equal requested rate: "<<rate<<std::endl;
    }

    uint64_t get_mavg_len()
    {
      uint64_t val = boost::uint64_t(user_reg_read64(RB_SUM_LEN));
      return val;
    }
    uint64_t get_mavg_div()
    {
      uint64_t val = boost::uint64_t(user_reg_read64(RB_DIVISOR));
      return val;
    }
    uint64_t get_cycles_per_sec()
    {
      uint64_t val = boost::uint64_t(user_reg_read64(RB_CYCLES_PER_SEC));
      return val;
    }

    void get_cycles_per_sec(int32_t &zcpsI,int32_t &zcpsQ){
      uint64_t zcps = get_cycles_per_sec();
      zcpsI = int32_t((0xFFFFFFFF00000000 & zcps)>>32);
      zcpsQ = int32_t((0x00000000FFFFFFFF & zcps));
    }

    uint64_t get_zc_count()
    {
      uint64_t val = boost::uint64_t(user_reg_read64(RB_ZC));
      return val;
    }
    uint64_t get_zc_count_inst()
    {
      uint64_t val = boost::uint64_t(user_reg_read64(RB_ZC_INST));
      return val;
    }
    void get_zc_count(int32_t &zcI,int32_t &zcQ){
      uint64_t zccount = get_zc_count();
      zcI = int32_t((0xFFFFFFFF00000000 & zccount)>>32);
      zcQ = int32_t((0x00000000FFFFFFFF & zccount));
    }
    void get_counts(int32_t &zcI,int32_t &zcQ,int32_t &zcpsI,int32_t &zcpsQ){
      get_zc_count(zcI,zcQ);
      get_cycles_per_sec(zcpsI,zcpsQ);
    }
    uint64_t get_zc_thresh_offset(){
      uint64_t val = boost::uint64_t(user_reg_read64(RB_THRESH_OFFSET));
      return val;
    }
    uint32_t get_zc_threshold()
    {
      uint64_t val = get_zc_thresh_offset();
      uint32_t val32 = uint32_t((0xFFFFFFFF00000000 & val)>>32);
      return val32;

    }
    uint32_t get_zc_offset(){
      uint64_t val = get_zc_thresh_offset();
      uint32_t val32 = uint32_t(0x00000000FFFFFFFF & val);
      return val32;
    }

    double get_rate(){
       return _tick_rate;
    }

    double get_tick_rate(){
       return _tick_rate;
    }
    double get_zc_ref_rate(){
      uint64_t val = boost::uint64_t(user_reg_read64(SR_ZC_REF_RATE));
      return double(val);
    }

    void get_zc_doppler_freq(double &fcI,double &fcQ){
      int32_t zcI,zcQ;
      get_zc_count(zcI,zcQ);
      double zc_ref_rate = (double)_zc_ref_rate;
      fcI = (get_rate()/zc_ref_rate)*.5*((double)zcI); //freq in hz
      fcQ = (get_rate()/zc_ref_rate)*.5*((double)zcQ); //freq in hz
      // fcI = get_rate() / (2.0 *((double) zcI + 1.0));
      // fcQ = get_rate() / (2.0 *((double) zcQ + 1.0));
    }

    void get_zcps_doppler_freq(double &fcpsI,double &fcpsQ){
      int32_t zcpsI,zcpsQ;
      get_cycles_per_sec(zcpsI,zcpsQ);
      fcpsI = (double) zcpsI;
      fcpsQ = (double) zcpsQ;
    }

private:
    const std::string _item_type;
    double _tick_rate;
    uint32_t _zc_ref_rate;
    int _spp;
};

UHD_RFNOC_BLOCK_REGISTER(doppler_tracker_block_ctrl,"DopplerTracker");
