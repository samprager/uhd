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
include tests/CMakeFiles/expert_test.dir/depend.make

# Include the progress variables for this target.
include tests/CMakeFiles/expert_test.dir/progress.make

# Include the compile flags for this target's objects.
include tests/CMakeFiles/expert_test.dir/flags.make

tests/CMakeFiles/expert_test.dir/expert_test.cpp.o: tests/CMakeFiles/expert_test.dir/flags.make
tests/CMakeFiles/expert_test.dir/expert_test.cpp.o: /Users/prager/Projects/uhd/host/tests/expert_test.cpp
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object tests/CMakeFiles/expert_test.dir/expert_test.cpp.o"
	cd /Users/prager/Projects/uhd/build/tests && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/expert_test.dir/expert_test.cpp.o -c /Users/prager/Projects/uhd/host/tests/expert_test.cpp

tests/CMakeFiles/expert_test.dir/expert_test.cpp.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/expert_test.dir/expert_test.cpp.i"
	cd /Users/prager/Projects/uhd/build/tests && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/tests/expert_test.cpp > CMakeFiles/expert_test.dir/expert_test.cpp.i

tests/CMakeFiles/expert_test.dir/expert_test.cpp.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/expert_test.dir/expert_test.cpp.s"
	cd /Users/prager/Projects/uhd/build/tests && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/tests/expert_test.cpp -o CMakeFiles/expert_test.dir/expert_test.cpp.s

# Object files for target expert_test
expert_test_OBJECTS = \
"CMakeFiles/expert_test.dir/expert_test.cpp.o"

# External object files for target expert_test
expert_test_EXTERNAL_OBJECTS =

tests/expert_test: tests/CMakeFiles/expert_test.dir/expert_test.cpp.o
tests/expert_test: tests/CMakeFiles/expert_test.dir/build.make
tests/expert_test: lib/libuhd.3.14.dylib
tests/expert_test: /usr/local/lib/libboost_chrono-mt.dylib
tests/expert_test: /usr/local/lib/libboost_date_time-mt.dylib
tests/expert_test: /usr/local/lib/libboost_filesystem-mt.dylib
tests/expert_test: /usr/local/lib/libboost_program_options-mt.dylib
tests/expert_test: /usr/local/lib/libboost_regex-mt.dylib
tests/expert_test: /usr/local/lib/libboost_system-mt.dylib
tests/expert_test: /usr/local/lib/libboost_unit_test_framework-mt.dylib
tests/expert_test: /usr/local/lib/libboost_serialization-mt.dylib
tests/expert_test: /usr/local/lib/libboost_thread-mt.dylib
tests/expert_test: /usr/local/lib/libboost_atomic-mt.dylib
tests/expert_test: /usr/local/Cellar/libusb/1.0.22/lib/libusb-1.0.dylib
tests/expert_test: tests/CMakeFiles/expert_test.dir/link.txt
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --bold --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Linking CXX executable expert_test"
	cd /Users/prager/Projects/uhd/build/tests && $(CMAKE_COMMAND) -E cmake_link_script CMakeFiles/expert_test.dir/link.txt --verbose=$(VERBOSE)

# Rule to build all files generated by this target.
tests/CMakeFiles/expert_test.dir/build: tests/expert_test

.PHONY : tests/CMakeFiles/expert_test.dir/build

tests/CMakeFiles/expert_test.dir/clean:
	cd /Users/prager/Projects/uhd/build/tests && $(CMAKE_COMMAND) -P CMakeFiles/expert_test.dir/cmake_clean.cmake
.PHONY : tests/CMakeFiles/expert_test.dir/clean

tests/CMakeFiles/expert_test.dir/depend:
	cd /Users/prager/Projects/uhd/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/prager/Projects/uhd/host /Users/prager/Projects/uhd/host/tests /Users/prager/Projects/uhd/build /Users/prager/Projects/uhd/build/tests /Users/prager/Projects/uhd/build/tests/CMakeFiles/expert_test.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : tests/CMakeFiles/expert_test.dir/depend

