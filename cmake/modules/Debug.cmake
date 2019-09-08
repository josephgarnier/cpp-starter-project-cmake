#! Function for debuging.
#
# Usage:
#
#	dump_variables(
#		EXCLUDE_REGEX [ext1 [ext2 [ext3 ...]]])
#
#
# Arguments:
#
#	\group:EXCLUDE_REGEX: specifies a regular expression that the file names
#	(without path) must be excluded of displaying.
#
#
# Requires these CMake modules:
#
#	None
#
# Requires CMake 3.12 or newer
#
#
# Licence:
#
# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

cmake_minimum_required (VERSION 3.12)

macro(dump_variables)
	set(options "")
	set(oneValueArgs EXCLUDE_REGEX)
	set(multiValueArgs "")
	cmake_parse_arguments(DV "${options}" "${oneValueArgs}" "${multiValueArgs}" ${ARGN})
	if(DV_UNPARSED_ARGUMENTS)
      message(FATAL_ERROR "Unrecognized arguments: \"${DV_UNPARSED_ARGUMENTS}\"")
	endif()

	get_cmake_property(variableNames VARIABLES)
	list (SORT variableNames)
	foreach (variableName ${variableNames})
		if(NOT variableName MATCHES "${DV_EXCLUDE_REGEX}")
			message(STATUS "${variableName}= ${${variableName}}")
		endif()
	endforeach()
endmacro()

get_cmake_property(variableNames VARIABLES)
list (SORT variableNames)
foreach (variableName ${variableNames})
	#if(NOT variableName MATCHES "CMAKE_")
		message(STATUS "${variableName}= ${${variableName}}")
	#endif()
endforeach()

#include(CMakePrintHelpers)
#cmake_print_variables(CMAKE_C_COMPILER CMAKE_MAJOR_VERSION DOES_NOT_EXIST)
#include(CMakePrintSystemInformation)
#variable_watch(PROJECT_NAME)
