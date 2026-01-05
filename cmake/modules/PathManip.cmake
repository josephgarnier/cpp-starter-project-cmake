# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
PathManip
---------

Operation to manipulate paths by extending the :cmake:command:`cmake_path() <cmake:command:cmake_path>`
command. It requires CMake 4.0.1 or newer.

Only syntactic aspects of paths are handled, there is no interaction of any
kind with any underlying file system. A path may represent a non-existing path
or even one that is not allowed to exist on the current file system or platform
, no error is raised when a file do not exist.

For operations that do interact with the filesystem, see the :module:`FileManip`
module and the :cmake:command:`file() <cmake:command:file>` command.

Synopsis
^^^^^^^^

.. parsed-literal::

  path_manip(`STRIP_PATH`_ <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])
  path_manip(`GET_COMPONENT`_ [<file-path>...] MODE <mode> OUTPUT_VARIABLE <output-list-var>)

Usage
^^^^^

.. signature::
  path_manip(STRIP_PATH <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])

  Removes the ``BASE_DIR`` prefix from each file or directory path in
  ``<file-list-var>``. The result is stored either in-place in
  ``<file-list-var>``, or in the variable specified by ``<output-list-var>``,
  if the ``OUTPUT_VARIABLE`` option is provided. ``BASE_DIR`` must be
  provided without trailing slash. A path can be relative or absolute. The
  result is an empty list if the input list is empty.

  Example usage:

  .. code-block:: cmake

    set(files
      "src/main.cpp"
      "src"
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src"
      "fake/directory/file.cpp"
      "fake/directory"
      "${CMAKE_SOURCE_DIR}/fake/directory/file.cpp"
      "${CMAKE_SOURCE_DIR}/fake/directory")
    path_manip(STRIP_PATH files BASE_DIR "${CMAKE_SOURCE_DIR}")
    # output is:
    #   src/main.cpp;src;src/main.cpp;src;fake/directory/file.cpp;fake/directory;fake/directory/file.cpp;fake/directory

.. signature::
  path_manip(GET_COMPONENT [<file-path>...] MODE <mode> OUTPUT_VARIABLE <output-list-var>)

  Extracts a specific component defined by ``MODE`` from each path to a file
  or a directory in the given ``<file-path>`` list and stores the result in the
  variable specified by ``OUTPUT_VARIABLE`` option. A path can be relative or
  absolute. The result is an empty list if the input list is empty.

  The ``MODE`` argument determines which component to extract and must be one of:

  * ``DIRECTORY`` - Directory without file name.
  * ``NAME``      - File name without directory.

  Example usage:

  .. code-block:: cmake

    set(files
      "src/main.cpp"
      "src"
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src"
      "fake/directory/file.cpp"
      "fake/directory"
      "${CMAKE_SOURCE_DIR}/fake/directory/file.cpp"
      "${CMAKE_SOURCE_DIR}/fake/directory")
    path_manip(GET_COMPONENT ${files} MODE DIRECTORY OUTPUT_VARIABLE dirs)
    # dirs is:
    #   src;src;/full/path/to/src;/full/path/to/src;fake/directory;fake;full/path/to/fake/directory;full/path/to/fake
    path_manip(GET_COMPONENT ${files} MODE NAME OUTPUT_VARIABLE filenames)
    # filenames is:
    #   main.cpp;src;main.cpp;src;file.cpp;directory;file.cpp;directory
#]=======================================================================]

include_guard()

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(path_manip)
  set(options "")
  set(one_value_args STRIP_PATH BASE_DIR MODE OUTPUT_VARIABLE)
  set(multi_value_args GET_COMPONENT)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${one_value_args}" "${multi_value_args}"
  )

  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"!")
  endif()

  if(DEFINED arg_STRIP_PATH)
    set(current_command "path_manip(STRIP_PATH)")
    _path_manip_strip_path()
  elseif((DEFINED arg_GET_COMPONENT)
      OR ("GET_COMPONENT" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    set(current_command "path_manip(GET_COMPONENT)")
    if("${arg_MODE}" STREQUAL DIRECTORY)
      _path_manip_get_component_directory()
    elseif("${arg_MODE}" STREQUAL NAME)
      _path_manip_get_component_name()
    else()
      message(FATAL_ERROR "${current_command} requires the keyword MODE to be provided with a supported value!")
    endif()
  else()
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}(<OP> <value> ...) requires an operation and a value to be specified!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_path_manip_strip_path)
  if((NOT DEFINED arg_STRIP_PATH)
      OR ("${arg_STRIP_PATH}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword STRIP_PATH to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_BASE_DIR)
      OR ("${arg_BASE_DIR}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword BASE_DIR to be provided with a non-empty string value!")
  endif()
  if((DEFINED arg_OUTPUT_VARIABLE)
      AND ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(stripped_path_list "")
  foreach(file_path IN ITEMS ${${arg_STRIP_PATH}})
    string(REPLACE "${arg_BASE_DIR}/" "" stripped_path "${file_path}")
    list(APPEND stripped_path_list ${stripped_path})
  endforeach()

  if(NOT DEFINED arg_OUTPUT_VARIABLE)
    set(${arg_STRIP_PATH} "${stripped_path_list}" PARENT_SCOPE)
  else()
    set(${arg_OUTPUT_VARIABLE} "${stripped_path_list}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_path_manip_get_component_directory)
  if((NOT DEFINED arg_GET_COMPONENT)
      AND (NOT "GET_COMPONENT" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword GET_COMPONENT to be provided!")
  endif()
  if((NOT DEFINED arg_MODE)
      OR (NOT "${arg_MODE}" STREQUAL DIRECTORY))
    message(FATAL_ERROR "${current_command} requires the keyword MODE to be provided with the 'DIRECTORY' value!")
  endif()
  if((NOT DEFINED arg_OUTPUT_VARIABLE)
      OR ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(${arg_OUTPUT_VARIABLE} "")
  foreach(file_path IN ITEMS ${arg_GET_COMPONENT})
    cmake_path(GET file_path PARENT_PATH directory_path)
    list(APPEND ${arg_OUTPUT_VARIABLE} "${directory_path}")
  endforeach()

  return(PROPAGATE "${arg_OUTPUT_VARIABLE}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_path_manip_get_component_name)
  if((NOT DEFINED arg_GET_COMPONENT)
      AND (NOT "GET_COMPONENT" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword GET_COMPONENT to be provided!")
  endif()
  if((NOT DEFINED arg_MODE)
      OR (NOT "${arg_MODE}" STREQUAL NAME))
    message(FATAL_ERROR "${current_command} requires the keyword MODE to be provided with the 'NAME' value!")
  endif()
  if((NOT DEFINED arg_OUTPUT_VARIABLE)
      OR ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(${arg_OUTPUT_VARIABLE} "")
  foreach(file_path IN ITEMS ${arg_GET_COMPONENT})
    cmake_path(GET file_path FILENAME file_name)
    list(APPEND ${arg_OUTPUT_VARIABLE} "${file_name}")
  endforeach()

  return(PROPAGATE "${arg_OUTPUT_VARIABLE}")
endmacro()