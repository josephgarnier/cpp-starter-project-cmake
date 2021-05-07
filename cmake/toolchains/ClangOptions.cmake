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

include(GccOptions.cmake)

# Target-independent compilation options
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-fdebug-macro>") # emit macro debug information
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-fstandalone-debug>") # emit full debug info for all types used by the program
add_compile_options("$<$<STREQUAL:${PARAM_BUILD_TYPE},debug>:-stdlib=libc++>") # c++ standard library to use