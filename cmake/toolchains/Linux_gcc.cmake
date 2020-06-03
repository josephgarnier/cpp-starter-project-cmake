# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

# CMAKE_SYSTEM_NAME - on unix use command "uname -s", for windows write "Windows" OR use command "cmake --system-information"
set(CMAKE_SYSTEM_NAME Linux)
# CMAKE_SYSTEM_VERSION - on unix use command "uname -r", for windows use command "cmake --system-information"
set(CMAKE_SYSTEM_VERSION 4.4.0-21-generic)
# CMAKE_SYSTEM - see https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM.html
set(CMAKE_SYSTEM "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")

#clang++-9 --version on unix
set(triple x86_64-pc-linux-gnu)

# specify the cross compiler
set(CMAKE_C_COMPILER gcc-10)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER g++-10)
set(CMAKE_CXX_COMPILER_TARGET ${triple})

# where is the target environment
list(APPEND CMAKE_FIND_ROOT_PATH "${${PROJECT_NAME}_PROJECT_DIR}")

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)

# compile flags
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-g>")
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-ggdb3>")
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wall>")
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wextra>")
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-O1>")
