# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
FileManip
---------

Operations on files. It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  file_manip(`RELATIVE_PATH`_ <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])
  file_manip(`ABSOLUTE_PATH`_ <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])
  file_manip(`STRIP_PATH`_ <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])
  file_manip(`GET_COMPONENT`_ <file-path>... MODE <mode> OUTPUT_VARIABLE <output-list-var>)

Usage
^^^^^

.. signature::
  file_manip(RELATIVE_PATH <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])

  Computes the relative path from a given ``BASE_DIR`` for each file
  in the list variable named ``<file-list-var>``. The result is stored either
  in-place in ``<file-list-var>``, or in the variable specified by
  ``<output-list-var>``, if the ``OUTPUT_VARIABLE`` option is provided.

  Example usage:

  .. code-block:: cmake

    set(files
      "/project/src/main.cpp"
      "/project/include/lib.h"
    )
    file_manip(RELATIVE_PATH "${files}" BASE_DIR "/project")
    # output is:
    #   src/main.cpp;include/lib.hpp

.. signature::
  file_manip(ABSOLUTE_PATH <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])

  Computes the absolute path from a given ``BASE_DIR`` for each file
  in the list variable named ``<file-list-var>``. The result is stored either
  in-place in ``<file-list-var>``, or in the variable specified by
  ``<output-list-var>``, if the ``OUTPUT_VARIABLE`` option is provided.

  Example usage:

  .. code-block:: cmake

    set(files
      "src/main.cpp"
      "include/lib.hpp"
    )
    file_manip(ABSOLUTE_PATH "${files}" BASE_DIR "/project")
    # output is:
    #   /project/src/main.cpp;/project/include/lib.h

.. signature::
  file_manip(STRIP_PATH <file-list-var> BASE_DIR <dir-path> [OUTPUT_VARIABLE <output-list-var>])

  Removes the ``BASE_DIR`` prefix from each file path in
  ``<file-list-var>``. The result is stored either in-place in
  ``<file-list-var>``, or in the variable specified by
  ``<output-list-var>``, if the ``OUTPUT_VARIABLE`` option is provided. Unlike
  to :command:`file_manip(RELATIVE_PATH)`, it performs no checks on the existence
  of files. Paths are processed like any string.

  Example usage:

  .. code-block:: cmake

    set(files
      "/project/src/main.cpp"
      "/project/include/lib.h"
    )
    file_manip(STRIP_PATH "${files}" BASE_DIR "/project")
    # output is:
    #   src/main.cpp;include/lib.hpp

.. signature::
  file_manip(GET_COMPONENT <file-path>... MODE <mode> OUTPUT_VARIABLE <output-list-var>)

  Extracts a specific component from each path in the given ``<file-path>``
  list and stores the result in the variable specified by ``OUTPUT_VARIABLE``
  option.

  The ``MODE`` argument determines which component to extract and must be one of:

  * ``DIRECTORY`` - Directory without file name.
  * ``NAME``      - File name without directory.

  Example usage:

  .. code-block:: cmake

    set(files
      "/project/src/main.cpp"
      "/project/include/lib.hpp"
    )
    file_manip(GET_COMPONENT "${files}" MODE DIRECTORY OUTPUT_VARIABLE dirs)
    # output is:
    #   /project/src;/project/include
#]=======================================================================]

include_guard()

