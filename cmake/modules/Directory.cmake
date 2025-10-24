# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Directory
---------

Operations to manipule directories. It requires CMake 3.20 or newer.

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
              LIST_DIRECTORIES <on|off>
              RELATIVE <on|off>
              ROOT_DIR <dir-path>
              <INCLUDE_REGEX|EXCLUDE_REGEX> <regular-expression>)

  Recursively scan and collect all files and directories under ``ROOT_DIR``
  that match the filter provided with either ``INCLUDE_REGEX`` or
  ``EXCLUDE_REGEX``, and store the result in ``<output-list-var>``.

  Paths are returned as relative to ``ROOT_DIR`` if ``RELATIVE`` is ``on``,
  or as absolute paths if ``RELATIVE`` is ``off``.

  If ``LIST_DIRECTORIES`` is ``on``, directories are included in
  the result. If ``LIST_DIRECTORIES`` is ``off``, only files are listed.

  Example usage:

  .. code-block:: cmake

    directory(SCAN files_found
      LIST_DIRECTORIES off
      RELATIVE on
      ROOT_DIR "${CMAKE_CURRENT_SOURCE_DIR}"
      INCLUDE_REGEX ".*[.]cpp$|.*[.]cc$|.*[.]cxx$"
    )
    # output is:
    #   src/main.cpp;src/util.cpp;lib/module.cpp

.. signature::
  directory(SCAN_DIRS <output-list-var> [...])

  Recursively get directories only:

  .. code-block:: cmake

     directory(SCAN_DIRS <output-list-var>
              RECURSE <on|off>
              RELATIVE <on|off>
              ROOT_DIR <dir-path>
              <INCLUDE_REGEX|EXCLUDE_REGEX> <regular-expression>)

  Scan and collect all directories under ``ROOT_DIR`` that match the regular
  expression provided with either ``INCLUDE_REGEX`` or ``EXCLUDE_REGEX``, and
  store the result in ``<output-list-var>``.

  If ``RECURSE`` is ``on``, the function traverses subdirectories recursively.
  If ``RECURSE`` is ``off``, only the directories directly under ``ROOT_DIR``
  are considered.

  The paths in the result are returned relative to ``ROOT_DIR`` if
  ``RELATIVE`` is ``on``, or as absolute paths if ``RELATIVE`` is ``off``.

  Example usage:

  .. code-block:: cmake

    directory(SCAN_DIRS matched_dirs
      RECURSE on
      RELATIVE on
      ROOT_DIR "${CMAKE_SOURCE_DIR}"
      INCLUDE_REGEX "include"
    )
    # output is:
    #   src/include;src/lib/include

.. signature::
  directory(FIND_LIB <output-lib-var> [...])
  
  Recursively search for libs:

  .. code-block:: cmake

    directory(FIND_LIB <output-lib-var>
              FIND_IMPLIB <output-implib-var>
              NAME <raw-filename>
              <STATIC|SHARED>
              RELATIVE <on|off>
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
  ``RELATIVE`` is set to ``on``, the results are relative to ``ROOT_DIR``.
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
      RELATIVE on
      ROOT_DIR "${CMAKE_SOURCE_DIR}/libs"
    )
    # output is:
    #   lib=lib/zlib1.dll
    #   implib=lib/zlib1.lib

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
              PUBLIC_HEADERS_SEPARATED <on|off> [<include-dir-path>]
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

  * If ``PUBLIC_HEADERS_SEPARATED on <include-dir-path>`` is specified:

    * Public headers are collected from ``<include-dir-path>`` and stored
      in the variable referenced by ``PUBLIC_HEADER_FILES``.
    * The variable referenced by ``PUBLIC_HEADER_DIR`` is set to
      ``<include-dir-path>``.
    * Private headers are collected from ``PRIVATE_SOURCE_DIR`` and stored in the
      variable referenced by ``PRIVATE_HEADER_FILES``.
    * The variable referenced by ``PRIVATE_HEADER_DIR`` is set to
      ``PRIVATE_SOURCE_DIR``.

  * If ``PUBLIC_HEADERS_SEPARATED off`` is specified:

    * All headers are treated as public and collected from ``PRIVATE_SOURCE_DIR``.
    * The variable referenced by ``PUBLIC_HEADER_FILES`` contains the
      header file list.
    * The variable referenced by ``PUBLIC_HEADER_DIR`` is set to ``PRIVATE_SOURCE_DIR``.
    * The variables referenced by ``PRIVATE_HEADER_DIR`` and
      ``PRIVATE_HEADER_FILES`` are set to empty.

  If the policy is set to ``on``, but ``<include-dir-path>`` is missing or
  does not refer to an existing directory, a fatal error is raised.

  Example usage:

  .. code-block:: cmake

    directory(COLLECT_SOURCES_BY_POLICY
      PUBLIC_HEADERS_SEPARATED on "${CMAKE_SOURCE_DIR}/include/mylib"
      PRIVATE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/src"
      PRIVATE_SOURCE_FILES private_sources
      PUBLIC_HEADER_DIR public_header_dir
      PUBLIC_HEADER_FILES public_headers
      PRIVATE_HEADER_DIR private_header_dir
      PRIVATE_HEADER_FILES private_headers
    )
