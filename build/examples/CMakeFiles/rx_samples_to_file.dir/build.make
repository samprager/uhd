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
include examples/CMakeFiles/rx_samples_to_file.dir/depend.make

# Include the progress variables for this target.
include examples/CMakeFiles/rx_samples_to_file.dir/progress.make

# Include the compile flags for this target's objects.
include examples/CMakeFiles/rx_samples_to_file.dir/flags.make

examples/CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.o: examples/CMakeFiles/rx_samples_to_file.dir/flags.make
examples/CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.o: /Users/prager/Projects/uhd/host/examples/rx_samples_to_file.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object examples/CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.o"
	cd /Users/prager/Projects/uhd/build/examples && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.o -c /Users/prager/Projects/uhd/host/examples/rx_samples_to_file.cpp

examples/CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.i"
	cd /Users/prager/Projects/uhd/build/examples && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/examples/rx_samples_to_file.cpp > CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.i

examples/CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.s"
	cd /Users/prager/Projects/uhd/build/examples && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/examples/rx_samples_to_file.cpp -o CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.s

# Object files for target rx_samples_to_file
rx_samples_to_file_OBJECTS = \
"CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.o"

# External object files for target rx_samples_to_file
rx_samples_to_file_EXTERNAL_OBJECTS =

examples/rx_samples_to_file: examples/CMakeFiles/rx_samples_to_file.dir/rx_samples_to_file.cpp.o
examples/rx_samples_to_file: examples/CMakeFiles/rx_samples_to_file.dir/build.make
examples/rx_samples_to_file: lib/libuhd.3.14.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_chrono-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_date_time-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_filesystem-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_program_options-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_regex-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_system-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_unit_test_framework-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_serialization-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_thread-mt.dylib
examples/rx_samples_to_file: /usr/local/lib/libboost_atomic-mt.dylib
examples/rx_samples_to_file: /usr/local/Cellar/libusb/1.0.22/lib/libusb-1.0.dylib
examples/rx_samples_to_file: examples/CMakeFiles/rx_samples_to_file.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable rx_samples_to_file"
	cd /Users/prager/Projects/uhd/build/examples && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/rx_samples_to_file.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
examples/CMakeFiles/rx_samples_to_file.dir/build: examples/rx_samples_to_file

.PHONY : examples/CMakeFiles/rx_samples_to_file.dir/build

examples/CMakeFiles/rx_samples_to_file.dir/clean:
	cd /Users/prager/Projects/uhd/build/examples && $(CMAKE_COMMAND) -P CMakeFiles/rx_samples_to_file.dir/cmake_clean.cmake
.PHONY : examples/CMakeFiles/rx_samples_to_file.dir/clean

examples/CMakeFiles/rx_samples_to_file.dir/depend:
	cd /Users/prager/Projects/uhd/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/prager/Projects/uhd/host /Users/prager/Projects/uhd/host/examples /Users/prager/Projects/uhd/build /Users/prager/Projects/uhd/build/examples /Users/prager/Projects/uhd/build/examples/CMakeFiles/rx_samples_to_file.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : examples/CMakeFiles/rx_samples_to_file.dir/depend

