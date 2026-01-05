# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
BinaryTarget
------------

Operations to fully create and configure a *C++* binary target. It greatly
simplifies the most common process of creating an executable or library, by
wrapping calls to CMake functions in higher-level functions. However, for more
complex cases, you will need to use CMake's native commands. It requires CMake
4.0.1 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  binary_target(`CREATE`_ <target-name> <STATIC|SHARED|HEADER|EXEC>)
  binary_target(`CONFIGURE_SETTINGS`_ <target-name> [...])
  binary_target(`ADD_SOURCES`_ <target-name> [...])
  binary_target(`ADD_PRECOMPILE_HEADER`_ <target-name> HEADER_FILE <file-path>)
  binary_target(`ADD_INCLUDE_DIRECTORIES`_ <target-name> PRIVATE [<dir-path>...|<gen-expr>...])
  binary_target(`ADD_LINK_LIBRARIES`_ <target-name> PUBLIC [<target-name>...|<gen-expr>...])
  binary_target(`CREATE_FULLY`_ <target-name> [...])

Usage
^^^^^

.. signature::
  binary_target(CREATE <target-name> <STATIC|SHARED|HEADER|EXEC>)

  Create a binary target named ``<PROJECT_NAME>_<target-name>`` and add it to
  the current CMake project, according to the specified binary type: ``STATIC``
  , ``SHARED``, ``HEADER``, ``EXEC``. Note that the logical name of the target
  ``<target-name>`` is prefixed with ``<PROJECT_NAME>_`` in order to follow
  best practices. That is also why an aliased target is created with the name
  ``<PROJECT_NAME>::<target-name>``, and the target properties
  :cmake:prop_tgt:`OUTPUT_NAME <cmake:prop_tgt:OUTPUT_NAME>` and
  :cmake:prop_tgt:`EXPORT_NAME <cmake:prop_tgt:EXPORT_NAME>` are set to
  ``<target-name>``.

  A ``STATIC`` library forces ``BUILD_SHARED_LIBS`` to ``off`` and a ``SHARED``
  library sets visibility and export-related variables before creating the
  target:

    * ``BUILD_SHARED_LIBS`` is set to ``on``.
    * ``CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS`` is set to ``off`` to disable
      automatic symbol exports on Windows.
    * ``CMAKE_CXX_VISIBILITY_PRESET`` is set to ``hidden`` to hide symbols
      by default.
    * ``CMAKE_VISIBILITY_INLINES_HIDDEN`` is set to ``on`` so that inline
      symbols follow the same visibility rules.

  Example usage:

  .. code-block:: cmake

    binary_target(CREATE "my_static_lib" STATIC)
    binary_target(CREATE "my_shared_lib" SHARED)

.. signature::
  binary_target(CONFIGURE_SETTINGS <target-name> [...])

  Configure settings for an existing binary target:

  .. code-block:: cmake

    binary_target(CONFIGURE_SETTINGS <target-name>
                 COMPILE_FEATURES [<feature>...]
                 COMPILE_DEFINITIONS [<definition>...]
                 COMPILE_OPTIONS [<option>...]
                 LINK_OPTIONS [<option>...])

  This command updates compile and link settings of a previously created
  target ``<target-name>`` with ``PRIVATE`` visibility. The following
  configuration options are supported:

  * ``COMPILE_FEATURES``: Add required compile features (e.g., ``cxx_std_20``,
    ``cxx_thread_local``, ``cxx_trailing_return_types``, etc.) with
    :cmake:command:`target_compile_features() <cmake:command:target_compile_features>`
    and populates the :cmake:prop_tgt:`COMPILE_FEATURES <cmake:prop_tgt:COMPILE_FEATURES>` target property.
  * ``COMPILE_DEFINITIONS``: Add preprocessor definitions (e.g., ``DEFINE_ONE=1``
    , ``DEFINE_TWO=2``, ``OPTION_1``, etc.) with
    :cmake:command:`target_compile_definitions() <cmake:command:target_compile_definitions>`
    and populates :cmake:prop_tgt:`COMPILE_OPTIONS <cmake:prop_tgt:COMPILE_DEFINITIONS>` target property.
  * ``COMPILE_OPTIONS``: Add compiler command-line options (e.g., ``-Wall``,
    ``-Wextra``, ``/W4``, etc.) with :cmake:command:`target_compile_options() <cmake:command:target_compile_options>`
    and populates :cmake:prop_tgt:`COMPILE_OPTIONS <cmake:prop_tgt:COMPILE_OPTIONS>` target property.
  * ``LINK_OPTIONS``: Add linker command-line options (e.g., ``-s``, ``-z``, 
    ``/INCREMENTAL:NO``, etc.) with :cmake:command:`target_link_options() <cmake:command:target_link_options>`
    and populates :cmake:prop_tgt:`LINK_OPTIONS <cmake:prop_tgt:LINK_OPTIONS>` target property.

  The command automatically adds compile feature ``cxx_std_<CMAKE_CXX_STANDARD>``
  to the target to set the :cmake:prop_tgt:`CXX_STANDARD <cmake:prop_tgt:CXX_STANDARD>`
  property, using the value of :cmake:variable:`CMAKE_CXX_STANDARD <cmake:variable:CMAKE_CXX_STANDARD>`.
  However, to avoid unnecessary duplication, it first checks whether the
  compile feature is already assigned to the target or in the arguments. An
  error is raised if :cmake:variable:`CMAKE_CXX_STANDARD <cmake:variable:CMAKE_CXX_STANDARD>` is not defined.

  The target is also assigned to a default folder for improved IDE
  integration. All options are optional and may appear in any order. If a
  section is missing, it is simply ignored without warning.

  This command is intended for targets that have been previously created
  using :command:`binary_target(CREATE)`.

  Example usage:

  .. code-block:: cmake

    binary_target(CREATE "my_shared_lib" SHARED)
    binary_target(CONFIGURE_SETTINGS "<PROJECT_NAME>_my_shared_lib"
      COMPILE_FEATURES "cxx_std_20" "cxx_thread_local" "cxx_trailing_return_types"
      COMPILE_DEFINITIONS "DEFINE_ONE=1" "DEFINE_TWO=2" "OPTION_1"
      COMPILE_OPTIONS "-Wall" "-Wextra"
      LINK_OPTIONS "-s" "-z"
    )

