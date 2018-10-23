# Install script for directory: /Users/prager/Projects/uhd/host/include/uhd/rfnoc

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "/usr/local")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "FALSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd/rfnoc" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/block_ctrl_base.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blockdef.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/block_id.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/constants.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/graph.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/node_ctrl_base.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/node_ctrl_base.ipp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/rate_node_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/scalar_node_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/sink_block_ctrl_base.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/sink_node_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/source_block_ctrl_base.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/source_node_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/stream_sig.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/terminator_node_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/tick_node_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/ddc_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/dma_fifo_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/duc_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/fir_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/null_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/radio_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/replay_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/siggen_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/window_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/wavegen_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/pulse_cir_avg_block_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/dma_fifo_block_ctrl.hpp"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/prager/Projects/uhd/build/include/uhd/rfnoc/blocks/cmake_install.cmake")

endif()

