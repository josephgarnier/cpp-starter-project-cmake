# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

# Get the system name by running `uname -s` in a terminal
set(CMAKE_SYSTEM_NAME "Linux")

# Get the system version by running `uname -r` in a terminal
set(CMAKE_SYSTEM_VERSION "4.4.0-21-generic")

# @see https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM.html
set(CMAKE_SYSTEM "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")

# Get the compiler target triple by running `g++ -v` in a terminal
set(triple x86_64-linux-gnu)

# Specify the cross-compiler and its target
set(CMAKE_C_COMPILER gcc)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER g++)
set(CMAKE_CXX_COMPILER_TARGET ${triple})

# Add the project root to CMAKE_FIND_ROOT_PATH to locate buildsystem files
# relative to the source directory
list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_SOURCE_DIR}")

# Search for programs in both host and target directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)

# Search for libraries, headers, and packages in both host and target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

# Include compiler flags for GCC
include("${CMAKE_CURRENT_LIST_DIR}/compiler/gcc.cmake")