#]=======================================================================]

include_guard()

cmake_minimum_required (VERSION 3.20 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(directory)
  set(options SHARED STATIC COLLECT_SOURCES_BY_LOCATION COLLECT_SOURCES_BY_POLICY)
  set(one_value_args SCAN SCAN_DIRS LIST_DIRECTORIES RELATIVE ROOT_DIR INCLUDE_REGEX EXCLUDE_REGEX RECURSE FIND_LIB FIND_IMPLIB NAME SRC_DIR SRC_SOURCE_FILES SRC_HEADER_FILES INCLUDE_DIR INCLUDE_HEADER_FILES PRIVATE_SOURCE_DIR PRIVATE_SOURCE_FILES PUBLIC_HEADER_DIR PUBLIC_HEADER_FILES PRIVATE_HEADER_DIR PRIVATE_HEADER_FILES)
  set(multi_value_args PUBLIC_HEADERS_SEPARATED)
  cmake_parse_arguments(DIR "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  
  if(DEFINED DIR_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${DIR_UNPARSED_ARGUMENTS}\"")
  endif()
  if(DEFINED DIR_SCAN)
    _directory_scan()
  elseif(DEFINED DIR_SCAN_DIRS)
    _directory_scan_dirs()
  elseif(DEFINED DIR_FIND_LIB)
    _directory_find_lib()
  elseif(${DIR_COLLECT_SOURCES_BY_LOCATION})
    _directory_collect_sources_by_location()
  elseif(${DIR_COLLECT_SOURCES_BY_POLICY})
    _directory_collect_sources_by_policy()
  else()
    message(FATAL_ERROR "The operation name or arguments are missing!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage
macro(_directory_scan)
  if(NOT DEFINED DIR_SCAN)
    message(FATAL_ERROR "SCAN arguments is missing!")
  endif()
  if((NOT DEFINED DIR_LIST_DIRECTORIES)
    OR (NOT ${DIR_LIST_DIRECTORIES} MATCHES "^(on|off)$"))
    message(FATAL_ERROR "LIST_DIRECTORIES arguments is wrong!")
  endif()
  if((NOT DEFINED DIR_RELATIVE)
    OR (NOT ${DIR_RELATIVE} MATCHES "^(on|off)$"))
    message(FATAL_ERROR "RELATIVE arguments is wrong!")
  endif()
  if(NOT DEFINED DIR_ROOT_DIR)
    message(FATAL_ERROR "ROOT_DIR arguments is missing!")
  endif()
  if((NOT DEFINED DIR_INCLUDE_REGEX)
    AND (NOT DEFINED DIR_EXCLUDE_REGEX))
    message(FATAL_ERROR "INCLUDE_REGEX|EXCLUDE_REGEX arguments is missing!")
  endif()
  if((NOT EXISTS "${DIR_ROOT_DIR}")
    OR (NOT IS_DIRECTORY "${DIR_ROOT_DIR}"))
    message(FATAL_ERROR "Given path: ${DIR_ROOT_DIR} does not refer to an existing path or directory on disk!")
  endif()

  set(files_list "")
  if(${DIR_RELATIVE})
    file(GLOB_RECURSE files_list FOLLOW_SYMLINKS LIST_DIRECTORIES ${DIR_LIST_DIRECTORIES} RELATIVE "${DIR_ROOT_DIR}" CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
  else()
    file(GLOB_RECURSE files_list FOLLOW_SYMLINKS LIST_DIRECTORIES ${DIR_LIST_DIRECTORIES} CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
  endif()
  
  if(DEFINED DIR_INCLUDE_REGEX)
    list(FILTER files_list INCLUDE REGEX "${DIR_INCLUDE_REGEX}")
  elseif(DEFINED DIR_EXCLUDE_REGEX)
    list(FILTER files_list EXCLUDE REGEX "${DIR_EXCLUDE_REGEX}")
  else()
    message(FATAL_ERROR "Invalid arguments: expected INCLUDE_REGEX or EXCLUDE_REGEX!")
  endif()
  
  set(${DIR_SCAN} "${files_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_directory_scan_dirs)
  if(NOT DEFINED DIR_SCAN_DIRS)
    message(FATAL_ERROR "SCAN_DIRS arguments is missing!")
  endif()
  if((NOT DEFINED DIR_RECURSE)
    OR (NOT ${DIR_RECURSE} MATCHES "^(on|off)$"))
    message(FATAL_ERROR "RECURSE arguments is wrong!")
  endif()
  if((NOT DEFINED DIR_RELATIVE)
    OR (NOT ${DIR_RELATIVE} MATCHES "^(on|off)$"))
    message(FATAL_ERROR "RELATIVE arguments is wrong!")
  endif()
  if(NOT DEFINED DIR_ROOT_DIR)
    message(FATAL_ERROR "ROOT_DIR arguments is missing!")
  endif()
  if((NOT DEFINED DIR_INCLUDE_REGEX)
    AND (NOT DEFINED DIR_EXCLUDE_REGEX))
    message(FATAL_ERROR "INCLUDE_REGEX|EXCLUDE_REGEX arguments is missing!")
  endif()
  if((NOT EXISTS "${DIR_ROOT_DIR}")
    OR (NOT IS_DIRECTORY "${DIR_ROOT_DIR}"))
    message(FATAL_ERROR "Given path: ${DIR_ROOT_DIR} does not refer to an existing path or directory on disk!")
  endif()
  
  # Paths should not be relative, but absolute, in order to be able to filter files and keep only folders
  set(files_list "")
  if(${DIR_RECURSE})
    file(GLOB_RECURSE files_list FOLLOW_SYMLINKS LIST_DIRECTORIES on CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
  else()
    file(GLOB files_list LIST_DIRECTORIES on CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
  endif()

  # Keep only directories and compute relative paths if needed
  set(directories_list "")
  foreach(file IN ITEMS ${files_list})
    if(IS_DIRECTORY "${file}")
      if(${DIR_RELATIVE})
        file(RELATIVE_PATH file "${DIR_ROOT_DIR}" "${file}")
      endif()
      list(APPEND directories_list "${file}")
    endif()
  endforeach()

  if(DEFINED DIR_INCLUDE_REGEX)
    list(FILTER directories_list INCLUDE REGEX "${DIR_INCLUDE_REGEX}")
  elseif(DEFINED DIR_EXCLUDE_REGEX)
    list(FILTER directories_list EXCLUDE REGEX "${DIR_EXCLUDE_REGEX}")
  else()
    message(FATAL_ERROR "Invalid arguments: expected INCLUDE_REGEX or EXCLUDE_REGEX!")
  endif()

  set(${DIR_SCAN_DIRS} "${directories_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_directory_find_lib)
  if(NOT DEFINED DIR_FIND_LIB)
    message(FATAL_ERROR "FIND_LIB arguments is missing or need a value!")
  endif()
  if(NOT DEFINED DIR_FIND_IMPLIB)
    message(FATAL_ERROR "FIND_IMPLIB arguments is missing or need a value!")
  endif()
  if(NOT DEFINED DIR_NAME)
    message(FATAL_ERROR "NAME arguments is missing or need a value!")
  endif()
  if((NOT ${DIR_SHARED})
    AND (NOT ${DIR_STATIC}))
    message(FATAL_ERROR "SHARED|STATIC arguments is missing!")
  endif()
  if(${DIR_SHARED} AND ${DIR_STATIC})
    message(FATAL_ERROR "SHARED|STATIC cannot be used together!")
  endif()
  if((NOT DEFINED DIR_RELATIVE)
    OR (NOT ${DIR_RELATIVE} MATCHES "^(on|off)$"))
    message(FATAL_ERROR "RELATIVE arguments is wrong!")
  endif()
  if(NOT DEFINED DIR_ROOT_DIR)
    message(FATAL_ERROR "ROOT_DIR arguments is missing or need a value!")
  endif()
  if((NOT EXISTS "${DIR_ROOT_DIR}")
    OR (NOT IS_DIRECTORY "${DIR_ROOT_DIR}"))
    message(FATAL_ERROR "Given path: ${DIR_ROOT_DIR} does not refer to an existing path or directory on disk!")
  endif()

  set(files_list "")
  if(${DIR_RELATIVE})
    file(GLOB_RECURSE files_list FOLLOW_SYMLINKS LIST_DIRECTORIES off RELATIVE "${DIR_ROOT_DIR}" CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
  else()
    file(GLOB_RECURSE files_list FOLLOW_SYMLINKS LIST_DIRECTORIES off CONFIGURE_DEPENDS "${DIR_ROOT_DIR}/*")
  endif()

  # Select appropriate prefix/suffix sets based on the requested library type
  if(${DIR_SHARED})
    # Shared library (.dll, .so, .dylib): used at runtime (IMPORTED_LOCATION)
    set(lib_prefixes_list "${CMAKE_SHARED_LIBRARY_PREFIX}") # 'lib' on Linux, empty on Windows
    set(lib_suffixes_list "${CMAKE_SHARED_LIBRARY_SUFFIX}") # '.so' on Linux, '.dll' on Windows

    # Import library (.lib, .dll.a, .a): used at link time (IMPORTED_IMPLIB)
    set(implib_prefixes_list "${CMAKE_FIND_LIBRARY_PREFIXES}") # 'empty|lib' on Linux, 'empty|lib' on Windows
    set(implib_suffixes_list "${CMAKE_FIND_LIBRARY_SUFFIXES}") # '.dll.a|.a|.lib' on Linux, '.dll.lib|.lib|.a' on Windows
  elseif(${DIR_STATIC})
    # Static library (.lib, .a): used at link time (no import lib concept)
    set(lib_prefixes_list "${CMAKE_STATIC_LIBRARY_PREFIX}") # 'lib' on Linux, empty on Windows
    set(lib_suffixes_list "${CMAKE_STATIC_LIBRARY_SUFFIX}") # '.a' on Linux, '.lib' on Windows

    # Static libraries do not use import libraries
    set(implib_prefixes_list "")
    set(implib_suffixes_list "")
  else()
    message(FATAL_ERROR "Invalid build type: expected SHARED or STATIC!")
  endif()

  # Build regex to find the binary library (IMPORTED_LOCATION)
  string(REGEX REPLACE [[\.]] [[\\.]] lib_suffixes_list "${lib_suffixes_list}") # escape '.' char
  set(lib_regex "^(${lib_prefixes_list})?${DIR_NAME}(${lib_suffixes_list})$")
  
  # Build regex to find the import library (IMPORTED_IMPLIB), only if applicable
  if(NOT "${implib_suffixes_list}" STREQUAL "")
    list(JOIN implib_prefixes_list "|" implib_prefixes_list)
    list(JOIN implib_suffixes_list "|" implib_suffixes_list)
    string(REGEX REPLACE [[\.]] [[\\.]] implib_suffixes_list "${implib_suffixes_list}") # escape '.' char
    set(implib_regex "^(${implib_prefixes_list})?${DIR_NAME}(${implib_suffixes_list})$")
  else()
    # No import library applicable for static libraries
    set(implib_regex "")
  endif()

  # Search lib and implib
  set(library_found_path "${DIR_FIND_LIB}-NOTFOUND")
  set(import_library_found_path "${DIR_FIND_IMPLIB}-NOTFOUND")
  foreach(file IN ITEMS ${files_list})
    cmake_path(GET file FILENAME file_name)
    if("${file_name}" MATCHES "${lib_regex}")
      # Find library (lib)
      if("${library_found_path}" STREQUAL "${DIR_FIND_LIB}-NOTFOUND")
        set(library_found_path "${file}")
      else()
        message(FATAL_ERROR "At least two matches with the library name \"${DIR_NAME}\"!")
      endif()
    endif()
    if((NOT "${implib_suffixes_list}" STREQUAL "")
      AND ("${file_name}" MATCHES "${implib_regex}"))
      # Find imported library (implib)
      if("${import_library_found_path}" STREQUAL "${DIR_FIND_IMPLIB}-NOTFOUND")
        set(import_library_found_path "${file}")
      else()
        message(FATAL_ERROR "At least two matches with the import library name \"${DIR_NAME}\"!")
      endif()
    endif()
  endforeach()

  set(${DIR_FIND_LIB} "${library_found_path}" PARENT_SCOPE)
  set(${DIR_FIND_IMPLIB} "${import_library_found_path}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_directory_collect_sources_by_location)
  if((NOT DEFINED DIR_SRC_DIR) AND (NOT DEFINED DIR_INCLUDE_DIR))
    message(FATAL_ERROR "At least one of SRC_DIR|INCLUDE_DIR argument is needed!")
  endif()
  if("SRC_DIR" IN_LIST DIR_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "SRC_DIR argument need a value!")
  endif()
  if("INCLUDE_DIR" IN_LIST DIR_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "INCLUDE_DIR argument need a value!")
  endif()
  if(DEFINED DIR_SRC_DIR)
    if((NOT EXISTS "${DIR_SRC_DIR}")
      OR (NOT IS_DIRECTORY "${DIR_SRC_DIR}"))
      message(FATAL_ERROR "Given path: ${DIR_SRC_DIR} does not refer to an existing path or directory on disk!")
    endif()
    if(NOT DEFINED DIR_SRC_SOURCE_FILES)
      message(FATAL_ERROR "SRC_SOURCE_FILES arguments is missing or need a value!")
    endif()
    if(NOT DEFINED DIR_SRC_HEADER_FILES)
      message(FATAL_ERROR "SRC_HEADER_FILES arguments is missing or need a value!")
    endif()
  endif()
  if(DEFINED DIR_INCLUDE_DIR)
    if((NOT EXISTS "${DIR_INCLUDE_DIR}")
      OR (NOT IS_DIRECTORY "${DIR_INCLUDE_DIR}"))
      message(FATAL_ERROR "Given path: ${DIR_INCLUDE_DIR} does not refer to an existing path or directory on disk!")
    endif()
    if(NOT DEFINED DIR_INCLUDE_HEADER_FILES)
      message(FATAL_ERROR "INCLUDE_HEADER_FILES arguments is missing or need a value!")
    endif()
  endif()

  # Get files
  if(DEFINED DIR_SRC_DIR)
    # Get the list of absolute paths to source files (.cpp|.cc|.cxx) stored
    # inside `SRC_DIR` directory
    set(src_source_files_list "")
    directory(SCAN src_source_files_list
      LIST_DIRECTORIES off
      RELATIVE off
      ROOT_DIR "${DIR_SRC_DIR}"
      INCLUDE_REGEX ".*[.]cpp$|.*[.]cc$|.*[.]cxx$"
    )
    set(${DIR_SRC_SOURCE_FILES} "${src_source_files_list}" PARENT_SCOPE)

    # Get the list of absolute path to header files (.h|.hpp|.hxx|.inl|.tpp) stored
    # inside `SRC_DIR` directory
    set(src_header_files_list "")
    directory(SCAN src_header_files_list
      LIST_DIRECTORIES off
      RELATIVE off
      ROOT_DIR "${DIR_SRC_DIR}"
      INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$|.*[.]tpp$"
    )
    set(${DIR_SRC_HEADER_FILES} "${src_header_files_list}" PARENT_SCOPE)
  endif()
  
  if(DEFINED DIR_INCLUDE_DIR)
    # Get the list of absolute path to header files (.h|.hpp|.hxx|.inl|.tpp) stored
    # inside `INCLUDE_DIR` directory
    set(include_header_files_list "")
    directory(SCAN include_header_files_list
      LIST_DIRECTORIES off
      RELATIVE off
      ROOT_DIR "${DIR_INCLUDE_DIR}"
      INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$|.*[.]tpp$"
    )
    set(${DIR_INCLUDE_HEADER_FILES} "${include_header_files_list}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_directory_collect_sources_by_policy)
  if(NOT DEFINED DIR_PRIVATE_SOURCE_DIR)
    message(FATAL_ERROR "PRIVATE_SOURCE_DIR arguments is missing or need a value!")
  endif()
  if(NOT DEFINED DIR_PRIVATE_SOURCE_FILES)
    message(FATAL_ERROR "PRIVATE_SOURCE_FILES arguments is missing!")
  endif()
  if(NOT DEFINED DIR_PUBLIC_HEADER_DIR)
    message(FATAL_ERROR "PUBLIC_HEADER_DIR arguments is missing!")
  endif()
  if(NOT DEFINED DIR_PUBLIC_HEADER_FILES)
    message(FATAL_ERROR "PUBLIC_HEADER_FILES arguments is missing!")
  endif()
  if(NOT DEFINED DIR_PRIVATE_HEADER_DIR)
    message(FATAL_ERROR "PRIVATE_HEADER_DIR arguments is missing!")
  endif()
  if(NOT DEFINED DIR_PRIVATE_HEADER_FILES)
    message(FATAL_ERROR "PRIVATE_HEADER_FILES arguments is missing!")
  endif()
  
  # Check PUBLIC_HEADERS_SEPARATED args
  if(NOT DEFINED DIR_PUBLIC_HEADERS_SEPARATED)
    message(FATAL_ERROR "PUBLIC_HEADERS_SEPARATED arguments is missing!")
  endif()
  list(GET DIR_PUBLIC_HEADERS_SEPARATED 0 is_headers_separated)
  if(NOT ${is_headers_separated} MATCHES "^(on|off)$")
    message(FATAL_ERROR "PUBLIC_HEADERS_SEPARATED arguments is wrong!")
  endif()
  if(${is_headers_separated})
    # Check if the PUBLIC_HEADERS_SEPARATED argument is well formatted
    list(LENGTH DIR_PUBLIC_HEADERS_SEPARATED nb_args_PUBLIC_HEADERS_SEPARATED)
    if(NOT ${nb_args_PUBLIC_HEADERS_SEPARATED} EQUAL 2)
      message(FATAL_ERROR "PUBLIC_HEADERS_SEPARATED argument is missing or wrong!")
    endif()
    
    # Check if `<include-dir-path>` exists
    list(GET DIR_PUBLIC_HEADERS_SEPARATED 1 include_dir_path)
    if((NOT EXISTS "${include_dir_path}")
      OR (NOT IS_DIRECTORY "${include_dir_path}"))
      message(FATAL_ERROR "Given path: ${include_dir_path} does not refer to an existing path or directory on disk!")
    endif()
  endif()
  
  # Collect files
  file(RELATIVE_PATH rel_private_dir_path "${CMAKE_SOURCE_DIR}" "${DIR_PRIVATE_SOURCE_DIR}")
  if(${is_headers_separated})
    file(RELATIVE_PATH rel_public_dir_path "${CMAKE_SOURCE_DIR}" "${include_dir_path}")
    message(VERBOSE "Header separation enabled - publics in \"${rel_public_dir_path}/\", privates in \"${rel_private_dir_path}/\"")
    directory(COLLECT_SOURCES_BY_LOCATION
      SRC_DIR "${DIR_PRIVATE_SOURCE_DIR}"
      SRC_SOURCE_FILES src_source_files_list
      SRC_HEADER_FILES src_header_files_list
      INCLUDE_DIR "${include_dir_path}"
      INCLUDE_HEADER_FILES include_header_files_list
    )
    set(${DIR_PRIVATE_SOURCE_FILES} "${src_source_files_list}" PARENT_SCOPE)
    set(${DIR_PUBLIC_HEADER_DIR} "${include_dir_path}" PARENT_SCOPE)
    set(${DIR_PUBLIC_HEADER_FILES} "${include_header_files_list}" PARENT_SCOPE)
    set(${DIR_PRIVATE_HEADER_DIR} "${DIR_PRIVATE_SOURCE_DIR}" PARENT_SCOPE)
    set(${DIR_PRIVATE_HEADER_FILES} "${src_header_files_list}" PARENT_SCOPE)
  else()
    message(VERBOSE "Header separation disabled - using \"${rel_private_dir_path}/\" headers as public, ignoring \"include/\"")
    directory(COLLECT_SOURCES_BY_LOCATION
      SRC_DIR "${DIR_PRIVATE_SOURCE_DIR}"
      SRC_SOURCE_FILES src_source_files_list
      SRC_HEADER_FILES src_header_files_list
    )
    set(${DIR_PRIVATE_SOURCE_FILES} "${src_source_files_list}" PARENT_SCOPE)
    set(${DIR_PUBLIC_HEADER_DIR} "${DIR_PRIVATE_SOURCE_DIR}" PARENT_SCOPE)
    set(${DIR_PUBLIC_HEADER_FILES} "${src_header_files_list}" PARENT_SCOPE)
    set(${DIR_PRIVATE_HEADER_DIR} "" PARENT_SCOPE)
    set(${DIR_PRIVATE_HEADER_FILES} "" PARENT_SCOPE)
  endif()
endmacro()
