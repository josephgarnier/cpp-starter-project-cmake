# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

# Get the system name by running `Windows` or `cmake --system-information` in
# a terminal
set(CMAKE_SYSTEM_NAME "Windows")

# Get the system version by running `cmake --system-information` in a terminal
set(CMAKE_SYSTEM_VERSION "10.0")

# @see https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM.html
set(CMAKE_SYSTEM "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")

# @see https://cmake.org/cmake/help/latest/variable/CMAKE_GENERATOR_PLATFORM.html
set(CMAKE_GENERATOR_PLATFORM "x64")

# Get the compiler target triple by running `cl` in a terminal
set(triple 19)

# Specify the cross-compiler and its target
set(CMAKE_C_COMPILER cl)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER cl)
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

# Include compiler flags for MSVC
include("${CMAKE_CURRENT_LIST_DIR}/compiler/msvc.cmake")