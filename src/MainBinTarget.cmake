# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

#-------------------------------------------------------------------------------
# Set the current target settings
#-------------------------------------------------------------------------------
macro(load_bin_target_settings) # TODO voir pour utiliser option()
	# Specify a name for the target
	set(PARAM_BIN_TARGET_NAME           "my-main-bin")
	# Specify the type of the main binary build target: "static", "shared", "header" (for header-only library), or "exec". See https://cmake.org/cmake/help/latest/prop_tgt/TYPE.html
	set(PARAM_BIN_TARGET_TYPE           "exec")
	# Specify a semicolon-separated list of preprocessor definitions (e.g., -DFOO;-DBAR or FOO;BAR). Leave empty if none.
	set(PARAM_COMPILE_DEFINITIONS       "test1;test2")
	# Specify whether public header files are separated from private ones
	set(PARAM_PUBLIC_HEADERS_SEPARATED  on)
	# Set the relative path from the `include/` directory to the public headers directory
	set(PARAM_PUBLIC_HEADERS_DIR         "${PROJECT_NAME}")
	# Set the CMakeLists-relative path to the "main" file
	set(PARAM_MAIN_FILE                 "main.cpp")
	# Specify use of a precompiled header file
	set(PARAM_USE_PRECOMPILED_HEADER    on)
	# Set the CMakeLists-relative path to the precompiled header file. Leave it empty if not used
	set(PARAM_PRECOMPILED_FILE          "${PROJECT_NAME}_pch.h")
endmacro()

#-------------------------------------------------------------------------------
# Import and link internal libraries for the current target
#-------------------------------------------------------------------------------
macro(link_internal_dependencies)

endmacro()

#-------------------------------------------------------------------------------
# Import and link external libraries for the current target
#-------------------------------------------------------------------------------
macro(link_external_dependencies)
include(RulesExtDepSpdlog)
endmacro()

#-------------------------------------------------------------------------------
# Internal usage
