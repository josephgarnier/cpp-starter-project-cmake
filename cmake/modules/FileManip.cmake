# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

FileManip
---------
Operations on files. It requires CMake 3.16 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    file_manip(`RELATIVE_PATH`_ <input-list-var> BASE_DIR <path> [OUTPUT_VARIABLE <output-var>])

Usage
^^^^^
.. _RELATIVE_PATH:
.. code-block:: cmake

  file_manip(RELATIVE_PATH <input-list-var> BASE_DIR <directory-path> [OUTPUT_VARIABLE <output-var>])

Compute the relative path from a `<directory-path>` to a the list of input path `<input-list-var>` and store the result in-place or in the specified ``<output-var>``.

#]=======================================================================]
cmake_minimum_required (VERSION 3.16)

#------------------------------------------------------------------------------
# Public function of this module.
function(file_manip)
	set(options "")
	set(one_value_args RELATIVE_PATH BASE_DIR OUTPUT_VARIABLE)
	set(multi_value_args "")
	cmake_parse_arguments(FM "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED FM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED FM_RELATIVE_PATH)
		file_manip_relative_path(RELATIVE_PATH ${FM_RELATIVE_PATH} BASE_DIR ${FM_BASE_DIR} OUTPUT_VARIABLE ${FM_OUTPUT_VARIABLE})
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(file_manip_relative_path)
	set(options "")
	set(one_value_args RELATIVE_PATH BASE_DIR OUTPUT_VARIABLE)
	set(multi_value_args "")
	cmake_parse_arguments(FMRP "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED FMRP_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SMTSL_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED FMRP_RELATIVE_PATH)
		message(FATAL_ERROR "RELATIVE_PATH arguments is missing")
	endif()
	if(NOT DEFINED FMRP_BASE_DIR)
		message(FATAL_ERROR "BASE_DIR arguments is missing")
	endif()
	
	set(relative_path_list "")
	foreach(file IN ITEMS ${${FMRP_RELATIVE_PATH}})
		file(RELATIVE_PATH relative_path "${FMRP_BASE_DIR}" "${file}")
		list(APPEND relative_path_list ${relative_path})
	endforeach()
	
	if(NOT DEFINED FMRP_OUTPUT_VARIABLE)
		set(${FMRP_RELATIVE_PATH} "${relative_path_list}" PARENT_SCOPE)
	else()
		set(${FMRP_OUTPUT_VARIABLE} "${relative_path_list}" PARENT_SCOPE)
	endif()
endmacro()