# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

Dependency
---------
Operations to manipule dependencies. It requires CMake 3.16 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    dependency(`IMPORT`_ <lib_name> <STATIC|SHARED> [RELEASE <raw_filename>] [DEBUG <raw_filename>] ROOT_DIR <directory_path> INCLUDE_DIR <directory_path>)

Usage
^^^^^
.. _IMPORT:
.. code-block:: cmake

  dependency(IMPORT <lib_name> <STATIC|SHARED> [RELEASE <raw_filename>] [DEBUG <raw_filename>] ROOT_DIR <directory_path> INCLUDE_DIR <directory_path>)

Find and creates an imported library target called ``<lib_name>``. This command embed
the behavior of ``find_library()`` and ``add_library(IMPORTED)``. First, it recursively
find the ``RELEASE`` and ``DEBUG`` library files in the given path ``INCLUDE_DIR`` from
their raw filenames ``<raw_filename>`` . ``RELEASE`` and ``DEBUG`` are facultative but
at least one has to be given. The ``<raw_filename>``
given should be a library file name without any numeric character (for versions), any
special character and any suffixes (e.g. .so). The command will loop over all file in
``ROOT_DIR`` and try to do a matching between the ``<raw_filename>`` and each filename
found striped from their numeric and special character and their suffix based on the
plateform and the kind of library ``STATIC`` or ``SHARED`` (eg. .lib and .dll.a for static
on Windows, .a for static on Unix, .dll for shared on Windows, .so for shared on Linux).
An error message occured if there is more than one result or if no file is found.
Secondly, when research is successful the `add_library(IMPORTED)`` CMake function
is called and all target properties are filled. To fill in the include header files,
the variable ``INCLUDE_DIR`` must give where the files are.

#]=======================================================================]
include_guard()

cmake_minimum_required (VERSION 3.16)
include(Directory)

#------------------------------------------------------------------------------
# Public function of this module.
function(dependency)
	set(options SHARED STATIC)
	set(one_value_args IMPORT RELEASE DEBUG ROOT_DIR INCLUDE_DIR)
	set(multi_value_args "")
	cmake_parse_arguments(DEP "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED DEP_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${DEP_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED DEP_IMPORT)
		_dependency_import()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(_dependency_import)
	if(NOT DEFINED DEP_IMPORT)
		message(FATAL_ERROR "IMPORT arguments is missing or need a value!")
	endif()
	if((NOT ${DEP_SHARED})
		AND (NOT ${DEP_STATIC}))
		message(FATAL_ERROR "SHARED|STATIC arguments is missing!")
	endif()
	if(${DEP_SHARED} AND ${DEP_STATIC})
		message(FATAL_ERROR "SHARED|STATIC cannot be used together!")
	endif()
	if((NOT DEFINED DEP_RELEASE)
		AND (NOT DEFINED DEP_DEBUG))
		message(FATAL_ERROR "RELEASE|DEBUG arguments is missing!")
	endif()
	if("RELEASE" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
		message(FATAL_ERROR "RELEASE need a value!")
	endif()
	if("DEBUG" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
		message(FATAL_ERROR "DEBUG need a value!")
	endif()
	if(NOT DEFINED DEP_ROOT_DIR)
		message(FATAL_ERROR "ROOT_DIR arguments is missing or need a value!")
	endif()
	if(NOT DEFINED DEP_INCLUDE_DIR)
		message(FATAL_ERROR "INCLUDE_DIR arguments is missing or need a value!")
	endif()
	
	if(${DEP_SHARED})
		set(library_type "SHARED")
	elseif(${DEP_STATIC})
		set(library_type "STATIC")
	else()
		message(FATAL_ERROR "Wrong library type!")
	endif()

	add_library("${DEP_IMPORT}" "${library_type}" IMPORTED)
	set_target_properties("${DEP_IMPORT}" PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${DEP_INCLUDE_DIR}")
	if(DEFINED DEP_RELEASE)
		# Get the library file for release.
		directory(FIND_LIB lib_release
			NAME "${DEP_RELEASE}"
			"${library_type}"
			RELATIVE off
			ROOT_DIR "${DEP_ROOT_DIR}"
		)
		if(NOT lib_release)
			message(FATAL_ERROR "The release library \"${DEP_RELEASE}\" was not found!")
		endif()
		# Add library properties for release.
		get_filename_component(lib_release_name "${lib_release}" NAME)
		set_target_properties("${DEP_IMPORT}" PROPERTIES
			IMPORTED_LOCATION "${lib_release}" # Only for ".dll" and ".a" and ".so".
			IMPORTED_IMPLIB "" # Only for ".lib" and ".dll.a" (not used).
			IMPORTED_SONAME "${lib_release_name}"
		)
		set_property(TARGET "${DEP_IMPORT}" APPEND PROPERTY IMPORTED_CONFIGURATIONS "RELEASE")
	endif()

	if(DEFINED DEP_DEBUG)
		# Get the library file for debug.
		directory(FIND_LIB lib_debug
			NAME "${DEP_DEBUG}"
			"${library_type}"
			RELATIVE off
			ROOT_DIR "${DEP_ROOT_DIR}"
		)
		if(NOT lib_debug)
			message(FATAL_ERROR "The debug library \"${DEP_DEBUG}\" was not found!")
		endif()
		# Add library properties for debug.
		get_filename_component(lib_debug_name "${lib_debug}" NAME)
		set_target_properties("${DEP_IMPORT}" PROPERTIES
			IMPORTED_LOCATION_DEBUG "${lib_debug}" # Only for ".dll" and ".a" and ".so".
			IMPORTED_IMPLIB "" # Only for ".lib" and ".dll.a" (not used).
			IMPORTED_SONAME_DEBUG "${lib_debug_name}"
		)
		set_property(TARGET "${DEP_IMPORT}" APPEND PROPERTY IMPORTED_CONFIGURATIONS "DEBUG")
	endif()
endmacro()
