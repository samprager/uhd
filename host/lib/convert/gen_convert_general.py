#!/usr/bin/env python
#
# Copyright 2011-2012 Ettus Research LLC
# Copyright 2018 Ettus Research, a National Instruments Company
#
# SPDX-License-Identifier: GPL-3.0-or-later
#

TMPL_HEADER = """
<%
    import time
%>
/***********************************************************************
 * This file was generated by ${file} on ${time.strftime("%c")}
 **********************************************************************/

#include "convert_common.hpp"
#include <uhd/utils/byteswap.hpp>

using namespace uhd::convert;


// item32 -> item32: Just a memcpy. No scaling possible.
DECLARE_CONVERTER(item32, 1, item32, 1, PRIORITY_GENERAL) {
    const item32_t *input = reinterpret_cast<const item32_t *>(inputs[0]);
    item32_t *output = reinterpret_cast<item32_t *>(outputs[0]);

    memcpy(output, input, nsamps * sizeof(item32_t));
}
"""

# Some 32-bit types converters are also defined in convert_item32.cpp to
# take care of quirks such as I/Q ordering on the wire etc.
TMPL_CONV_ITEM32 = """
DECLARE_CONVERTER({in_type}, 1, {out_type}, 1, PRIORITY_GENERAL) {{
    const item32_t *input = reinterpret_cast<const item32_t *>(inputs[0]);
    item32_t *output = reinterpret_cast<item32_t *>(outputs[0]);

    for (size_t i = 0; i < nsamps; i++) {{
        output[i] = {to_wire_or_host}(input[i]);
    }}
}}
"""

# 64-bit data types are two consecutive item32 items
TMPL_CONV_ITEM64 = """
DECLARE_CONVERTER({in_type}, 1, {out_type}, 1, PRIORITY_GENERAL) {{
    const item32_t *input = reinterpret_cast<const item32_t *>(inputs[0]);
    item32_t *output = reinterpret_cast<item32_t *>(outputs[0]);

    // An item64 is two item32_t's
    for (size_t i = 0; i < nsamps * 2; i++) {{
        output[i] = {to_wire_or_host}(input[i]);
    }}
}}
"""


TMPL_CONV_U8S8 = """
DECLARE_CONVERTER({us8}, 1, {us8}_item32_{end}, 1, PRIORITY_GENERAL) {{
    const item32_t *input = reinterpret_cast<const item32_t *>(inputs[0]);
    item32_t *output = reinterpret_cast<item32_t *>(outputs[0]);

    // 1) Copy all the 4-byte tuples
    size_t n_words = nsamps / 4;
    for (size_t i = 0; i < n_words; i++) {{
        output[i] = {to_wire}(input[i]);
    }}
    // 2) If nsamps was not a multiple of 4, copy the rest by hand
    size_t bytes_left = nsamps % 4;
    if (bytes_left) {{
        const {us8}_t *last_input_word  = reinterpret_cast<const {us8}_t *>(&input[n_words]);
        {us8}_t *last_output_word = reinterpret_cast<{us8}_t *>(&output[n_words]);
        for (size_t k = 0; k < bytes_left; k++) {{
            last_output_word[k] = last_input_word[k];
        }}
        output[n_words] = {to_wire}(output[n_words]);
    }}
}}

DECLARE_CONVERTER({us8}_item32_{end}, 1, {us8}, 1, PRIORITY_GENERAL) {{
    const item32_t *input = reinterpret_cast<const item32_t *>(inputs[0]);
    item32_t *output = reinterpret_cast<item32_t *>(outputs[0]);

    // 1) Copy all the 4-byte tuples
    size_t n_words = nsamps / 4;
    for (size_t i = 0; i < n_words; i++) {{
        output[i] = {to_host}(input[i]);
    }}
    // 2) If nsamps was not a multiple of 4, copy the rest by hand
    size_t bytes_left = nsamps % 4;
    if (bytes_left) {{
        item32_t last_input_word = {to_host}(input[n_words]);
        const {us8}_t *last_input_word_ptr = reinterpret_cast<const {us8}_t *>(&last_input_word);
        {us8}_t *last_output_word = reinterpret_cast<{us8}_t *>(&output[n_words]);
        for (size_t k = 0; k < bytes_left; k++) {{
            last_output_word[k] = last_input_word_ptr[k];
        }}
    }}
}}
"""

TMPL_CONV_S16 = """
DECLARE_CONVERTER(s16, 1, s16_item32_{end}, 1, PRIORITY_GENERAL) {{
    const uint16_t *input = reinterpret_cast<const uint16_t *>(inputs[0]);
    uint16_t *output = reinterpret_cast<uint16_t *>(outputs[0]);

    for (size_t i = 0; i < nsamps; i++) {{
        output[i] = {to_wire}(input[i]);
    }}
}}

DECLARE_CONVERTER(s16_item32_{end}, 1, s16, 1, PRIORITY_GENERAL) {{
    const uint16_t *input = reinterpret_cast<const uint16_t *>(inputs[0]);
    uint16_t *output = reinterpret_cast<uint16_t *>(outputs[0]);

    for (size_t i = 0; i < nsamps; i++) {{
        output[i] = {to_host}(input[i]);
    }}
}}
"""

