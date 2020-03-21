# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

# CMAKE_SYSTEM_NAME - on unix use command "uname -s", for windows write "Windows" OR use command "cmake --system-information"
set(CMAKE_SYSTEM_NAME Windows)
# CMAKE_SYSTEM_VERSION - on unix use command "uname -r", for windows use command "cmake --system-information"
set(CMAKE_SYSTEM_VERSION 10.0)
# CMAKE_SYSTEM - see https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM.html
set(CMAKE_SYSTEM "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")

#cl command on windows
set(triple 19)

# specify the cross compiler
set(CMAKE_C_COMPILER cl)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER cl)
set(CMAKE_CXX_COMPILER_TARGET ${triple})

# where is the target environment
list(APPEND CMAKE_FIND_ROOT_PATH "${${PROJECT_NAME}_PROJECT_DIR}")

# search for programs in the build host directories
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
# for libraries and headers in the target directories
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

# settings of directories organisation
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMakeTargets")
set(CMAKE_FOLDER "")

# compile flags: general
add_compile_options("/Zm200")
add_compile_options("$<$<CONFIG:DEBUG>:/Zi>")
add_compile_options("$<$<CONFIG:DEBUG>:/MP>")

# compile flags: code generation
add_compile_options("$<$<CONFIG:DEBUG>:/EHsc>")
add_compile_options("$<$<CONFIG:DEBUG>:/MDd>")
add_compile_options("$<$<CONFIG:DEBUG>:/Gy>")
add_compile_options("$<$<CONFIG:DEBUG>:/Qpar>")
add_compile_options("$<$<CONFIG:DEBUG>:/fp:fast>")
STRING(REGEX REPLACE "/RTC(su|[1su])" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")

# compile flags: disable optimizations. Comment "enable optimizations" flags to use it
add_compile_options("$<$<CONFIG:DEBUG>:/Od>")

# compile flags: enable optimizations. Comment "disable optimizations" flags to use it
add_compile_options("$<$<CONFIG:DEBUG>:/O2>")
add_compile_options("$<$<CONFIG:DEBUG>:/Ob2>")
add_compile_options("$<$<CONFIG:DEBUG>:/Oi>")
add_compile_options("$<$<CONFIG:DEBUG>:/Oy>")
#add_compile_options("$<$<CONFIG:DEBUG>:/GL>") # disable /ZI to use it

# compile flags: linker
add_link_options("$<$<CONFIG:DEBUG>:/INCREMENTAL>")
add_link_options("$<$<CONFIG:DEBUG>:/DEBUG>")
#add_link_options("$<$<CONFIG:DEBUG>:/OPT:REF>") # disable /ZI to use it
#add_link_options("$<$<CONFIG:DEBUG>:/OPT:NOICF>") # disable /ZI to use it
#add_link_options("$<$<CONFIG:DEBUG>:/LTCG:incremental>") # disable /ZI to use it
