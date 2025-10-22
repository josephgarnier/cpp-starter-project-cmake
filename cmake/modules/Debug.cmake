# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Debug
-----

Operations for helping with debug. It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

    debug(`DUMP_TARGETS`_ <root-dir>)
    debug(`DUMP_VARIABLES`_ [EXCLUDE_REGEX <regular-expression>])
    debug(`DUMP_PROPERTIES`_ [])
    debug(`DUMP_TARGET_PROPERTIES`_ <target-name>)
    debug(`DUMP_PROJECT_VARIABLES`_ <project-name>)

Usage
^^^^^

.. signature::
  debug(DUMP_TARGETS <root-dir>)

  Print all buildsystem targets defined in the given directory ``<root-dir>``
  and its subdirectories. The output displays each target prefixed by its
  relative directory path from
  :cmake:variable:`CMAKE_SOURCE_DIR <cmake:variable:CMAKE_SOURCE_DIR>`.

  Example usage:

  .. code-block:: cmake

    debug(DUMP_TARGETS "${CMAKE_SOURCE_DIR}")
    # output is:
    #   -- [] Experimental
    #   -- [] Nightly
    #   ...
    #   -- [tests/data] static_mock_lib
    #   -- [tests/data] shared_mock_lib
    #   -- [doc] doc

.. signature::
  debug(DUMP_VARIABLES [EXCLUDE_REGEX <regular-expression>])

  Disaply all CMake variables except those that match with the optional
  ``<regular-expression>`` parameter.

  Display all defined CMake variables, optionally excluding those whose names
  match a given regular expression.

  This command retrieves all variables currently defined in the CMake
  context and prints their names and values using :cmake:command:`message() <cmake:command:message()>`.
  The output is sorted alphabetically and contains no duplicates.

  If ``<regular-expression>`` is provided, any variable whose name matches the
  given expression is omitted from the output.

  Example usage:

  .. code-block:: cmake

    debug(DUMP_VARIABLES)
    # output is:
    #   BUILD_SHARED_LIBS=ON
    #   CMAKE_CURRENT_SOURCE_DIR=/home/user/project/src
    #   CMAKE_VERSION=3.28.3
    #   PROJECT_NAME=MyProject
    #   ...

    debug(DUMP_VARIABLES
      EXCLUDE_REGEX "^CMAKE_"
    )
    # output is:
    #   BUILD_SHARED_LIBS=ON
    #   PROJECT_NAME=MyProject
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
    # output is:
    #   ADDITIONAL_CLEAN_FILES
    #   ALIAS_GLOBAL
    #   ANDROID_API
    #   ARCHIVE_OUTPUT_DIRECTORY
    #   AUTOMOC
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
    # output is:
    #
    #   -----
    #   Properties for TARGET my_library:
    #     my_library.TYPE = "STATIC_LIBRARY"
    #     my_library.SOURCES = "src/a.cpp;src/b.cpp"
    #     my_library.INTERFACE_INCLUDE_DIRECTORIES = "include"
    #     ...
    #   -----
    #

.. signature::
  debug(DUMP_PROJECT_VARIABLES <project-name>)

  Display all global CMake variables related to the current project and
  prefixed with ``<project-name>_``.

  This command prints the values of all defined variables whose name starts
  with the current ``<project-name>_``. This relies on the naming convention
  that project-specific variables are prefixed with the project name followed
  by an underscore.

  This command is useful for debugging and inspecting variables that are
  explicitly scoped to the project. It filters out unrelated variables
  defined by CMake or third-party scripts.

  Example usage:

  .. code-block:: cmake

    debug(DUMP_PROJECT_VARIABLES "my_project")
    # output is:
    #
    #   -----
    #   Variables for PROJECT my_project:
    #     my_project_SOURCE_DIR = "/home/user/my_project/src"
    #     my_project_BUILD_DIR = "/home/user/my_project/build"
    #     ...
    #   -----
    #

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
  command allows to interpret  a generator expression:

  .. code-block:: cmake

    file(GENERATE OUTPUT debug.txt CONTENT "$<...>")

  Check `the documentation <https://cmake.org/cmake/help/latest/manual/cmake-generator-expressions.7.html#debugging>`__ for more informations.
