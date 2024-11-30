# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

Directory
---------
Operations to manipule directories. It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    directory(`SCAN`_ <output_list_var> [LIST_DIRECTORIES <on|off>] RELATIVE <on|off> ROOT_DIR <directory_path> <INCLUDE_REGEX|EXCLUDE_REGEX> <regular_expression>)
    directory(`SCAN_DIRS`_ <output_list_var> RECURSE <on|off> RELATIVE <on|off> ROOT_DIR <directory_path> <INCLUDE_REGEX|EXCLUDE_REGEX> <regular_expression>)
    directory(`FIND_LIB`_ <output_var> NAME <raw_filename> <STATIC|SHARED> RELATIVE <on|off> ROOT_DIR <directory_path>)

Usage
^^^^^
.. _SCAN:
.. code-block:: cmake

  directory(SCAN <output_list_var> [LIST_DIRECTORIES <on|off>] RELATIVE <on|off> ROOT_DIR <directory_path> <INCLUDE_REGEX|EXCLUDE_REGEX> <regular_expression>)

Recursively generate a list of all files that match the ``<regular_expressions>``
from the ROOT_DIR and store it into ``<output_list_var>`` as a list. The results will be
returned as absolute paths to the given path ``<directory_path>`` if RELATIVE
flag is set to off, else as relative path to ROOT_DIR. By default the function
also add directories to result list. Setting LIST_DIRECTORIES to off removes
directories to result list.

.. _SCAN_DIRS:
.. code-block:: cmake

  directory(SCAN_DIRS <output_list_var> RECURSE <on|off> RELATIVE <on|off> ROOT_DIR <directory_path> <INCLUDE_REGEX|EXCLUDE_REGEX> <regular_expression>)

Generate a list of all directories that match the ``<regular_expressions>``
from the ROOT_DIR and store it into ``<output_list_var>`` as a list. The results will be
returned as absolute paths to the given path ``<directory_path>`` if RELATIVE 
flag is set to off, else as relative path to ROOT_DIR. If RECURSE is set to on, the
function will traverse all the subdirectories from ROOT_DIR.

.. _FIND_LIB:
.. code-block:: cmake

  directory(FIND_LIB <output_var_lib> FIND_IMPLIB <output_var_implib> NAME <raw_filename> <STATIC|SHARED> RELATIVE <on|off> ROOT_DIR <directory_path>)

Recursively try to find a library and its import library on DLL platforms in the given path ``ROOT_DIR`` from its raw filename ``NAME``. The behavior is similar to ``find_library()``, but more complete.

If the library is found the result path is stored in the variable ``<output_var_lib>``. If the import library is found the result path is stored in the variable ``<output_var_implib>``. The results will be returned as absolute paths if ``RELATIVE `` flag is set to off, else as relative path to ``ROOT_DIR``. If nothing is found, the result will be <output_var_lib>-NOTFOUND and <output_var_implib>-NOTFOUND.

The name given to the ``NAME`` option should be a library file name, including its version number, but without any special character, any prefixes (e.g. lib) and any suffixes (e.g. .so), that are platform-dependent. The command will loop over all files in ``ROOT_DIR`` and try to get a library filename that match ``[<CMAKE_STATIC_LIBRARY_PREFIX|CMAKE_SHARED_LIBRARY_PREFIX|CMAKE_FIND_LIBRARY_PREFIXES>]<raw_filename><CMAKE_STATIC_LIBRARY_SUFFIX|CMAKE_SHARED_LIBRARY_SUFFIX>`` and an import library filename that match ``[<CMAKE_STATIC_LIBRARY_PREFIX|CMAKE_SHARED_LIBRARY_PREFIX|CMAKE_FIND_LIBRARY_PREFIXES>]<raw_filename><CMAKE_FIND_LIBRARY_SUFFIXES>``. As noted, the prefix can be overwritten by ``CMAKE_FIND_LIBRARY_PREFIXES``.

An error message occured if there is more than one result or if no file is found.

#]=======================================================================]
include_guard()

cmake_minimum_required (VERSION 3.20)

