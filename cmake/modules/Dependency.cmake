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
    dependency(`EXPORT`_ <lib_name> <BUILD_TREE|INSTALL_TREE> [APPEND] OUTPUT_FILE <file_path>)
    dependency(`INCLUDE_DIRECTORIES`_ <lib_name> <SET|APPEND> PUBLIC <item_list>...)
    dependency(`IMPORTED_LOCATION`_ <lib_name> [CONFIGURATION <build_type>] PUBLIC <item>...)

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
(for versions), any special character, any prefixes (e.g. lib) and any suffixes (e.g. .so)
that are platform dependent. The command will loop over all file in ``ROOT_DIR`` and
try to do a matching between the ``<raw_filename>`` in format ``<CMAKE_STATIC_LIBRARY_PREFIX|
CMAKE_SHARED_LIBRARY_PREFIX><raw_filename><verions-numbers><CMAKE_STATIC_LIBRARY_SUFFIX|
CMAKE_SHARED_LIBRARY_SUFFIX>`` and each filename found striped from their numeric and
special character version and their suffix and their prefix based on the plateform and
the kind of library ``STATIC`` or ``SHARED`` (eg. .lib and .dll.a for static on
Windows, .a for static on Unix, .dll for shared on Windows, .so for shared on Linux).
An error message occured if there is more than one result or if no file is found.
Secondly, when research is successful the `add_library(IMPORTED)`` CMake function is
called and all target properties are filled. To fill in the include header files,
the variable ``INCLUDE_DIR`` must give where the files are.

.. _EXPORT:
.. code-block:: cmake

  dependency(EXPORT <lib_name> <BUILD_TREE|INSTALL_TREE> [APPEND] OUTPUT_FILE <file_path>)

Export imported library target ``<lib_name>`` from the build-tree or the install-tree
for a use by outside projects. It includes the features customized of the ``export()``
for ``BUILD_TREE`` and the ``install(EXPORT)`` and ``install(TARGETS)`` CMake commands
for ``INSTALL_TREE`` (see https://cmake.org/cmake/help/latest/command/export.html and
https://cmake.org/cmake/help/latest/command/install.html#export) for imported dependencies.
The command will create a file ``<file_path>`` that may be included by outside projects to
import targets from the current project's build-tree or install-tree. This file will be create
in ``CMAKE_CURRENT_BINARY_DIR`` for ``BUILD_TREE`` and in ``CMAKE_CURRENT_BINARY_DIR/CMakeFiles/Export"
for ``INSTALL_TREE``. If the ``APPEND`` option is given the generated code will be appended
to the file instead of overwriting it.

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
	elseif(DEFINED DEP_EXPORT)
		_dependency_export()
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
		cmake_path(GET lib_release FILENAME lib_release_name)
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
		cmake_path(GET lib_debug FILENAME lib_debug_name)
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
macro(_dependency_export)
	if(NOT DEFINED DEP_EXPORT)
		message(FATAL_ERROR "EXPORT argument is missing or need a value!")
	endif()
	if((NOT ${DEP_BUILD_TREE})
		AND (NOT ${DEP_INSTALL_TREE}))
		message(FATAL_ERROR "BUILD_TREE|INSTALL_TREE argument is missing!")
	endif()
	if(${DEP_BUILD_TREE} AND ${DEP_INSTALL_TREE})
		message(FATAL_ERROR "BUILD_TREE|INSTALL_TREE cannot be used together!")
	endif()
	if(NOT DEFINED DEP_OUTPUT_FILE)
		message(FATAL_ERROR "OUTPUT_FILE argument is missing or need a value!")
	endif()
	if(NOT TARGET "${DEP_EXPORT}")
		message(FATAL_ERROR "The target \"${DEP_EXPORT}\" does not exists!")
	endif()

	cmake_path(SET export_temp_file "${CMAKE_CURRENT_BINARY_DIR}")
	cmake_path(SET export_file "${CMAKE_CURRENT_BINARY_DIR}")
	if(${DEP_BUILD_TREE})
		cmake_path(APPEND export_temp_file "DependencyBuildTreeTemp.cmake")
	elseif(${DEP_INSTALL_TREE})
		cmake_path(APPEND export_temp_file "DependencyInstallTreeTemp.cmake")
		cmake_path(APPEND export_file "CMakeFiles" "Export")
	endif()
	cmake_path(APPEND export_file "${DEP_OUTPUT_FILE}")

	# When cmake command is call, the previous generated files has to be removed.
	if(EXISTS "${export_file}")
		file(REMOVE
			"${export_file}"
			"${export_temp_file}"
		)
	endif()
	
	set(import_instructions "")
	if((EXISTS "${export_temp_file}") AND (NOT ${DEP_APPEND}))
		message(FATAL_ERROR "Export command already specified for the file \"${export_file}\". Did you miss 'APPEND' keyword?")
	endif()
	if(NOT EXISTS "${export_temp_file}")
		# Ouptut file will be generated only one time after processing all of a project's CMakeLists.txt files.
		file(GENERATE OUTPUT "${export_file}" 
			INPUT "${export_temp_file}"
			TARGET "${DEP_EXPORT}"
		)
		if(${DEP_INSTALL_TREE})
			cmake_path(GET DEP_OUTPUT_FILE PARENT_PATH install_export_dir)
			install(FILES "${export_file}"
				DESTINATION "${install_export_dir}"
			)
		endif()
		_export_generate_header_code()
	endif()

	if(${DEP_BUILD_TREE})
		_export_generate_build_tree()
	elseif(${DEP_INSTALL_TREE})
		_export_generate_install_tree()
	endif()
	_export_generate_footer_code()
	
	file(APPEND "${export_temp_file}" "${import_instructions}")
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_export_generate_build_tree)
	# Create the imported target.
	get_target_property(target_type "${DEP_EXPORT}" TYPE)
  	string(APPEND import_instructions "# Create imported target \"$<TARGET_PROPERTY:NAME>\"\n")
	if("${target_type}" STREQUAL "STATIC_LIBRARY")
		string(APPEND import_instructions "add_library(\"$<TARGET_PROPERTY:NAME>\" STATIC IMPORTED)\n")
	elseif("${target_type}" STREQUAL "SHARED_LIBRARY")
		string(APPEND import_instructions "add_library(\"$<TARGET_PROPERTY:NAME>\" SHARED IMPORTED)\n")
	else()
		message(FATAL_ERROR "Target type \"${target_type}\" is unsupported by export command!")
	endif()

	# Add usage requirements.
	string(APPEND import_instructions "\n")
	string(APPEND import_instructions "set_target_properties(\"$<TARGET_PROPERTY:NAME>\" PROPERTIES\n")
	string(APPEND import_instructions "  INTERFACE_INCLUDE_DIRECTORIES \"$<TARGET_PROPERTY:INTERFACE_INCLUDE_DIRECTORIES_BUILD>\"\n")
	string(APPEND import_instructions "  IMPORTED_LOCATION_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_LOCATION_BUILD_$<CONFIG>>\"\n")
	string(APPEND import_instructions "  IMPORTED_IMPLIB_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_IMPLIB_$<CONFIG>>\"\n")
	string(APPEND import_instructions "  IMPORTED_SONAME_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_SONAME_$<CONFIG>>\"\n")
	string(APPEND import_instructions ")\n")
	string(APPEND import_instructions "set_property(TARGET \"$<TARGET_PROPERTY:NAME>\" APPEND PROPERTY IMPORTED_CONFIGURATIONS \"$<CONFIG>\")\n")
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_export_generate_install_tree)
	# Add code to compute the installation prefix relative to the import file location.
	string(APPEND import_instructions "# Compute the installation prefix relative to this file.\n")
	string(APPEND import_instructions "get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)\n")
	set(import_prefix "${install_export_dir}")
	while((NOT "${import_prefix}" STREQUAL "${CMAKE_INSTALL_PREFIX}")
		AND (NOT "${import_prefix}" STREQUAL ""))
		string(APPEND import_instructions "get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)\n")
		cmake_path(GET import_prefix PARENT_PATH import_prefix)
	endwhile()
	string(APPEND import_instructions "if(_IMPORT_PREFIX STREQUAL \"/\")\n")
	string(APPEND import_instructions "  set(_IMPORT_PREFIX \"\")\n")
	string(APPEND import_instructions "endif()\n")
	string(APPEND import_instructions "\n")

	# Create the imported target.
	get_target_property(target_type "${DEP_EXPORT}" TYPE)
  	string(APPEND import_instructions "# Create imported target \"$<TARGET_PROPERTY:NAME>\"\n")
	if("${target_type}" STREQUAL "STATIC_LIBRARY")
		string(APPEND import_instructions "add_library(\"$<TARGET_PROPERTY:NAME>\" STATIC IMPORTED)\n")
	elseif("${target_type}" STREQUAL "SHARED_LIBRARY")
		string(APPEND import_instructions "add_library(\"$<TARGET_PROPERTY:NAME>\" SHARED IMPORTED)\n")
	else()
		message(FATAL_ERROR "Target type \"${target_type}\" is unsupported by export command!")
	endif()

	# Add usage requirements.
	string(APPEND import_instructions "\n")
	string(APPEND import_instructions "set_target_properties(\"$<TARGET_PROPERTY:NAME>\" PROPERTIES\n")
	string(APPEND import_instructions "  INTERFACE_INCLUDE_DIRECTORIES \"\${_IMPORT_PREFIX}/$<TARGET_PROPERTY:INTERFACE_INCLUDE_DIRECTORIES_INSTALL>\"\n")
	string(APPEND import_instructions "  IMPORTED_LOCATION_$<CONFIG> \"\${_IMPORT_PREFIX}/$<TARGET_PROPERTY:IMPORTED_LOCATION_INSTALL_$<CONFIG>>\"\n")
	string(APPEND import_instructions "  IMPORTED_IMPLIB_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_IMPLIB_$<CONFIG>>\"\n")
	string(APPEND import_instructions "  IMPORTED_SONAME_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_SONAME_$<CONFIG>>\"\n")
	string(APPEND import_instructions ")\n")
	string(APPEND import_instructions "set_property(TARGET \"$<TARGET_PROPERTY:NAME>\" APPEND PROPERTY IMPORTED_CONFIGURATIONS \"$<CONFIG>\")\n")
	string(APPEND import_instructions "\n")
	
	# Cleanup temporary variables.
	string(APPEND import_instructions "# Cleanup temporary variables.\n")
	string(APPEND import_instructions "unset(_IMPORT_PREFIX)\n")
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_export_generate_header_code)
	string(APPEND import_instructions "# Generated by the \"${PROJECT_NAME}\" project \n")
	string(APPEND import_instructions "\n")
	string(APPEND import_instructions "#----------------------------------------------------------------\n")
	string(APPEND import_instructions "# Generated CMake target import file for internal libraries.\n")
	string(APPEND import_instructions "#----------------------------------------------------------------\n")
	string(APPEND import_instructions "\n")
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_export_generate_footer_code)
	string(APPEND import_instructions "#----------------------------------------------------------------\n")
	string(APPEND import_instructions "\n")
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
	if("CONFIGURATION" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
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