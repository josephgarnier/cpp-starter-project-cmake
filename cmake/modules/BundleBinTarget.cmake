# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

BinTarget
---------
Operations to fully create and configure a binary target. It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    `reset_local_bin_target_settings`_()
    `add_bin_target`_(TARGET_NAME <target_name> <STATIC|SHARED|HEADER|EXEC>)
    `configure_bin_target_settings`_(TARGET_NAME <target_name> COMPILE_DEFINITIONS <definition_list>...)
    `collect_source_files_by_location`_([SRC_DIR <directory_path> SRC_SOURCE_FILES <output_list_var> SRC_HEADER_FILES <output_list_var>]|[INCLUDE_DIR <directory_path> INCLUDE_HEADER_FILES <output_list_var>])
    `collect_source_files_by_policy`_(PUBLIC_HEADERS_SEPARATED <on|off> [<include_directory_path>] SRC_DIR <directory_path> SRC_SOURCE_FILES <output_list_var> PUBLIC_HEADER_DIR <output_var> PUBLIC_HEADER_FILES <output_list_var> PRIVATE_HEADER_DIR <output_var> PRIVATE_HEADER_FILES <output_list_var>)
    `add_sources_to_target`_(TARGET_NAME <target_name> SOURCE_FILES <file_path_list>... PRIVATE_HEADER_FILES <file_path_list>... PUBLIC_HEADER_FILES <file_path_list>... PROJECT_DIR <directory_path>)
    `add_precompiled_header_to_target`_(TARGET_NAME <target_name> HEADER_FILE <file_path>)
    `add_include_directories_to_target`_(TARGET_NAME <target_name> INCLUDE_DIRECTORIES <directory_path_list>...)

Usage
^^^^^
.. reset_local_bin_target_settings:
.. code-block:: cmake

  reset_local_bin_target_settings()

Reset all settings of the binary target currently under construction.

.. _add_bin_target:
.. code-block:: cmake

  add_bin_target(TARGET_NAME <target_name> <STATIC|SHARED|HEADER|EXEC>)

Add a binary target ``<target_name>`` to the project as type ``STATIC``, ``SHARED``, ``HEADER`` or ``EXEC``.

.. _configure_bin_target_settings:
.. code-block:: cmake

  configure_bin_target_settings(TARGET_NAME <target_name> COMPILE_DEFINITIONS [<definition_list>...])

Configure the binary target ``<target_name>``: add it in a folder for IDE project, set compile features (C++ standard), set compile definitions, set compile options, add link options

.. _collect_source_files_by_location:
.. code-block:: cmake

  collect_source_files_by_location([SRC_DIR <directory_path> SRC_SOURCE_FILES <output_list_var> SRC_HEADER_FILES <output_list_var>]|[INCLUDE_DIR <directory_path> INCLUDE_HEADER_FILES <output_list_var>])

Generates lists of source files (e.g. ".cpp") and header files (e.g. ".h") found in the specified directories by ``SRC_DIR`` and ``INCLUDE_DIR``, and store them into each ``<output_list_var>`` variable.

* If ``SRC_DIR`` is provided, the function searches for source and header files in the given directory:
    * Source files are stored in ``SRC_SOURCE_FILES``.
    * Header files are stored in ``SRC_HEADER_FILES``.

If ``INCLUDE_DIR`` is provided, the function searches for header files in the specified directory:
    * Header files are stored in ``INCLUDE_HEADER_FILES``.

Both ``SRC_DIR`` and ``INCLUDE_DIR`` may be used together. In that case, files are collected from both locations into their respective output variables.

At least one of ``SRC_DIR`` or ``INCLUDE_DIR`` must be specified. If neither is provided, or if their corresponding output variables are missing, an error is raised.

.. _collect_source_files_by_policy:
.. code-block:: cmake

  collect_source_files_by_policy(PUBLIC_HEADERS_SEPARATED <on|off> [<include_directory_path>] SRC_DIR <directory_path> SRC_SOURCE_FILES <output_list_var> PUBLIC_HEADER_DIR <output_var> PUBLIC_HEADER_FILES <output_list_var> PRIVATE_HEADER_DIR <output_var> PRIVATE_HEADER_FILES <output_list_var>)

