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


#ifndef INCLUDED_LIBUHD_RFNOC_DOPPLER_TRACKER_BLOCK_CTRL_HPP
#define INCLUDED_LIBUHD_RFNOC_DOPPLER_TRACKER_BLOCK_CTRL_HPP

#include <uhd/rfnoc/source_block_ctrl_base.hpp>
#include <uhd/rfnoc/sink_block_ctrl_base.hpp>

namespace uhd {
    namespace rfnoc {

/*! \brief Block controller for the standard copy RFNoC block.
 *
 */
class UHD_RFNOC_API doppler_tracker_block_ctrl : public source_block_ctrl_base, public sink_block_ctrl_base
{
public:
    UHD_RFNOC_BLOCK_OBJECT(doppler_tracker_block_ctrl)

    /*!
     * Your block configuration here
    */
    virtual void set_mavg_len(uint32_t val) = 0;
    virtual void set_zc_threshold(int16_t i_val,int16_t q_val) = 0;
    virtual void set_zc_threshold(uint32_t val) = 0;
    virtual void set_zc_offset(int16_t i_val,int16_t q_val) = 0;
    virtual void set_zc_offset(int32_t val) = 0;
    virtual void run_calibration(uint32_t len) = 0;
    virtual void autocal_enable(bool val) = 0;
    virtual void set_zcsum_len(uint32_t val) = 0;
    virtual void set_rate(double rate) = 0;
    virtual void set_tick_rate(double rate) = 0;
    virtual void set_zc_ref_rate(double rate) = 0;
    virtual void set_ppx(double ppx, double duty = 25) = 0;

    virtual uint32_t get_ppx() = 0;
    virtual uint64_t get_mavg_len() = 0;
    virtual uint64_t get_mavg_div() = 0;
    virtual uint64_t get_cycles_per_sec() = 0;
    virtual void get_cycles_per_sec(int32_t &zcpsI,int32_t &zcpsQ) = 0;
    virtual uint64_t get_zc_count() = 0;
    virtual uint64_t get_zc_count_inst() = 0;
    virtual void get_zc_count(int32_t &zcI,int32_t &zcQ) = 0;
    virtual void get_counts(int32_t &zcI,int32_t &zcQ,int32_t &zcpsI,int32_t &zcpsQ) = 0;
    virtual uint64_t get_zc_thresh_offset() = 0;
    virtual uint32_t get_zc_threshold() = 0;
    virtual uint32_t get_zc_offset() = 0;
    virtual double get_rate() = 0;
    virtual double get_tick_rate() = 0;
    virtual double get_zc_ref_rate() = 0;
    virtual void get_zc_doppler_freq(double &fcI,double &fcQ) = 0;
    virtual void get_zcps_doppler_freq(double &fcpsI,double &fcpsQ) = 0;

}; /* class doppler_tracker_block_ctrl*/

}} /* namespace uhd::rfnoc */

#endif /* INCLUDED_LIBUHD_RFNOC_DOPPLER_TRACKER_BLOCK_CTRL_HPP */
