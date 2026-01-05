# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Debug
-----

Operations for helping with debug, inspired by :cmake:module:`CMakePrintHelpers <cmake:module:CMakePrintHelpers>` module. It requires CMake 4.0.1 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

    debug(`DUMP_TARGETS`_ <root-dir>)
    debug(`DUMP_VARIABLES`_ [<INCLUDE_REGEX|EXCLUDE_REGEX> <regular-expression>])
    debug(`DUMP_PROPERTIES`_ [])
    debug(`DUMP_TARGET_PROPERTIES`_ <target-name>)

Usage
^^^^^

.. signature::
  debug(DUMP_TARGETS <root-dir>)

  Print all buildsystem and imported targets defined in the given directory
  ``<root-dir>`` and its subdirectories. The output displays each target
  prefixed by its relative directory path from
  :cmake:variable:`CMAKE_SOURCE_DIR <cmake:variable:CMAKE_SOURCE_DIR>`.

  Example usage:

  .. code-block:: cmake

    debug(DUMP_TARGETS "${CMAKE_SOURCE_DIR}")
    # Output:
    #   --
    #    Targets in the project:
    #      [][Buildsystem] Experimental
    #      [][Buildsystem] Nightly
    #   ...
    #      [tests/data][Buildsystem] static_mock_lib
    #      [tests/data][Buildsystem] shared_mock_lib
    #      [doc][Buildsystem] doc
    #      [src][Imported   ] Qt6::Platform

.. signature::
  debug(DUMP_VARIABLES [<INCLUDE_REGEX|EXCLUDE_REGEX> <regular-expression>])

  Print the list of all currently defined CMake variables and their values,
  useful for debugging and inspecting project scope variables. The output is
  sorted alphabetically and contains no duplicates.

  If ``INCLUDE_REGEX`` is provided, only variables whose names match the given
  regular expression are printed. If ``EXCLUDE_REGEX`` is provided, variables
  whose names match the given expression are omitted from the output.

  Example usage:

  .. code-block:: cmake

    debug(DUMP_VARIABLES)
    # Output:
    #   --
    #    Variables of CMake:
    #      BUILD_SHARED_LIBS = "ON"
    #      CMAKE_CURRENT_SOURCE_DIR = "/home/user/project/src"
    #      CMAKE_VERSION = "3.28.3"
    #      PROJECT_NAME = "MyProject"
    #   ...

    debug(DUMP_VARIABLES INCLUDE_REGEX "^PROJECT_")
    # Output:
    #   --
    #    Variables of CMake:
    #   ...
    #      PROJECT_IS_TOP_LEVEL = "ON"
    #      PROJECT_NAME = "MyProject"
    #   ...

    debug(DUMP_VARIABLES EXCLUDE_REGEX "^CMAKE_")
    # Output:
    #   --
    #    Variables of CMake:
    #      BUILD_SHARED_LIBS = "ON"
    #      PROJECT_NAME = "MyProject"
    #   ...

.. signature::
  debug(DUMP_PROPERTIES [])

  Display all CMake properties available in the current version of CMake.

  This command executes the equivalent of :cmake:option:`cmake.--help-property-list`
  and prints each property name using :cmake:command:`message() <cmake:command:message()>`. The output
  is sorted alphabetically.

  It provides a quick reference for all built-in CMake properties, including
  those related to targets, directories, sources, tests, cache entries, and
  more.

  This command does not inspect actual property values but rather enumerates
  all recognized property names in the CMake environment.

  Example usage:

  .. code-block:: cmake

    debug(DUMP_PROPERTIES)
    # Output:
    #   --
    #    Properties of CMake:
    #      ADDITIONAL_CLEAN_FILES
    #      ALIAS_GLOBAL
    #      ANDROID_API
    #      ARCHIVE_OUTPUT_DIRECTORY
    #      AUTOMOC
    #   ...

