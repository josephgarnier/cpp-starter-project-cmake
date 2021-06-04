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
# @see https://clang.llvm.org/docs/ClangCommandLineReference.html
# @see https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md

# Diagnostic options.
# @see https://clang.llvm.org/docs/DiagnosticsReference.html
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
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wduplicate-decl-specifier>") # warn if duplicate ‘A’ declaration specifier
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wduplicate-enum>") # warn if element A has been implicitly assigned B which another element has been assigned
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wduplicate-method-arg>") # warn if redeclaration of method parameter A
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wduplicate-method-match>") # warn if multiple declarations of method A found and ignored
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wduplicate-protocol>") # warn if duplicate protocol definition of A is ignored
# add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wlogical-op-parentheses¶>") # warn about logical operations being used where bitwise were probably wanted: ’&&’ within ‘||’ (only from Clang 13)
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wnull-dereference>") # warn if a null dereference is detected
# add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wuseless-cast>") # warn if you perform a cast to the same type (bug with GTest)
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wdouble-promotion>") # warn if float is implicit promoted to double
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wformat=2>") # warn on security issues around functions that format output (ie printf)
#add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-Wlifetime>") # shows object lifetime issues (only special branch of Clang currently)

# Debug information generation options.
# @see https://clang.llvm.org/docs/ClangCommandLineReference.html#debug-information-generation
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-g>") # produces debugging information
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-ggdb3>") # additional debugging info

# Optimization level options.
# @see https://clang.llvm.org/docs/ClangCommandLineReference.html#optimization-level
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-O1>") # optimize

# Target-independent compilation options.
# @see https://clang.llvm.org/docs/ClangCommandLineReference.html#target-independent-compilation-options
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-fdebug-macro>") # emit macro debug information
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-fstandalone-debug>") # emit full debug info for all types used by the program
# add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-stdlib=libc++>") # c++ standard library to use (no more necessary)