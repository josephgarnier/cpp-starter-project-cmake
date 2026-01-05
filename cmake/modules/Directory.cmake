# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Directory
---------

Operations to manipule directories. It requires CMake 4.0.1 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  directory(`SCAN`_ <output-list-var> [...])
  directory(`SCAN_DIRS`_ <output-list-var> [...])
  directory(`FIND_LIB`_ <output-lib-var> [...])
  directory(`COLLECT_SOURCES_BY_LOCATION`_ [...])
  directory(`COLLECT_SOURCES_BY_POLICY`_ [...])

Usage
^^^^^

.. signature::
  directory(SCAN <output-list-var> [...])

  Recursively get files and directories:

  .. code-block:: cmake

    directory(SCAN <output-list-var>
              LIST_DIRECTORIES <true|false>
              RELATIVE <true|false>
              ROOT_DIR <dir-path>
              <INCLUDE_REGEX|EXCLUDE_REGEX> <regular-expression>)

  Recursively scan and collect all files and directories under ``ROOT_DIR``
  that match the filter provided with either ``INCLUDE_REGEX`` or
  ``EXCLUDE_REGEX``, and store the result in ``<output-list-var>``.

  Paths are returned as relative to ``ROOT_DIR`` if ``RELATIVE`` is ``true``,
  or as absolute paths if ``RELATIVE`` is ``false``.

  If ``LIST_DIRECTORIES`` is ``true``, directories are included in
  the result. If ``LIST_DIRECTORIES`` is ``false``, only files are listed.

  Example usage:

  .. code-block:: cmake

    directory(SCAN files_found
      LIST_DIRECTORIES false
      RELATIVE true
      ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
      INCLUDE_REGEX ".*[.]cpp$|.*[.]cc$|.*[.]cxx$"
    )
    # files_found is:
    #   src/main.cpp;src/util.cpp;lib/module.cpp

.. signature::
  directory(SCAN_DIRS <output-list-var> [...])

  Recursively get directories only:

  .. code-block:: cmake

     directory(SCAN_DIRS <output-list-var>
               RECURSE <true|false>
               RELATIVE <true|false>
               ROOT_DIR <dir-path>
               <INCLUDE_REGEX|EXCLUDE_REGEX> <regular-expression>)

  Scan and collect all directories under ``ROOT_DIR`` that match the regular
  expression provided with either ``INCLUDE_REGEX`` or ``EXCLUDE_REGEX``, and
  store the result in ``<output-list-var>``.

  If ``RECURSE`` is ``true``, the function traverses subdirectories recursively.
  If ``RECURSE`` is ``false``, only the directories directly under ``ROOT_DIR``
  are considered.

  The paths in the result are returned relative to ``ROOT_DIR`` if
  ``RELATIVE`` is ``true``, or as absolute paths if ``RELATIVE`` is ``false``.

  Example usage:

  .. code-block:: cmake

    directory(SCAN_DIRS matched_dirs
      RECURSE true
      RELATIVE true
      ROOT_DIR "${CMAKE_SOURCE_DIR}"
      INCLUDE_REGEX "include"
    )
    # matched_dirs is:
    #   src/include;src/lib/include

