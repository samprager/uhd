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
include tests/CMakeFiles/soft_reg_test.dir/depend.make

# Include the progress variables for this target.
include tests/CMakeFiles/soft_reg_test.dir/progress.make

# Include the compile flags for this target's objects.
include tests/CMakeFiles/soft_reg_test.dir/flags.make

tests/CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.o: tests/CMakeFiles/soft_reg_test.dir/flags.make
tests/CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.o: /Users/prager/Projects/uhd/host/tests/soft_reg_test.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object tests/CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.o"
	cd /Users/prager/Projects/uhd/build/tests && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.o -c /Users/prager/Projects/uhd/host/tests/soft_reg_test.cpp

tests/CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.i"
	cd /Users/prager/Projects/uhd/build/tests && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/tests/soft_reg_test.cpp > CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.i

tests/CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.s"
	cd /Users/prager/Projects/uhd/build/tests && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/tests/soft_reg_test.cpp -o CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.s

# Object files for target soft_reg_test
soft_reg_test_OBJECTS = \
"CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.o"

# External object files for target soft_reg_test
soft_reg_test_EXTERNAL_OBJECTS =

tests/soft_reg_test: tests/CMakeFiles/soft_reg_test.dir/soft_reg_test.cpp.o
tests/soft_reg_test: tests/CMakeFiles/soft_reg_test.dir/build.make
tests/soft_reg_test: lib/libuhd.3.14.dylib
tests/soft_reg_test: /usr/local/lib/libboost_chrono-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_date_time-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_filesystem-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_program_options-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_regex-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_system-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_unit_test_framework-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_serialization-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_thread-mt.dylib
tests/soft_reg_test: /usr/local/lib/libboost_atomic-mt.dylib
tests/soft_reg_test: /usr/local/Cellar/libusb/1.0.22/lib/libusb-1.0.dylib
tests/soft_reg_test: tests/CMakeFiles/soft_reg_test.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable soft_reg_test"
	cd /Users/prager/Projects/uhd/build/tests && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/soft_reg_test.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
tests/CMakeFiles/soft_reg_test.dir/build: tests/soft_reg_test

.PHONY : tests/CMakeFiles/soft_reg_test.dir/build

tests/CMakeFiles/soft_reg_test.dir/clean:
	cd /Users/prager/Projects/uhd/build/tests && $(CMAKE_COMMAND) -P CMakeFiles/soft_reg_test.dir/cmake_clean.cmake
.PHONY : tests/CMakeFiles/soft_reg_test.dir/clean

tests/CMakeFiles/soft_reg_test.dir/depend:
	cd /Users/prager/Projects/uhd/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/prager/Projects/uhd/host /Users/prager/Projects/uhd/host/tests /Users/prager/Projects/uhd/build /Users/prager/Projects/uhd/build/tests /Users/prager/Projects/uhd/build/tests/CMakeFiles/soft_reg_test.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : tests/CMakeFiles/soft_reg_test.dir/depend

