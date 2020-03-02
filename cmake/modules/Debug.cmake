# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

Debug
-----
Operations for helping with debug. It requires CMake 3.16 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    debug(`DUMP_VARIABLES`_ [EXCLUDE_REGEX <regular-expression>])

Usage
^^^^^
.. _DUMP_VARIABLES:
.. code-block:: cmake

  debug(DUMP_VARIABLES [EXCLUDE_REGEX <regular-expression>])

Disaply all CMake variables except those that match with the optional 
``<regular-expression>`` parameter.

#]=======================================================================]
cmake_minimum_required (VERSION 3.16)
include(CMakePrintHelpers)

#------------------------------------------------------------------------------
# Public function of this module.
function(debug)
	set(options DUMP_VARIABLES)
	set(one_value_args EXCLUDE_REGEX)
	set(multi_value_args "")
	cmake_parse_arguments(DB "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	if(DB_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${DB_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED DB_DUMP_VARIABLES)
		get_cmake_property(variable_names VARIABLES)
		list(SORT variable_names)
		foreach (variable_name IN ITEMS ${variable_names})
			if((NOT DB_EXCLUDE_REGEX) OR (NOT "${variable_name}" MATCHES "${DB_EXCLUDE_REGEX}"))
				message(STATUS "${variable_name}= ${${variable_name}}")
			endif()
		endforeach()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
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