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

    file_manip(`RELATIVE_PATH`_ <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_var>])
    file_manip(`ABSOLUTE_PATH`_ <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_var>])
    file_manip(`STRIP_PATH`_ <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_var>])
    file_manip(`GET_COMPONENT`_ <file_list>... MODE <mode> OUTPUT_VARIABLE <output_var>)

Usage
^^^^^
.. _RELATIVE_PATH:
.. code-block:: cmake

  file_manip(RELATIVE_PATH <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_var>])

Compute the relative path from a ``<directory_path>`` for each files in the
list of input path ``<file_list_var>`` and store the result in-place or in
the specified ``<output_var>``.

.. _ABSOLUTE_PATH:
.. code-block:: cmake

  file_manip(ABSOLUTE_PATH <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_var>])

Compute the absolute path from a ``<directory_path>`` for each files in the
list of input path ``<file_list_var>`` and store the result in-place or in
the specified ``<output_var>``.

.. _GET_COMPONENT:
.. code-block:: cmake

  file_manip(STRIP_PATH <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_var>])

Strip the <directory_path>`` prefix of each file in ``<file_list_var>`` and
store the result in-place or in the specified ``<output_var>``.

.. _GET_COMPONENT:
.. code-block:: cmake

  file_manip(GET_COMPONENT <file_list>... MODE <mode> OUTPUT_VARIABLE <output_var>)

Sets in the specified ``<output_var>`` to a component of file of ``<file_list>``
, where ``<mode>`` is one of:

::

 DIRECTORY = Directory without file name
 NAME      = File name without directory

#]=======================================================================]
cmake_minimum_required (VERSION 3.16)

