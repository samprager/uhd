# CMAKE generated file: DO NOT EDIT!
# Generated by "Unix Makefiles" Generator, CMake Version 3.11

# Delete rule output on recipe failure.
.DELETE_ON_ERROR:


#=============================================================================
# Special targets provided by cmake.

# Disable implicit rules so canonical targets will work.
.SUFFIXES:


# Remove some rules from gmake that .SUFFIXES does not remove.
SUFFIXES =

.SUFFIXES: .hpux_make_needs_suffix_list


# Suppress display of executed commands.
$(VERBOSE).SILENT:


# A target that is always out of date.
cmake_force:

.PHONY : cmake_force

#=============================================================================
# Set environment variables for the build.

# The shell in which to execute make rules.
SHELL = /bin/sh

# The CMake executable.
CMAKE_COMMAND = /usr/local/Cellar/cmake/3.11.1/bin/cmake

# The command to remove a file.
RM = /usr/local/Cellar/cmake/3.11.1/bin/cmake -E remove -f

# Escaping for special characters.
EQUALS = =

# The top-level source directory on which CMake was run.
CMAKE_SOURCE_DIR = /Users/prager/Projects/uhd/host

# The top-level build directory on which CMake was run.
CMAKE_BINARY_DIR = /Users/prager/Projects/uhd/build

# Include any dependencies generated for this target.
include examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/depend.make

# Include the progress variables for this target.
include examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/progress.make

# Include the compile flags for this target's objects.
include examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/flags.make

examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.o: examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/flags.make
examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.o: /Users/prager/Projects/uhd/host/examples/rfnoc_wavegen_ce_rx.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.o"
	cd /Users/prager/Projects/uhd/build/examples && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.o -c /Users/prager/Projects/uhd/host/examples/rfnoc_wavegen_ce_rx.cpp

examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.i"
	cd /Users/prager/Projects/uhd/build/examples && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/examples/rfnoc_wavegen_ce_rx.cpp > CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.i

examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.s"
	cd /Users/prager/Projects/uhd/build/examples && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/examples/rfnoc_wavegen_ce_rx.cpp -o CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.s

# Object files for target rfnoc_wavegen_ce_rx
rfnoc_wavegen_ce_rx_OBJECTS = \
"CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.o"

# External object files for target rfnoc_wavegen_ce_rx
rfnoc_wavegen_ce_rx_EXTERNAL_OBJECTS =

examples/rfnoc_wavegen_ce_rx: examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/rfnoc_wavegen_ce_rx.cpp.o
examples/rfnoc_wavegen_ce_rx: examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/build.make
examples/rfnoc_wavegen_ce_rx: lib/libuhd.3.14.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_chrono-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_date_time-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_filesystem-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_program_options-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_regex-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_system-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_unit_test_framework-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_serialization-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_thread-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/lib/libboost_atomic-mt.dylib
examples/rfnoc_wavegen_ce_rx: /usr/local/Cellar/libusb/1.0.22/lib/libusb-1.0.dylib
examples/rfnoc_wavegen_ce_rx: examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable rfnoc_wavegen_ce_rx"
	cd /Users/prager/Projects/uhd/build/examples && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/rfnoc_wavegen_ce_rx.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/build: examples/rfnoc_wavegen_ce_rx

.PHONY : examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/build

examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/clean:
	cd /Users/prager/Projects/uhd/build/examples && $(CMAKE_COMMAND) -P CMakeFiles/rfnoc_wavegen_ce_rx.dir/cmake_clean.cmake
.PHONY : examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/clean

examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/depend:
	cd /Users/prager/Projects/uhd/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/prager/Projects/uhd/host /Users/prager/Projects/uhd/host/examples /Users/prager/Projects/uhd/build /Users/prager/Projects/uhd/build/examples /Users/prager/Projects/uhd/build/examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : examples/CMakeFiles/rfnoc_wavegen_ce_rx.dir/depend

