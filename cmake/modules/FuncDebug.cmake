# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

Debug
-----
Operations for helping with debug. It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    debug(`DUMP_VARIABLES`_ [EXCLUDE_REGEX <regular_expression>])
    debug(`DUMP_PROPERTIES`_)
    debug(`DUMP_TARGET_PROPERTIES`_ <target_name>)
    debug(`DUMP_PROJECT_VARIABLES`_)

Usage
^^^^^
.. _DUMP_VARIABLES:
.. code-block:: cmake

  debug(DUMP_VARIABLES [EXCLUDE_REGEX <regular_expression>])

Disaply all CMake variables except those that match with the optional 
``<regular_expression>`` parameter.

.. _DUMP_PROPERTIES:
.. code-block:: cmake

  debug(DUMP_PROPERTIES)

Disaply all CMake properties.

.. _DUMP_TARGET_PROPERTIES:
.. code-block:: cmake

  debug(DUMP_TARGET_PROPERTIES <target_name>)

Display all CMake properties of target ``<target_name>`` parameter.

.. _DUMP_PROJECT_VARIABLES:
.. code-block:: cmake

  debug(DUMP_PROJECT_VARIABLES)

Display all global variables of the project. The trick is to exploit the
naming convention which stipulates that each variable is prefixed
by ${PROJECT_NAME}.

#]=======================================================================]
include_guard()

cmake_minimum_required (VERSION 3.20)
include(CMakePrintHelpers)