#------------------------------------------------------------------------------
# Public function of this module.
function(directory)
	set(options SHARED STATIC)
	set(one_value_args SCAN SCAN_DIRS LIST_DIRECTORIES RELATIVE ROOT_DIR INCLUDE_REGEX EXCLUDE_REGEX RECURSE FIND_LIB FIND_IMPLIB NAME)
	set(multi_value_args "")
	cmake_parse_arguments(DIR "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED DIR_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${DIR_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED DIR_SCAN)
		_directory_scan()
	elseif(DEFINED DIR_SCAN_DIRS)
		_directory_scan_dirs()
	elseif(DEFINED DIR_FIND_LIB)
		_directory_find_lib()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(_directory_scan)
	if(NOT DEFINED DIR_SCAN)
		message(FATAL_ERROR "SCAN arguments is missing")
	endif()
	if((DEFINED DIR_LIST_DIRECTORIES)
		AND	((NOT ${DIR_LIST_DIRECTORIES} STREQUAL "on")
		AND (NOT ${DIR_LIST_DIRECTORIES} STREQUAL "off")))
		message(FATAL_ERROR "LIST_DIRECTORIES arguments is wrong")
	endif()
	if((NOT DEFINED DIR_RELATIVE)
		OR ((NOT ${DIR_RELATIVE} STREQUAL "on")
		AND (NOT ${DIR_RELATIVE} STREQUAL "off")))
		message(FATAL_ERROR "RELATIVE arguments is wrong")
	endif()
	if(NOT DEFINED DIR_ROOT_DIR)
		message(FATAL_ERROR "ROOT_DIR arguments is missing")
	endif()
	if((NOT DEFINED DIR_INCLUDE_REGEX)
		AND (NOT DEFINED DIR_EXCLUDE_REGEX))
		message(FATAL_ERROR "INCLUDE_REGEX|EXCLUDE_REGEX arguments is missing")
	endif()

	set(file_list "")
	if(NOT DEFINED DIR_LIST_DIRECTORIES)
		set(DIR_LIST_DIRECTORIES on)
	endif()
	if(${DIR_RELATIVE})
		file(GLOB_RECURSE file_list FOLLOW_SYMLINKS LIST_DIRECTORIES ${DIR_LIST_DIRECTORIES} RELATIVE "${DIR_ROOT_DIR}" CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
	else()
		file(GLOB_RECURSE file_list FOLLOW_SYMLINKS LIST_DIRECTORIES ${DIR_LIST_DIRECTORIES} CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
	endif()
	
	if(DEFINED DIR_INCLUDE_REGEX)
		list(FILTER file_list INCLUDE REGEX "${DIR_INCLUDE_REGEX}")
	elseif(DEFINED DIR_EXCLUDE_REGEX)
		list(FILTER file_list EXCLUDE REGEX "${DIR_EXCLUDE_REGEX}")
	endif()
	
	set(${DIR_SCAN} "${file_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_directory_scan_dirs)
	if(NOT DEFINED DIR_SCAN_DIRS)
		message(FATAL_ERROR "SCAN_DIRS arguments is missing")
	endif()
	if((NOT DEFINED DIR_RECURSE)
		OR ((NOT ${DIR_RECURSE} STREQUAL "on")
		AND (NOT ${DIR_RECURSE} STREQUAL "off")))
		message(FATAL_ERROR "RECURSE arguments is wrong")
	endif()
	if((NOT DEFINED DIR_RELATIVE)
		OR ((NOT ${DIR_RELATIVE} STREQUAL "on")
		AND (NOT ${DIR_RELATIVE} STREQUAL "off")))
		message(FATAL_ERROR "RELATIVE arguments is wrong")
	endif()
	if(NOT DEFINED DIR_ROOT_DIR)
		message(FATAL_ERROR "ROOT_DIR arguments is missing")
	endif()
	if((NOT DEFINED DIR_INCLUDE_REGEX)
		AND (NOT DEFINED DIR_EXCLUDE_REGEX))
		message(FATAL_ERROR "INCLUDE_REGEX|EXCLUDE_REGEX arguments is missing")
	endif()

	set(file_list "")
	if(${DIR_RECURSE} AND ${DIR_RELATIVE})
		file(GLOB_RECURSE file_list FOLLOW_SYMLINKS LIST_DIRECTORIES on RELATIVE "${DIR_ROOT_DIR}" CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
	elseif(${DIR_RECURSE} AND NOT ${DIR_RELATIVE})
		file(GLOB_RECURSE file_list FOLLOW_SYMLINKS LIST_DIRECTORIES on CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
	elseif(NOT ${DIR_RECURSE} AND ${DIR_RELATIVE})
		file(GLOB file_list LIST_DIRECTORIES on RELATIVE "${DIR_ROOT_DIR}" CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
	else()
		file(GLOB file_list LIST_DIRECTORIES on CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
	endif()

	# Removes non-directory files.
	set(directory_list "")
	foreach(file IN ITEMS ${file_list})
		if(IS_DIRECTORY "${file}")
			list(APPEND directory_list "${file}")
		endif()
	endforeach()

	if(DEFINED DIR_INCLUDE_REGEX)
		list(FILTER directory_list INCLUDE REGEX "${DIR_INCLUDE_REGEX}")
	elseif(DEFINED DIR_EXCLUDE_REGEX)
		list(FILTER directory_list EXCLUDE REGEX "${DIR_EXCLUDE_REGEX}")
	endif()

	set(${DIR_SCAN_DIRS} "${directory_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_directory_find_lib)
	if(NOT DEFINED DIR_FIND_LIB)
		message(FATAL_ERROR "FIND_LIB arguments is missing or need a value!")
	endif()
	if(NOT DEFINED DIR_FIND_IMPLIB)
		message(FATAL_ERROR "FIND_IMPLIB arguments is missing or need a value!")
	endif()
	if(NOT DEFINED DIR_NAME)
		message(FATAL_ERROR "NAME arguments is missing or need a value!")
	endif()
	if((NOT ${DIR_SHARED})
		AND (NOT ${DIR_STATIC}))
		message(FATAL_ERROR "SHARED|STATIC arguments is missing!")
	endif()
	if((NOT DEFINED DIR_RELATIVE)
		OR ((NOT ${DIR_RELATIVE} STREQUAL "on")
		AND (NOT ${DIR_RELATIVE} STREQUAL "off")))
		message(FATAL_ERROR "RELATIVE arguments is wrong!")
	endif()
	if(NOT DEFINED DIR_ROOT_DIR)
		message(FATAL_ERROR "ROOT_DIR arguments is missing or need a value!")
	endif()

	set(file_list "")
	if(${DIR_RELATIVE})
		file(GLOB_RECURSE file_list FOLLOW_SYMLINKS LIST_DIRECTORIES off RELATIVE "${DIR_ROOT_DIR}" CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
	else()
		file(GLOB_RECURSE file_list FOLLOW_SYMLINKS LIST_DIRECTORIES off CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
	endif()

	# Init prefixes and suffixes.
	if(DEFINED DIR_SHARED)
		set(library_prefixes "${CMAKE_SHARED_LIBRARY_PREFIX}")
		set(library_suffixes "${CMAKE_SHARED_LIBRARY_SUFFIX}")
	elseif(DEFINED DIR_STATIC)
		set(library_prefixes "${CMAKE_STATIC_LIBRARY_PREFIX}")
		set(library_suffixes "${CMAKE_STATIC_LIBRARY_SUFFIX}")
	else()
		message(FATAL_ERROR "Wrong library suffix!")
	endif()
	if(CMAKE_FIND_LIBRARY_PREFIXES)
		list(JOIN CMAKE_FIND_LIBRARY_PREFIXES "|" library_prefixes)
	endif()
	set(import_library_prefixes "${library_prefixes}")
	list(JOIN CMAKE_FIND_LIBRARY_SUFFIXES "|" import_library_suffixes)

	# Build search regex.
	set(library_regex "^(${library_prefixes})?${DIR_NAME}(${library_suffixes})$")
	string(REGEX REPLACE [[(\.)]] [[\\\1]] library_regex "${library_regex}")
	set(import_library_regex "^(${import_library_prefixes})?${DIR_NAME}(${import_library_suffixes})$")
	string(REGEX REPLACE [[(\.)]] [[\\\1]] import_library_regex "${import_library_regex}")
	
	# Search lib and implib.
	set(library_found_path "${DIR_FIND_LIB}-NOTFOUND")
	set(import_library_found_path "${DIR_FIND_IMPLIB}-NOTFOUND")
	foreach(file IN ITEMS ${file_list})
		cmake_path(GET file FILENAME file_name)
		if("${file_name}" MATCHES "${library_regex}")
			# Found the library.
			if("${library_found_path}" STREQUAL "${DIR_FIND_LIB}-NOTFOUND")
				set(library_found_path "${file}")
			else()
				message(FATAL_ERROR "At least two matches with the library name \"${DIR_NAME}\"!")
			endif()
		elseif("${file_name}" MATCHES "${import_library_regex}")
			# Found the import library.
			if("${import_library_found_path}" STREQUAL "${DIR_FIND_IMPLIB}-NOTFOUND")
				set(import_library_found_path "${file}")
			else()
				message(FATAL_ERROR "At least two matches with the import library name \"${DIR_NAME}\"!")
			endif()
		endif()
	endforeach()

	set(${DIR_FIND_LIB} "${library_found_path}" PARENT_SCOPE)
	set(${DIR_FIND_IMPLIB} "${import_library_found_path}" PARENT_SCOPE)
endmacro()
