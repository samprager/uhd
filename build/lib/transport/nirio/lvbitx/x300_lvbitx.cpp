// Auto-generated file: DO NOT EDIT!
// Generated from a LabVIEW FPGA LVBITX image using "process-lvbitx.py"

#include "x300_lvbitx.hpp"
#include <string>
#include <iostream>
#include <fstream>
#include <streambuf>
#include <boost/filesystem/path.hpp>
#include <boost/algorithm/string.hpp>
#include <boost/regex.hpp>
#include <uhd/utils/paths.hpp>

namespace uhd { namespace niusrprio {

#define SEARCH_PATHS "OFF"

const char* x300_lvbitx::CONTROLS[] = {
    "DiagramReset",
    "ViControl",
    "InterruptEnable",
    "InterruptMask",
    "InterruptStatus",
};

const char* x300_lvbitx::INDICATORS[] = {
    "ViSignature",
};

const char* x300_lvbitx::OUTPUT_FIFOS[] = {
    "TX FIFO 0",
    "TX FIFO 1",
    "TX FIFO 2",
    "TX FIFO 3",
    "TX FIFO 4",
    "TX FIFO 5",
};

const char* x300_lvbitx::INPUT_FIFOS[] = {
    "RX FIFO 0",
    "RX FIFO 1",
    "RX FIFO 2",
    "RX FIFO 3",
    "RX FIFO 4",
    "RX FIFO 5",
};

x300_lvbitx::x300_lvbitx(const std::string& option)
{
    std::string fpga_file = "usrp_x300_fpga_" + option + ".lvbitx";
    boost::filesystem::path fpga_path(uhd::find_image_path(fpga_file, SEARCH_PATHS));

    _fpga_file_name = fpga_path.string();
    _bitstream_checksum = _get_bitstream_checksum(_fpga_file_name);
}

const char* x300_lvbitx::get_bitfile_path() {
    return _fpga_file_name.c_str();
}

const char* x300_lvbitx::get_signature() {
    return "97C6D9F4F4829001B83378F93CAB0C94";
}

const char* x300_lvbitx::get_bitstream_checksum() {
    return _bitstream_checksum.c_str();
}

size_t x300_lvbitx::get_input_fifo_count() {
    return sizeof(INPUT_FIFOS)/sizeof(*INPUT_FIFOS);
}

const char** x300_lvbitx::get_input_fifo_names() {
    return INPUT_FIFOS;
}

size_t x300_lvbitx::get_output_fifo_count() {
    return sizeof(OUTPUT_FIFOS)/sizeof(*OUTPUT_FIFOS);
}

const char** x300_lvbitx::get_output_fifo_names() {
    return OUTPUT_FIFOS;
}

size_t x300_lvbitx::get_control_count() {
    return sizeof(CONTROLS)/sizeof(*CONTROLS);
}

const char** x300_lvbitx::get_control_names() {
    return CONTROLS;
}

size_t x300_lvbitx::get_indicator_count() {
    return sizeof(INDICATORS)/sizeof(*INDICATORS);
}

const char** x300_lvbitx::get_indicator_names() {
    return INDICATORS;
}

void x300_lvbitx::init_register_info(nirio_register_info_vtr& vtr) { 
    vtr.push_back(nirio_register_info_t(0x3fff4, INDICATORS[0], INDICATOR)); //"ViSignature"
    vtr.push_back(nirio_register_info_t(0x3fffc, CONTROLS[0], CONTROL)); //"DiagramReset"
    vtr.push_back(nirio_register_info_t(0x3fff8, CONTROLS[1], CONTROL)); //"ViControl"
    vtr.push_back(nirio_register_info_t(0x3ffe4, CONTROLS[2], CONTROL)); //"InterruptEnable"
    vtr.push_back(nirio_register_info_t(0x3ffec, CONTROLS[3], CONTROL)); //"InterruptMask"
    vtr.push_back(nirio_register_info_t(0x3fff0, CONTROLS[4], CONTROL)); //"InterruptStatus"
}

void x300_lvbitx::init_fifo_info(nirio_fifo_info_vtr& vtr) { 
    vtr.push_back(nirio_fifo_info_t(0, INPUT_FIFOS[0], INPUT_FIFO, 0xff80, 1023, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"RX FIFO 0"
    vtr.push_back(nirio_fifo_info_t(1, INPUT_FIFOS[1], INPUT_FIFO, 0xff40, 1023, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"RX FIFO 1"
    vtr.push_back(nirio_fifo_info_t(2, INPUT_FIFOS[2], INPUT_FIFO, 0xff00, 1023, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"RX FIFO 2"
    vtr.push_back(nirio_fifo_info_t(3, INPUT_FIFOS[3], INPUT_FIFO, 0xfec0, 1023, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"RX FIFO 3"
    vtr.push_back(nirio_fifo_info_t(4, INPUT_FIFOS[4], INPUT_FIFO, 0xfe80, 1023, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"RX FIFO 4"
    vtr.push_back(nirio_fifo_info_t(5, INPUT_FIFOS[5], INPUT_FIFO, 0xfe40, 1023, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"RX FIFO 5"
    vtr.push_back(nirio_fifo_info_t(6, OUTPUT_FIFOS[0], OUTPUT_FIFO, 0xfe00, 1029, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"TX FIFO 0"
    vtr.push_back(nirio_fifo_info_t(7, OUTPUT_FIFOS[1], OUTPUT_FIFO, 0xfdc0, 1029, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"TX FIFO 1"
    vtr.push_back(nirio_fifo_info_t(8, OUTPUT_FIFOS[2], OUTPUT_FIFO, 0xfd80, 1029, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"TX FIFO 2"
    vtr.push_back(nirio_fifo_info_t(9, OUTPUT_FIFOS[3], OUTPUT_FIFO, 0xfd40, 1029, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"TX FIFO 3"
    vtr.push_back(nirio_fifo_info_t(10, OUTPUT_FIFOS[4], OUTPUT_FIFO, 0xfd00, 1029, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"TX FIFO 4"
    vtr.push_back(nirio_fifo_info_t(11, OUTPUT_FIFOS[5], OUTPUT_FIFO, 0xfcc0, 1029, RIO_SCALAR_TYPE_UQ, 64, 64, 2)); //"TX FIFO 5"
}

}}