.. signature::
  directory(FIND_LIB <output-lib-var> [...])

  Recursively search for libs:

  .. code-block:: cmake

    directory(FIND_LIB <output-lib-var>
              FIND_IMPLIB <output-implib-var>
              NAME <raw-filename>
              <STATIC|SHARED>
              RELATIVE <true|false>
              ROOT_DIR <dir-path>)

  Search recursively in ``ROOT_DIR`` for a library and, on DLL platforms, its
  import library. The name to search for is given via ``NAME``, which should
  represent the base name of the library (without prefix or suffix).

  The matching uses system-defined prefixes and suffixes depending on the
  ``STATIC`` (by :cmake:variable:`CMAKE_STATIC_LIBRARY_PREFIX <cmake:variable:CMAKE_STATIC_LIBRARY_PREFIX>` and :cmake:variable:`CMAKE_STATIC_LIBRARY_SUFFIX <cmake:variable:CMAKE_STATIC_LIBRARY_SUFFIX>`)
  or ``SHARED`` (by :cmake:variable:`CMAKE_SHARED_LIBRARY_PREFIX <cmake:variable:CMAKE_SHARED_LIBRARY_PREFIX>` and
  :cmake:variable:`CMAKE_SHARED_LIBRARY_SUFFIX <cmake:variable:CMAKE_SHARED_LIBRARY_SUFFIX>`) flag, as well as
  :cmake:variable:`CMAKE_FIND_LIBRARY_PREFIXES <cmake:variable:CMAKE_FIND_LIBRARY_PREFIXES>` and :cmake:variable:`CMAKE_FIND_LIBRARY_SUFFIXES <cmake:variable:CMAKE_FIND_LIBRARY_SUFFIXES>` if
  defined. This makes the behavior similar to :cmake:command:`find_library() <cmake:command:find_library()>`, but more robust.

  .. note::

    The different value of prefix and suffix that the variables used
    to search for libraries can take are:

    .. code-block:: cmake

      # With GCC on Windows
      # CMAKE_SHARED_LIBRARY_PREFIX: lib
      # CMAKE_SHARED_LIBRARY_SUFFIX: .dll
      # CMAKE_STATIC_LIBRARY_PREFIX: lib
      # CMAKE_STATIC_LIBRARY_SUFFIX: .a
      # CMAKE_FIND_LIBRARY_PREFIXES: lib;
      # CMAKE_FIND_LIBRARY_SUFFIXES: .dll.a;.a;.lib

      # With MSVC on Windows
      # CMAKE_SHARED_LIBRARY_PREFIX:
      # CMAKE_SHARED_LIBRARY_SUFFIX: .dll
      # CMAKE_STATIC_LIBRARY_PREFIX:
      # CMAKE_STATIC_LIBRARY_SUFFIX: .lib
      # CMAKE_FIND_LIBRARY_PREFIXES: ;lib
      # CMAKE_FIND_LIBRARY_SUFFIXES: .dll.lib;.lib;.a

  If a matching library is found, its path is stored in ``<output-lib-var>``. If a
  matching import library is found, its path is stored in ``<output-implib-var>``. If
  ``RELATIVE`` is set to ``true``, the results are relative to ``ROOT_DIR``.
  Otherwise, absolute paths are returned.

  If no match is found, the values will be ``<output-lib-var>-NOTFOUND`` and
  ``<output-implib-var>-NOTFOUND``. In ``STATIC`` mode,
  ``<output-implib-var>-NOTFOUND`` is always returned, because an import
  library is only for a shared library. If multiple matches are found, a
  fatal error is raised.

  This command is especially useful to locate dependency artifacts when
  configuring :ref:`Imported Target <Imported Targets>`  manually (see also
  `CMake's guide to binary import and export <https://cmake.org/cmake/help/latest/guide/importing-exporting/index.html>`_). The resulting paths are typically
  used to set properties like :cmake:prop_tgt:`IMPORTED_LOCATION <cmake:prop_tgt:IMPORTED_LOCATION>` and
  :cmake:prop_tgt:`IMPORTED_IMPLIB <cmake:prop_tgt:IMPORTED_IMPLIB>` on an imported target, particularly in development
  or custom build setups where standard :cmake:command:`find_library() <cmake:command:find_library()>` behavior is not
  sufficient.

  Example usage:

  .. code-block:: cmake

    directory(FIND_LIB mylib_path
      FIND_IMPLIB mylib_import
      NAME "zlib1"
      SHARED
      RELATIVE true
      ROOT_DIR "${CMAKE_SOURCE_DIR}/libs"
    )
    # mylib_path is:
    #   lib/zlib1.dll
    # mylib_import is:
    #   lib/zlib1.lib

.. signature::
  directory(COLLECT_SOURCES_BY_LOCATION [...])

  Recursively get source and header file in a dir:

  .. code-block:: cmake

    directory(COLLECT_SOURCES_BY_LOCATION
              [SRC_DIR <dir-path>
              SRC_SOURCE_FILES <output-list-var>
              SRC_HEADER_FILES <output-list-var>]
              [INCLUDE_DIR <dir-path>
              INCLUDE_HEADER_FILES <output-list-var>])

  Recursively collect source and header files from specified directories
  and store them in output variables.

  If the ``SRC_DIR`` option is specified, the command searches the directory
  recursively for C++ source files with the following extensions:
  ``.cpp``, ``.cc``, or ``.cxx``, and header files with the extensions
  ``.h``, ``.hpp``, ``.hxx``, ``.inl``, or ``.tpp``.

  Source files found in ``SRC_DIR`` are assigned to the variable specified
  by ``SRC_SOURCE_FILES``, and header files are assigned to the variable
  specified by ``SRC_HEADER_FILES``.

  If the ``INCLUDE_DIR`` option is specified, only header files are
  collected recursively using the same extensions as above. These are
  assigned to the variable specified by ``INCLUDE_HEADER_FILES``.

  Both ``SRC_DIR`` and ``INCLUDE_DIR`` may be specified simultaneously.
  In that case, files are collected from both locations and stored into
  their respective output variables.

  At least one of ``SRC_DIR`` or ``INCLUDE_DIR`` must be provided. If
  neither is specified, or if any of the corresponding output variable
  arguments are missing, the command raises a fatal error.

  Example usage:

  .. code-block:: cmake

    directory(COLLECT_SOURCES_BY_LOCATION
      SRC_DIR "${CMAKE_SOURCE_DIR}/src"
      SRC_SOURCE_FILES src_sources
      SRC_HEADER_FILES src_headers
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include"
      INCLUDE_HEADER_FILES include_headers
    )

    # Or
    directory(COLLECT_SOURCES_BY_LOCATION
      SRC_DIR "${CMAKE_SOURCE_DIR}/src"
      SRC_SOURCE_FILES src_sources
      SRC_HEADER_FILES src_headers
    )

    # Or
    directory(INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include"
      INCLUDE_HEADER_FILES include_headers
    )

