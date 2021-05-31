# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

Dependency
---------
Operations to manipule dependencies. It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    dependency(`IMPORT`_ <lib_name> <STATIC|SHARED> [RELEASE_NAME <raw_filename>] [DEBUG_NAME <raw_filename>] ROOT_DIR <directory_path> INCLUDE_DIR <directory_path>)

Usage
^^^^^
.. _IMPORT:
.. code-block:: cmake

  dependency(IMPORT <lib_name> <STATIC|SHARED> [RELEASE_NAME <raw_filename>] [DEBUG_NAME <raw_filename>] ROOT_DIR <directory_path> INCLUDE_DIR <directory_path>)

Find and creates an imported library target called ``<lib_name>``. This command embed
the behavior of ``find_library()`` and ``add_library(IMPORTED)``. First, it recursively
find the possible filenames for ``RELEASE_NAME`` and ``DEBUG_NAME`` library files in the given path
``ROOT_DIR`` from their raw filenames ``<raw_filename>``. ``RELEASE_NAME`` and ``DEBUG_NAME`` are facultative
but at least one has to be given, they define what configurtion types (in ``CMAKE_CONFIGURATION_TYPES``
cmake variable) will be supported by the library (see https://cmake.org/cmake/help/latest/variable/CMAKE_CONFIGURATION_TYPES.html).
The ``<raw_filename>`` given should be a library file name without any numeric character
(for versions), any special character and any suffixes (e.g. .so). The command will loop
over all file in ``ROOT_DIR`` and try to do a matching between the ``<raw_filename>``
and each filename found striped from their numeric and special character and their
suffix based on the plateform and the kind of library ``STATIC`` or ``SHARED``
(eg. .lib and .dll.a for static on Windows, .a for static on Unix, .dll for shared on
Windows, .so for shared on Linux). An error message occured if there is more than one
result or if no file is found. Secondly, when research is successful the `add_library(IMPORTED)``
CMake function is called and all target properties are filled. To fill in the include
header files, the variable ``INCLUDE_DIR`` must give where the files are.

.. _INCLUDE_DIRECTORIES:
.. code-block:: cmake

  dependency(INCLUDE_DIRECTORIES <lib_name> <SET|APPEND> PUBLIC <item_list>...)

Set or append interface include directories to the imported library ``<lib_name>``.
It works like the ``target_include_directories()`` CMake command
(see https://cmake.org/cmake/help/latest/command/target_include_directories.html)
but with a custom behavior for imported dependencies. PUBLIC specifies the scope
of the following arguments. These one has to use the generator expressions
``BUILD_INTERFACE`` and ``INSTALL_INTERFACE`` (see https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-specification-with-generator-expressions).

.. _IMPORTED_LOCATION:
.. code-block:: cmake

  dependency(IMPORTED_LOCATION <lib_name> [CONFIGURATION <config_type>] PUBLIC <item>...)

Set the full path to the imported library ``<lib_name>``. If a ``CONFIGURATION``
option is given (DEBUG, RELEASE, etc) then the file will only be setted for this
config type and only if it is a supported configuration. Otherwise it is setted
for all configuration supported by the imported library. PUBLIC specifies the
scope of the following arguments. These one has to use the generator expressions
``BUILD_INTERFACE`` and ``INSTALL_INTERFACE``
(see https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-specification-with-generator-expressions).

#]=======================================================================]
include_guard()

cmake_minimum_required (VERSION 3.20)
include(Directory)
include(StringManip)

#------------------------------------------------------------------------------
# Public function of this module.
function(dependency)
	set(options SHARED STATIC BUILD_TREE INSTALL_TREE SET APPEND)
	set(one_value_args IMPORT RELEASE_NAME DEBUG_NAME ROOT_DIR INCLUDE_DIR EXPORT OUTPUT_FILE INCLUDE_DIRECTORIES IMPORTED_LOCATION CONFIGURATION)
	set(multi_value_args PUBLIC)
	cmake_parse_arguments(DEP "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED DEP_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${DEP_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED DEP_IMPORT)
		_dependency_import()
	elseif(DEFINED DEP_INCLUDE_DIRECTORIES)
		_dependency_include_directories()
	elseif(DEFINED DEP_IMPORTED_LOCATION)
		_dependency_imported_location()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(_dependency_import)
	if(NOT DEFINED DEP_IMPORT)
		message(FATAL_ERROR "IMPORT argument is missing or need a value!")
	endif()
	if((NOT ${DEP_SHARED})
		AND (NOT ${DEP_STATIC}))
		message(FATAL_ERROR "SHARED|STATIC argument is missing!")
	endif()
	if(${DEP_SHARED} AND ${DEP_STATIC})
		message(FATAL_ERROR "SHARED|STATIC cannot be used together!")
	endif()
	if((NOT DEFINED DEP_RELEASE_NAME)
		AND (NOT DEFINED DEP_DEBUG_NAME))
		message(FATAL_ERROR "RELEASE_NAME|DEBUG_NAME argument is missing!")
	endif()
	if("RELEASE_NAME" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
		message(FATAL_ERROR "RELEASE_NAME need a value!")
	endif()
	if("DEBUG_NAME" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
		message(FATAL_ERROR "DEBUG_NAME need a value!")
	endif()
	if(NOT DEFINED DEP_ROOT_DIR)
		message(FATAL_ERROR "ROOT_DIR argument is missing or need a value!")
	endif()
	if(NOT DEFINED DEP_INCLUDE_DIR)
		message(FATAL_ERROR "INCLUDE_DIR argument is missing or need a value!")
	endif()
	
	if(${DEP_SHARED})
		set(library_type "SHARED")
	elseif(${DEP_STATIC})
		set(library_type "STATIC")
	else()
		message(FATAL_ERROR "Wrong library type!")
	endif()

	add_library("${DEP_IMPORT}" "${library_type}" IMPORTED)
	set_target_properties("${DEP_IMPORT}" PROPERTIES INTERFACE_INCLUDE_DIRECTORIES "${DEP_INCLUDE_DIR}") # For usage from source-tree.
	set_target_properties("${DEP_IMPORT}" PROPERTIES INTERFACE_INCLUDE_DIRECTORIES_BUILD "") # Custom property for usage from build-tree.
	set_target_properties("${DEP_IMPORT}" PROPERTIES INTERFACE_INCLUDE_DIRECTORIES_INSTALL "") # Custom property for usage from install-tree.
	if(DEFINED DEP_RELEASE_NAME)
		# Get the library file for release.
		directory(FIND_LIB lib_release
			NAME "${DEP_RELEASE_NAME}"
			"${library_type}"
			RELATIVE off
			ROOT_DIR "${DEP_ROOT_DIR}"
		)
		if(NOT lib_release)
			message(FATAL_ERROR "The release library \"${DEP_RELEASE_NAME}\" was not found!")
		endif()
		# Add library properties for release.
		get_filename_component(lib_release_name "${lib_release}" NAME)
		set_target_properties("${DEP_IMPORT}" PROPERTIES
			IMPORTED_LOCATION_RELEASE "${lib_release}" # Only for ".dll" and ".a" and ".so". For usage from source-tree.
			IMPORTED_LOCATION_BUILD_RELEASE "" # Custom property for usage from build-tree.
			IMPORTED_LOCATION_INSTALL_RELEASE "" # Custom property for usage from install-tree.
			IMPORTED_IMPLIB_RELEASE "" # Only for ".lib" and ".dll.a" (not used).
			IMPORTED_SONAME_RELEASE "${lib_release_name}"
		)
		set_property(TARGET "${DEP_IMPORT}" APPEND PROPERTY IMPORTED_CONFIGURATIONS "RELEASE")
	endif()

	if(DEFINED DEP_DEBUG_NAME)
		# Get the library file for debug.
		directory(FIND_LIB lib_debug
			NAME "${DEP_DEBUG_NAME}"
			"${library_type}"
			RELATIVE off
			ROOT_DIR "${DEP_ROOT_DIR}"
		)
		if(NOT lib_debug)
			message(FATAL_ERROR "The debug library \"${DEP_DEBUG_NAME}\" was not found!")
		endif()
		# Add library properties for debug.
		get_filename_component(lib_debug_name "${lib_debug}" NAME)
		set_target_properties("${DEP_IMPORT}" PROPERTIES
			IMPORTED_LOCATION_DEBUG "${lib_debug}" # Only for ".dll" and ".a" and ".so". For usage from source-tree.
			IMPORTED_LOCATION_BUILD_DEBUG "" # Custom property for usage from build-tree.
			IMPORTED_LOCATION_INSTALL_DEBUG "" # Custom property for usage from install-tree.
			IMPORTED_IMPLIB_DEBUG "" # Only for ".lib" and ".dll.a" (not used).
			IMPORTED_SONAME_DEBUG "${lib_debug_name}"
		)
		set_property(TARGET "${DEP_IMPORT}" APPEND PROPERTY IMPORTED_CONFIGURATIONS "DEBUG")
	endif()
endmacro()


#------------------------------------------------------------------------------
# Internal usage.
macro(_dependency_include_directories)
	if(NOT DEFINED DEP_INCLUDE_DIRECTORIES)
		message(FATAL_ERROR "INCLUDE_DIRECTORIES argument is missing or need a value!")
	endif()
	if((NOT ${DEP_SET})
		AND (NOT ${DEP_APPEND}))
		message(FATAL_ERROR "SET|APPEND argument is missing!")
	endif()
	if(${DEP_SET} AND ${DEP_APPEND})
		message(FATAL_ERROR "SET|APPEND cannot be used together!")
	endif()
	if(NOT DEFINED DEP_PUBLIC)
		OR ("PUBLIC" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
		message(FATAL_ERROR "PUBLIC argument is missing or need a value!")
	endif()

	if(NOT TARGET "${DEP_INCLUDE_DIRECTORIES}")
		message(FATAL_ERROR "The target \"${DEP_INCLUDE_DIRECTORIES}\" does not exists!")
	endif()

	string_manip(EXTRACT_INTERFACE DEP_PUBLIC BUILD OUTPUT_VARIABLE include_directories_build_interface)
	string_manip(EXTRACT_INTERFACE DEP_PUBLIC INSTALL OUTPUT_VARIABLE include_directories_install_interface)
	if(${DEP_SET})
		set_property(TARGET "${DEP_INCLUDE_DIRECTORIES}"
			PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${include_directories_build_interface}"
		)
		set_property(TARGET "${DEP_INCLUDE_DIRECTORIES}"
			PROPERTY INTERFACE_INCLUDE_DIRECTORIES_BUILD "${include_directories_build_interface}"
		)
		set_property(TARGET "${DEP_INCLUDE_DIRECTORIES}"
			PROPERTY INTERFACE_INCLUDE_DIRECTORIES_INSTALL "${include_directories_install_interface}"
		)
	elseif(${DEP_APPEND})
		set_property(TARGET "${DEP_INCLUDE_DIRECTORIES}" APPEND
			PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${include_directories_build_interface}"
		)
		set_property(TARGET "${DEP_INCLUDE_DIRECTORIES}" APPEND
			PROPERTY INTERFACE_INCLUDE_DIRECTORIES_BUILD "${include_directories_build_interface}"
		)
		set_property(TARGET "${DEP_INCLUDE_DIRECTORIES}" APPEND
			PROPERTY INTERFACE_INCLUDE_DIRECTORIES_INSTALL "${include_directories_install_interface}"
		)
	else()
		message(FATAL_ERROR "Wrong option!")
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_dependency_imported_location)
	if(NOT DEFINED DEP_IMPORTED_LOCATION)
		message(FATAL_ERROR "IMPORTED_LOCATION argument is missing or need a value!")
	endif()
	if(NOT (DEFINED DEP_CONFIGURATION)
		AND	("CONFIGURATION" IN_LIST DEP_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "CONFIGURATION argument is missing or need a value!")
	endif()
	if(NOT DEFINED DEP_PUBLIC)
		OR ("PUBLIC" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
		message(FATAL_ERROR "PUBLIC argument is missing or need a value!")
	endif()

	if(NOT TARGET "${DEP_IMPORTED_LOCATION}")
		message(FATAL_ERROR "The target \"${DEP_IMPORTED_LOCATION}\" does not exists!")
	endif()

	get_target_property(supported_config_types "${imported_library}" IMPORTED_CONFIGURATIONS)
	string_manip(EXTRACT_INTERFACE DEP_PUBLIC BUILD OUTPUT_VARIABLE imported_location_build_interface)
	string_manip(EXTRACT_INTERFACE DEP_PUBLIC INSTALL OUTPUT_VARIABLE imported_location_install_interface)
	if(DEFINED DEP_CONFIGURATION)
		if(NOT "${DEP_CONFIGURATION}" IN_LIST supported_config_types)
			message(FATAL_ERROR "The build type \"${DEP_CONFIGURATION}\" is not a supported configuration!")
		endif()
		set_target_properties("${DEP_IMPORTED_LOCATION}" PROPERTIES
			IMPORTED_LOCATION_${DEP_CONFIGURATION} "${imported_location_build_interface}"
			IMPORTED_LOCATION_BUILD_${DEP_CONFIGURATION} "${imported_location_build_interface}"
			IMPORTED_LOCATION_INSTALL_${DEP_CONFIGURATION} "${imported_location_install_interface}"
		)
	else()
		foreach(config_type IN ITEMS ${supported_config_types})
			set_target_properties("${DEP_IMPORTED_LOCATION}" PROPERTIES
				IMPORTED_LOCATION_${config_type} "${imported_location_build_interface}"
				IMPORTED_LOCATION_BUILD_${config_type} "${imported_location_build_interface}"
				IMPORTED_LOCATION_INSTALL_${config_type} "${imported_location_install_interface}"
			)
		endforeach()
	endif()
endmacro()