# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

# CMAKE_SYSTEM_NAME - on unix use command `uname -s`, for windows write `Windows` OR use command `cmake --system-information`.
set(CMAKE_SYSTEM_NAME "Windows")
# CMAKE_SYSTEM_VERSION - on unix use command `uname -r`, for windows use command `cmake --system-information`.
set(CMAKE_SYSTEM_VERSION "10.0")
# CMAKE_SYSTEM - see https://cmake.org/cmake/help/latest/variable/CMAKE_SYSTEM.html.
set(CMAKE_SYSTEM "${CMAKE_SYSTEM_NAME}-${CMAKE_SYSTEM_VERSION}")
# CMAKE_GENERATOR_PLATFORM - see https://cmake.org/cmake/help/latest/variable/CMAKE_GENERATOR_PLATFORM.html.
set(CMAKE_GENERATOR_PLATFORM "x64")

# Write "cl" in a terminal.
set(triple 19)

# Specify the cross compiler.
set(CMAKE_C_COMPILER cl)
set(CMAKE_C_COMPILER_TARGET ${triple})
set(CMAKE_CXX_COMPILER cl)
set(CMAKE_CXX_COMPILER_TARGET ${triple})

# Where is the target environment.
list(APPEND CMAKE_FIND_ROOT_PATH "${${PROJECT_NAME}_PROJECT_DIR}")

# Search for programs in the build host directories.
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
# For libraries and headers in the target directories.
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)

# Settings of directories organisation.
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "CMakeTargets")
set(CMAKE_FOLDER "")

#------------------------------------------------------------------------------
# Compile flags. See https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=vs-2019 and https://docs.microsoft.com/en-us/cpp/build/reference/linker-options?view=vs-2019.
#------------------------------------------------------------------------------
# General section.
add_compile_options("/Zm200") # Specifies the precompiled header memory allocation limit.
add_compile_options("$<$<CONFIG:DEBUG>:/Zi>") # Generates complete debugging information.
add_compile_options("$<$<CONFIG:DEBUG>:/MP>") # Builds multiple source files concurrently.

# Code generation section. See https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=vs-2019#code-generation.
add_compile_options("$<$<CONFIG:DEBUG>:/EHsc>") # Specifies the model of exception handling.
add_compile_options("$<$<CONFIG:DEBUG>:/MDd>") # Compiles to create a debug multithreaded DLL.
add_compile_options("$<$<CONFIG:DEBUG>:/Gy>") # Enables function-level linking.
add_compile_options("$<$<CONFIG:DEBUG>:/Qpar>") # Enables automatic parallelization of loops.
add_compile_options("$<$<CONFIG:DEBUG>:/fp:fast>") # Specifies floating-point behavior.
STRING(REGEX REPLACE "/RTC(su|[1su])" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}")

# Optimizations section: disable optimizations. Comment all "enable optimizations" section flags to use it. See https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=vs-2019#optimization.
add_compile_options("$<$<CONFIG:DEBUG>:/Od>") # Disables optimization.

# Optimizations section: enable optimizations. Comment all "disable optimizations" section flags to use it. See https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=vs-2019#optimization.
add_compile_options("$<$<CONFIG:DEBUG>:/O2>") # Creates fast code.
add_compile_options("$<$<CONFIG:DEBUG>:/Ob2>") # Controls inline expansion.
add_compile_options("$<$<CONFIG:DEBUG>:/Oi>") # Generates intrinsic functions.
add_compile_options("$<$<CONFIG:DEBUG>:/Oy>") # Omits frame pointer (x86 only).
#add_compile_options("$<$<CONFIG:DEBUG>:/GL>") # Enables whole program optimization (disable /ZI to use it).

# Linker section. See https://docs.microsoft.com/en-us/cpp/build/reference/linker-options?view=vs-2019.
add_link_options("$<$<CONFIG:DEBUG>:/INCREMENTAL>") # Enables incremental linking.
add_link_options("$<$<CONFIG:DEBUG>:/DEBUG>") # Generate program database file.
#add_link_options("$<$<CONFIG:DEBUG>:/OPT:REF>") # Eliminates functions and/or data that's never referenced (disable /ZI to use it).
#add_link_options("$<$<CONFIG:DEBUG>:/OPT:NOICF>") # Perform identical COMDAT folding (disable /ZI to use it).
#add_link_options("$<$<CONFIG:DEBUG>:/LTCG:incremental>") # Specifies link-time code generation (disable /ZI to use it).