.. signature::
  directory(COLLECT_SOURCES_BY_POLICY [...])

  Recursively get source and header file according to a policy:

  .. code-block:: cmake

    directory(COLLECT_SOURCES_BY_POLICY
              PUBLIC_HEADERS_SEPARATED <true|false> [<include-dir-path>]
              PRIVATE_SOURCE_DIR <dir-path>
              PRIVATE_SOURCE_FILES <output-list-var>
              PUBLIC_HEADER_DIR <output-var>
              PUBLIC_HEADER_FILES <output-list-var>
              PRIVATE_HEADER_DIR <output-var>
              PRIVATE_HEADER_FILES <output-list-var>)

  Recursively collect source and header files from specified directories
  according to a header separation policy.

  This command collects source files with extensions ``.cpp``, ``.cc``,
  or ``.cxx`` from the directory specified by ``PRIVATE_SOURCE_DIR`` and stores them
  in the variable referenced by ``PRIVATE_SOURCE_FILES``.

  The behavior for header files depends on the policy value given to
  ``PUBLIC_HEADERS_SEPARATED``:

  * If ``PUBLIC_HEADERS_SEPARATED true <include-dir-path>`` is specified:

    * Public headers are collected from ``<include-dir-path>`` and stored
      in the variable referenced by ``PUBLIC_HEADER_FILES``.
    * The variable referenced by ``PUBLIC_HEADER_DIR`` is set to
      ``<include-dir-path>``.
    * Private headers are collected from ``PRIVATE_SOURCE_DIR`` and stored in the
      variable referenced by ``PRIVATE_HEADER_FILES``.
    * The variable referenced by ``PRIVATE_HEADER_DIR`` is set to
      ``PRIVATE_SOURCE_DIR``.

  * If ``PUBLIC_HEADERS_SEPARATED false`` is specified:

    * All headers are treated as public and collected from ``PRIVATE_SOURCE_DIR``.
    * The variable referenced by ``PUBLIC_HEADER_FILES`` contains the
      header file list.
    * The variable referenced by ``PUBLIC_HEADER_DIR`` is set to ``PRIVATE_SOURCE_DIR``.
    * The variables referenced by ``PRIVATE_HEADER_DIR`` and
      ``PRIVATE_HEADER_FILES`` are set to empty.

  If the policy is set to ``true``, but ``<include-dir-path>`` is missing or
  does not refer to an existing directory, a fatal error is raised.

  Example usage:

  .. code-block:: cmake

    directory(COLLECT_SOURCES_BY_POLICY
      PUBLIC_HEADERS_SEPARATED true "${CMAKE_SOURCE_DIR}/include/mylib"
      PRIVATE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/src"
      PRIVATE_SOURCE_FILES private_sources
      PUBLIC_HEADER_DIR public_header_dir
      PUBLIC_HEADER_FILES public_headers
      PRIVATE_HEADER_DIR private_header_dir
      PRIVATE_HEADER_FILES private_headers
    )
#]=======================================================================]

