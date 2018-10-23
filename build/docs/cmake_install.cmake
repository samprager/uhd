# Install script for directory: /Users/prager/Projects/uhd/host/docs

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

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdoxygenx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/doc/uhd" TYPE DIRECTORY FILES "/Users/prager/Projects/uhd/build/docs/doxygen")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/octoclock_firmware_burner.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/uhd_cal_rx_iq_balance.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/uhd_cal_tx_dc_offset.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/uhd_cal_tx_iq_balance.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/uhd_config_info.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/uhd_find_devices.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/uhd_image_loader.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/uhd_images_downloader.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/uhd_usrp_probe.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/usrp_n2xx_simple_net_burner.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/usrp_x3xx_fpga_burner.1.gz")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xmanpagesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/share/man/man1" TYPE FILE FILES "/Users/prager/Projects/uhd/build/docs/usrp2_card_burner.1.gz")
endif()