.. signature::
  debug(DUMP_TARGET_PROPERTIES <target-name>)

  Display all defined CMake properties of the given target ``<target-name>``.

  This command enumerates all known target properties supported by CMake,
  including custom properties specific to the project. For each property set
  on the target, its value is printed using :cmake:command:`message() <cmake:command:message()>`.

  Configuration-specific properties such as :cmake:prop_tgt:`IMPORTED_LOCATION_<CONFIG> <cmake:prop_tgt:IMPORTED_LOCATION_<CONFIG>>`
  or ``INTERFACE_INCLUDE_DIRECTORIES_<CONFIG>`` (a custom property used by :module:`Dependency` module) are
  expanded for ``DEBUG`` and ``RELEASE`` configurations. Internal properties
  like :cmake:prop_tgt:`LOCATION <cmake:prop_tgt:LOCATION>` and those
  known to trigger errors on access are excluded from the output.

  Example usage:

  .. code-block:: cmake

    debug(DUMP_TARGET_PROPERTIES my_library)
    # Output:
    #   --
    #    Properties for TARGET my_library:
    #      my_library.TYPE = "STATIC_LIBRARY"
    #      my_library.SOURCES = "src/a.cpp;src/b.cpp"
    #      my_library.INTERFACE_INCLUDE_DIRECTORIES = "include"
    #      ...

Additional commands
^^^^^^^^^^^^^^^^^^^

CMake provides convenience commands, primarily intended for debugging, to
print various information about the CMake environment.

* Printing the values of properties for the specified targets, source files,
  directories, tests, or cache entries:

  .. code-block:: cmake

    include(CMakePrintHelpers)
    cmake_print_properties(<[TARGETS <target-name>...] |
                          [SOURCES <file-path>...] |
                          [DIRECTORIES <dir-path>...] |
                          [TESTS <test-name>...] |
                          [CACHE_ENTRIES <entry-name>...]>
                          PROPERTIES <property-name>...
    )

  Check `the documentation <https://cmake.org/cmake/help/latest/module/CMakePrintHelpers.html>`__ for more informations.

* Printing each variable name followed by its value:

  .. code-block:: cmake

    include(CMakePrintHelpers)
    cmake_print_variables(<var>...)

  Check `the documentation <https://cmake.org/cmake/help/latest/module/CMakePrintHelpers.html>`__ for more informations.

* Printing system information and various internal CMake variables for
  diagnostics:

  .. code-block:: cmake

    include(CMakePrintSystemInformation)

  Check `the documentation <https://cmake.org/cmake/help/latest/module/CMakePrintSystemInformation.html>`__ for more informations.

* Print a dependency graph of the targets:

  .. code-block:: cmake

    set_property(GLOBAL PROPERTY GLOBAL_DEPENDS_DEBUG_MODE 1)

  Check `the documentation <https://cmake.org/cmake/help/latest/prop_gbl/GLOBAL_DEPENDS_DEBUG_MODE.html>`__ for more informations.

* Since generator expressions are evaluated during generation of the
  buildsystem, and not during processing of ``CMakeLists.txt`` files, this
  command allows to interpret a generator expression:

  .. code-block:: cmake

    file(GENERATE OUTPUT debug.txt CONTENT "$<...>")

  Check `the documentation <https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#debugging>`__ for more informations.

* Watch a CMake variable for change:

  .. code-block:: cmake

    variable_watch(CMAKE_CXX_STANDARD)

  Check `the documentation <https://cmake.org/cmake/help/latest/command/variable_watch.html>`__ for more informations.

* Debugging facility to print the origin of the contents of properties which
  may be determined by dependencies:

  .. code-block:: cmake

    set(CMAKE_DEBUG_TARGET_PROPERTIES
      INCLUDE_DIRECTORIES
      COMPILE_DEFINITIONS
      POSITION_INDEPENDENT_CODE
      CONTAINER_SIZE_REQUIRED
      LIB_VERSION
    )

  Check `the documentation <https://cmake.org/cmake/help/latest/variable/CMAKE_DEBUG_TARGET_PROPERTIES.html>`__ for more informations.
#]=======================================================================]

include_guard()

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)
include(CMakePrintHelpers)

