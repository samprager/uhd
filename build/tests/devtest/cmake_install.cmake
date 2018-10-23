# Install script for directory: /Users/prager/Projects/uhd/host/tests/devtest

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

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xtestsx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/lib/uhd/tests/devtest" TYPE PROGRAM FILES
    "/Users/prager/Projects/uhd/host/tests/devtest/benchmark_rate_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/bitbang_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/devtest_b2xx.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/devtest_e320.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/devtest_e3xx.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/devtest_n3x0.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/devtest_x3x0.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/gpio_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/list_sensors_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/multi_usrp_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/python_api_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/run_testsuite.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/rx_samples_to_file_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/test_messages_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/test_pps_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/tx_bursts_test.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/uhd_test_base.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/usrp_probe.py"
    "/Users/prager/Projects/uhd/host/tests/devtest/usrp_probe_test.py"
    )
endif()

