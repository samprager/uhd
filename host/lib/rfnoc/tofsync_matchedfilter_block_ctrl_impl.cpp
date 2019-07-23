//
// Copyright 2014-2018 Ettus Research, a National Instruments Company
//
// SPDX-License-Identifier: GPL-3.0-or-later
//

#include <uhd/convert.hpp>
#include <uhd/rfnoc/tofsync_matchedfilter_block_ctrl.hpp>
#include <uhd/utils/log.hpp>

using namespace uhd::rfnoc;

class tofsync_matchedfilter_block_ctrl_impl : public tofsync_matchedfilter_block_ctrl
{
public:

    static const boost::uint32_t SR_AWG_RELOAD = 170;
    static const boost::uint32_t SR_AWG_RELOAD_LAST = 171;

    /*Waveform Data Upload Header Command Identifier */
    static const boost::uint16_t WAVEFORM_WRITE_CMD = 0x5744;

    UHD_RFNOC_BLOCK_CONSTRUCTOR(tofsync_matchedfilter_block_ctrl),
        _item_type("sc16"), // We only support sc16 in this block
        _bpi(uhd::convert::get_bytes_per_item("sc16"))
    {
        UHD_LOGGER_DEBUG(unique_id());
        wfrm_header.cmd = WAVEFORM_WRITE_CMD;
        std::random_device rdev;
        std::uniform_int_distribution<boost::uint16_t> rdist(0, 65535);
        boost::uint16_t rnum = (boost::uint16_t) rdist(rdev);
        wfrm_header.id = rnum;
        wfrm_header.ind = 0;
        wfrm_header.len = 0;
    }

    //! Set window coefficients and length
    void set_fft_size(int fft_size)
    {
        UHD_LOGGER_TRACE(unique_id()) << "tofsync_matchedfilter::set_fft_size()" << std::endl;
        sr_write(132, fft_size);
    }

    void set_ref_waveform(const std::vector<boost::uint32_t> &samples)
    {
        UHD_RFNOC_BLOCK_TRACE() << "matchedfilter_block::set_ref_waveform()" << std::endl;
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

    void set_ref_waveform(const std::vector<boost::uint32_t> &samples, int spp)
    {
        UHD_RFNOC_BLOCK_TRACE() << "matchedfilter_block::set_ref_waveform()" << std::endl;
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
    boost::uint64_t get_fractional_peak(){
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_vita_time()" << std::endl;
        boost::uint64_t fractional_peak = boost::uint64_t(user_reg_read64(2));
    //    UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_vita_time() vita_time ==" << vita_time << std::endl;
        // UHD_ASSERT_THROW(vita_time);
        return fractional_peak;
    }
    boost::uint64_t get_user_register(boost::uint32_t addr){
      //  UHD_RFNOC_BLOCK_TRACE() << "wavegen_block::get_vita_time()" << std::endl;
        boost::uint64_t regvalue = boost::uint64_t(user_reg_read64(addr));
    //    UHD_LOGGER_INFO("RFNOC") << "wavegen_block::get_vita_time() vita_time ==" << vita_time << std::endl;
        // UHD_ASSERT_THROW(vita_time);
        return regvalue;
    }

private:
    const std::string _item_type;
    const size_t _bpi;
    int _spp;
    struct waveform_header {
        boost::uint16_t len;
        boost::uint16_t ind;
        boost::uint16_t id;
        boost::uint16_t cmd;
    }wfrm_header;
};

UHD_RFNOC_BLOCK_REGISTER(tofsync_matchedfilter_block_ctrl, "TofsyncMatchedFilter");
