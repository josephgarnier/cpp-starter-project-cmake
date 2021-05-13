# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.


#---- Compiler options. ----
# @see https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html
# @see https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md

# Warning options.
# @see https://gcc.gnu.org/onlinedocs/gcc/Warning-Options.html
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wall>") # enables all the warnings about constructions
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wextra>") # enables some extra warning flags
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wshadow>") # warn the user if a variable declaration shadows one from a parent context
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wnon-virtual-dtor>") # warn the user if a class with virtual functions has a non-virtual destructor. This helps catch hard to track down memory errors
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wold-style-cast>") # warn for c-style casts
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wcast-align>") # warn for potential performance problem casts
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wunused>") # warn on anything being unused
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Woverloaded-virtual>") # warn if you overload (not override) a virtual function
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wpedantic>") # warn if non-standard C++ is used
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wconversion>") # warn on type conversions that may lose data
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wsign-conversion>") # warn on sign conversions
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wmisleading-indentation>") # warn if indentation implies blocks where blocks do not exist
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wduplicated-cond>") # warn if if / else chain has duplicated conditions
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wduplicated-branches>") # warn if if / else branches have duplicated code
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wlogical-op>") # warn about logical operations being used where bitwise were probably wanted
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wnull-dereference>") # warn if a null dereference is detected
# add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wuseless-cast>") # warn if you perform a cast to the same type (bug with GTest)
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wdouble-promotion>") # warn if float is implicit promoted to double
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wformat=2>") # warn on security issues around functions that format output (ie printf)

# Debugging options.
# @see https://gcc.gnu.org/onlinedocs/gcc/Debugging-Options.html
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-g>") # produces debugging information
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-ggdb3>") # additional debugging info

# Optimization options.
# @see https://gcc.gnu.org/onlinedocs/gcc/Optimize-Options.html
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-O1>") # optimize