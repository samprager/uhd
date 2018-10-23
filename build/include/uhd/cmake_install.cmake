# Install script for directory: /Users/prager/Projects/uhd/host/include/uhd

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/build_info.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/config.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/convert.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/deprecated.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/device.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/exception.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/property_tree.ipp"
    "/Users/prager/Projects/uhd/host/include/uhd/property_tree.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/stream.hpp"
    "/Users/prager/Projects/uhd/build/include/uhd/version.hpp"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd" TYPE FILE FILES "/Users/prager/Projects/uhd/host/include/uhd/device3.hpp")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/config.h"
    "/Users/prager/Projects/uhd/host/include/uhd/error.h"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("/Users/prager/Projects/uhd/build/include/uhd/rfnoc/cmake_install.cmake")
  include("/Users/prager/Projects/uhd/build/include/uhd/transport/cmake_install.cmake")
  include("/Users/prager/Projects/uhd/build/include/uhd/types/cmake_install.cmake")
  include("/Users/prager/Projects/uhd/build/include/uhd/cal/cmake_install.cmake")
  include("/Users/prager/Projects/uhd/build/include/uhd/usrp/cmake_install.cmake")
  include("/Users/prager/Projects/uhd/build/include/uhd/usrp_clock/cmake_install.cmake")
  include("/Users/prager/Projects/uhd/build/include/uhd/utils/cmake_install.cmake")

endif()