.. signature::
  binary_target(ADD_SOURCES <target-name> [...])

  Add source and header files to an existing binary target:

  .. code-block:: cmake

    binary_target(ADD_SOURCES <target-name>
                 SOURCE_FILES [<file-path>...]
                 PRIVATE_HEADER_FILES [<file-path>...]
                 PUBLIC_HEADER_FILES [<file-path>...])

  Assigns implementation and header files to the given binary target
  ``<target-name>`` with ``PRIVATE`` visibility:

  * ``SOURCE_FILES``: A list of source files (e.g., ``.cpp``, ``.c``)
    typically located in the ``src/`` directory.
  * ``PRIVATE_HEADER_FILES``: A list of private headers (e.g., ``.h``)
    typically located in the ``src/`` directory.
  * ``PUBLIC_HEADER_FILES``: A list of public headers, usually found in an
    ``include/`` directory.

  These files are added to the target with :cmake:command:`target_sources() <cmake:command:target_sources>` to populate
  the :cmake:prop_tgt:`SOURCES <cmake:prop_tgt:SOURCES>` target property.
  The command also defines a logical grouping of source files in IDEs (e.g.,
  Visual Studio) using :cmake:command:`source_group() <cmake:command:source_group>`,
  based on the project's source tree.

  This command is intended for targets that have been previously created
  using :command:`binary_target(CREATE)`, and is typically used in conjunction
  with :command:`directory(COLLECT_SOURCES_BY_POLICY)` to get the required
  files.

  Example usage:

  .. code-block:: cmake

    binary_target(CREATE "my_static_lib" STATIC)
    binary_target(ADD_SOURCES "<PROJECT_NAME>_my_static_lib"
      SOURCE_FILES "src/main.cpp" "src/util.cpp" "src/source_1.cpp"
      PRIVATE_HEADER_FILES "src/util.h" "src/source_1.h"
      PUBLIC_HEADER_FILES "include/lib_1.h" "include/lib_2.h"
    )

    # Or with `directory(COLLECT_SOURCES_BY_POLICY)`
    binary_target(CREATE "my_static_lib" STATIC)
    directory(COLLECT_SOURCES_BY_POLICY
      PUBLIC_HEADERS_SEPARATED true "${CMAKE_SOURCE_DIR}/include/mylib"
      PRIVATE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/src"
      PRIVATE_SOURCE_FILES private_sources
      PUBLIC_HEADER_DIR public_header_dir
      PUBLIC_HEADER_FILES public_headers
      PRIVATE_HEADER_DIR private_header_dir
      PRIVATE_HEADER_FILES private_headers
    )
    binary_target(ADD_SOURCES "<PROJECT_NAME>_my_static_lib"
      SOURCE_FILES "${private_sources}"
      PRIVATE_HEADER_FILES "${private_headers}"
      PUBLIC_HEADER_FILES "${public_headers}"
    )