#------------------------------------------------------------------------------
# Public function of this module.
function(file_manip)
	set(options "")
	set(one_value_args RELATIVE_PATH ABSOLUTE_PATH STRIP_PATH BASE_DIR MODE OUTPUT_VARIABLE)
	set(multi_value_args GET_COMPONENT)
	cmake_parse_arguments(FM "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED FM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED FM_RELATIVE_PATH)
		file_manip_relative_path(RELATIVE_PATH ${FM_RELATIVE_PATH} BASE_DIR "${FM_BASE_DIR}" OUTPUT_VARIABLE ${FM_OUTPUT_VARIABLE})
	elseif(DEFINED FM_ABSOLUTE_PATH)
		file_manip_absolute_path(ABSOLUTE_PATH ${FM_ABSOLUTE_PATH} BASE_DIR "${FM_BASE_DIR}" OUTPUT_VARIABLE ${FM_OUTPUT_VARIABLE})
	elseif(DEFINED FM_STRIP_PATH)
		file_manip_strip_path(STRIP_PATH ${FM_STRIP_PATH} BASE_DIR "${FM_BASE_DIR}" OUTPUT_VARIABLE ${FM_OUTPUT_VARIABLE})
	elseif((DEFINED FM_GET_COMPONENT)
		OR ("GET_COMPONENT" IN_LIST FM_KEYWORDS_MISSING_VALUES))
		if("${FM_MODE}" STREQUAL DIRECTORY)
			file_manip_get_component_directory(GET_COMPONENT "${FM_GET_COMPONENT}" MODE "${FM_MODE}" OUTPUT_VARIABLE ${FM_OUTPUT_VARIABLE})
		elseif("${FM_MODE}" STREQUAL NAME)
			file_manip_get_component_name(GET_COMPONENT "${FM_GET_COMPONENT}" MODE "${FM_MODE}" OUTPUT_VARIABLE ${FM_OUTPUT_VARIABLE})
		else()
			message(FATAL_ERROR "MODE arguments is missing")
		endif()
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

#------------------------------------------------------------------------------
# Internal usage.
macro(file_manip_absolute_path)
	set(options "")
	set(one_value_args ABSOLUTE_PATH BASE_DIR OUTPUT_VARIABLE)
	set(multi_value_args "")
	cmake_parse_arguments(FMAP "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED FMAP_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SMTSL_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED FMAP_ABSOLUTE_PATH)
		message(FATAL_ERROR "ABSOLUTE_PATH arguments is missing")
	endif()
	if(NOT DEFINED FMAP_BASE_DIR)
		message(FATAL_ERROR "BASE_DIR arguments is missing")
	endif()
	
	set(absolute_path_list "")
	foreach(file IN ITEMS ${${FMAP_ABSOLUTE_PATH}})
		get_filename_component(absolute_path "${file}" ABSOLUTE BASE_DIR "${FMAP_BASE_DIR}")
		list(APPEND absolute_path_list ${absolute_path})
	endforeach()
	
	if(NOT DEFINED FMAP_OUTPUT_VARIABLE)
		set(${FMAP_ABSOLUTE_PATH} "${absolute_path_list}" PARENT_SCOPE)
	else()
		set(${FMAP_OUTPUT_VARIABLE} "${absolute_path_list}" PARENT_SCOPE)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(file_manip_strip_path)
	set(options "")
	set(one_value_args STRIP_PATH BASE_DIR OUTPUT_VARIABLE)
	set(multi_value_args "")
	cmake_parse_arguments(FMSP "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED FMSP_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SMTSL_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED FMSP_STRIP_PATH)
		message(FATAL_ERROR "STRIP_PATH arguments is missing")
	endif()
	if(NOT DEFINED FMSP_BASE_DIR)
		message(FATAL_ERROR "BASE_DIR arguments is missing")
	endif()
	
	set(stripped_path_list "")
	foreach(file IN ITEMS ${${FMSP_STRIP_PATH}})
		string(REPLACE "${FMSP_BASE_DIR}/" "" stripped_path ${file})
		list(APPEND stripped_path_list ${stripped_path})
	endforeach()
	
	if(NOT DEFINED FMSP_OUTPUT_VARIABLE)
		set(${FMSP_STRIP_PATH} "${stripped_path_list}" PARENT_SCOPE)
	else()
		set(${FMSP_OUTPUT_VARIABLE} "${stripped_path_list}" PARENT_SCOPE)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(file_manip_get_component_directory)
	set(options "")
	set(one_value_args MODE OUTPUT_VARIABLE)
	set(multi_value_args GET_COMPONENT)
	cmake_parse_arguments(FMGCD "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED FMGCD_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SMTSL_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED FMGCD_GET_COMPONENT)
		message(FATAL_ERROR "GET_COMPONENT arguments is missing")
	endif()
	if(NOT DEFINED FMGCD_MODE)
		message(FATAL_ERROR "MODE arguments is missing")
	endif()
	if(NOT DEFINED FMGCD_OUTPUT_VARIABLE)
		message(FATAL_ERROR "OUTPUT_VARIABLE arguments is missing")
	endif()
	
	set(directorty_path_list "")
	foreach(file IN ITEMS ${FMGCD_GET_COMPONENT})
		get_filename_component(directory_path "${file}" DIRECTORY)
		list(APPEND directorty_path_list "${directory_path}")
	endforeach()
	
	set(${FMGCD_OUTPUT_VARIABLE} "${directorty_path_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(file_manip_get_component_name)
	set(options "")
	set(one_value_args MODE OUTPUT_VARIABLE)
	set(multi_value_args GET_COMPONENT)
	cmake_parse_arguments(FMGCN "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	if(DEFINED FMGCN_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SMTSL_UNPARSED_ARGUMENTS}\"")
	endif()
	if((NOT DEFINED FMGCN_GET_COMPONENT)
		AND (NOT "GET_COMPONENT" IN_LIST FMGCN_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "GET_COMPONENT arguments is missing")
	endif()
	if(NOT DEFINED FMGCN_MODE)
		message(FATAL_ERROR "MODE arguments is missing")
	endif()
	if(NOT DEFINED FMGCN_OUTPUT_VARIABLE)
		message(FATAL_ERROR "OUTPUT_VARIABLE arguments is missing")
	endif()
	
	set(file_name_list "")
	foreach(file IN ITEMS ${FMGCN_GET_COMPONENT})
		get_filename_component(file_name "${file}" NAME)
		list(APPEND file_name_list "${file_name}")
	endforeach()
	
	set(${FMGCN_OUTPUT_VARIABLE} "${file_name_list}" PARENT_SCOPE)
endmacro()