Collects source (e.g., ``.cpp``) and header (e.g. ``.h``) files from specified directories, applying a policy (``PUBLIC_HEADERS_SEPARATED```value) that determines how public and private headers are handled.

This function generates a list of all source files (e.g.,``.cpp``) in the directory specified by ``SRC_DIR`` and stores the list into ``SRC_SOURCE_FILES``. The source file collection is not affected by the PUBLIC_HEADERS_SEPARATED policy.

Header file handling depends on the value of ``PUBLIC_HEADERS_SEPARATED``:

* If ``PUBLIC_HEADERS_SEPARATED`` is set to ``on``, public and private headers are considered to be in separate directories:
    * Public headers are expected to reside in ``<include_directory_path>``, typically a subdirectory of ``include/``. These files are stored in ``PUBLIC_HEADER_FILES``, and ``PUBLIC_HEADER_DIR`` is set to ``<include_directory_path>``.
    * Private headers are searched in ``SRC_DIR``. These files are stored in ``PRIVATE_HEADER_FILES``, and ``PRIVATE_HEADER_DIR`` is set to ``SRC_DIR``.
* If ``PUBLIC_HEADERS_SEPARATED`` is set to ``off``, all headers are treated as public and are expected to reside in ``SRC_DIR``:
    * The function searches ``SRC_DIR`` for header files, stores them in ``PUBLIC_HEADER_FILES``, and sets ``PUBLIC_HEADER_DIR`` to ``SRC_DIR``.
    * In this mode, ``<include_directory_path>`` is ignored, and ``PRIVATE_HEADER_FILES`` and ``PRIVATE_HEADER_DIR`` are set to empty.

An error is raised if ``PUBLIC_HEADERS_SEPARATED`` is ``on`` but ``<include_directory_path>`` is either empty or not exists.

.. _add_sources_to_target:
.. code-block:: cmake

  add_sources_to_target(TARGET_NAME <target_name> SOURCE_FILES <file_path_list>... PRIVATE_HEADER_FILES <file_path_list>... PUBLIC_HEADER_FILES <file_path_list>... PROJECT_DIR <directory_path>)

Assign sources of ``SOURCE_FILES``, ``PRIVATE_HEADER_FILES`` and headers of ``PUBLIC_HEADER_FILES`` to the target ``<target_name>``, and define a grouping for source files in IDE project generation in ``PROJECT_DIR``.

.. _add_precompiled_header_to_target:
.. code-block:: cmake

  add_precompiled_header_to_target(TARGET_NAME <target_name> HEADER_FILE <file_path>)
  
Add a precompiled header file ``<file_path>`` to the target ``<target_name>``.

.. _add_include_directories_to_target:
.. code-block:: cmake

  add_include_directories_to_target(TARGET_NAME <target_name> INCLUDE_DIRECTORIES <directory_path_list>...)

Add include directories ``<directory_path_list>`` to the target ``<target_name>``.

#]=======================================================================]
include_guard()

cmake_minimum_required (VERSION 3.20)

#------------------------------------------------------------------------------
# Public function of this module
macro(reset_local_bin_target_settings)
	unset(PARAM_BIN_TARGET_NAME)
	unset(PARAM_BIN_TARGET_TYPE)
	unset(PARAM_COMPILE_DEFINITIONS)
	unset(PARAM_PUBLIC_HEADERS_SEPARATED)
	unset(PARAM_PUBLIC_HEADERS_DIR)
	unset(PARAM_MAIN_FILE)
	unset(PARAM_USE_PRECOMPILED_HEADER)
	unset(PARAM_PRECOMPILED_FILE)
endmacro()

#------------------------------------------------------------------------------
# Public function of this module
function(add_bin_target)
	set(options STATIC SHARED HEADER EXEC)
	set(one_value_args TARGET_NAME)
	set(multi_value_args "")
	cmake_parse_arguments(arg "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED arg_TARGET_NAME)
		message(FATAL_ERROR "TARGET_NAME arguments is missing!")
	endif()
	if(TARGET "${arg_TARGET_NAME}")
		message(FATAL_ERROR "The target \"${arg_TARGET_NAME}\" already exists!")
	endif()
	if((NOT ${arg_STATIC})
		AND (NOT ${arg_SHARED})
		AND (NOT ${arg_HEADER})
		AND (NOT ${arg_EXEC}))
		message(FATAL_ERROR "STATIC|SHARED|HEADER|EXEC arguments is missing!")
	endif()
	if(${arg_STATIC}
		AND ${arg_SHARED}
		AND ${arg_HEADER}
		AND ${arg_EXEC})
		message(FATAL_ERROR "STATIC|SHARED|HEADER|EXEC cannot be used together!")
	endif()

	if(${arg_STATIC})
		add_library("${arg_TARGET_NAME}" STATIC)
		message(STATUS "Static library target added to project")
	elseif(${arg_SHARED})
		# All libraries will be built shared unless the library was explicitly added as a static library
		set(BUILD_SHARED_LIBS                           on)
		message(STATUS "All exported symbols are hidden by default")
		set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS            off)
		set(CMAKE_CXX_VISIBILITY_PRESET                 "hidden")
		set(CMAKE_VISIBILITY_INLINES_HIDDEN             on)
		add_library("${arg_TARGET_NAME}" SHARED)
		message(STATUS "Shared library target added to project")
	elseif(${arg_HEADER})
		add_library("${arg_TARGET_NAME}" INTERFACE)
		message(STATUS "Header-only library target added to project")
	elseif(${arg_EXEC})
		add_executable("${arg_TARGET_NAME}")
		message(STATUS "Executable target added to project")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Public function of this module
function(configure_bin_target_settings)
	set(options "")
	set(one_value_args TARGET_NAME)
	set(multi_value_args COMPILE_DEFINITIONS)
	cmake_parse_arguments(arg "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED arg_TARGET_NAME)
		message(FATAL_ERROR "TARGET_NAME arguments is missing!")
	endif()
	if(NOT TARGET "${arg_TARGET_NAME}")
		message(FATAL_ERROR "The target \"${arg_TARGET_NAME}\" does not exists!")
	endif()
	if((NOT DEFINED arg_COMPILE_DEFINITIONS)
		AND (NOT "COMPILE_DEFINITIONS" IN_LIST arg_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "COMPILE_DEFINITIONS arguments is missing!")
	endif()

	# Add the bin target in a folder for IDE project
	set_target_properties("${arg_TARGET_NAME}" PROPERTIES FOLDER "")

	# Set compile features (C++ standard)
	target_compile_features("${arg_TARGET_NAME}"
		PRIVATE
			"cxx_std_${CMAKE_CXX_STANDARD}"
	)
	message(STATUS "C++ standard set to: C++${CMAKE_CXX_STANDARD}")

	# Set compile definitions
	target_compile_definitions("${arg_TARGET_NAME}"
		PRIVATE
			"${arg_COMPILE_DEFINITIONS}"
	)
	message(STATUS "Applied compile definitions: ${arg_COMPILE_DEFINITIONS}")

	# Set compile options
	target_compile_options("${arg_TARGET_NAME}"
		PRIVATE
			""
	)
	message(STATUS "Applied compile options: (none)")

	# Add link options
	target_link_options("${arg_TARGET_NAME}"
		PRIVATE
			""
	)
	message(STATUS "Applied link options: (none)")
endfunction()

#  [SRC_DIR <directory_path> SRC_SOURCE_FILES <output_list_var> SRC_HEADER_FILES <output_list_var>]|[INCLUDE_DIR <directory_path> INCLUDE_HEADER_FILES <output_list_var>]

#------------------------------------------------------------------------------
# Public function of this module
function(collect_source_files_by_location)
	set(options "")
	set(one_value_args SRC_DIR INCLUDE_DIR SRC_SOURCE_FILES SRC_HEADER_FILES INCLUDE_HEADER_FILES)
	set(multi_value_args "")
	cmake_parse_arguments(arg "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
	endif()
	if((NOT DEFINED arg_SRC_DIR) AND (NOT DEFINED arg_INCLUDE_DIR))
		message(FATAL_ERROR "At least one of SRC_DIR|INCLUDE_DIR argument is needed!")
	endif()
	if("SRC_DIR" IN_LIST arg_KEYWORDS_MISSING_VALUES)
		message(FATAL_ERROR "SRC_DIR need a value!")
	endif()
	if("INCLUDE_DIR" IN_LIST arg_KEYWORDS_MISSING_VALUES)
		message(FATAL_ERROR "INCLUDE_DIR need a value!")
	endif()

	# Check errors
	if(DEFINED arg_SRC_DIR)
		if(NOT DEFINED arg_SRC_SOURCE_FILES)
			message(FATAL_ERROR "SRC_SOURCE_FILES arguments is missing!")
		endif()
		if(NOT DEFINED arg_SRC_HEADER_FILES)
			message(FATAL_ERROR "SRC_HEADER_FILES arguments is missing!")
		endif()
	endif()
	if(DEFINED arg_INCLUDE_DIR)
		if(NOT DEFINED arg_INCLUDE_HEADER_FILES)
			message(FATAL_ERROR "INCLUDE_HEADER_FILES arguments is missing!")
		endif()
	endif()
	
	# Get files
	set(${arg_SRC_SOURCE_FILES} "" PARENT_SCOPE)
	set(${arg_SRC_HEADER_FILES} "" PARENT_SCOPE)
	set(${arg_INCLUDE_HEADER_FILES} "" PARENT_SCOPE)
	if(DEFINED arg_SRC_DIR)
		# Get the list of absolute paths to source files (.cpp) that are
		# inside `SRC_DIR` directory
		set(src_source_file_list "")
		directory(SCAN src_source_file_list
			LIST_DIRECTORIES off
			RELATIVE off
			ROOT_DIR "${arg_SRC_DIR}"
			INCLUDE_REGEX ".*[.]cpp$|.*[.]cc$|.*[.]cxx$"
		)
		set(${arg_SRC_SOURCE_FILES} "${src_source_file_list}" PARENT_SCOPE)

		# Get the list of absolute path to header files (.h) that are
		# inside `SRC_DIR` directory
		set(src_header_file_list "")
		directory(SCAN src_header_file_list
			LIST_DIRECTORIES off
			RELATIVE off
			ROOT_DIR "${arg_SRC_DIR}"
			INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$|.*[.]tpp$"
		)
		set(${arg_SRC_HEADER_FILES} "${src_header_file_list}" PARENT_SCOPE)
	endif()
	
	if(DEFINED arg_INCLUDE_DIR)
		# Get the list of absolute path to header files (.h) that are
		# inside `INCLUDE_DIR` directory
		set(include_header_file_list "")
		directory(SCAN include_header_file_list
			LIST_DIRECTORIES off
			RELATIVE off
			ROOT_DIR "${arg_INCLUDE_DIR}"
			INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$|.*[.]tpp$"
		)
		set(${arg_INCLUDE_HEADER_FILES} "${include_header_file_list}" PARENT_SCOPE)
	endif()
endfunction()

#------------------------------------------------------------------------------
# Public function of this module
function(collect_source_files_by_policy)
	set(options "")
	set(one_value_args SRC_DIR SRC_SOURCE_FILES PUBLIC_HEADER_DIR PUBLIC_HEADER_FILES PRIVATE_HEADER_DIR PRIVATE_HEADER_FILES)
	set(multi_value_args PUBLIC_HEADERS_SEPARATED)
	cmake_parse_arguments(arg "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED arg_SRC_DIR)
		message(FATAL_ERROR "SRC_DIR arguments is missing!")
	endif()
	if(NOT DEFINED arg_SRC_SOURCE_FILES)
		message(FATAL_ERROR "SRC_SOURCE_FILES arguments is missing!")
	endif()
	if(NOT DEFINED arg_PUBLIC_HEADER_DIR)
		message(FATAL_ERROR "PUBLIC_HEADER_DIR arguments is missing!")
	endif()
	if(NOT DEFINED arg_PUBLIC_HEADER_FILES)
		message(FATAL_ERROR "PUBLIC_HEADER_FILES arguments is missing!")
	endif()
	if(NOT DEFINED arg_PRIVATE_HEADER_DIR)
		message(FATAL_ERROR "PRIVATE_HEADER_DIR arguments is missing!")
	endif()
	if(NOT DEFINED arg_PRIVATE_HEADER_FILES)
		message(FATAL_ERROR "PRIVATE_HEADER_FILES arguments is missing!")
	endif()
	if(NOT DEFINED arg_PUBLIC_HEADERS_SEPARATED)
		message(FATAL_ERROR "PUBLIC_HEADERS_SEPARATED arguments is missing!")
	endif()
	
	# Check errors
	list(GET arg_PUBLIC_HEADERS_SEPARATED 0 is_headers_separated)
	if((NOT ${is_headers_separated} STREQUAL "on")
		AND (NOT ${is_headers_separated} STREQUAL "off"))
		message(FATAL_ERROR "PUBLIC_HEADERS_SEPARATED arguments is wrong!")
	endif()
	if(${is_headers_separated})
		# Check if the PUBLIC_HEADERS_SEPARATED argument is well formatted
		list(LENGTH arg_PUBLIC_HEADERS_SEPARATED nb_args_PUBLIC_HEADERS_SEPARATED)
		if(NOT ${nb_args_PUBLIC_HEADERS_SEPARATED} EQUAL 2)
			message(FATAL_ERROR "PUBLIC_HEADERS_SEPARATED argument is missing or wrong!")
		endif()
		
		# Check if the include directory exists
		list(GET arg_PUBLIC_HEADERS_SEPARATED 1 include_directory_path)
		if(NOT IS_DIRECTORY "${include_directory_path}")
			message(FATAL_ERROR "\"${include_directory_path}\" directory missing while public headers separation is active (\"PARAM_PUBLIC_HEADERS_SEPARATED\" is set with on)!")
		endif()
	endif()
	
	# Collect files
	if(${is_headers_separated})
		collect_source_files_by_location(
			SRC_DIR "${arg_SRC_DIR}"
			SRC_SOURCE_FILES src_source_file_list
			SRC_HEADER_FILES src_header_file_list
			INCLUDE_DIR "${include_directory_path}"
			INCLUDE_HEADER_FILES include_header_file_list
		)
		set(${arg_SRC_SOURCE_FILES} "${src_source_file_list}" PARENT_SCOPE)
		set(${arg_PUBLIC_HEADER_DIR} "${include_directory_path}" PARENT_SCOPE)
		set(${arg_PUBLIC_HEADER_FILES} "${include_header_file_list}" PARENT_SCOPE)
		set(${arg_PRIVATE_HEADER_DIR} "${arg_SRC_DIR}" PARENT_SCOPE)
		set(${arg_PRIVATE_HEADER_FILES} "${src_header_file_list}" PARENT_SCOPE)
		message(STATUS "Considering headers from \"include/\" as public and from \"src/\" as private")
	else()
		collect_source_files_by_location(
			SRC_DIR "${arg_SRC_DIR}"
			SRC_SOURCE_FILES src_source_file_list
			SRC_HEADER_FILES src_header_file_list
		)
		set(${arg_SRC_SOURCE_FILES} "${src_source_file_list}" PARENT_SCOPE)
		set(${arg_PUBLIC_HEADER_DIR} "${arg_SRC_DIR}" PARENT_SCOPE)
		set(${arg_PUBLIC_HEADER_FILES} "${src_header_file_list}" PARENT_SCOPE)
		set(${arg_PRIVATE_HEADER_DIR} "" PARENT_SCOPE)
		set(${arg_PRIVATE_HEADER_FILES} "" PARENT_SCOPE)
		message(STATUS "Considering headers from \"src/\" as public, ignoring \"include/\"")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Public function of this module
function(add_sources_to_target)
	set(options "")
	set(one_value_args TARGET_NAME PROJECT_DIR)
	set(multi_value_args SOURCE_FILES PRIVATE_HEADER_FILES PUBLIC_HEADER_FILES)
	cmake_parse_arguments(arg "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED arg_TARGET_NAME)
		message(FATAL_ERROR "TARGET_NAME arguments is missing!")
	endif()
	if(NOT TARGET "${arg_TARGET_NAME}")
		message(FATAL_ERROR "The target \"${arg_TARGET_NAME}\" does not exists!")
	endif()
	if((NOT DEFINED arg_SOURCE_FILES)
		AND (NOT "SOURCE_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "SOURCE_FILES arguments is missing!")
	endif()
	if((NOT DEFINED arg_PRIVATE_HEADER_FILES)
		AND (NOT "PRIVATE_HEADER_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "PRIVATE_HEADER_FILES arguments is missing!")
	endif()
	if((NOT DEFINED arg_PUBLIC_HEADER_FILES)
		AND (NOT "PUBLIC_HEADER_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "PUBLIC_HEADER_FILES arguments is missing!")
	endif()
	if(NOT DEFINED arg_PROJECT_DIR)
		message(FATAL_ERROR "PROJECT_DIR arguments is missing!")
	endif()

	message(STATUS "Assigning sources and headers to the target")
	target_sources("${arg_TARGET_NAME}"
		PRIVATE
			"${arg_SOURCE_FILES}"
			"${arg_PRIVATE_HEADER_FILES}"
			"${arg_PUBLIC_HEADER_FILES}"
	)
	message(STATUS "Organizing files according to the project tree")
	source_group(TREE "${arg_PROJECT_DIR}"
		FILES
			${arg_SOURCE_FILES}
			${arg_PRIVATE_HEADER_FILES}
			${arg_PUBLIC_HEADER_FILES}
	)
endfunction()

#------------------------------------------------------------------------------
# Public function of this module
function(add_precompiled_header_to_target)
	set(options "")
	set(one_value_args TARGET_NAME HEADER_FILE)
	set(multi_value_args "")
	cmake_parse_arguments(arg "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED arg_TARGET_NAME)
		message(FATAL_ERROR "TARGET_NAME arguments is missing!")
	endif()
	if(NOT TARGET "${arg_TARGET_NAME}")
		message(FATAL_ERROR "The target \"${arg_TARGET_NAME}\" does not exists!")
	endif()
	if(NOT DEFINED arg_HEADER_FILE)
		message(FATAL_ERROR "HEADER_FILE arguments is missing!")
	endif()
	if(NOT EXISTS "${arg_HEADER_FILE}")
		message(FATAL_ERROR "Precompiled header file \"${arg_HEADER_FILE}\" does not exist!")
	endif()

	target_precompile_headers("${arg_TARGET_NAME}"
		PRIVATE
			"${arg_HEADER_FILE}"
	)
endfunction()

#------------------------------------------------------------------------------
# Public function of this module
function(add_include_directories_to_target)
	set(options "")
	set(one_value_args TARGET_NAME)
	set(multi_value_args INCLUDE_DIRECTORIES)
	cmake_parse_arguments(arg "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED arg_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED arg_TARGET_NAME)
		message(FATAL_ERROR "TARGET_NAME arguments is missing!")
	endif()
	if(NOT TARGET "${arg_TARGET_NAME}")
		message(FATAL_ERROR "The target \"${arg_TARGET_NAME}\" does not exists!")
	endif()
	if((NOT DEFINED arg_INCLUDE_DIRECTORIES)
		AND (NOT "INCLUDE_DIRECTORIES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "INCLUDE_DIRECTORIES arguments is missing!")
	endif()

	target_include_directories("${arg_TARGET_NAME}"
		# @see https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-specification-and-usage-requirements
		# and https://stackoverflow.com/questions/26243169/cmake-target-include-directories-meaning-of-scope
		# and https://cmake.org/pipermail/cmake/2017-October/066457.html.
		# If PRIVATE is specified for a certain option/property, then that option/property will only impact
		# the current target. If PUBLIC is specified, then the option/property impacts both the current
		# target and any others that link to it. If INTERFACE is specified, then the option/property does
		# not impact the current target but will propagate to other targets that link to it.
		PRIVATE
			"${arg_INCLUDE_DIRECTORIES}"
	)
endfunction()


