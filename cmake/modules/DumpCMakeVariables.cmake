# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
DumpCMakeVariables
---------

Function for displaying cmake variables.

 Usage
 ^^^^^
	dump_cmake_variables(
		EXCLUDE_REGEX [ext1 [ext2 [ext3 ...]]])


 Arguments
 ^^^^^^^^^
	``\group:EXCLUDE_REGEX``
	specifies a regular expression that the file names (without path) must be
	excluded of displaying.


 Requires these CMake modules
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	CMakePrintHelpers

 Requires CMake 3.12 or newer
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#]=======================================================================]

cmake_minimum_required (VERSION 3.12)
include(CMakePrintHelpers)

function(dump_cmake_variables)
	set(options "")
	set(one_value_args EXCLUDE_REGEX)
	set(multi_value_args "")
	cmake_parse_arguments(DV "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	if(DV_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${DV_UNPARSED_ARGUMENTS}\"")
	endif()

	get_cmake_property(variable_names VARIABLES)
	list(SORT variable_names)
	foreach (variable_name IN ITEMS ${variable_names})
		if((NOT DV_EXCLUDE_REGEX) OR (NOT "${variable_name}" MATCHES "${DV_EXCLUDE_REGEX}"))
			message(STATUS "${variable_name}= ${${variable_name}}")
		endif()
	endforeach()
endfunction()

#------------------------------------------------------------------------------
# Some usefull cmake functions
#------------------------------------------------------------------------------

# For printing properties and variables (see https://cmake.org/cmake/help/latest/module/CMakePrintHelpers.html
# and https://cmake.org/cmake/help/latest/manual/cmake-properties.7.html)
#cmake_print_properties([TARGETS target1 ..  targetN]
#	[SOURCES source1 .. sourceN]
#	[DIRECTORIES dir1 .. dirN]
#	[TESTS test1 .. testN]
#	[CACHE_ENTRIES entry1 .. entryN]
#	PROPERTIES prop1 .. propN )
#cmake_print_variables(var1 var2 ..  varN)

# For printing system information (see https://cmake.org/cmake/help/latest/module/CMakePrintSystemInformation.html)
#include(CMakePrintSystemInformation)