.. signature::
  binary_target(ADD_PRECOMPILE_HEADER <target-name> HEADER_FILE <file-path>)

  Add a precompile header file (PCH) ``<file-path>`` to an existing binary
  target ``<target-name>`` with ``PRIVATE`` visibility.

  This function is just a wrapper around
  :cmake:command:`target_precompile_headers() <cmake:command:target_precompile_headers>`
  that populates the :cmake:prop_tgt:`PRECOMPILE_HEADERS <cmake:prop_tgt:PRECOMPILE_HEADERS>`
  target property, so it follows the same specifications.

  It is intended for targets that have been previously created using
  :command:`binary_target(CREATE)`.

  Example usage:

  .. code-block:: cmake

    binary_target(CREATE "my_static_lib" STATIC)
    binary_target(ADD_PRECOMPILE_HEADER "<PROJECT_NAME>_my_static_lib"
      HEADER_FILE "src/header_pch.h"
    )

.. signature::
  binary_target(ADD_INCLUDE_DIRECTORIES <target-name> PRIVATE [<dir-path>...|<gen-expr>...])

  Add include directories to an existing binary target ``<target-name>`` with
  ``PRIVATE`` visibility. The ``PRIVATE`` keyword is passed with the list of
  directory paths to add to ``<target-name>``, or with generator expressions
  with the syntax ``$<...>``. No checks are performed out on the nature and existence of
  the values associated with PRIVATE.

  This function is just a wrapper around
  :cmake:command:`target_include_directories() <cmake:command:target_include_directories>`
  that populates the :cmake:prop_tgt:`INCLUDE_DIRECTORIES <cmake:prop_tgt:INCLUDE_DIRECTORIES>`
  target property, so it follows the same specifications.

  It is intended for targets that have been previously created using
  :command:`binary_target(CREATE)`, and is typically used in conjunction with
  :command:`directory(COLLECT_SOURCES_BY_POLICY)` to get the required
  files.

  Example usage:

  .. code-block:: cmake

    binary_target(CREATE "my_static_lib" STATIC)
    binary_target(ADD_INCLUDE_DIRECTORIES "my_static_lib"
      PRIVATE "include"
    )

.. signature::
  binary_target(ADD_LINK_LIBRARIES <target-name> PUBLIC [<target-name>...|<gen-expr>...])

  Add ``PUBLIC`` libraries to use when linking an existing binary target
  ``<target-name>``. The ``PUBLIC`` keyword is passed with the list of names of
  other targets to link to ``<target-name>``, or with generator expressions with
  the syntax ``$<...>``.

  This function is just a wrapper around
  :cmake:command:`target_link_libraries() <cmake:command:target_link_libraries>`
  that populates the :cmake:prop_tgt:`LINK_LIBRARIES <cmake:prop_tgt:LINK_LIBRARIES>`
  target property, so it follows the same specifications.

  It is intended for targets that have been previously created using
  :command:`binary_target(CREATE)`.

  Example usage:

  .. code-block:: cmake

    # With target name
    binary_target(CREATE "my_static_lib" STATIC)
    binary_target(ADD_LINK_LIBRARIES "<PROJECT_NAME>_my_static_lib"
      PUBLIC "dep_1" "dep_2"
    )

    # With generator expression
    binary_target(CREATE "my_static_lib" STATIC)
    binary_target(ADD_LINK_LIBRARIES "<PROJECT_NAME>_my_static_lib"
      PUBLIC
        "$<BUILD_INTERFACE:dep_1;dep_2>"
        "$<INSTALL_INTERFACE:dep_1;dep_2>"
    )

