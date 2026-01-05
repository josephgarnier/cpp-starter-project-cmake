# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
FileManip
---------

Operations on files by extending the :cmake:command:`file() <cmake:command:file>`
command. It requires CMake 4.0.1 or newer.

This module is dedicated to file and path manipulation requiring access to the filesystem. All files must exist on the disk. For other path manipulation, handling only syntactic aspects, see the :module:`PathManip` module and the :cmake:command:`cmake_path() <cmake:command:cmake_path>` command.

Synopsis
^^^^^^^^

.. parsed-literal::

  file_manip(`RELATIVE_PATH`_ <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])
  file_manip(`ABSOLUTE_PATH`_ <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])

Usage
^^^^^

.. signature::
  file_manip(RELATIVE_PATH <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])

  Computes the relative path from a given ``BASE_DIR`` for each file and
  directory in the list variable named ``<file-list-var>``. The files and the
  ``BASE_DIR`` must exist on the disk and must be passed as absolute path. The
  result is stored either in-place in ``<file-list-var>``, or in the variable
  specified by ``<output-list-var>``, if the ``OUTPUT_VARIABLE`` option is
  provided. The result is an empty list if the input list is empty.

  Example usage:

  .. code-block:: cmake

    set(files
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src")
    file_manip(RELATIVE_PATH files BASE_DIR "${CMAKE_SOURCE_DIR}")
    # files is:
    #   src/main.cpp;src

.. signature::
  file_manip(ABSOLUTE_PATH <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])

  Computes the absolute path from a given ``BASE_DIR`` for each file and
  directory in the list variable named ``<file-list-var>``. Files and the
  ``BASE_DIR`` must exist on the disk. ``BASE_DIR`` must be passed as absolute
  path, while the files can be relative or absolute. The result is stored
  either in-place in ``<file-list-var>``, or in the variable specified by
  ``<output-list-var>``, if the ``OUTPUT_VARIABLE`` option is provided. The
  result is an empty list if the input list is empty.

  Example usage:

  .. code-block:: cmake

    set(files
      "src/main.cpp"
      "src"
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src")
    file_manip(ABSOLUTE_PATH files BASE_DIR "${CMAKE_SOURCE_DIR}")
    # files is:
    #   /full/path/to/src/main.cpp;/full/path/to/src;/full/path/to/src/main.cpp;/full/path/to/src
#]=======================================================================]

include_guard()

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(file_manip)
  set(options "")
  set(one_value_args RELATIVE_PATH ABSOLUTE_PATH BASE_DIR OUTPUT_VARIABLE)
  set(multi_value_args "")
  cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${one_value_args}" "${multi_value_args}"
  )

  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"!")
  endif()

  if(DEFINED arg_RELATIVE_PATH)
    set(current_command "file_manip(RELATIVE_PATH)")
    _file_manip_relative_path()
  elseif(DEFINED arg_ABSOLUTE_PATH)
    set(current_command "file_manip(ABSOLUTE_PATH)")
    _file_manip_absolute_path()
  else()
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}(<OP> <value> ...) requires an operation and a value to be specified!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_file_manip_relative_path)
  if((NOT DEFINED arg_RELATIVE_PATH)
      OR ("${arg_RELATIVE_PATH}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword RELATIVE_PATH to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_BASE_DIR)
      OR (NOT IS_DIRECTORY "${arg_BASE_DIR}"))
    message(FATAL_ERROR "${current_command} requires the keyword BASE_DIR '${arg_BASE_DIR}' to be provided with a path to an existing directory on disk!")
  endif()
  if((DEFINED arg_OUTPUT_VARIABLE)
      AND ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(relative_path_list "")
  foreach(file IN ITEMS ${${arg_RELATIVE_PATH}})
    if(NOT EXISTS "${file}")
      message(FATAL_ERROR "${current_command} given path '${file}' does not exist on disk!")
    endif()
    file(RELATIVE_PATH relative_path "${arg_BASE_DIR}" "${file}")
    list(APPEND relative_path_list "${relative_path}")
  endforeach()

  if(NOT DEFINED arg_OUTPUT_VARIABLE)
    set(${arg_RELATIVE_PATH} "${relative_path_list}" PARENT_SCOPE)
  else()
    set(${arg_OUTPUT_VARIABLE} "${relative_path_list}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_file_manip_absolute_path)
  if((NOT DEFINED arg_ABSOLUTE_PATH)
      OR ("${arg_ABSOLUTE_PATH}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword ABSOLUTE_PATH to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_BASE_DIR)
      OR (NOT IS_DIRECTORY "${arg_BASE_DIR}"))
    message(FATAL_ERROR "${current_command} requires the keyword BASE_DIR '${arg_BASE_DIR}' to be provided with a path to an existing directory on disk!")
  endif()
  if((DEFINED arg_OUTPUT_VARIABLE)
      AND ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(absolute_path_list "")
  foreach(file IN ITEMS ${${arg_ABSOLUTE_PATH}})
    file(REAL_PATH "${file}" absolute_path BASE_DIRECTORY "${arg_BASE_DIR}")
    if(NOT EXISTS "${absolute_path}")
      message(FATAL_ERROR "${current_command} given path '${absolute_path}' does not exist on disk!")
    endif()
    list(APPEND absolute_path_list ${absolute_path})
  endforeach()

  if(NOT DEFINED arg_OUTPUT_VARIABLE)
    set(${arg_ABSOLUTE_PATH} "${absolute_path_list}" PARENT_SCOPE)
  else()
    set(${arg_OUTPUT_VARIABLE} "${absolute_path_list}" PARENT_SCOPE)
  endif()
endmacro()