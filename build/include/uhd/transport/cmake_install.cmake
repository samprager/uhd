# Install script for directory: /Users/prager/Projects/uhd/host/include/uhd/transport

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd/transport" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/transport/bounded_buffer.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/bounded_buffer.ipp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/buffer_pool.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/chdr.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/if_addrs.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/udp_constants.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/udp_simple.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/udp_zero_copy.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/tcp_zero_copy.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/usb_control.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/usb_zero_copy.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/usb_device_handle.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/vrt_if_packet.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/zero_copy.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/transport/zero_copy_flow_ctrl.hpp"
    )
endif()

