// Copyright (c) 2017 - WINLAB, Rutgers University, USA
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

//Team WINLAB
//RFNoC HLS Challenge
/* cir_avg_block_ctrl_impl.cpp - Block controller implementation for cir_avg NoC block
   Used Ettus provided block controllers for reference
*/
#include <uhd/rfnoc/pulse_cir_avg_block_ctrl.hpp>
#include <uhd/convert.hpp>
#include <uhd/utils/msg.hpp>

using namespace uhd::rfnoc;

class pulse_cir_avg_block_ctrl_impl : public pulse_cir_avg_block_ctrl
{
public:

    UHD_RFNOC_BLOCK_CONSTRUCTOR(pulse_cir_avg_block_ctrl)
    {
        set_pulse_cir_avg(0/*threshold*/, 4/*avg_size*/, 4096/*pn seq len*/);
    }

    void set_pulse_cir_avg(const uint32_t threshold, const uint32_t avg_size, const uint32_t seq_len)
    {
        UHD_RFNOC_BLOCK_TRACE() << "pulse_cir_avg::set_pulse_cir_avg()" << std::endl;
        UHD_MSG(status) << "Configuring PulseCir avg. Threshold : " << threshold << "Avg_size : " << avg_size << "Seq_len : " << seq_len << std::endl;

        // if(avg_size > 7) {
        //    throw uhd::value_error(str(boost::format("log2(avg_size) should be <= 7 - Maximum averaging factor is 256")));
        // }
        // if(seq_len > 1023){
        //    throw uhd::value_error(str(boost::format("PN sequence too long!! length should be <= 1023")));
        // }

        sr_write("BLOCK_RESET", 1);
        sr_write("BLOCK_RESET", 0);

        sr_write("THRESHOLD", threshold);

        sr_write("SEQ_LEN", seq_len );
        sr_write("AVG_SIZE", avg_size );
     }

};

UHD_RFNOC_BLOCK_REGISTER(pulse_cir_avg_block_ctrl, "PulseCirAvg");
