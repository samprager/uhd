#!/bin/sh
export PATH=/Users/prager/Projects/uhd/build/tests:$PATH
export DYLD_LIBRARY_PATH=/Users/prager/Projects/uhd/build/lib:/Users/prager/Projects/uhd/build/tests:/usr/local/lib:$DYLD_LIBRARY_PATH
export UHD_RFNOC_DIR=/Users/prager/Projects/uhd/host/include/uhd/rfnoc
eeprom_c_test 