#------------------------------------------------------------------------------
# Public function of this module.
function(debug)
	set(options DUMP_VARIABLES DUMP_PROPERTIES DUMP_PROJECT_VARIABLES)
	set(one_value_args EXCLUDE_REGEX DUMP_TARGET_PROPERTIES)
	set(multi_value_args "")
	cmake_parse_arguments(DB "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED DB_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${DB_UNPARSED_ARGUMENTS}\"")
	endif()

	if(${DB_DUMP_VARIABLES})
		_debug_dump_variables()
	elseif(${DB_DUMP_PROPERTIES})
		_debug_dump_properties()
	elseif(DEFINED DB_DUMP_TARGET_PROPERTIES)
		_debug_dump_target_properties()
	elseif(${DB_DUMP_PROJECT_VARIABLES})
		_debug_dump_project_variables()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(_debug_dump_variables)
	if(NOT ${DB_DUMP_VARIABLES})
		message(FATAL_ERROR "DUMP_VARIABLES arguments is missing")
	endif()

	get_cmake_property(variable_names VARIABLES)
	list(SORT variable_names)
	list(REMOVE_DUPLICATES variable_names)
	foreach (variable_name IN ITEMS ${variable_names})
		if((NOT DEFINED DB_EXCLUDE_REGEX) OR (NOT "${variable_name}" MATCHES "${DB_EXCLUDE_REGEX}"))
			message(STATUS "${variable_name}= ${${variable_name}}")
		endif()
	endforeach()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_debug_dump_properties)
	if(NOT ${DB_DUMP_PROPERTIES})
		message(FATAL_ERROR "DUMP_PROPERTIES arguments is missing")
	endif()

	execute_process(COMMAND
		${CMAKE_COMMAND} --help-property-list
		OUTPUT_VARIABLE propertie_names
	)
	# Convert command output into a CMake list.
	string(REGEX REPLACE ";" "\\\\;" propertie_names "${propertie_names}")
	string(REGEX REPLACE "\n" ";" propertie_names "${propertie_names}")
	list(SORT propertie_names)
	foreach (propertie_name IN ITEMS ${propertie_names})
		message(STATUS "${propertie_name}")
	endforeach()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_debug_dump_target_properties)
	if(NOT DEFINED DB_DUMP_TARGET_PROPERTIES)
		message(FATAL_ERROR "DB_DUMP_TARGET_PROPERTIES arguments is missing")
	endif()
	if(NOT TARGET "${DB_DUMP_TARGET_PROPERTIES}")
		message(FATAL_ERROR "There is no target named \"${DB_DUMP_TARGET_PROPERTIES}\"")
	endif()

	# Get all propreties that cmake supports
	execute_process(COMMAND
		${CMAKE_COMMAND} --help-property-list
		OUTPUT_VARIABLE propertie_names
	)

	# Convert command output into a CMake list.
	string(REGEX REPLACE ";" "\\\\;" propertie_names "${propertie_names}")
	string(REGEX REPLACE "\n" ";" propertie_names "${propertie_names}")
	
	# Add custom properties used in this project.
	list(APPEND propertie_names
		"INTERFACE_INCLUDE_DIRECTORIES_BUILD"
		"INTERFACE_INCLUDE_DIRECTORIES_INSTALL"
		"IMPORTED_LOCATION_BUILD_<CONFIG>"
		"IMPORTED_LOCATION_INSTALL_<CONFIG>"
	)
	
	# Substitute "_<CONFIG>"" for each variable by the real configuration types (RELEASE and DEBUG).
	set(config_dependent_propertie_names ${propertie_names})
	list(FILTER config_dependent_propertie_names INCLUDE REGEX "_<CONFIG>$")
	list(FILTER propertie_names EXCLUDE REGEX "_<CONFIG>$")
	foreach(propertie_name IN ITEMS ${config_dependent_propertie_names})
		string(REPLACE "<CONFIG>" "DEBUG" propertie_name_debug ${propertie_name})
		list(APPEND propertie_names "${propertie_name_debug}")
		string(REPLACE "<CONFIG>" "RELEASE" propertie_name_release ${propertie_name})
		list(APPEND propertie_names "${propertie_name_release}")
	endforeach()

	# Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
	list(FILTER propertie_names EXCLUDE REGEX "^LOCATION$|^LOCATION_|_LOCATION$")
	list(REMOVE_DUPLICATES propertie_names)
	list(SORT propertie_names)

	message("")
	message("-----")
	list(APPEND CMAKE_MESSAGE_INDENT " ")
	message("Properties for TARGET ${DB_DUMP_TARGET_PROPERTIES}:")
	list(APPEND CMAKE_MESSAGE_INDENT "  ")
	foreach(propertie_name IN ITEMS ${propertie_names})
		get_property(propertie_set TARGET "${DB_DUMP_TARGET_PROPERTIES}" PROPERTY "${propertie_name}" SET)
		if(${propertie_set})
			get_target_property(propertie_value "${DB_DUMP_TARGET_PROPERTIES}" "${propertie_name}")
			message("${DB_DUMP_TARGET_PROPERTIES}.${propertie_name} = \"${propertie_value}\"")
		endif()
	endforeach()
	list(POP_BACK CMAKE_MESSAGE_INDENT)
	list(POP_BACK CMAKE_MESSAGE_INDENT)
	message("-----")
	message("")
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_debug_dump_project_variables)
	if(NOT ${DB_DUMP_PROJECT_VARIABLES})
		message(FATAL_ERROR "DUMP_PROJECT_VARIABLES arguments is missing")
	endif()

	get_cmake_property(variable_names VARIABLES)
	list(SORT variable_names)
	
	message("")
	message("-----")
	list(APPEND CMAKE_MESSAGE_INDENT " ")
	message("Variables for PROJECT ${PROJECT_NAME}:")
	list(APPEND CMAKE_MESSAGE_INDENT "  ")
	foreach (variable_name IN ITEMS ${variable_names})
		if("${variable_name}" MATCHES "${PROJECT_NAME}_")
			message("${variable_name} = \"${${variable_name}}\"")
		endif()
	endforeach()
	list(POP_BACK CMAKE_MESSAGE_INDENT)
	list(POP_BACK CMAKE_MESSAGE_INDENT)
	message("-----")
	message("")
endmacro()

#------------------------------------------------------------------------------
# Some usefull cmake functions
#------------------------------------------------------------------------------

# For printing properties and variables (@see https://cmake.org/cmake/help/latest/module/CMakePrintHelpers.html
# and https://cmake.org/cmake/help/latest/manual/cmake-properties.7.html)
#cmake_print_properties([TARGETS target1 ..  targetN]
#	[SOURCES source1 .. sourceN]
#	[DIRECTORIES dir1 .. dirN]
#	[TESTS test1 .. testN]
#	[CACHE_ENTRIES entry1 .. entryN]
#	PROPERTIES prop1 .. propN )
#cmake_print_variables(var1 var2 ..  varN)

# For printing system information (@see https://cmake.org/cmake/help/latest/module/CMakePrintSystemInformation.html)
#include(CMakePrintSystemInformation)

# For printing a graph of dependencies of the targets (@see https://cmake.org/cmake/help/latest/prop_gbl/GLOBAL_DEPENDS_DEBUG_MODE.html)
#set_property(GLOBAL PROPERTY GLOBAL_DEPENDS_DEBUG_MODE 1)

# For testing generator expressions (@see https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#debugging)
#file(GENERATE OUTPUT debug.txt CONTENT "$<...>")