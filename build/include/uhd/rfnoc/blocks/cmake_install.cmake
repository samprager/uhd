# Install script for directory: /Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/uhd/rfnoc/blocks" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/addsub.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/block.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/ddc.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/ddc_eiscat.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/ddc_single.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/debug.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/digital_gain.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/dma_fifo.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/dma_fifo_x4.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/duc.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/duc_single.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/fft.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/fifo.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/fir.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/fosphor.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/keep_one_in_n.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/logpwr.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/moving_avg.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/nullblock.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/ofdmeq.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/packetresizer.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/pulse_cir_avg.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/radio_e3xx.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/radio_eiscat.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/radio_magnesium.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/radio_neon.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/radio_x300.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/replay.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/replay_x2.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/replay_x4.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/schmidlcox.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/serialdemod.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/siggen.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/splitstream.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/vector_iir.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/wavegen.xml"
    "/Users/prager/Projects/uhd/host/include/uhd/rfnoc/blocks/window.xml"
    )
endif()

