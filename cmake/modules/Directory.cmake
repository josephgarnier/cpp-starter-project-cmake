# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

Directory
---------
Operations to manipule directories. It requires CMake 3.16 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    directory(`SCAN`_ <output-var> ROOT_DIR <path> INCLUDE_REGEX <regular-expression>)

Usage
^^^^^
.. _SCAN:
.. code-block:: cmake

  directory(SCAN <output-var> ROOT_DIR <path> INCLUDE_REGEX <regular-expression>)

Generate a list of files that match the `<globbing-expressions>` and store it into the `<output-var>`. The results will be returned as absolute paths to the given path `<path>`.

#]=======================================================================]
cmake_minimum_required (VERSION 3.16)

#------------------------------------------------------------------------------
# Public function of this module.
function(directory)
	set(options "")
	set(one_value_args SCAN ROOT_DIR INCLUDE_REGEX)
	set(multi_value_args "")
	cmake_parse_arguments(DIR "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	if(DIR_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${DIR_UNPARSED_ARGUMENTS}\"")
	endif()
	
	if(DEFINED DIR_SCAN)
		if(NOT DEFINED DIR_ROOT_DIR)
			set(DIR_ROOT_DIR "")
		endif()
		if(NOT DEFINED DIR_INCLUDE_REGEX)
			message(FATAL_ERROR "Regex arguments is missing")
		endif()
	
		file(GLOB relative_path RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${DIR_ROOT_DIR}")
		file(GLOB children RELATIVE ${DIR_ROOT_DIR} "${DIR_ROOT_DIR}/*")
		set(list_dirs "")
		set(list_files "")

		foreach(child IN ITEMS ${children})
			if(IS_DIRECTORY "${DIR_ROOT_DIR}/${child}")
				list(APPEND list_dirs ${child})
			elseif("${child}" MATCHES "${DIR_INCLUDE_REGEX}")
				list(APPEND list_files "${DIR_ROOT_DIR}/${child}")
			endif()
		endforeach()

		string(REPLACE "/" "\\" relative_path "${relative_path}")
		if ("${relative_path}" STREQUAL "")
			set(source_group "")
		else()
			set(source_group "${relative_path}")
		endif()
		source_group("${source_group}" FILES "${list_files}")

		foreach(subdirectory IN ITEMS ${list_dirs})
			directory(SCAN ${DIR_SCAN} ROOT_DIR "${DIR_ROOT_DIR}/${subdirectory}" INCLUDE_REGEX "${DIR_INCLUDE_REGEX}")
		endforeach()
		
		if(NOT ${DIR_SCAN})
			set(${DIR_SCAN} "${list_files}" PARENT_SCOPE)
		else()
			set(${DIR_SCAN} "${${DIR_SCAN}}" "${list_files}" PARENT_SCOPE)
		endif()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()
