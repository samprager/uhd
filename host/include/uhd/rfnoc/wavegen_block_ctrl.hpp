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


#ifndef INCLUDED_LIBUHD_RFNOC_WAVEGEN_WAVEGEN_HPP
#define INCLUDED_LIBUHD_RFNOC_WAVEGEN_WAVEGEN_HPP

#include <uhd/rfnoc/source_block_ctrl_base.hpp>
#include <uhd/rfnoc/sink_block_ctrl_base.hpp>

namespace uhd {
    namespace rfnoc {

/*! \brief Block controller for the standard copy RFNoC block.
 *
 */
class UHD_RFNOC_API wavegen_block_ctrl : public source_block_ctrl_base, public sink_block_ctrl_base
{
public:
    UHD_RFNOC_BLOCK_OBJECT(wavegen_block_ctrl)

    /*!
     * Your block configuration here
    */
    virtual void register_loopback_self_test() = 0;
    virtual void set_waveform(const std::vector<boost::uint32_t> &samples) = 0;
    virtual void set_waveform(const std::vector<boost::uint32_t> &samples, int spp) = 0;
    virtual void set_rate(double rate) = 0;
    virtual void send_pulse() = 0;
    virtual void send_pulse(const boost::uint64_t ticks) = 0;
    virtual void send_pulses(const boost::uint64_t ticks, boost::uint32_t npulses) = 0;
    virtual void stop_pulses() = 0;
    virtual void stop_pulses(const boost::uint64_t ticks) = 0;
    virtual void set_ctrl_word(boost::uint32_t ctrl_word) = 0;
    virtual void set_src_awg() = 0;
    virtual void set_src_chirp() = 0;
    virtual void set_policy(boost::uint32_t policy) = 0;
    virtual void set_policy_manual() = 0;
    virtual void set_policy_auto() = 0;
    virtual void set_policy_use_time() = 0;
    virtual void set_policy_fwd_time() = 0;
    virtual void set_policy_no_cmd() = 0;
    virtual void set_policy_fwd_cmd() = 0;
    virtual void set_num_adc_samples(boost::uint32_t n) = 0;
    virtual void set_rx_len(boost::uint32_t rx_len) = 0;
    virtual void set_prf_count(boost::uint64_t prf_count) = 0;
    virtual void set_prf_count(boost::uint32_t prf_count_int, boost::uint32_t prf_count_frac) = 0;
    virtual void set_chirp_counter(boost::uint32_t chirp_counter) = 0;
    virtual void set_chirp_tuning_coef(boost::uint32_t tuning_coef) = 0;
    virtual void set_chirp_freq_offset(boost::uint32_t freq_offset) = 0;
    virtual void setup_chirp(boost::uint32_t len, boost::uint32_t tuning_coef, boost::uint32_t freq_offset) = 0;
    virtual void clear_commands() = 0;
    virtual void set_time_now(const uhd::time_spec_t &time) = 0;
    virtual void set_time_sync(const uhd::time_spec_t &time) = 0;
    virtual void set_time_next_pps(const uhd::time_spec_t &time) = 0;
    virtual void set_spp(int spp) = 0;

    virtual std::string get_src() = 0;
    virtual std::string get_policy() = 0;

    virtual boost::uint32_t get_ctrl_word() = 0;
    virtual boost::uint32_t get_policy_word() = 0;
    virtual boost::uint32_t get_num_adc_samples() = 0;
    virtual boost::uint32_t get_rx_len() = 0;
    virtual boost::uint32_t get_waveform_len() = 0;
    virtual boost::uint64_t get_prf_count() = 0;
    virtual boost::uint64_t get_state() = 0;
    virtual boost::uint64_t get_vita_time() = 0;
    virtual double get_rate() = 0;
    virtual uhd::time_spec_t get_time_now(void) = 0;
    virtual uhd::time_spec_t get_time_last_pps(void) = 0;
    virtual int get_spp() = 0;


}; /* class wavegen_block_ctrl*/

}} /* namespace uhd::rfnoc */

#endif /* INCLUDED_LIBUHD_RFNOC_WAVEGEN_WAVEGEN_BLOCK_CTRL_HPP */
