# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

# On unix use command `uname -s`, for windows write `Windows` OR use command `cmake --system-information`
set(CMAKE_SYSTEM_NAME Linux)

# On unix use command `uname -r`, for windows use command `cmake --system-information`
set(CMAKE_SYSTEM_VERSION 4.4.0-21-generic)

# @see https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM.html
set(CMAKE_SYSTEM "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")

# Write `g++ -v` in a terminal.
set(triple x86_64-linux-gnu)

# Specify the cross compiler.
set(CMAKE_C_COMPILER gcc)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER g++)
set(CMAKE_CXX_COMPILER_TARGET ${triple})

# Where is the target environment.
list(APPEND CMAKE_FIND_ROOT_PATH "${CMAKE_SOURCE_DIR}")

# Search for programs in the build host directories.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)

# Search for libraries and headers in the target directories.
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

# Compiler flags.
include("${CMAKE_CURRENT_LIST_DIR}/GccOptions.cmake")