include_guard()

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(directory)
  set(options SHARED STATIC COLLECT_SOURCES_BY_LOCATION COLLECT_SOURCES_BY_POLICY)
  set(one_value_args SCAN SCAN_DIRS LIST_DIRECTORIES RELATIVE ROOT_DIR INCLUDE_REGEX EXCLUDE_REGEX RECURSE FIND_LIB FIND_IMPLIB NAME SRC_DIR SRC_SOURCE_FILES SRC_HEADER_FILES INCLUDE_DIR INCLUDE_HEADER_FILES PRIVATE_SOURCE_DIR PRIVATE_SOURCE_FILES PUBLIC_HEADER_DIR PUBLIC_HEADER_FILES PRIVATE_HEADER_DIR PRIVATE_HEADER_FILES)
  set(multi_value_args PUBLIC_HEADERS_SEPARATED)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${one_value_args}" "${multi_value_args}"
  )

  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
  endif()
  if(DEFINED arg_SCAN)
    set(current_command "directory(SCAN)")
    _directory_scan()
  elseif(DEFINED arg_SCAN_DIRS)
    set(current_command "directory(SCAN_DIRS)")
    _directory_scan_dirs()
  elseif(DEFINED arg_FIND_LIB)
    set(current_command "directory(FIND_LIB)")
    _directory_find_lib()
  elseif(${arg_COLLECT_SOURCES_BY_LOCATION})
    set(current_command "directory(COLLECT_SOURCES_BY_LOCATION)")
    _directory_collect_sources_by_location()
  elseif(${arg_COLLECT_SOURCES_BY_POLICY})
    set(current_command "directory(COLLECT_SOURCES_BY_POLICY)")
    _directory_collect_sources_by_policy()
  else()
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}(<OP> <value> ...) requires an operation and a value to be specified!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_directory_scan)
  if((NOT DEFINED arg_SCAN)
      OR ("${arg_SCAN}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword SCAN to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_LIST_DIRECTORIES)
      OR (NOT ${arg_LIST_DIRECTORIES} MATCHES "^(true|false)$"))
    message(FATAL_ERROR "${current_command} requires the keyword LIST_DIRECTORIES to be provided with a boolean with value 'true' or 'false'!")
  endif()
  if((NOT DEFINED arg_RELATIVE)
      OR (NOT ${arg_RELATIVE} MATCHES "^(true|false)$"))
    message(FATAL_ERROR "${current_command} requires the keyword RELATIVE to be provided with a boolean with value 'true' or 'false'!")
  endif()
  if((NOT DEFINED arg_ROOT_DIR)
      OR (NOT IS_DIRECTORY "${arg_ROOT_DIR}"))
    message(FATAL_ERROR "${current_command} requires the keyword ROOT_DIR '${arg_ROOT_DIR}' to be provided with a path to an existing directory on disk!")
  endif()
  if((NOT DEFINED arg_INCLUDE_REGEX)
      AND (NOT DEFINED arg_EXCLUDE_REGEX))
    message(FATAL_ERROR "${current_command} requires the keyword INCLUDE_REGEX or EXCLUDE_REGEX to be provided!")
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

  set(${arg_SCAN} "")
  if(${arg_RELATIVE})
    file(GLOB_RECURSE ${arg_SCAN}
      FOLLOW_SYMLINKS
      LIST_DIRECTORIES ${arg_LIST_DIRECTORIES}
      RELATIVE "${arg_ROOT_DIR}"
      CONFIGURE_DEPENDS
      "${arg_ROOT_DIR}/*"
    )
  else()
    file(GLOB_RECURSE ${arg_SCAN}
      FOLLOW_SYMLINKS
      LIST_DIRECTORIES ${arg_LIST_DIRECTORIES}
      CONFIGURE_DEPENDS
      "${arg_ROOT_DIR}/*"
    )
  endif()

  if(DEFINED arg_INCLUDE_REGEX)
    list(FILTER ${arg_SCAN} INCLUDE REGEX "${arg_INCLUDE_REGEX}")
  elseif(DEFINED arg_EXCLUDE_REGEX)
    list(FILTER ${arg_SCAN} EXCLUDE REGEX "${arg_EXCLUDE_REGEX}")
  else()
    message(FATAL_ERROR "${current_command} called with invalid arguments: expected INCLUDE_REGEX or EXCLUDE_REGEX!")
  endif()

  return(PROPAGATE "${arg_SCAN}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_directory_scan_dirs)
  if((NOT DEFINED arg_SCAN_DIRS)
      OR ("${arg_SCAN_DIRS}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword SCAN_DIRS to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_RECURSE)
      OR (NOT ${arg_RECURSE} MATCHES "^(true|false)$"))
    message(FATAL_ERROR "${current_command} requires the keyword RECURSE to be provided with a boolean with value 'true' or 'false'!")
  endif()
  if((NOT DEFINED arg_RELATIVE)
      OR (NOT ${arg_RELATIVE} MATCHES "^(true|false)$"))
    message(FATAL_ERROR "${current_command} requires the keyword RELATIVE to be provided with a boolean with value 'true' or 'false'!")
  endif()
  if((NOT DEFINED arg_ROOT_DIR)
      OR (NOT IS_DIRECTORY "${arg_ROOT_DIR}"))
    message(FATAL_ERROR "${current_command} requires the keyword ROOT_DIR '${arg_ROOT_DIR}' to be provided with a path to an existing directory on disk!")
  endif()
  if((NOT DEFINED arg_INCLUDE_REGEX)
      AND (NOT DEFINED arg_EXCLUDE_REGEX))
    message(FATAL_ERROR "${current_command} requires the keyword INCLUDE_REGEX or EXCLUDE_REGEX to be provided!")
  endif()
  if(DEFINED arg_INCLUDE_REGEX AND "${arg_INCLUDE_REGEX}" STREQUAL "")
    message(FATAL_ERROR "${current_command} requires INCLUDE_REGEX to be a non-empty string value!")
  endif()
  if(DEFINED arg_EXCLUDE_REGEX AND "${arg_EXCLUDE_REGEX}" STREQUAL "")
    message(FATAL_ERROR "${current_command} requires EXCLUDE_REGEX to be a non-empty string value!")
  endif()
  if(DEFINED arg_INCLUDE_REGEX AND DEFINED arg_EXCLUDE_REGEX)
    message(FATAL_ERROR "${current_command} requires INCLUDE_REGEX and EXCLUDE_REGEX not to be used together, they are mutually exclusive!")
  endif()

  # Paths should not be relative, but absolute, in order to be able to filter
  # files and keep only folders
  set(file_list "")
  if(${arg_RECURSE})
    file(GLOB_RECURSE file_list
      FOLLOW_SYMLINKS
      LIST_DIRECTORIES true
      CONFIGURE_DEPENDS
      "${arg_ROOT_DIR}/*"
    )
  else()
    file(GLOB file_list
      LIST_DIRECTORIES true
      CONFIGURE_DEPENDS
      "${arg_ROOT_DIR}/*"
    )
  endif()

  # Keep only directories and compute relative paths if needed
  set(${arg_SCAN_DIRS} "")
  foreach(file IN ITEMS ${file_list})
    if(IS_DIRECTORY "${file}")
      if(${arg_RELATIVE})
        file(RELATIVE_PATH file "${arg_ROOT_DIR}" "${file}")
      endif()
      list(APPEND ${arg_SCAN_DIRS} "${file}")
    endif()
  endforeach()

  if(DEFINED arg_INCLUDE_REGEX)
    list(FILTER ${arg_SCAN_DIRS} INCLUDE REGEX "${arg_INCLUDE_REGEX}")
  elseif(DEFINED arg_EXCLUDE_REGEX)
    list(FILTER ${arg_SCAN_DIRS} EXCLUDE REGEX "${arg_EXCLUDE_REGEX}")
  else()
    message(FATAL_ERROR "${current_command} called with invalid arguments: expected INCLUDE_REGEX or EXCLUDE_REGEX!")
  endif()

  return(PROPAGATE "${arg_SCAN_DIRS}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_directory_find_lib)
  if((NOT DEFINED arg_FIND_LIB)
      OR ("${arg_FIND_LIB}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword FIND_LIB to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_FIND_IMPLIB)
      OR ("${arg_FIND_IMPLIB}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword FIND_IMPLIB to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_NAME)
      OR ("${arg_NAME}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword NAME to be provided with a non-empty string value!")
  endif()
  if((NOT ${arg_SHARED})
      AND (NOT ${arg_STATIC}))
    message(FATAL_ERROR "${current_command} requires the keyword SHARED or STATIC to be provided!")
  endif()
  if(${arg_SHARED} AND ${arg_STATIC})
    message(FATAL_ERROR "${current_command} requires SHARED and STATIC not to be used together, they are mutually exclusive!")
  endif()
  if((NOT DEFINED arg_RELATIVE)
      OR (NOT ${arg_RELATIVE} MATCHES "^(true|false)$"))
    message(FATAL_ERROR "${current_command} requires the keyword RELATIVE to be provided with a boolean with value 'true' or 'false'!")
  endif()
  if((NOT DEFINED arg_ROOT_DIR)
      OR (NOT IS_DIRECTORY "${arg_ROOT_DIR}"))
    message(FATAL_ERROR "${current_command} requires the keyword ROOT_DIR '${arg_ROOT_DIR}' to be provided with a path to an existing directory on disk!")
  endif()

  set(file_list "")
  if(${arg_RELATIVE})
    file(GLOB_RECURSE file_list
      FOLLOW_SYMLINKS
      LIST_DIRECTORIES false
      RELATIVE "${arg_ROOT_DIR}"
      CONFIGURE_DEPENDS
      "${arg_ROOT_DIR}/*"
    )
  else()
    file(GLOB_RECURSE file_list
      FOLLOW_SYMLINKS
      LIST_DIRECTORIES false
      CONFIGURE_DEPENDS
      "${arg_ROOT_DIR}/*"
    )
  endif()

  # Select appropriate prefix/suffix sets based on the requested library type
  if(${arg_SHARED})
    # Shared library (.dll, .so, .dylib): used at runtime (IMPORTED_LOCATION)
    set(lib_prefixe_list "${CMAKE_SHARED_LIBRARY_PREFIX}") # 'lib' on Linux, empty on Windows
    set(lib_suffixe_list "${CMAKE_SHARED_LIBRARY_SUFFIX}") # '.so' on Linux, '.dll' on Windows

    # Import library (.lib, .dll.a, .a): used at link time (IMPORTED_IMPLIB)
    set(implib_prefixe_list "${CMAKE_FIND_LIBRARY_PREFIXES}") # 'empty|lib' on Linux, 'empty|lib' on Windows
    set(implib_suffixe_list "${CMAKE_FIND_LIBRARY_SUFFIXES}") # '.dll.a|.a|.lib' on Linux, '.dll.lib|.lib|.a' on Windows
  elseif(${arg_STATIC})
    # Static library (.lib, .a): used at link time (no import lib concept)
    set(lib_prefixe_list "${CMAKE_STATIC_LIBRARY_PREFIX}") # 'lib' on Linux, empty on Windows
    set(lib_suffixe_list "${CMAKE_STATIC_LIBRARY_SUFFIX}") # '.a' on Linux, '.lib' on Windows

    # Static libraries do not use import libraries
    set(implib_prefixe_list "")
    set(implib_suffixe_list "")
  else()
    message(FATAL_ERROR "${current_command} called with invalid build type: expected SHARED or STATIC!")
  endif()

  # Build regex to find the binary library (IMPORTED_LOCATION)
  string(REGEX REPLACE [[\.]] [[\\.]] lib_suffixe_list "${lib_suffixe_list}") # escape '.' char
  set(lib_regex "^(${lib_prefixe_list})?${arg_NAME}(${lib_suffixe_list})$")

  # Build regex to find the import library (IMPORTED_IMPLIB), only if applicable
  if(NOT "${implib_suffixe_list}" STREQUAL "")
    list(JOIN implib_prefixe_list "|" implib_prefixe_list)
    list(JOIN implib_suffixe_list "|" implib_suffixe_list)
    string(REGEX REPLACE [[\.]] [[\\.]] implib_suffixe_list "${implib_suffixe_list}") # escape '.' char
    set(implib_regex "^(${implib_prefixe_list})?${arg_NAME}(${implib_suffixe_list})$")
  else()
    # No import library applicable for static libraries
    set(implib_regex "")
  endif()

  # Search lib and implib
  set(${arg_FIND_LIB} "${arg_FIND_LIB}-NOTFOUND")
  set(${arg_FIND_IMPLIB} "${arg_FIND_IMPLIB}-NOTFOUND")
  foreach(file IN ITEMS ${file_list})
    cmake_path(GET file FILENAME file_name)
    if("${file_name}" MATCHES "${lib_regex}")
      # Find library (lib)
      if("${${arg_FIND_LIB}}" STREQUAL "${arg_FIND_LIB}-NOTFOUND")
        set(${arg_FIND_LIB} "${file}")
      else()
        message(FATAL_ERROR "${current_command} found at least two matches with the library name \"${arg_NAME}\"!")
      endif()
    endif()
    if((NOT "${implib_suffixe_list}" STREQUAL "")
        AND ("${file_name}" MATCHES "${implib_regex}"))
      # Find imported library (implib)
      if("${${arg_FIND_IMPLIB}}" STREQUAL "${arg_FIND_IMPLIB}-NOTFOUND")
        set(${arg_FIND_IMPLIB} "${file}")
      else()
        message(FATAL_ERROR "${current_command} found at least two matches with the import library name \"${arg_NAME}\"!")
      endif()
    endif()
  endforeach()

  return(PROPAGATE "${arg_FIND_LIB}" "${arg_FIND_IMPLIB}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_directory_collect_sources_by_location)
  if(NOT ${arg_COLLECT_SOURCES_BY_LOCATION})
    message(FATAL_ERROR "${current_command} requires the keyword COLLECT_SOURCES_BY_LOCATION to be provided!")
  endif()
  if((NOT DEFINED arg_SRC_DIR) AND (NOT DEFINED arg_INCLUDE_DIR))
    message(FATAL_ERROR "${current_command} requires the keyword SRC_DIR or INCLUDE_DIR to be provided!")
  endif()
  if(DEFINED arg_SRC_DIR)
    if(NOT IS_DIRECTORY "${arg_SRC_DIR}")
      message(FATAL_ERROR "${current_command} requires SRC_DIR '${arg_SRC_DIR}' to be an existing directory on disk!")
    endif()
    if((NOT DEFINED arg_SRC_SOURCE_FILES)
        OR ("${arg_SRC_SOURCE_FILES}" STREQUAL ""))
      message(FATAL_ERROR "${current_command} requires the keyword SRC_SOURCE_FILES to be provided with a non-empty string value!")
    endif()
    if((NOT DEFINED arg_SRC_HEADER_FILES)
        OR ("${arg_SRC_HEADER_FILES}" STREQUAL ""))
      message(FATAL_ERROR "${current_command} requires the keyword SRC_HEADER_FILES to be provided with a non-empty string value!")
    endif()
  endif()
  if(DEFINED arg_INCLUDE_DIR)
    if("${arg_INCLUDE_DIR}" STREQUAL "")
      message(FATAL_ERROR "${current_command} requires INCLUDE_DIR to be a non-empty string value!")
    endif()
    if(NOT IS_DIRECTORY "${arg_INCLUDE_DIR}")
      message(FATAL_ERROR "${current_command} requires INCLUDE_DIR '${arg_INCLUDE_DIR}' to be an existing directory on disk!")
    endif()
    if((NOT DEFINED arg_INCLUDE_HEADER_FILES)
        OR ("${arg_INCLUDE_HEADER_FILES}" STREQUAL ""))
      message(FATAL_ERROR "${current_command} requires the keyword INCLUDE_HEADER_FILES to be provided with a non-empty string value!")
    endif()
  endif()

  # Get files
  if(DEFINED arg_SRC_DIR)
    # Get the list of absolute paths to source files (.cpp|.cc|.cxx) stored
    # inside `SRC_DIR` directory
    set(${arg_SRC_SOURCE_FILES} "")
    directory(SCAN ${arg_SRC_SOURCE_FILES}
      LIST_DIRECTORIES false
      RELATIVE false
      ROOT_DIR "${arg_SRC_DIR}"
      INCLUDE_REGEX ".*[.]cpp$|.*[.]cc$|.*[.]cxx$"
    )

    # Get the list of absolute path to header files (.h|.hpp|.hxx|.inl|.tpp) stored
    # inside `SRC_DIR` directory
    set(${arg_SRC_HEADER_FILES} "")
    directory(SCAN ${arg_SRC_HEADER_FILES}
      LIST_DIRECTORIES false
      RELATIVE false
      ROOT_DIR "${arg_SRC_DIR}"
      INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$|.*[.]tpp$"
    )
  endif()

  if(DEFINED arg_INCLUDE_DIR)
    # Get the list of absolute path to header files (.h|.hpp|.hxx|.inl|.tpp) stored
    # inside `INCLUDE_DIR` directory
    set(${arg_INCLUDE_HEADER_FILES} "")
    directory(SCAN ${arg_INCLUDE_HEADER_FILES}
      LIST_DIRECTORIES false
      RELATIVE false
      ROOT_DIR "${arg_INCLUDE_DIR}"
      INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$|.*[.]tpp$"
    )
  endif()

  return(PROPAGATE
    "${arg_SRC_SOURCE_FILES}"
    "${arg_SRC_HEADER_FILES}"
    "${arg_INCLUDE_HEADER_FILES}"
  )
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_directory_collect_sources_by_policy)
  if(NOT ${arg_COLLECT_SOURCES_BY_POLICY})
    message(FATAL_ERROR "${current_command} requires the keyword COLLECT_SOURCES_BY_POLICY to be provided!")
  endif()
  if(NOT DEFINED arg_PRIVATE_SOURCE_DIR)
    message(FATAL_ERROR "${current_command} requires the keyword PRIVATE_SOURCE_DIR to be provided!")
  endif()
  if((NOT DEFINED arg_PRIVATE_SOURCE_DIR)
      OR (NOT IS_DIRECTORY "${arg_PRIVATE_SOURCE_DIR}"))
    message(FATAL_ERROR "${current_command} requires the keyword PRIVATE_SOURCE_DIR '${arg_PRIVATE_SOURCE_DIR}' to be provided with a path to an existing directory on disk!")
  endif()
  if((NOT DEFINED arg_PRIVATE_SOURCE_FILES)
      OR ("${arg_PRIVATE_SOURCE_FILES}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword PRIVATE_SOURCE_FILES to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_PUBLIC_HEADER_DIR)
      OR ("${arg_PUBLIC_HEADER_DIR}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword PUBLIC_HEADER_DIR to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_PUBLIC_HEADER_FILES)
      OR ("${arg_PUBLIC_HEADER_FILES}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword PUBLIC_HEADER_FILES to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_PRIVATE_HEADER_DIR)
      OR ("${arg_PRIVATE_HEADER_DIR}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword PRIVATE_HEADER_DIR to be provided with a non-empty string value!")
  endif()
  if((NOT DEFINED arg_PRIVATE_HEADER_FILES)
      OR ("${arg_PRIVATE_HEADER_FILES}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword PRIVATE_HEADER_FILES to be provided with a non-empty string value!")
  endif()

  # Check PUBLIC_HEADERS_SEPARATED args
  if((NOT DEFINED arg_PUBLIC_HEADERS_SEPARATED)
      OR ("PUBLIC_HEADERS_SEPARATED" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword PUBLIC_HEADERS_SEPARATED to be provided with at least one non-empty string value!")
  endif()
  list(GET arg_PUBLIC_HEADERS_SEPARATED 0 are_headers_separated)
  if(NOT ${are_headers_separated} MATCHES "^(true|false)$")
    message(FATAL_ERROR "${current_command} requires the first arg of PUBLIC_HEADERS_SEPARATED to be a boolean with value 'true' or 'false'!")
  endif()
  if(${are_headers_separated})
    # Check if the PUBLIC_HEADERS_SEPARATED argument is well formatted
    list(LENGTH arg_PUBLIC_HEADERS_SEPARATED nb_args_PUBLIC_HEADERS_SEPARATED)
    if(NOT ${nb_args_PUBLIC_HEADERS_SEPARATED} EQUAL 2)
      message(FATAL_ERROR "${current_command} requires the keyword PUBLIC_HEADERS_SEPARATED to be provided with a path to directory!")
    endif()

    # Check if `<include-dir-path>` exists
    list(GET arg_PUBLIC_HEADERS_SEPARATED 1 include_dir_path)
    if(NOT IS_DIRECTORY "${include_dir_path}")
      message(FATAL_ERROR "${current_command} requires PUBLIC_HEADERS_SEPARATED '${include_dir_path}' to be an existing directory on disk!")
    endif()
  endif()

  # Collect files
  file(RELATIVE_PATH rel_private_dir_path "${CMAKE_SOURCE_DIR}" "${arg_PRIVATE_SOURCE_DIR}")
  if(${are_headers_separated})
    file(RELATIVE_PATH rel_public_dir_path "${CMAKE_SOURCE_DIR}" "${include_dir_path}")
    message(VERBOSE "Header separation enabled - publics in \"${rel_public_dir_path}/\", privates in \"${rel_private_dir_path}/\"")
    directory(COLLECT_SOURCES_BY_LOCATION
      SRC_DIR "${arg_PRIVATE_SOURCE_DIR}"
      SRC_SOURCE_FILES src_source_file_list
      SRC_HEADER_FILES src_header_file_list
      INCLUDE_DIR "${include_dir_path}"
      INCLUDE_HEADER_FILES include_header_file_list
    )
    set(${arg_PRIVATE_SOURCE_FILES} "${src_source_file_list}" PARENT_SCOPE)
    set(${arg_PUBLIC_HEADER_DIR} "${include_dir_path}" PARENT_SCOPE)
    set(${arg_PUBLIC_HEADER_FILES} "${include_header_file_list}" PARENT_SCOPE)
    set(${arg_PRIVATE_HEADER_DIR} "${arg_PRIVATE_SOURCE_DIR}" PARENT_SCOPE)
    set(${arg_PRIVATE_HEADER_FILES} "${src_header_file_list}" PARENT_SCOPE)
  else()
    message(VERBOSE "Header separation disabled - using \"${rel_private_dir_path}/\" headers as public, ignoring \"include/\"")
    directory(COLLECT_SOURCES_BY_LOCATION
      SRC_DIR "${arg_PRIVATE_SOURCE_DIR}"
      SRC_SOURCE_FILES src_source_file_list
      SRC_HEADER_FILES src_header_file_list
    )
    set(${arg_PRIVATE_SOURCE_FILES} "${src_source_file_list}" PARENT_SCOPE)
    set(${arg_PUBLIC_HEADER_DIR} "${arg_PRIVATE_SOURCE_DIR}" PARENT_SCOPE)
    set(${arg_PUBLIC_HEADER_FILES} "${src_header_file_list}" PARENT_SCOPE)
    set(${arg_PRIVATE_HEADER_DIR} "" PARENT_SCOPE)
    set(${arg_PRIVATE_HEADER_FILES} "" PARENT_SCOPE)
  endif()
endmacro()
