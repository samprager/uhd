# Install script for directory: /Users/prager/Projects/uhd/host/include/uhd/usrp

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd/usrp" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/fe_connection.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/dboard_base.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/dboard_eeprom.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/dboard_id.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/dboard_iface.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/dboard_manager.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/gps_ctrl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/gpio_defs.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/mboard_eeprom.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/subdev_spec.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/multi_usrp.hpp"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd/usrp" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/dboard_eeprom.h"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/mboard_eeprom.h"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/subdev_spec.h"
    "/Users/prager/Projects/uhd/host/include/uhd/usrp/usrp.h"
    )
endif()

