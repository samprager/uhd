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
include lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/depend.make

# Include the progress variables for this target.
include lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/progress.make

# Include the compile flags for this target's objects.
include lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/dispatcher.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_1) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/dispatcher.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/dispatcher.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/dispatcher.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/server.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_2) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/server.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/server.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/server.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/client.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_3) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/client.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/client.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/client.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_handler.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_4) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_handler.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_handler.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_handler.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_session.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_5) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_session.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_session.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_session.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_server.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_6) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_server.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_server.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/this_server.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/rpc_error.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_7) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/rpc_error.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/rpc_error.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/rpc_error.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/server_session.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_8) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/server_session.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/server_session.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/server_session.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/response.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_9) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/response.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/response.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/response.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.s

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.o: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/flags.make
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.o: /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/client_error.cc
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green --progress-dir=/Users/prager/Projects/uhd/build/CMakeFiles --progress-num=$(CMAKE_PROGRESS_10) "Building CXX object lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.o"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++  $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -o CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.o -c /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/client_error.cc

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.i: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Preprocessing CXX source to CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.i"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -E /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/client_error.cc > CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.i

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.s: cmake_force
	@$(CMAKE_COMMAND) -E cmake_echo_color --switch=$(COLOR) --green "Compiling CXX source to assembly CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.s"
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && /usr/bin/llvm-g++ $(CXX_DEFINES) $(CXX_INCLUDES) $(CXX_FLAGS) -S /Users/prager/Projects/uhd/host/lib/deps/rpclib/lib/rpc/detail/client_error.cc -o CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.s

uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/dispatcher.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/server.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/client.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_handler.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_session.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/this_server.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/rpc_error.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/server_session.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/response.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/lib/rpc/detail/client_error.cc.o
uhd_rpclib: lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/build.make

.PHONY : uhd_rpclib

# Rule to build all files generated by this target.
lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/build: uhd_rpclib

.PHONY : lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/build

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/clean:
	cd /Users/prager/Projects/uhd/build/lib/deps/rpclib && $(CMAKE_COMMAND) -P CMakeFiles/uhd_rpclib.dir/cmake_clean.cmake
.PHONY : lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/clean

lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/depend:
	cd /Users/prager/Projects/uhd/build && $(CMAKE_COMMAND) -E cmake_depends "Unix Makefiles" /Users/prager/Projects/uhd/host /Users/prager/Projects/uhd/host/lib/deps/rpclib /Users/prager/Projects/uhd/build /Users/prager/Projects/uhd/build/lib/deps/rpclib /Users/prager/Projects/uhd/build/lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/DependInfo.cmake --color=$(COLOR)
.PHONY : lib/deps/rpclib/CMakeFiles/uhd_rpclib.dir/depend