.. signature::
  binary_target(CREATE_FULLY <target-name> [...])

  Create a fully configured binary target:

  .. code-block:: cmake

    binary_target(CREATE_FULLY <target-name>
                  <STATIC|SHARED|HEADER|EXEC>
                  [COMPILE_FEATURES <feature>...]
                  [COMPILE_DEFINITIONS <definition>...]
                  [COMPILE_OPTIONS <option>...]
                  [LINK_OPTIONS <option>...]
                  SOURCE_FILES [<file-path>...]
                  PRIVATE_HEADER_FILES [<file-path>...]
                  PUBLIC_HEADER_FILES [<file-path>...]
                  [PRECOMPILE_HEADER_FILE <file-path>]
                  INCLUDE_DIRECTORIES [<dir-path>...|<gen-expr>...]
                  [LINK_LIBRARIES [<target-name>...|<gen-expr>...] ])

  Create a fully configured binary target named ``<target-name>`` and add it
  to the current project. This command acts as a high-level wrapper that
  combines the behavior of other module sub-commands, including
  :command:`binary_target(CREATE)`, :command:`binary_target(CONFIGURE_SETTINGS)`,
  :command:`binary_target(ADD_SOURCES)`, :command:`binary_target(ADD_PRECOMPILE_HEADER)`,
  :command:`binary_target(ADD_INCLUDE_DIRECTORIES)`, and :command:`binary_target(ADD_LINK_LIBRARIES)`.

  The second argument must specify the type of binary target to create:
  ``STATIC``, ``SHARED``, ``HEADER``, or ``EXEC``. Only one type may be given.

  Additional parameters can be provided to configure compile options,
  precompiled headers, include directories, and target dependencies. Each of
  these keywords delegates internally to the corresponding
  :module:`BinaryTarget` command. See their documentation for details.

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
    binary_target(
      CREATE_FULLY "my_shared_lib"
      SHARED
      COMPILE_FEATURES "cxx_std_20" "cxx_thread_local" "cxx_trailing_return_types"
      COMPILE_DEFINITIONS "DEFINE_ONE=1" "DEFINE_TWO=2" "OPTION_1"
      COMPILE_OPTIONS "-Wall" "-Wextra"
      LINK_OPTIONS "-s" "-z"
      SOURCE_FILES "${private_sources}"
      PRIVATE_HEADER_FILES "${private_headers}"
      PUBLIC_HEADER_FILES "${public_headers}"
      PRECOMPILE_HEADER_FILE "src/header_pch.h"
      INCLUDE_DIRECTORIES "$<$<BOOL:${private_header_dir}>:${private_header_dir}>" "${public_header_dir}"
      LINK_LIBRARIES "dep_1" "dep_2"
    )

Full example
^^^^^^^^^^^^

This example shows how to call the module functions to create a complete
binary.

.. code-block:: cmake

  binary_target(CREATE "my_shared_lib" SHARED)
  binary_target(CONFIGURE_SETTINGS "my_shared_lib"
    COMPILE_FEATURES "cxx_std_20" "cxx_thread_local" "cxx_trailing_return_types"
    COMPILE_DEFINITIONS "DEFINE_ONE=1" "DEFINE_TWO=2" "OPTION_1"
    COMPILE_OPTIONS "-Wall" "-Wextra"
    LINK_OPTIONS "-s" "-z"
  )
  directory(COLLECT_SOURCES_BY_POLICY
    PUBLIC_HEADERS_SEPARATED true "${CMAKE_SOURCE_DIR}/include/mylib"
    PRIVATE_SOURCE_DIR "${CMAKE_SOURCE_DIR}/src"
    PRIVATE_SOURCE_FILES private_sources
    PUBLIC_HEADER_DIR public_header_dir
    PUBLIC_HEADER_FILES public_headers
    PRIVATE_HEADER_DIR private_header_dir
    PRIVATE_HEADER_FILES private_headers
  )
  binary_target(ADD_SOURCES "my_shared_lib"
    SOURCE_FILES "${private_sources}"
    PRIVATE_HEADER_FILES "${private_headers}"
    PUBLIC_HEADER_FILES "${public_headers}"
  )
  binary_target(ADD_PRECOMPILE_HEADER "my_shared_lib"
    HEADER_FILE "src/header_pch.h"
  )
  binary_target(ADD_INCLUDE_DIRECTORIES "my_shared_lib"
    PRIVATE "$<$<BOOL:${private_header_dir}>:${private_header_dir}>" "${public_header_dir}"
  )
#]=======================================================================]

