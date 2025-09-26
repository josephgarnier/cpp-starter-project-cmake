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
# @see https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category
# @see https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md

# General options.
add_compile_options("/Zm200") # specifies the precompiled header memory allocation limit
add_compile_options("$<$<CONFIG:DEBUG>:/Zi>") # generates complete debugging information
add_compile_options("$<$<CONFIG:DEBUG>:/MP>") # builds multiple source files concurrently
add_compile_options("$<$<CONFIG:DEBUG>:/W4>") # displays level 1, level 2, and level 3 warnings, and all level 4 (informational) warnings that aren't off by default
add_compile_options("$<$<CONFIG:DEBUG>:/w14242>") # 'identfier': conversion from 'type1' to 'type1', possible loss of data
add_compile_options("$<$<CONFIG:DEBUG>:/w14254>") # 'operator': conversion from 'type1:field_bits' to 'type2:field_bits', possible loss of data
add_compile_options("$<$<CONFIG:DEBUG>:/w14263>") # 'function': member function does not override any base class virtual member function
add_compile_options("$<$<CONFIG:DEBUG>:/w14265>") # 'classname': class has virtual functions, but destructor is not virtual instances of this class may not be destructed correctly
add_compile_options("$<$<CONFIG:DEBUG>:/w14287>") # 'operator': unsigned/negative constant mismatch
add_compile_options("$<$<CONFIG:DEBUG>:/we4289>") # nonstandard extension used: 'variable': loop control variable declared in the for-loop is used outside the for-loop scope
add_compile_options("$<$<CONFIG:DEBUG>:/w14296>") # 'operator': expression is always 'boolean_value'
add_compile_options("$<$<CONFIG:DEBUG>:/w14311>") # 'variable': pointer truncation from 'type1' to 'type2'
add_compile_options("$<$<CONFIG:DEBUG>:/w14545>") # expression before comma evaluates to a function which is missing an argument list
add_compile_options("$<$<CONFIG:DEBUG>:/w14546>") # function call before comma missing argument list
add_compile_options("$<$<CONFIG:DEBUG>:/w14547>") # 'operator': operator before comma has no effect; expected operator with side-effect
add_compile_options("$<$<CONFIG:DEBUG>:/w14549>") # 'operator': operator before comma has no effect; did you intend 'operator'?
add_compile_options("$<$<CONFIG:DEBUG>:/w14555>") # expression has no effect; expected expression with side-effect
add_compile_options("$<$<CONFIG:DEBUG>:/w14619>") # pragma warning: there is no warning number 'number'
add_compile_options("$<$<CONFIG:DEBUG>:/w14640>") # enable warning on thread un-safe static member initialization
add_compile_options("$<$<CONFIG:DEBUG>:/w14826>") # conversion from 'type1' to 'type_2' is sign-extended. This may cause unexpected runtime behavior
add_compile_options("$<$<CONFIG:DEBUG>:/w14905>") # wide string literal cast to 'LPSTR'
add_compile_options("$<$<CONFIG:DEBUG>:/w14906>") # string literal cast to 'LPWSTR'
add_compile_options("$<$<CONFIG:DEBUG>:/w14928>") # illegal copy-initialization; more than one user-defined conversion has been implicitly applied

# Code generation options.
# @see https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=msvc-160#code-generation
add_compile_options("$<$<CONFIG:DEBUG>:/EHsc>") # specifies the model of exception handling
add_compile_options("$<$<CONFIG:DEBUG>:/MDd>") # compiles to create a debug multithreaded DLL
add_compile_options("$<$<CONFIG:DEBUG>:/Gy>") # enables function-level linking
add_compile_options("$<$<CONFIG:DEBUG>:/Qpar>") # enables automatic parallelization of loops
add_compile_options("$<$<CONFIG:DEBUG>:/fp:fast>") # specifies floating-point behavior
string(REGEX REPLACE "/RTC(su|[1su])" "" CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG}") # enables run-time error checking

# Optimizations options.
# @see https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category?view=msvc-160#optimization
#add_compile_options("$<$<CONFIG:DEBUG>:/Od>") # disables optimization (disable below options to use it)
#add_compile_options("$<$<CONFIG:DEBUG>:/O2>") # creates fast code (incompatible with /RTC, disable it to use this option)
add_compile_options("$<$<CONFIG:DEBUG>:/Ob2>") # controls inline expansion
add_compile_options("$<$<CONFIG:DEBUG>:/Oi>") # generates intrinsic functions
add_compile_options("$<$<CONFIG:DEBUG>:/Oy>") # omits frame pointer (x86 only)
add_compile_options("$<$<CONFIG:DEBUG>:/GL>") # enables whole program optimization (disable /ZI to use it)


#---- Linker options. ----
# @see https://docs.microsoft.com/en-us/cpp/build/reference/linker-options
# @see https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md
add_compile_options("$<$<CONFIG:DEBUG>:/INCREMENTAL>") # enables incremental linking
add_compile_options("$<$<CONFIG:DEBUG>:/DEBUG>") # generate program database file
# add_compile_options("$<$<CONFIG:DEBUG>:/OPT:REF>") # eliminates functions and/or data that's never referenced (disable /ZI to use it)
# add_compile_options("$<$<CONFIG:DEBUG>:/OPT:NOICF>") # perform identical COMDAT folding (disable /ZI to use it)
# add_compile_options("$<$<CONFIG:DEBUG>:/LTCG:incremental>") # specifies link-time code generation (disable /ZI to use it)