# Install script for directory: /Users/prager/Projects/uhd/host/include/uhd/utils

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
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd/utils" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/utils/algorithm.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/assert_has.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/assert_has.ipp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/byteswap.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/byteswap.ipp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/cast.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/csv.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/fp_compare_delta.ipp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/fp_compare_epsilon.ipp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/gain_group.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/log.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/log_add.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/math.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/msg_task.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/paths.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/pimpl.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/platform.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/safe_call.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/safe_main.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/static.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/tasks.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/thread_priority.hpp"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/thread.hpp"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xheadersx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/uhd/utils" TYPE FILE FILES
    "/Users/prager/Projects/uhd/host/include/uhd/utils/thread_priority.h"
    "/Users/prager/Projects/uhd/host/include/uhd/utils/log.h"
    )
endif()