cmake_minimum_required (VERSION 3.20 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(file_manip)
  set(options "")
  set(one_value_args RELATIVE_PATH ABSOLUTE_PATH STRIP_PATH BASE_DIR MODE OUTPUT_VARIABLE)
  set(multi_value_args GET_COMPONENT)
  cmake_parse_arguments(FM "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  
  if(DEFINED FM_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${FM_UNPARSED_ARGUMENTS}\"!")
  endif()

  if(DEFINED FM_RELATIVE_PATH)
    _file_manip_relative_path()
  elseif(DEFINED FM_ABSOLUTE_PATH)
    _file_manip_absolute_path()
  elseif(DEFINED FM_STRIP_PATH)
    _file_manip_strip_path()
  elseif((DEFINED FM_GET_COMPONENT)
    OR ("GET_COMPONENT" IN_LIST FM_KEYWORDS_MISSING_VALUES))
    if("${FM_MODE}" STREQUAL DIRECTORY)
      _file_manip_get_component_directory()
    elseif("${FM_MODE}" STREQUAL NAME)
      _file_manip_get_component_name()
    else()
      message(FATAL_ERROR "MODE arguments is missing!")
    endif()
  else()
    message(FATAL_ERROR "The operation name or arguments are missing!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage
macro(_file_manip_relative_path)
  if(NOT DEFINED FM_RELATIVE_PATH)
    message(FATAL_ERROR "RELATIVE_PATH arguments is missing!")
  endif()
  if(NOT DEFINED FM_BASE_DIR)
    message(FATAL_ERROR "BASE_DIR arguments is missing!")
  endif()
  if((NOT EXISTS "${FM_BASE_DIR}")
    OR (NOT IS_DIRECTORY "${FM_BASE_DIR}"))
    message(FATAL_ERROR "Given path: ${FM_BASE_DIR} does not refer to an existing path or directory on disk!")
  endif()

  set(relative_paths_list "")
  foreach(file IN ITEMS ${${FM_RELATIVE_PATH}})
    if(NOT EXISTS "${file}")
      message(FATAL_ERROR "Given path: ${file} does not refer to an existing path on disk!")
    endif()
    file(RELATIVE_PATH relative_path "${FM_BASE_DIR}" "${file}")
    list(APPEND relative_paths_list "${relative_path}")
  endforeach()
  
  if(NOT DEFINED FM_OUTPUT_VARIABLE)
    set(${FM_RELATIVE_PATH} "${relative_paths_list}" PARENT_SCOPE)
  else()
    set(${FM_OUTPUT_VARIABLE} "${relative_paths_list}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_file_manip_absolute_path)
  if(NOT DEFINED FM_ABSOLUTE_PATH)
    message(FATAL_ERROR "ABSOLUTE_PATH arguments is missing!")
  endif()
  if(NOT DEFINED FM_BASE_DIR)
    message(FATAL_ERROR "BASE_DIR arguments is missing!")
  endif()
  if((NOT EXISTS "${FM_BASE_DIR}")
    OR (NOT IS_DIRECTORY "${FM_BASE_DIR}"))
    message(FATAL_ERROR "Given path: ${FM_BASE_DIR} does not refer to an existing path or directory on disk!")
  endif()

  set(absolute_paths_list "")
  foreach(file IN ITEMS ${${FM_ABSOLUTE_PATH}})
    file(REAL_PATH "${file}" absolute_path BASE_DIRECTORY "${FM_BASE_DIR}")
    if(NOT EXISTS "${absolute_path}")
      message(FATAL_ERROR "Given path: ${absolute_path} does not refer to an existing path on disk!")
    endif()
    list(APPEND absolute_paths_list ${absolute_path})
  endforeach()
  
  if(NOT DEFINED FM_OUTPUT_VARIABLE)
    set(${FM_ABSOLUTE_PATH} "${absolute_paths_list}" PARENT_SCOPE)
  else()
    set(${FM_OUTPUT_VARIABLE} "${absolute_paths_list}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_file_manip_strip_path)
  if(NOT DEFINED FM_STRIP_PATH)
    message(FATAL_ERROR "STRIP_PATH arguments is missing!")
  endif()
  if(NOT DEFINED FM_BASE_DIR)
    message(FATAL_ERROR "BASE_DIR arguments is missing!")
  endif()
  
  set(stripped_paths_list "")
  foreach(file_path IN ITEMS ${${FM_STRIP_PATH}})
    string(REPLACE "${FM_BASE_DIR}/" "" stripped_path "${file_path}")
    list(APPEND stripped_paths_list ${stripped_path})
  endforeach()
  
  if(NOT DEFINED FM_OUTPUT_VARIABLE)
    set(${FM_STRIP_PATH} "${stripped_paths_list}" PARENT_SCOPE)
  else()
    set(${FM_OUTPUT_VARIABLE} "${stripped_paths_list}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_file_manip_get_component_directory)
  if((NOT DEFINED FM_GET_COMPONENT)
    AND (NOT "GET_COMPONENT" IN_LIST FM_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "GET_COMPONENT arguments is missing!")
  endif()
  if(NOT DEFINED FM_MODE)
    message(FATAL_ERROR "MODE arguments is missing!")
  endif()
  if(NOT DEFINED FM_OUTPUT_VARIABLE)
    message(FATAL_ERROR "OUTPUT_VARIABLE arguments is missing!")
  endif()

  set(directorty_paths_list "")
  foreach(file_path IN ITEMS ${FM_GET_COMPONENT})
    cmake_path(GET file_path PARENT_PATH directory_path)
    list(APPEND directorty_paths_list "${directory_path}")
  endforeach()

  set(${FM_OUTPUT_VARIABLE} "${directorty_paths_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_file_manip_get_component_name)
  if((NOT DEFINED FM_GET_COMPONENT)
    AND (NOT "GET_COMPONENT" IN_LIST FM_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "GET_COMPONENT arguments is missing!")
  endif()
  if(NOT DEFINED FM_MODE)
    message(FATAL_ERROR "MODE arguments is missing!")
  endif()
  if(NOT DEFINED FM_OUTPUT_VARIABLE)
    message(FATAL_ERROR "OUTPUT_VARIABLE arguments is missing!")
  endif()
  
  set(file_names_list "")
  foreach(file_path IN ITEMS ${FM_GET_COMPONENT})
    cmake_path(GET file_path FILENAME file_name)
    list(APPEND file_names_list "${file_name}")
  endforeach()
  
  set(${FM_OUTPUT_VARIABLE} "${file_names_list}" PARENT_SCOPE)
endmacro()