include_guard()

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(binary_target)
  set(options STATIC SHARED HEADER EXEC)
  set(one_value_args CREATE CONFIGURE_SETTINGS ADD_SOURCES ADD_PRECOMPILE_HEADER HEADER_FILE ADD_INCLUDE_DIRECTORIES ADD_LINK_LIBRARIES CREATE_FULLY PRECOMPILE_HEADER_FILE)
  set(multi_value_args COMPILE_FEATURES COMPILE_DEFINITIONS COMPILE_OPTIONS LINK_OPTIONS SOURCE_FILES PRIVATE_HEADER_FILES PUBLIC_HEADER_FILES PRIVATE INCLUDE_DIRECTORIES PUBLIC LINK_LIBRARIES)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${one_value_args}" "${multi_value_args}"
  )

  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"")
  endif()
  if(DEFINED arg_CREATE)
    set(current_command "binary_target(CREATE)")
    _binary_target_create()
  elseif(DEFINED arg_CREATE_FULLY)
    set(current_command "binary_target(CREATE_FULLY)")
    _binary_target_create_fully()
  elseif(DEFINED arg_CONFIGURE_SETTINGS)
    set(current_command "binary_target(CONFIGURE_SETTINGS)")
    _binary_target_config_settings()
  elseif(DEFINED arg_ADD_SOURCES)
    set(current_command "binary_target(ADD_SOURCES)")
    _binary_target_add_sources()
  elseif(DEFINED arg_ADD_PRECOMPILE_HEADER)
    set(current_command "binary_target(ADD_PRECOMPILE_HEADER)")
    _binary_target_add_pre_header()
  elseif(DEFINED arg_ADD_INCLUDE_DIRECTORIES)
    set(current_command "binary_target(ADD_INCLUDE_DIRECTORIES)")
    _binary_target_add_include_dirs()
  elseif(DEFINED arg_ADD_LINK_LIBRARIES)
    set(current_command "binary_target(ADD_LINK_LIBRARIES)")
    _binary_target_add_link_libraries()
  else()
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}(<OP> <value> ...) requires an operation and a value to be specified!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_binary_target_create)
  if((NOT DEFINED arg_CREATE)
      OR ("${arg_CREATE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword CREATE to be provided with a non-empty string value!")
  endif()
  if(TARGET "${PROJECT_NAME}_${arg_CREATE}")
    message(FATAL_ERROR "${current_command} requires the target \"${PROJECT_NAME}_${arg_CREATE}\" does not already exist!")
  endif()
  if(TARGET "${PROJECT_NAME}::${arg_CREATE}")
    message(FATAL_ERROR "${current_command} requires the aliased target \"${PROJECT_NAME}::${arg_CREATE}\" does not already exist!")
  endif()
  if((NOT ${arg_STATIC})
      AND (NOT ${arg_SHARED})
      AND (NOT ${arg_HEADER})
      AND (NOT ${arg_EXEC}))
    message(FATAL_ERROR "${current_command} requires the keyword SHARED, STATIC, HEADER or EXEC to be provided!")
  endif()
  if(${arg_STATIC} AND ${arg_SHARED} AND ${arg_HEADER} AND ${arg_EXEC})
    message(FATAL_ERROR "${current_command} requires SHARED, STATIC, HEADER and EXEC not to be used together, they are mutually exclusive!")
  endif()

  set(bin_target_fullname "${PROJECT_NAME}_${arg_CREATE}")
  set(bin_target_aliasname "${PROJECT_NAME}::${arg_CREATE}")
  if(${arg_STATIC})
    # All libraries will be built static unless the library was explicitly
    # added as a shared library
    set(BUILD_SHARED_LIBS off)
    add_library("${bin_target_fullname}" STATIC)
    add_library("${bin_target_aliasname}" ALIAS "${bin_target_fullname}")
  elseif(${arg_SHARED})
    # All libraries will be built shared unless the library was explicitly
    # added as a static library
    set(BUILD_SHARED_LIBS                  on)
    set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS   off)
    set(CMAKE_CXX_VISIBILITY_PRESET        "hidden")
    set(CMAKE_VISIBILITY_INLINES_HIDDEN    on)
    message(VERBOSE "Symbol visibility is configured as: no automatic exports, hidden by default, inline hidden")
    add_library("${bin_target_fullname}" SHARED)
    add_library("${bin_target_aliasname}" ALIAS "${bin_target_fullname}")
  elseif(${arg_HEADER})
    add_library("${bin_target_fullname}" INTERFACE)
    add_library("${bin_target_aliasname}" ALIAS "${bin_target_fullname}")
  elseif(${arg_EXEC})
    add_executable("${bin_target_fullname}")
    add_executable("${bin_target_aliasname}" ALIAS "${bin_target_fullname}")
  else()
    message(FATAL_ERROR "${current_command} called with an invalid binary type: expected STATIC, SHARED, HEADER or EXEC!")
  endif()
  set_target_properties("${bin_target_fullname}" PROPERTIES
    OUTPUT_NAME "${arg_CREATE}"
    EXPORT_NAME "${arg_CREATE}"
  )
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_binary_target_config_settings)
  if((NOT DEFINED arg_CONFIGURE_SETTINGS)
      OR ("${arg_CONFIGURE_SETTINGS}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword CONFIGURE_SETTINGS to be provided with a non-empty string value!")
  endif()
  if(NOT TARGET "${arg_CONFIGURE_SETTINGS}")
    message(FATAL_ERROR "${current_command} requires the target \"${arg_CONFIGURE_SETTINGS}\" to already exist!")
  endif()
  if((NOT DEFINED arg_COMPILE_FEATURES)
      AND (NOT "COMPILE_FEATURES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword COMPILE_FEATURES to be provided!")
  endif()
  if((NOT DEFINED arg_COMPILE_DEFINITIONS)
      AND (NOT "COMPILE_DEFINITIONS" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword COMPILE_DEFINITIONS to be provided!")
  endif()
  if((NOT DEFINED arg_COMPILE_OPTIONS)
      AND (NOT "COMPILE_OPTIONS" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword COMPILE_OPTIONS to be provided!")
  endif()
  if((NOT DEFINED arg_LINK_OPTIONS)
      AND (NOT "LINK_OPTIONS" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword LINK_OPTIONS to be provided!")
  endif()
  if(NOT DEFINED CMAKE_CXX_STANDARD)
    message(FATAL_ERROR "${current_command} requires the variable CMAKE_CXX_STANDARD to be set!")
  endif()

  # Add the bin target in a folder for IDE project
  set_target_properties("${arg_CONFIGURE_SETTINGS}" PROPERTIES FOLDER "")

  # Add input target compile features
  if(DEFINED arg_COMPILE_FEATURES)
    target_compile_features("${arg_CONFIGURE_SETTINGS}"
      PRIVATE
        ${arg_COMPILE_FEATURES}
    )
  endif()

  # Add input target compile definitions
  if(DEFINED arg_COMPILE_DEFINITIONS)
    target_compile_definitions("${arg_CONFIGURE_SETTINGS}"
      PRIVATE
        ${arg_COMPILE_DEFINITIONS}
    )
  endif()

  # Add input target compile options
  if(DEFINED arg_COMPILE_OPTIONS)
    target_compile_options("${arg_CONFIGURE_SETTINGS}"
      PRIVATE
        ${arg_COMPILE_OPTIONS}
    )
  endif()

  # Add input target link options
  if(DEFINED arg_LINK_OPTIONS)
    get_target_property(bin_type "${arg_CONFIGURE_SETTINGS}" TYPE)
    if(bin_type STREQUAL "STATIC_LIBRARY")
      message(FATAL_ERROR "${current_command}: no link options can be added to a static library!")
    endif()
    target_link_options("${arg_CONFIGURE_SETTINGS}"
      PRIVATE
        ${arg_LINK_OPTIONS}
    )
  endif()

  # Add C++ standard in target compile features if not already set
  set(cxx_standard "cxx_std_${CMAKE_CXX_STANDARD}")
  get_target_property(compile_features "${arg_CONFIGURE_SETTINGS}" COMPILE_FEATURES)
  list(FIND compile_features "${cxx_standard}" index_of)
  if(index_of EQUAL -1)
    message(VERBOSE "Setting target C++ standard to C++${CMAKE_CXX_STANDARD} by adding ${cxx_standard} to compile features")
    target_compile_features("${arg_CONFIGURE_SETTINGS}" PRIVATE "${cxx_standard}")
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_binary_target_add_sources)
  if((NOT DEFINED arg_ADD_SOURCES)
      OR ("${arg_ADD_SOURCES}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword ADD_SOURCES to be provided with a non-empty string value!")
  endif()
  if(NOT TARGET "${arg_ADD_SOURCES}")
    message(FATAL_ERROR "${current_command} requires the target \"${arg_ADD_SOURCES}\" to already exist!")
  endif()
  if((NOT DEFINED arg_SOURCE_FILES)
      AND (NOT "SOURCE_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword SOURCE_FILES to be provided!")
  endif()
  if((NOT DEFINED arg_PRIVATE_HEADER_FILES)
      AND (NOT "PRIVATE_HEADER_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword PRIVATE_HEADER_FILES to be provided!")
  endif()
  if((NOT DEFINED arg_PUBLIC_HEADER_FILES)
      AND (NOT "PUBLIC_HEADER_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword PUBLIC_HEADER_FILES to be provided!")
  endif()

  message(VERBOSE "Attaching sources and headers to target")
  message(VERBOSE "Structuring source groups to match project tree")
  if(DEFINED arg_SOURCE_FILES)
    target_sources("${arg_ADD_SOURCES}" PRIVATE ${arg_SOURCE_FILES})
    source_group(TREE "${CMAKE_SOURCE_DIR}"
      FILES ${arg_SOURCE_FILES}
    )
  endif()
  if(DEFINED arg_PRIVATE_HEADER_FILES)
    target_sources("${arg_ADD_SOURCES}" PRIVATE ${arg_PRIVATE_HEADER_FILES})
    source_group(TREE "${CMAKE_SOURCE_DIR}"
      FILES ${arg_PRIVATE_HEADER_FILES}
    )
  endif()
  if(DEFINED arg_PUBLIC_HEADER_FILES)
    target_sources("${arg_ADD_SOURCES}" PRIVATE ${arg_PUBLIC_HEADER_FILES})
    source_group(TREE "${CMAKE_SOURCE_DIR}"
      FILES ${arg_PUBLIC_HEADER_FILES}
    )
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_binary_target_add_pre_header)
  if((NOT DEFINED arg_ADD_PRECOMPILE_HEADER)
      OR ("${arg_ADD_PRECOMPILE_HEADER}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword ADD_PRECOMPILE_HEADER to be provided with a non-empty string value!")
  endif()
  if(NOT TARGET "${arg_ADD_PRECOMPILE_HEADER}")
    message(FATAL_ERROR "${current_command} requires the target \"${arg_ADD_PRECOMPILE_HEADER}\" to already exist!")
  endif()
  if((NOT DEFINED arg_HEADER_FILE)
      OR (NOT EXISTS "${arg_HEADER_FILE}")
      OR (IS_DIRECTORY "${arg_HEADER_FILE}"))
    message(FATAL_ERROR "${current_command} requires the keyword HEADER_FILE '${arg_HEADER_FILE}' to be provided with a path to an existing file on disk!")
  endif()

  target_precompile_headers("${arg_ADD_PRECOMPILE_HEADER}"
    PRIVATE
      ${arg_HEADER_FILE}
  )
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_binary_target_add_include_dirs)
  if((NOT DEFINED arg_ADD_INCLUDE_DIRECTORIES)
      OR ("${arg_ADD_INCLUDE_DIRECTORIES}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword ADD_INCLUDE_DIRECTORIES to be provided with a non-empty string value!")
  endif()
  if(NOT TARGET "${arg_ADD_INCLUDE_DIRECTORIES}")
    message(FATAL_ERROR "${current_command} requires the target \"${arg_ADD_INCLUDE_DIRECTORIES}\" to already exist!")
  endif()
  if((NOT DEFINED arg_PRIVATE)
      AND (NOT "PRIVATE" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword PRIVATE to be provided!")
  endif()
  
  if(DEFINED arg_PRIVATE)
    target_include_directories("${arg_ADD_INCLUDE_DIRECTORIES}"
      # @see https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-specification-and-usage-requirements
      # and https://stackoverflow.com/questions/26243169/cmake-target-include-directories-meaning-of-scope
      # and https://cmake.org/pipermail/cmake/2017-October/066457.html.
      # If PRIVATE is specified for a certain option/property, then that option
      # /property will only impact the current target.
      # If PUBLIC is specified, then the option/property impacts both the current
      # target and any others that link to it (consummers).
      # If INTERFACE is specified, then the option/property does not impact the
      # current target but will propagate to other targets that link to it
      # (consummers).
      # When a target A depends on target B, then A is the consumer and B is the
      # provider.
      PRIVATE
        ${arg_PRIVATE}
    )
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_binary_target_add_link_libraries)
  if((NOT DEFINED arg_ADD_LINK_LIBRARIES)
      OR ("${arg_ADD_LINK_LIBRARIES}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword ADD_LINK_LIBRARIES to be provided with a non-empty string value!")
  endif()
  if(NOT TARGET "${arg_ADD_LINK_LIBRARIES}")
    message(FATAL_ERROR "${current_command} requires the target \"${arg_ADD_LINK_LIBRARIES}\" to already exist!")
  endif()
  if((NOT DEFINED arg_PUBLIC)
      AND (NOT "PUBLIC" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword PUBLIC to be provided!")
  endif()

  if(DEFINED arg_PUBLIC)
    target_link_libraries("${arg_ADD_LINK_LIBRARIES}"
      PUBLIC
        ${arg_PUBLIC}
    )
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_binary_target_create_fully)
  if((NOT DEFINED arg_CREATE_FULLY)
      OR ("${arg_CREATE_FULLY}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword CREATE_FULLY to be provided with a non-empty string value!")
  endif()
  if(TARGET "${arg_CREATE_FULLY}")
    message(FATAL_ERROR "${current_command} requires the target \"${arg_CREATE_FULLY}\" does not already exist!")
  endif()
  if((NOT ${arg_STATIC})
      AND (NOT ${arg_SHARED})
      AND (NOT ${arg_HEADER})
      AND (NOT ${arg_EXEC}))
    message(FATAL_ERROR "${current_command} requires the keyword SHARED, STATIC, HEADER or EXEC to be provided!")
  endif()
  if(${arg_STATIC} AND ${arg_SHARED} AND ${arg_HEADER} AND ${arg_EXEC})
    message(FATAL_ERROR "${current_command} requires SHARED, STATIC, HEADER and EXEC not to be used together, they are mutually exclusive!")
  endif()
  if("COMPILE_FEATURES" IN_LIST arg_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "${current_command} requires the keyword COMPILE_FEATURES to be provided with at least one value!")
  endif()
  if("COMPILE_DEFINITIONS" IN_LIST arg_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "${current_command} requires the keyword COMPILE_DEFINITIONS to be provided with at least one value!")
  endif()
  if("COMPILE_OPTIONS" IN_LIST arg_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "${current_command} requires the keyword COMPILE_OPTIONS to be provided with at least one value!")
  endif()
  if("LINK_OPTIONS" IN_LIST arg_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "${current_command} requires the keyword LINK_OPTIONS to be provided with at least one value!")
  endif()
  if(NOT DEFINED CMAKE_CXX_STANDARD)
    message(FATAL_ERROR "${current_command} requires the variable CMAKE_CXX_STANDARD to be set!")
  endif()
  if((NOT DEFINED arg_SOURCE_FILES)
      AND (NOT "SOURCE_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword SOURCE_FILES to be provided!")
  endif()
  if((NOT DEFINED arg_PRIVATE_HEADER_FILES)
      AND (NOT "PRIVATE_HEADER_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword PRIVATE_HEADER_FILES to be provided!")
  endif()
  if((NOT DEFINED arg_PUBLIC_HEADER_FILES)
      AND (NOT "PUBLIC_HEADER_FILES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword PUBLIC_HEADER_FILES to be provided!")
  endif()
  if((DEFINED arg_PRECOMPILE_HEADER_FILE)
      AND ((NOT EXISTS "${arg_PRECOMPILE_HEADER_FILE}")
          OR (IS_DIRECTORY "${arg_PRECOMPILE_HEADER_FILE}")))
    message(FATAL_ERROR "${current_command} requires the keyword PRECOMPILE_HEADER_FILE '${arg_PRECOMPILE_HEADER_FILE}' to be provided with a path to an existing file on disk!")
  endif()
  if((NOT DEFINED arg_INCLUDE_DIRECTORIES)
      AND (NOT "INCLUDE_DIRECTORIES" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword INCLUDE_DIRECTORIES to be provided!")
  endif()

  # Call binary_target(CREATE)
  set(arg_CREATE "${arg_CREATE_FULLY}")
  _binary_target_create()

  # Call binary_target(CONFIGURE_SETTINGS)
  set(arg_CONFIGURE_SETTINGS "${PROJECT_NAME}_${arg_CREATE_FULLY}")
  if(NOT DEFINED arg_COMPILE_FEATURES)
    list(APPEND arg_KEYWORDS_MISSING_VALUES "COMPILE_FEATURES")
  endif()
  if(NOT DEFINED arg_COMPILE_DEFINITIONS)
    list(APPEND arg_KEYWORDS_MISSING_VALUES "COMPILE_DEFINITIONS")
  endif()
  if(NOT DEFINED arg_COMPILE_OPTIONS)
    list(APPEND arg_KEYWORDS_MISSING_VALUES "COMPILE_OPTIONS")
  endif()
  if(NOT DEFINED arg_LINK_OPTIONS)
    list(APPEND arg_KEYWORDS_MISSING_VALUES "LINK_OPTIONS")
  endif()
  _binary_target_config_settings()

  # Call binary_target(ADD_SOURCES)
  set(arg_ADD_SOURCES "${PROJECT_NAME}_${arg_CREATE_FULLY}")
  _binary_target_add_sources()

  # Call binary_target(ADD_PRECOMPILE_HEADER)
  if(DEFINED arg_PRECOMPILE_HEADER_FILE)
    set(arg_ADD_PRECOMPILE_HEADER "${PROJECT_NAME}_${arg_CREATE_FULLY}")
    set(arg_HEADER_FILE "${arg_PRECOMPILE_HEADER_FILE}")
    _binary_target_add_pre_header()
  endif()

  # Call binary_target(ADD_INCLUDE_DIRECTORIES)
  set(arg_ADD_INCLUDE_DIRECTORIES "${PROJECT_NAME}_${arg_CREATE_FULLY}")
  set(arg_PRIVATE "${arg_INCLUDE_DIRECTORIES}")
  _binary_target_add_include_dirs()

  # Call binary_target(ADD_LINK_LIBRARIES)
  if(DEFINED arg_LINK_LIBRARIES)
    set(arg_ADD_LINK_LIBRARIES "${PROJECT_NAME}_${arg_CREATE_FULLY}")
    set(arg_PUBLIC "${arg_LINK_LIBRARIES}")
    _binary_target_add_link_libraries()
  endif()
endmacro()