TMPL_CONV_USRP1_COMPLEX = """
DECLARE_CONVERTER(${cpu_type}, ${width}, sc16_item16_usrp1, 1, PRIORITY_GENERAL){
    % for w in range(width):
    const ${cpu_type}_t *input${w} = reinterpret_cast<const ${cpu_type}_t *>(inputs[${w}]);
    % endfor
    uint16_t *output = reinterpret_cast<uint16_t *>(outputs[0]);

    for (size_t i = 0, j = 0; i < nsamps; i++){
        % for w in range(width):
        output[j++] = ${to_wire}(uint16_t(int16_t(input${w}[i].real()${do_scale})));
        output[j++] = ${to_wire}(uint16_t(int16_t(input${w}[i].imag()${do_scale})));
        % endfor
    }
}

DECLARE_CONVERTER(sc16_item16_usrp1, 1, ${cpu_type}, ${width}, PRIORITY_GENERAL){
    const uint16_t *input = reinterpret_cast<const uint16_t *>(inputs[0]);
    % for w in range(width):
    ${cpu_type}_t *output${w} = reinterpret_cast<${cpu_type}_t *>(outputs[${w}]);
    % endfor

    for (size_t i = 0, j = 0; i < nsamps; i++){
        % for w in range(width):
        output${w}[i] = ${cpu_type}_t(
            int16_t(${to_host}(input[j+0]))${do_scale},
            int16_t(${to_host}(input[j+1]))${do_scale}
        );
        j += 2;
        % endfor
    }
}

DECLARE_CONVERTER(sc8_item16_usrp1, 1, ${cpu_type}, ${width}, PRIORITY_GENERAL){
    const uint16_t *input = reinterpret_cast<const uint16_t *>(inputs[0]);
    % for w in range(width):
    ${cpu_type}_t *output${w} = reinterpret_cast<${cpu_type}_t *>(outputs[${w}]);
    % endfor

    for (size_t i = 0, j = 0; i < nsamps; i++){
        % for w in range(width):
        {
        const uint16_t num = ${to_host}(input[j++]);
        output${w}[i] = ${cpu_type}_t(
            int8_t(num)${do_scale},
            int8_t(num >> 8)${do_scale}
        );
        }
        % endfor
    }
}
"""

def parse_tmpl(_tmpl_text, **kwargs):
    from mako.template import Template
    return Template(_tmpl_text).render(**kwargs)

if __name__ == '__main__':
    import sys, os
    file = os.path.basename(__file__)
    output = parse_tmpl(TMPL_HEADER, file=file)

    ## Generate all data types that are exactly
    ## item32 or multiples thereof:
    for end in ('be', 'le'):
        host_to_wire = {'be': 'uhd::htonx', 'le': 'uhd::htowx'}[end]
        wire_to_host = {'be': 'uhd::ntohx', 'le': 'uhd::wtohx'}[end]
        # item32 types (sc16->sc16 is a special case because it defaults
        # to Q/I order on the wire:
        for in_type, out_type, to_wire_or_host in (
                ('item32', 'sc16_item32_{end}', host_to_wire),
                ('sc16_item32_{end}', 'item32', wire_to_host),
                ('f32', 'f32_item32_{end}', host_to_wire),
                ('f32_item32_{end}', 'f32', wire_to_host),
        ):
            output += TMPL_CONV_ITEM32.format(
                    end=end, to_wire_or_host=to_wire_or_host,
                    in_type=in_type.format(end=end), out_type=out_type.format(end=end)
            )
        # 2xitem32 types:
        for in_type, out_type in (
                ('fc32', 'fc32_item32_{end}'),
                ('fc32_item32_{end}', 'fc32'),
        ):
            output += TMPL_CONV_ITEM64.format(
                    end=end, to_wire_or_host=to_wire_or_host,
                    in_type=in_type.format(end=end), out_type=out_type.format(end=end)
            )

    ## Real 16-Bit:
    for end, to_host, to_wire in (
        ('be', 'uhd::ntohx', 'uhd::htonx'),
        ('le', 'uhd::wtohx', 'uhd::htowx'),
    ):
        output += TMPL_CONV_S16.format(
            end=end, to_host=to_host, to_wire=to_wire
        )

    ## Real 8-Bit Types:
    for us8 in ('u8', 's8'):
        for end, to_host, to_wire in (
            ('be', 'uhd::ntohx', 'uhd::htonx'),
            ('le', 'uhd::wtohx', 'uhd::htowx'),
        ):
            output += TMPL_CONV_U8S8.format(
                    us8=us8, end=end, to_host=to_host, to_wire=to_wire
            )

    #generate complex converters for usrp1 format (requires Cheetah)
    for width in 1, 2, 4:
        for cpu_type, do_scale in (
            ('fc64', '*scale_factor'),
            ('fc32', '*float(scale_factor)'),
            ('sc16', ''),
        ):
            output += parse_tmpl(
                TMPL_CONV_USRP1_COMPLEX,
                width=width, to_host='uhd::wtohx', to_wire='uhd::htowx',
                cpu_type=cpu_type, do_scale=do_scale
            )
    open(sys.argv[1], 'w').write(output)