#]=======================================================================]

include_guard()

cmake_minimum_required (VERSION 3.20 FATAL_ERROR)
include(CMakePrintHelpers)

#------------------------------------------------------------------------------
# Public function of this module
function(debug)
  set(options DUMP_VARIABLES DUMP_PROPERTIES)
  set(one_value_args DUMP_TARGETS EXCLUDE_REGEX DUMP_TARGET_PROPERTIES DUMP_PROJECT_VARIABLES)
  set(multi_value_args "")
  cmake_parse_arguments(DB "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  
  if(DEFINED DB_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${DB_UNPARSED_ARGUMENTS}\"!")
  endif()

  if(DEFINED DB_DUMP_TARGETS)
    _debug_dump_targets()
  elseif(${DB_DUMP_VARIABLES})
    _debug_dump_variables()
  elseif(${DB_DUMP_PROPERTIES})
    _debug_dump_properties()
  elseif(DEFINED DB_DUMP_TARGET_PROPERTIES)
    _debug_dump_target_properties()
  elseif(DEFINED DB_DUMP_PROJECT_VARIABLES)
    _debug_dump_project_variables()
  else()
    message(FATAL_ERROR "The operation name or arguments are missing!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage
macro(_debug_dump_targets)
  if(NOT DEFINED DB_DUMP_TARGETS)
    message(FATAL_ERROR "DUMP_TARGETS arguments is missing!")
  endif()
  if((NOT EXISTS "${DB_DUMP_TARGETS}")
    OR (NOT IS_DIRECTORY "${DB_DUMP_TARGETS}"))
      message(FATAL_ERROR "Given path: ${DB_DUMP_TARGETS} does not refer to an existing path or directory on disk!")
  endif()

  get_directory_property(targets DIRECTORY "${DB_DUMP_TARGETS}" BUILDSYSTEM_TARGETS)
  file(RELATIVE_PATH rel_dir_path "${CMAKE_SOURCE_DIR}" "${DB_DUMP_TARGETS}")
  foreach(target IN ITEMS ${targets})
    message(STATUS "[${rel_dir_path}] ${target}")
  endforeach()

  get_directory_property(subdirs DIRECTORY "${DB_DUMP_TARGETS}" SUBDIRECTORIES)
  foreach(subdir IN ITEMS ${subdirs})
    set(DB_DUMP_TARGETS "${subdir}")
    _debug_dump_targets()
  endforeach()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_debug_dump_variables)
  if(NOT ${DB_DUMP_VARIABLES})
    message(FATAL_ERROR "DUMP_VARIABLES arguments is missing!")
  endif()

  get_cmake_property(variable_names VARIABLES)
  list(SORT variable_names)
  list(REMOVE_DUPLICATES variable_names)
  foreach (variable_name IN ITEMS ${variable_names})
    if((NOT DEFINED DB_EXCLUDE_REGEX)
      OR (NOT "${variable_name}" MATCHES "${DB_EXCLUDE_REGEX}"))
      message(STATUS "${variable_name}= ${${variable_name}}")
    endif()
  endforeach()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_debug_dump_properties)
  if(NOT ${DB_DUMP_PROPERTIES})
    message(FATAL_ERROR "DUMP_PROPERTIES arguments is missing!")
  endif()

  execute_process(COMMAND
    ${CMAKE_COMMAND} --help-property-list
    OUTPUT_VARIABLE propertie_names
  )
  # Convert command output into a CMake list.
  string(REGEX REPLACE ";" "\\\\;" propertie_names "${propertie_names}")
  string(REGEX REPLACE "\n" ";" propertie_names "${propertie_names}")
  list(SORT propertie_names)
  foreach (propertie_name IN ITEMS ${propertie_names})
    message(STATUS "${propertie_name}")
  endforeach()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_debug_dump_target_properties)
  if(NOT DEFINED DB_DUMP_TARGET_PROPERTIES)
    message(FATAL_ERROR "DUMP_TARGET_PROPERTIES arguments is missing!")
  endif()
  if(NOT TARGET "${DB_DUMP_TARGET_PROPERTIES}")
    message(FATAL_ERROR "There is no target named \"${DB_DUMP_TARGET_PROPERTIES}\"!")
  endif()

  # Get all propreties that cmake supports
  execute_process(COMMAND
    ${CMAKE_COMMAND} --help-property-list
    OUTPUT_VARIABLE propertie_names
  )

  # Convert command output into a CMake list.
  string(REGEX REPLACE ";" "\\\\;" propertie_names "${propertie_names}")
  string(REGEX REPLACE "\n" ";" propertie_names "${propertie_names}")
  
  # Add custom properties used in this project.
  list(APPEND propertie_names
    "INTERFACE_INCLUDE_DIRECTORIES_BUILD"
    "INTERFACE_INCLUDE_DIRECTORIES_INSTALL"
    "IMPORTED_LOCATION_BUILD_<CONFIG>"
    "IMPORTED_LOCATION_INSTALL_<CONFIG>"
  )
  
  # Substitute "_<CONFIG>"" for each variable by the real configuration types (RELEASE and DEBUG).
  set(config_dependent_propertie_names ${propertie_names})
  list(FILTER config_dependent_propertie_names INCLUDE REGEX "_<CONFIG>$")
  list(FILTER propertie_names EXCLUDE REGEX "_<CONFIG>$")
  foreach(propertie_name IN ITEMS ${config_dependent_propertie_names})
    string(REPLACE "<CONFIG>" "DEBUG" propertie_name_debug ${propertie_name})
    list(APPEND propertie_names "${propertie_name_debug}")
    string(REPLACE "<CONFIG>" "RELEASE" propertie_name_release ${propertie_name})
    list(APPEND propertie_names "${propertie_name_release}")
  endforeach()

  # Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
  list(FILTER propertie_names EXCLUDE REGEX "^LOCATION$|^LOCATION_|_LOCATION$")
  list(REMOVE_DUPLICATES propertie_names)
  list(SORT propertie_names)

  message("")
  message("-----")
  list(APPEND CMAKE_MESSAGE_INDENT " ")
  message("Properties for TARGET ${DB_DUMP_TARGET_PROPERTIES}:")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")
  foreach(propertie_name IN ITEMS ${propertie_names})
    get_property(propertie_set TARGET "${DB_DUMP_TARGET_PROPERTIES}" PROPERTY "${propertie_name}" SET)
    if(${propertie_set})
      get_target_property(propertie_value "${DB_DUMP_TARGET_PROPERTIES}" "${propertie_name}")
      message("${DB_DUMP_TARGET_PROPERTIES}.${propertie_name} = \"${propertie_value}\"")
    endif()
  endforeach()
  list(POP_BACK CMAKE_MESSAGE_INDENT)
  list(POP_BACK CMAKE_MESSAGE_INDENT)
  message("-----")
  message("")
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_debug_dump_project_variables)
  if(NOT DEFINED DB_DUMP_PROJECT_VARIABLES)
    message(FATAL_ERROR "DUMP_PROJECT_VARIABLES arguments is missing!")
  endif()

  get_cmake_property(variable_names VARIABLES)
  list(SORT variable_names)
  
  message("")
  message("-----")
  list(APPEND CMAKE_MESSAGE_INDENT " ")
  message("Variables for PROJECT ${DB_DUMP_PROJECT_VARIABLES}:")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")
  foreach (variable_name IN ITEMS ${variable_names})
    if("${variable_name}" MATCHES "${DB_DUMP_PROJECT_VARIABLES}_")
      message("${variable_name} = \"${${variable_name}}\"")
    endif()
  endforeach()
  list(POP_BACK CMAKE_MESSAGE_INDENT)
  list(POP_BACK CMAKE_MESSAGE_INDENT)
  message("-----")
  message("")
endmacro()