#------------------------------------------------------------------------------
# Public function of this module
function(debug)
  set(options DUMP_VARIABLES DUMP_PROPERTIES)
  set(one_value_args DUMP_TARGETS INCLUDE_REGEX EXCLUDE_REGEX DUMP_TARGET_PROPERTIES)
  set(multi_value_args "")
  cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${one_value_args}" "${multi_value_args}"
  )

  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"!")
  endif()

  if(DEFINED arg_DUMP_TARGETS)
    set(current_command "debug(DUMP_TARGETS)")
    _debug_dump_targets()
  elseif(${arg_DUMP_VARIABLES})
    set(current_command "debug(DUMP_VARIABLES)")
    _debug_dump_variables()
  elseif(${arg_DUMP_PROPERTIES})
    set(current_command "debug(DUMP_PROPERTIES)")
    _debug_dump_properties()
  elseif(DEFINED arg_DUMP_TARGET_PROPERTIES)
    set(current_command "debug(DUMP_TARGET_PROPERTIES)")
    _debug_dump_target_properties()
  else()
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}(<OP> <value> ...) requires an operation and a value to be specified!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_debug_dump_targets)
  if((NOT DEFINED arg_DUMP_TARGETS)
      OR (NOT IS_DIRECTORY "${arg_DUMP_TARGETS}"))
    message(FATAL_ERROR "${current_command} requires the keyword DUMP_TARGETS '${arg_DUMP_TARGETS}' to be provided with a path to an existing directory on disk!")
  endif()

  function(__debug_dump_targets_recursive output_msg_var dir)
    get_directory_property(local_targets DIRECTORY "${dir}" BUILDSYSTEM_TARGETS)
    get_directory_property(imp_targets DIRECTORY "${dir}" IMPORTED_TARGETS)
    file(RELATIVE_PATH rel_dir_path "${CMAKE_SOURCE_DIR}" "${dir}")

    foreach(target IN ITEMS ${local_targets})
      string(APPEND "${output_msg_var}" "   [${rel_dir_path}][Buildsystem] ${target}\n")
    endforeach()
    foreach(target IN ITEMS ${imp_targets})
      string(APPEND "${output_msg_var}" "   [${rel_dir_path}][Imported   ] ${target}\n")
    endforeach()

    get_directory_property(subdirs DIRECTORY "${dir}" SUBDIRECTORIES)
    foreach(subdir IN ITEMS ${subdirs})
      __debug_dump_targets_recursive("${output_msg_var}" "${subdir}")
    endforeach()
    return(PROPAGATE "${output_msg_var}")
  endfunction()

  set(message "\n")
  string(APPEND message " Targets in the project:\n")
  __debug_dump_targets_recursive(message "${arg_DUMP_TARGETS}")
  message(STATUS "${message}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_debug_dump_variables)
  if(NOT DEFINED arg_DUMP_VARIABLES)
    message(FATAL_ERROR "${current_command} requires the keyword DUMP_VARIABLES to be provided!")
  endif()
  if((DEFINED arg_INCLUDE_REGEX) AND ("${arg_INCLUDE_REGEX}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires INCLUDE_REGEX to be a non-empty string value!")
  endif()
  if((DEFINED arg_EXCLUDE_REGEX) AND ("${arg_EXCLUDE_REGEX}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires EXCLUDE_REGEX to be a non-empty string value!")
  endif()
  if((DEFINED arg_INCLUDE_REGEX) AND (DEFINED arg_EXCLUDE_REGEX))
    message(FATAL_ERROR "${current_command} requires INCLUDE_REGEX and EXCLUDE_REGEX not to be used together, they are mutually exclusive!")
  endif()

  get_cmake_property(variable_names VARIABLES)
  list(SORT variable_names)
  list(REMOVE_DUPLICATES variable_names)

  set(message "\n")
  string(APPEND message " Variables of CMake:\n")
  foreach (variable_name IN ITEMS ${variable_names})
    if((NOT DEFINED arg_INCLUDE_REGEX AND NOT DEFINED arg_EXCLUDE_REGEX)
        OR (DEFINED arg_INCLUDE_REGEX AND "${variable_name}" MATCHES "${arg_INCLUDE_REGEX}")
        OR (DEFINED arg_EXCLUDE_REGEX AND NOT "${variable_name}" MATCHES "${arg_EXCLUDE_REGEX}"))
      string(APPEND message "   ${variable_name} = \"${${variable_name}}\"\n")
    endif()
  endforeach()
  message(STATUS "${message}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_debug_dump_properties)
  if(NOT DEFINED arg_DUMP_PROPERTIES)
    message(FATAL_ERROR "${current_command} requires the keyword DUMP_PROPERTIES to be provided!")
  endif()

  execute_process(COMMAND
    ${CMAKE_COMMAND} --help-property-list
    OUTPUT_VARIABLE property_names
  )
  # Convert command output into a CMake list
  string(REGEX REPLACE ";" "\\\\;" property_names "${property_names}")
  string(REGEX REPLACE "\n" ";" property_names "${property_names}")
  list(SORT property_names)

  set(message "\n")
  string(APPEND message " Properties of CMake:\n")
  foreach (property_name IN ITEMS ${property_names})
    string(APPEND message "   ${property_name}\n")
  endforeach()
  message(STATUS "${message}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_debug_dump_target_properties)
  if((NOT DEFINED arg_DUMP_TARGET_PROPERTIES)
      OR ("${arg_DUMP_TARGET_PROPERTIES}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword DUMP_TARGET_PROPERTIES to be provided with a non-empty string value!")
  endif()
  if(NOT TARGET "${arg_DUMP_TARGET_PROPERTIES}")
    message(FATAL_ERROR "${current_command} requires the target \"${arg_DUMP_TARGET_PROPERTIES}\" to already exist!")
  endif()

  # Get all propreties that cmake supports
  execute_process(COMMAND
    ${CMAKE_COMMAND} --help-property-list
    OUTPUT_VARIABLE property_names
  )

  # Convert command output into a CMake list
  string(REGEX REPLACE ";" "\\\\;" property_names "${property_names}")
  string(REGEX REPLACE "\n" ";" property_names "${property_names}")

  # Add custom properties used in this project
  list(APPEND property_names
    "INTERFACE_INCLUDE_DIRECTORIES_BUILD"
    "INTERFACE_INCLUDE_DIRECTORIES_INSTALL"
    "IMPORTED_LOCATION_BUILD_<CONFIG>"
    "IMPORTED_LOCATION_INSTALL_<CONFIG>"
  )

  # Substitute "_<CONFIG>" for each variable by the real configuration types
  # (RELEASE and DEBUG)
  set(config_dependent_property_names ${property_names})
  list(FILTER config_dependent_property_names INCLUDE REGEX "_<CONFIG>$")
  list(FILTER property_names EXCLUDE REGEX "_<CONFIG>$")
  foreach(property_name IN ITEMS ${config_dependent_property_names})
    string(REPLACE "<CONFIG>" "DEBUG" property_name_debug ${property_name})
    list(APPEND property_names "${property_name_debug}")
    string(REPLACE "<CONFIG>" "RELEASE" property_name_release ${property_name})
    list(APPEND property_names "${property_name_release}")
  endforeach()

  # Substitue "_<NAME>" in "HEADER_SET_<NAME>" variables by the names in
  # "HEADER_SETS" property
  get_property(property_set TARGET "${arg_DUMP_TARGET_PROPERTIES}"
    PROPERTY "HEADER_SETS" SET)
  if(${property_set})
    get_target_property(property_value "${arg_DUMP_TARGET_PROPERTIES}" "HEADER_SETS")
    foreach(header_set_name IN ITEMS ${property_value})
      list(APPEND property_names "HEADER_SET_${header_set_name}")
    endforeach()
  endif()

  # Substitue "_<NAME>" in "HEADER_DIRS_<NAME>" variables by the names in
  # "HEADER_DIRS" property
  get_property(property_set TARGET "${arg_DUMP_TARGET_PROPERTIES}"
    PROPERTY "HEADER_DIRS" SET)
  if(${property_set})
    get_target_property(property_value "${arg_DUMP_TARGET_PROPERTIES}" "HEADER_DIRS")
    foreach(header_dir_name IN ITEMS ${property_value})
      list(APPEND property_names "HEADER_DIRS_${header_dir_name}")
    endforeach()
  endif()

  # Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
  list(FILTER property_names EXCLUDE REGEX "^LOCATION$|^LOCATION_|_LOCATION$")
  list(REMOVE_DUPLICATES property_names)
  list(SORT property_names)

  set(message "\n")
  string(APPEND message " Properties for TARGET ${arg_DUMP_TARGET_PROPERTIES}:\n")
  foreach(property_name IN ITEMS ${property_names})
    get_property(property_set TARGET "${arg_DUMP_TARGET_PROPERTIES}"
      PROPERTY "${property_name}" SET)
    if(${property_set})
      get_target_property(property_value "${arg_DUMP_TARGET_PROPERTIES}" "${property_name}")
      string(APPEND message "   ${arg_DUMP_TARGET_PROPERTIES}.${property_name} = \"${property_value}\"\n")
    endif()
  endforeach()
  message(STATUS "${message}")
endmacro()
