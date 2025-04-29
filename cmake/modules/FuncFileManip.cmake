# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

FileManip
---------
Operations on files. It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    file_manip(`RELATIVE_PATH`_ <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_list_var>])
    file_manip(`ABSOLUTE_PATH`_ <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_list_var>])
    file_manip(`STRIP_PATH`_ <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_list_var>])
    file_manip(`GET_COMPONENT`_ <file_list>... MODE <mode> OUTPUT_VARIABLE <output_list_var>)

Usage
^^^^^
.. _RELATIVE_PATH:
.. code-block:: cmake

  file_manip(RELATIVE_PATH <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_list_var>])

Compute the relative path from a ``<directory_path>`` for each files in the
list of input path ``<file_list_var>`` and store the result in-place or in
the specified ``<output_list_var>`` as a list.

.. _ABSOLUTE_PATH:
.. code-block:: cmake

  file_manip(ABSOLUTE_PATH <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_list_var>])

Compute the absolute path from a ``<directory_path>`` for each files in the
list of input path ``<file_list_var>`` and store the result in-place or in
the specified ``<output_list_var>`` as a list.

.. _STRIP_PATH:
.. code-block:: cmake

  file_manip(STRIP_PATH <file_list_var> BASE_DIR <directory_path> [OUTPUT_VARIABLE <output_list_var>])

Strip the <directory_path>`` prefix of each file in ``<file_list_var>`` and
store the result in-place or in the specified ``<output_list_var>`` as a list.

.. _GET_COMPONENT:
.. code-block:: cmake

  file_manip(GET_COMPONENT <file_list>... MODE <mode> OUTPUT_VARIABLE <output_list_var>)

Sets as a list in the specified ``<output_list_var>`` a component of file in the list of ``<file_list>``
, where ``<mode>`` is one of:

::

 DIRECTORY = Directory without file name
 NAME      = File name without directory

#]=======================================================================]
include_guard()

cmake_minimum_required (VERSION 3.20)

#------------------------------------------------------------------------------
# Public function of this module.
function(file_manip)
	set(options "")
	set(one_value_args RELATIVE_PATH ABSOLUTE_PATH STRIP_PATH BASE_DIR MODE OUTPUT_VARIABLE)
	set(multi_value_args GET_COMPONENT)
	cmake_parse_arguments(FM "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED FM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${FM_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED FM_RELATIVE_PATH)
		_file_manip_relative_path()
	elseif(DEFINED FM_ABSOLUTE_PATH)
		_file_manip_absolute_path()
	elseif(DEFINED FM_STRIP_PATH)
		_file_manip_strip_path()
	elseif((DEFINED FM_GET_COMPONENT)
		OR ("GET_COMPONENT" IN_LIST FM_KEYWORDS_MISSING_VALUES))
		if("${FM_MODE}" STREQUAL DIRECTORY)
			_file_manip_get_component_directory()
		elseif("${FM_MODE}" STREQUAL NAME)
			_file_manip_get_component_name()
		else()
			message(FATAL_ERROR "MODE arguments is missing")
		endif()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(_file_manip_relative_path)
	if(NOT DEFINED FM_RELATIVE_PATH)
		message(FATAL_ERROR "RELATIVE_PATH arguments is missing")
	endif()
	if(NOT DEFINED FM_BASE_DIR)
		message(FATAL_ERROR "BASE_DIR arguments is missing")
	endif()
	
	set(relative_path_list "")
	foreach(file IN ITEMS ${${FM_RELATIVE_PATH}})
		file(RELATIVE_PATH relative_path "${FM_BASE_DIR}" "${file}")
		list(APPEND relative_path_list "${relative_path}")
	endforeach()
	
	if(NOT DEFINED FM_OUTPUT_VARIABLE)
		set(${FM_RELATIVE_PATH} "${relative_path_list}" PARENT_SCOPE)
	else()
		set(${FM_OUTPUT_VARIABLE} "${relative_path_list}" PARENT_SCOPE)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_file_manip_absolute_path)
	if(NOT DEFINED FM_ABSOLUTE_PATH)
		message(FATAL_ERROR "ABSOLUTE_PATH arguments is missing")
	endif()
	if(NOT DEFINED FM_BASE_DIR)
		message(FATAL_ERROR "BASE_DIR arguments is missing")
	endif()
	
	set(absolute_path_list "")
	foreach(file IN ITEMS ${${FM_ABSOLUTE_PATH}})
		file(REAL_PATH "${file}" absolute_path BASE_DIRECTORY "${FM_BASE_DIR}")
		list(APPEND absolute_path_list ${absolute_path})
	endforeach()
	
	if(NOT DEFINED FM_OUTPUT_VARIABLE)
		set(${FM_ABSOLUTE_PATH} "${absolute_path_list}" PARENT_SCOPE)
	else()
		set(${FM_OUTPUT_VARIABLE} "${absolute_path_list}" PARENT_SCOPE)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_file_manip_strip_path)
	if(NOT DEFINED FM_STRIP_PATH)
		message(FATAL_ERROR "STRIP_PATH arguments is missing")
	endif()
	if(NOT DEFINED FM_BASE_DIR)
		message(FATAL_ERROR "BASE_DIR arguments is missing")
	endif()
	
	set(stripped_path_list "")
	foreach(file IN ITEMS ${${FM_STRIP_PATH}})
		string(REPLACE "${FM_BASE_DIR}/" "" stripped_path ${file})
		list(APPEND stripped_path_list ${stripped_path})
	endforeach()
	
	if(NOT DEFINED FM_OUTPUT_VARIABLE)
		set(${FM_STRIP_PATH} "${stripped_path_list}" PARENT_SCOPE)
	else()
		set(${FM_OUTPUT_VARIABLE} "${stripped_path_list}" PARENT_SCOPE)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_file_manip_get_component_directory)
	if((NOT DEFINED FM_GET_COMPONENT)
		AND (NOT "GET_COMPONENT" IN_LIST FM_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "GET_COMPONENT arguments is missing")
	endif()
	if(NOT DEFINED FM_MODE)
		message(FATAL_ERROR "MODE arguments is missing")
	endif()
	if(NOT DEFINED FM_OUTPUT_VARIABLE)
		message(FATAL_ERROR "OUTPUT_VARIABLE arguments is missing")
	endif()
	
	set(directorty_path_list "")
	foreach(file IN ITEMS ${FM_GET_COMPONENT})
		cmake_path(GET file PARENT_PATH directory_path)
		list(APPEND directorty_path_list "${directory_path}")
	endforeach()
	
	set(${FM_OUTPUT_VARIABLE} "${directorty_path_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_file_manip_get_component_name)
	if((NOT DEFINED FM_GET_COMPONENT)
		AND (NOT "GET_COMPONENT" IN_LIST FM_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "GET_COMPONENT arguments is missing")
	endif()
	if(NOT DEFINED FM_MODE)
		message(FATAL_ERROR "MODE arguments is missing")
	endif()
	if(NOT DEFINED FM_OUTPUT_VARIABLE)
		message(FATAL_ERROR "OUTPUT_VARIABLE arguments is missing")
	endif()
	
	set(file_name_list "")
	foreach(file IN ITEMS ${FM_GET_COMPONENT})
		cmake_path(FILENAME file PARENT_PATH file_name)
		list(APPEND file_name_list "${file_name}")
	endforeach()
	
	set(${FM_OUTPUT_VARIABLE} "${file_name_list}" PARENT_SCOPE)
endmacro()