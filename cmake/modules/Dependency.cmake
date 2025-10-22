# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Dependency
----------

Operations to manipule dependencies. They mainly encapsulate the numerous
function calls required to `import and export dependencies <https://cmake.org/cmake/help/latest/guide/importing-exporting/index.html>`__.
It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  dependency(`BUILD`_ <lib-target-name> [...])
  dependency(`IMPORT`_ <lib-target-name> [...])
  dependency(`ADD_INCLUDE_DIRECTORIES`_ <lib-target-name> <SET|APPEND> PUBLIC <gen-expr>...)
  dependency(`SET_IMPORTED_LOCATION`_ <lib-target-name> [CONFIGURATION <config-type>] PUBLIC <gen-expr>...)
  dependency(`EXPORT`_ <lib-target-name>... <BUILD_TREE|INSTALL_TREE> [APPEND] OUTPUT_FILE <file-name>)

Usage
^^^^^

.. signature::
  dependency(IMPORT <lib-target-name> [...])

  Import a depedency:

  .. code-block:: cmake

    dependency(IMPORT <lib-target-name>
              <STATIC|SHARED>
              [RELEASE_NAME <raw-filename>]
              [DEBUG_NAME <raw-filename>]
              ROOT_DIR <dir-path>
              INCLUDE_DIR <dir-path>)

  Create an imported library target named ``<lib-target-name>``, which should
  represent the base name of the library (without prefix or suffix), by
  locating its binary files and setting the necessary target properties. This
  command combines behavior similar to :cmake:command:`find_library() <cmake:command:find_library()>` and
  :cmake:command:`add_library(IMPORTED) <cmake:command:add_library(imported)>`.

  The main purpose of this command is to manually import a target from a
  package that does not provide a generated import script for the build-tree
  (with :cmake:command:`export(TARGETS) <cmake:command:export(targets)>`) or
  the install-tree (with :cmake:command:`install(EXPORT) <cmake:command:install(export)>`).

  The command requires either the ``STATIC`` or ``SHARED`` keyword to specify
  the type of library. Only one may be used. At least one of
  ``RELEASE_NAME <raw-filename>`` or ``DEBUG_NAME <raw-filename>`` must be
  provided. Both can be used. These arguments determine which configurations
  of the library will be available, typically matching values in the
  :cmake:variable:`CMAKE_CONFIGURATION_TYPES <cmake:variable:CMAKE_CONFIGURATION_TYPES>` variable.

  The value of ``<raw-filename>`` should be the core name of the library file,
  stripped of:

  * Any version numbers.
  * Platform-specific prefixes (e.g. ``lib``).
  * Platform-specific suffixes (e.g. ``.so``, ``.dll``, ``.dll.a``, ``.a``, ``.lib``).

  The file will be resolved by scanning recursively all files in the given
  ``ROOT_DIR`` and attempting to match against expected filename patterns
  constructed using the relevant ``CMAKE_<CONFIG>_LIBRARY_PREFIX`` and
  ``CMAKE_<CONFIG>_LIBRARY_SUFFIX``, accounting for platform conventions
  and possible version-number noise in filenames. More specifically, it tries
  to do a matching between the ``<raw-filename>`` in format
  ``<CMAKE_STATIC_LIBRARY_PREFIX|CMAKE_SHARED_LIBRARY_PREFIX><raw-filename>
  <verions-numbers><CMAKE_STATIC_LIBRARY_SUFFIX|CMAKE_SHARED_LIBRARY_SUFFIX>``
  and each filename found striped from their numeric and special character
  version and their suffix and their prefix based on the plateform and the
  kind of library ``STATIC`` or ``SHARED``. See the command module
  :command:`directory(SCAN)`, that is used internally, for full details.

  If more than one file matches or no file is found, an error is raised.

  Once located, an imported target is created using :cmake:command:`add_library(IMPORTED) <cmake:command:add_library(imported)>` and
  appropriate properties for each available configuration (``RELEASE`` and/or
  ``DEBUG``) are set, including paths to the binary and import libraries (if
  applicable), as well as the soname.

  The ``INCLUDE_DIR`` keyword defines a public include directory required by
  the imported target. This directory populates the target's
  :cmake:prop_tgt:`INTERFACE_INCLUDE_DIRECTORIES <cmake:prop_tgt:INTERFACE_INCLUDE_DIRECTORIES>`
  property, which specifies the list of directories published as usage
  requirements to consumers, and which are added to the compiler's header
  search path when another target links against it. In practice, this ensures
  that any consumer of the imported library automatically receives the correct
  include paths needed to compile against its headers.

  The following target properties are configured:

    ``INTERFACE_INCLUDE_DIRECTORIES``
      Set to the directory given by ``INCLUDE_DIR``. This property defines
      the include directories as a usage requirement to consumers of the
      imported target, so that it is automatically added to their header
      search paths when they link against it.

      In this context, the value is intended for source-tree usage, meaning
      that the directory path refers to headers available directly in the
      project source (rather than in an installed or exported package). See the
      `CMake doc <https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_INCLUDE_DIRECTORIES.html>`__
      for full details. The value of this property can be overridden using
      :command:`dependency(ADD_INCLUDE_DIRECTORIES)`.

    ``INTERFACE_INCLUDE_DIRECTORIES_BUILD``
      Set to an empty value. This is a *custom property*, not used by CMake
      natively, intended to track include directories for usage from the
      build-tree context. Use :command:`dependency(ADD_INCLUDE_DIRECTORIES)` to
      populate this property.

    ``INTERFACE_INCLUDE_DIRECTORIES_INSTALL``
      Set to an empty value. This is a *custom property* intended for tracking
      include paths during installation or packaging, for usage from the
      install-tree context. Use :command:`dependency(ADD_INCLUDE_DIRECTORIES)` to
      populate this property.

    ``IMPORTED_LOCATION_<CONFIG>``
      The full path to the actual library file (e.g. ``.so``, ``.dll``, ``.a``, ``.lib``),
      set separately for each configuration (``RELEASE`` and/or ``DEBUG``). See the `CMake doc <https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_LOCATION_CONFIG.html>`__ for full details.

    ``IMPORTED_LOCATION_BUILD_<CONFIG>``
      *Custom property* set to an empty value. Intended for build-tree specific
      overrides of the library path, for usage from the build-tree context.
      Use :command:`dependency(SET_IMPORTED_LOCATION)` to initialize this property.

    ``IMPORTED_LOCATION_INSTALL_<CONFIG>``
      *Custom property* set to an empty value. Intended for install-time
      overrides of the library path, for usage from the install-tree context.
      Use :command:`dependency(SET_IMPORTED_LOCATION)` to initialize this property.

    ``IMPORTED_IMPLIB_<CONFIG>``
      On DLL-based platforms (e.g. Windows), set to the full path of the
      import library file (e.g. ``.dll.a``, ``.a``, ``.lib``) for the corresponding
      configuration. For static libraries, this property is set to empty,
      because an import library is only for a shared library. See the
      `CMake doc <https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_IMPLIB_CONFIG.html>`__ for full details.

    ``IMPORTED_SONAME_<CONFIG>``
      Set to the filename of the resolved library (without path), allowing
      CMake to handle runtime linking and version resolution. See the
      `CMake doc <https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_SONAME_CONFIG.html>`__ for full details.

    ``IMPORTED_CONFIGURATIONS``
      Appended with each configuration for which a library was found and
      configured (e.g. ``RELEASE``, ``DEBUG``). See the `CMake doc <https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_CONFIGURATIONS.html>`__ for full
      details.

  Example usage:

  .. code-block:: cmake

    # Import shared lib
    dependency(IMPORT "my_shared_lib"
      SHARED
      RELEASE_NAME "mylib_1.11.0"
      DEBUG_NAME "mylibd_1.11.0"
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include/mylib"
    )
    # Is more or less equivalent to:
    add_library("my_shared_lib" SHARED IMPORTED)
    set_target_properties("my_shared_lib" PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_SOURCE_DIR}/include/mylib"
      INTERFACE_INCLUDE_DIRECTORIES_BUILD ""
      INTERFACE_INCLUDE_DIRECTORIES_INSTALL ""
    )
    find_library(lib NAMES "mylib_1.11.0")
    find_library(implib NAMES "mylibd_1.11.0")
    cmake_path(GET lib FILENAME lib_name)
    set_target_properties("my_shared_lib" PROPERTIES
      IMPORTED_LOCATION_RELEASE "${lib}"
      IMPORTED_LOCATION_BUILD_RELEASE ""
      IMPORTED_LOCATION_INSTALL_RELEASE ""
      IMPORTED_IMPLIB_RELEASE "${implib}"
      IMPORTED_SONAME_RELEASE "${lib_name}"
    )
    set_property(TARGET "my_shared_lib"
      APPEND PROPERTY IMPORTED_CONFIGURATIONS "${CMAKE_BUILD_TYPE}"
    )

    # Import static lib
    dependency(IMPORT "my_static_lib"
      STATIC
      RELEASE_NAME "mylib_1.11.0"
      DEBUG_NAME "mylibd_1.11.0"
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include/mylib"
    )
    # Is more or less equivalent to:
    add_library("my_shared_lib" SHARED IMPORTED)
    set_target_properties("my_shared_lib" PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${CMAKE_SOURCE_DIR}/include/mylib"
      INTERFACE_INCLUDE_DIRECTORIES_BUILD ""
      INTERFACE_INCLUDE_DIRECTORIES_INSTALL ""
    )
    find_library(lib NAMES "mylib_1.11.0")
    find_library(implib NAMES "mylibd_1.11.0")
    cmake_path(GET lib FILENAME lib_name)
    set_target_properties("my_shared_lib" PROPERTIES
      IMPORTED_LOCATION_RELEASE "${lib}"
      IMPORTED_LOCATION_BUILD_RELEASE ""
      IMPORTED_LOCATION_INSTALL_RELEASE ""
      IMPORTED_IMPLIB_RELEASE "${implib}"
      IMPORTED_SONAME_RELEASE "${lib_name}"
    )
    set_property(TARGET "my_shared_lib"
      APPEND PROPERTY IMPORTED_CONFIGURATIONS "${CMAKE_BUILD_TYPE}"
    )

.. signature::
  dependency(ADD_INCLUDE_DIRECTORIES <lib-target-name> <SET|APPEND> PUBLIC <gen-expr>...)

  Set or append public include directories required by the imported target
  ``<lib-target-name>`` to expose its headers to consumers. It populates its
  :cmake:prop_tgt:`INTERFACE_INCLUDE_DIRECTORIES <cmake:prop_tgt:INTERFACE_INCLUDE_DIRECTORIES>`
  property and its derivatives to allow the target to be imported from the
  three contexts source-tree, build-tree, and install-tree.

  The name should represent the base name of the library (without prefix or
  suffix). This command copies the behavior of
  :cmake:command:`target_include_directories() <cmake:command:target_include_directories>`
  in CMake, but introduces a separation between build-time and install-time
  contexts for imported dependencies.

  This command is intended for targets that have been previously declared
  using :command:`dependency(IMPORT)`, and is typically used in conjunction
  with :command:`dependency(EXPORT)` to complete the definition of
  an imported target for external reuse. It fills in target properties that
  are used when generating the export script. Therefore, there is no benefit
  in calling it if the target is not intended to be exported.

  The behavior differs from standard CMake in that it stores build and install
  include paths separately using generator expressions (see 
  `how write build specification with generator expressions <https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#include-directories-and-usage-requirements>`__).

  The ``PUBLIC`` keyword indicates that the specified directories apply to the
  usage requirements of the target (i.e., will be propagated to consumers of
  the target). The directories following it **must use generator expressions** like
  ``$<BUILD_INTERFACE:...>`` and ``$<INSTALL_INTERFACE:...>`` to distinguish
  between build and install phases.

  The command accepts the following mutually exclusive modifiers:

  * ``SET``: Replaces any existing include directories.
  * ``APPEND``: Adds to the current list of include directories.

  This command internally sets or appends the following CMake properties on the target:

    ``INTERFACE_INCLUDE_DIRECTORIES``
      This standard CMake target property specifies the public include
      directories for the imported target. These directories define the usage
      requirements of the target and are automatically propagated to any
      consuming target that links against it.

      This property is populated from the ``$<BUILD_INTERFACE:...>``
      portion of the arguments, corresponding to the directories available
      in the source-tree context. This ensures that when a target consumes the
      imported library during a build, it automatically receives the correct
      include paths for compilation.

      For more details, see the official `CMake documentation
      <https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_INCLUDE_DIRECTORIES.html>`__.

    ``INTERFACE_INCLUDE_DIRECTORIES_BUILD``
      A *custom property* defined by this module to track the include
      directories used in the build-tree context. It contains the fully
      expanded list of directories extracted from the ``$<BUILD_INTERFACE:...>``
      generator expressions. This ensures that when a target consumes the
      imported library during the build, it correctly receives all necessary
      include paths even before installation.

    ``INTERFACE_INCLUDE_DIRECTORIES_INSTALL``
      A *custom property* defined by this module to track the include
      directories intended for use in the install-tree context. It contains
      the fully expanded list of directories extracted from the
      ``$<INSTALL_INTERFACE:...>`` generator expressions. This ensures that
      after installation, any consumer of the imported library will have the
      correct include paths set for compilation against the installed headers.

  These custom properties (`_BUILD` and `_INSTALL`) are not directly used by
  CMake itself but are later re-injected into export files generated by
  :command:`dependency(EXPORT)`.

  Example usage:

  .. code-block:: cmake

    # Import libs
    dependency(IMPORT "my_shared_lib"
      SHARED
      RELEASE_NAME "mylib_1.11.0"
      DEBUG_NAME "mylibd_1.11.0"
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include/mylib"
    )
    dependency(IMPORT "my_static_lib"
      STATIC
      RELEASE_NAME "mylib_1.11.0"
      DEBUG_NAME "mylibd_1.11.0"
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include/mylib"
    )

    # Set include directories for shared lib
    dependency(ADD_INCLUDE_DIRECTORIES "my_shared_lib" SET
      PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
        "$<INSTALL_INTERFACE:include/mylib>"
    )
    # Is more or less equivalent to:
    target_include_directories(static_mock_lib
      PUBLIC
          "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
          "$<INSTALL_INTERFACE:include/mylib>"
    )

    # Set include directories for static lib
    dependency(ADD_INCLUDE_DIRECTORIES "my_static_lib" SET
      PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
        "$<INSTALL_INTERFACE:include/mylib>"
    )
    # Is more or less equivalent to:
    target_include_directories(static_mock_lib
      PUBLIC
          "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
          "$<INSTALL_INTERFACE:include/mylib>"
    )

  This example sets ``my_shared_lib`` and ``my_static_lib`` to expose:

  * ``${CMAKE_SOURCE_DIR}/include/mylib`` during the build.
  * ``<CMAKE_INSTALL_PREFIX>/include/mylib`` after installation (where
    ``<CMAKE_INSTALL_PREFIX>`` is resolved when imported via :command:`dependency(EXPORT)`).

.. signature::
  dependency(SET_IMPORTED_LOCATION <lib-target-name> [CONFIGURATION <config-type>] PUBLIC <gen-expr>...)

  Set the :cmake:prop_tgt:`IMPORTED_LOCATION_<CONFIG> <cmake:prop_tgt:IMPORTED_LOCATION_<CONFIG>>` property of the imported
  target ``<lib-target-name>`` using generator expressions to provide the
  full path to the library file. The name should represent the base name of
  the library (without prefix or suffix).

  This command is intended for targets that have been previously declared
  using :command:`dependency(IMPORT)`, and is typically used in conjunction
  with :command:`dependency(EXPORT)` to complete the definition of
  an imported target for external reuse. It allows specifying a different
  location for each build configuration type, or for all configurations
  if no configuration is specified. It fills in target properties that
  are used when generating the export script. Therefore, there is no benefit
  in calling it if the target is not intended to be exported.

  If ``CONFIGURATION`` is given, the property is only set for that
  configuration. Otherwise, the property is set for all configurations
  supported by the target. Configuration types must match one of the
  values listed in the target's :cmake:prop_tgt:`IMPORTED_CONFIGURATIONS <cmake:prop_tgt:IMPORTED_CONFIGURATIONS>` property.

  The ``PUBLIC`` keyword must be followed by one or more generator expressions
  that define the path to the library file during build and install phases.
  The paths following it **must use generator expressions** like
  ``$<BUILD_INTERFACE:...>`` and ``$<INSTALL_INTERFACE:...>`` to distinguish
  between build and install phases. (see 
  `how write build specification with generator expressions <https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-specification-with-generator-expressions>`__).

  These expressions are evaluated to determine the value of the following
  CMake properties set by this command:

    ``IMPORTED_LOCATION_<CONFIG>``
      The full path to the actual library file (e.g. ``.so``, ``.dll``, ``.a``, ``.lib``),
      set separately for each configuration (``RELEASE`` and/or ``DEBUG``).
      See the `CMake doc <https://cmake.org/cmake/help/latest/prop_tgt/IMPORTED_LOCATION.html>`__ for full details. The command :command:`directory(FIND_LIB)` can be used to find the library file.

    ``IMPORTED_LOCATION_BUILD_<CONFIG>``
      *Custom property* set to the full path to the actual library file,
      set separately for each configuration (``RELEASE`` and/or ``DEBUG``),
      and for usage from the build-tree context. This property is used by
      :command:`dependency(EXPORT)` to complete the definition of an imported
      target for external reuse.

    ``IMPORTED_LOCATION_INSTALL_<CONFIG>``
      *Custom property* set to the full path to the actual library file,
      set separately for each configuration (``RELEASE`` and/or ``DEBUG``),
      and for usage from the install-tree context.  This property is used by
      :command:`dependency(EXPORT)` to complete the definition of an imported
      target for external reuse.

  Example usage:

  .. code-block:: cmake

    # Import libs
    dependency(IMPORT "my_shared_lib"
      SHARED
      RELEASE_NAME "mylib_1.11.0"
      DEBUG_NAME "mylibd_1.11.0"
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include/mylib"
    )
    dependency(IMPORT "my_static_lib"
      STATIC
      RELEASE_NAME "mylib_1.11.0"
      DEBUG_NAME "mylibd_1.11.0"
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include/mylib"
    )

    # Set imported location for shared lib
    dependency(SET_IMPORTED_LOCATION "my_shared_lib"
      CONFIGURATION RELEASE
      PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/lib/mylib_1.11.0.dll>"
        "$<INSTALL_INTERFACE:lib/mylib_1.11.0.dll>"
    )
    dependency(SET_IMPORTED_LOCATION "my_shared_lib"
      CONFIGURATION DEBUG
      PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/lib/mylibd_1.11.0.dll>"
        "$<INSTALL_INTERFACE:lib/mylibd_1.11.0.dll>"
    )

    # Set include directories for static lib
    dependency(SET_IMPORTED_LOCATION "my_static_lib"
      CONFIGURATION RELEASE
      PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/lib/mylib_1.11.0.lib>"
        "$<INSTALL_INTERFACE:lib/mylib_1.11.0.lib>"
    )
    dependency(SET_IMPORTED_LOCATION "my_static_lib"
      CONFIGURATION DEBUG
      PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/lib/mylibd_1.11.0.lib>"
        "$<INSTALL_INTERFACE:lib/mylibd_1.11.0.lib>"
    )

.. signature::
  dependency(EXPORT <lib-target-name>... <BUILD_TREE|INSTALL_TREE> [APPEND] OUTPUT_FILE <file-name>)

  Creates a file ``<file-name>`` that may be included by outside projects to
  import targets in ``<lib-target-name>`` list from the current project's
  build-tree or install-tree. This command is functionally similar to using
  :cmake:command:`export(TARGETS) <cmake:command:export(targets)>` in a ``BUILD_TREE`` context and :cmake:command:`install(EXPORT) <cmake:command:install(export)>`
  in an ``INSTALL_TREE`` context, but is designed specifically to export
  imported targets with :command:`dependency(IMPORT)` instead of build targets.

  The targets in ``<lib-target-name>`` list  must be previously created imported
  targets. The names should match exactly the target names used during import.

  One of ``BUILD_TREE`` or ``INSTALL_TREE`` must be specified to indicate the
  context in which the file is generated:

  * When ``BUILD_TREE`` is used, the command generates the file in
    ``CMAKE_CURRENT_BINARY_DIR/<file-name>``, similar to how :cmake:command:`export(TARGETS) <cmake:command:export(targets)>`
    produces a file to be included by other build projects. This file enables
    other projects to import the specified targets directly from the build-tree
    . It can be included from a ``<PackageName>Config.cmake`` file to provide
    usage information for downstream projects.

  * When ``INSTALL_TREE`` is used, the file is generated in
    ``CMAKE_CURRENT_BINARY_DIR/cmake/export/<file-name>`` and an install rule
    is added to copy the file to ``CMAKE_INSTALL_PREFIX/cmake/export/
    <file-name>``. This is similar to combining :cmake:command:`install(TARGETS) <cmake:command:install(targets)>` with
    :cmake:command:`install(EXPORT) <cmake:command:install(export)>`, but applies to imported rather than built targets.
    This makes the export file available post-install and allows downstream
    projects to include the file from a package configuration file.

  Note that no install rules are created for the actual binary files of the
  imported targets; only the export script ``OUTPUT_FILE`` itself is installed.

  If the ``APPEND`` keyword is specified, the generated code is appended to the
  existing file instead of overwriting it. This is useful for exporting
  multiple targets incrementally to a single file.

  The generated file defines all necessary target properties so that the
  imported targets can be used as if they were defined locally. The properties
  are identical to those set by the :command:`dependency(IMPORT)` command; see
  its documentation for additional details.

  Example usage:

  .. code-block:: cmake

    # Import libs before exporting
    dependency(IMPORT "my_shared_lib"
      SHARED
      RELEASE_NAME "mylib_1.11.0"
      DEBUG_NAME "mylibd_1.11.0"
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include/mylib"
    )
    dependency(ADD_INCLUDE_DIRECTORIES "my_shared_lib" SET
      PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
        "$<INSTALL_INTERFACE:include/mylib>"
    )
    dependency(IMPORT "my_static_lib"
      STATIC
      RELEASE_NAME "mylib_1.11.0"
      DEBUG_NAME "mylibd_1.11.0"
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      INCLUDE_DIR "${CMAKE_SOURCE_DIR}/include/mylib"
    )
    dependency(ADD_INCLUDE_DIRECTORIES "my_static_lib" SET
      PUBLIC
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
        "$<INSTALL_INTERFACE:include/mylib>"
    )

    # Export from Build-Tree
    dependency(EXPORT "myimportedlib-1" "myimportedlib-2"
      BUILD_TREE
      OUTPUT_FILE "InternalDependencyTargets.cmake"
    )
    # Is more or less equivalent to:
    export(TARGETS "myimportedlib-1" "myimportedlib-2"
      APPEND
      FILE "InternalDependencyTargets.cmake"
    )

    # Exporting from Install-Tree
    set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install")
    dependency(EXPORT "myimportedlib-1" "myimportedlib-2"
      INSTALL_TREE
      OUTPUT_FILE "InternalDependencyTargets.cmake"
    )
    # Is more or less equivalent to:
    install(TARGETS "myimportedlib-1" "myimportedlib-2"
      EXPORT "LibExport"
    )
    install(EXPORT "LibExport"
      DESTINATION "cmake/export"
      FILE "InternalDependencyTargets.cmake"
    )

  The resulting file ``InternalDependencyTargets.cmake`` may then be included
  by a package configuration file ``<PackageName>Config.cmake.in`` to be used by
  :cmake:command:`configure_package_config_file() <cmake:command:configure_package_config_file>` command:

  .. code-block:: cmake

    include("${CMAKE_CURRENT_LIST_DIR}/InternalDependencyTargets.cmake")
#]=======================================================================]

include_guard()

cmake_minimum_required (VERSION 3.20 FATAL_ERROR)
include(Directory)
include(StringManip)

#------------------------------------------------------------------------------
# Public function of this module
function(dependency)
  set(options SHARED STATIC BUILD_TREE INSTALL_TREE SET APPEND)
  set(one_value_args IMPORT RELEASE_NAME DEBUG_NAME ROOT_DIR INCLUDE_DIR OUTPUT_FILE ADD_INCLUDE_DIRECTORIES SET_IMPORTED_LOCATION CONFIGURATION)
  set(multi_value_args EXPORT PUBLIC)
  cmake_parse_arguments(DEP "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  
  if(DEFINED DEP_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${DEP_UNPARSED_ARGUMENTS}\"")
  endif()

  if(DEFINED DEP_IMPORT)
    _dependency_import()
  elseif(DEFINED DEP_EXPORT)
    _dependency_export()
  elseif(DEFINED DEP_ADD_INCLUDE_DIRECTORIES)
    _dependency_add_include_directories()
  elseif(DEFINED DEP_SET_IMPORTED_LOCATION)
    _dependency_set_imported_location()
  else()
    message(FATAL_ERROR "The operation name or arguments are missing!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage
macro(_dependency_import)
  if(NOT DEFINED DEP_IMPORT)
    message(FATAL_ERROR "IMPORT argument is missing or need a value!")
  endif()
  if(TARGET "${DEP_IMPORT}")
    message(FATAL_ERROR "The target \"${DEP_IMPORT}\" already exists!")
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
    set(lib_type "SHARED")
  elseif(${DEP_STATIC})
    set(lib_type "STATIC")
  else()
    message(FATAL_ERROR "Wrong library type!")
  endif()

  # Create target
  add_library("${DEP_IMPORT}" "${lib_type}" IMPORTED)
  set_target_properties("${DEP_IMPORT}" PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${DEP_INCLUDE_DIR}" # For usage from source-tree.
    INTERFACE_INCLUDE_DIRECTORIES_BUILD "" # Custom property for usage from build-tree.
    INTERFACE_INCLUDE_DIRECTORIES_INSTALL "" # Custom property for usage from install-tree.
  )

  # Get the library file for release and debug
  foreach(build_type IN ITEMS "RELEASE" "DEBUG")
    if(NOT DEFINED DEP_${build_type}_NAME)
      continue()
    endif()
  
    # Find library and import library
    directory(FIND_LIB lib
      FIND_IMPLIB implib
      NAME "${DEP_${build_type}_NAME}"
      "${lib_type}"
      RELATIVE off
      ROOT_DIR "${DEP_ROOT_DIR}"
    )
    if(NOT lib)
      message(FATAL_ERROR "The ${build_type} library \"${DEP_${build_type}_NAME}\" was not found!")
    endif()
    if(WIN32 AND ("${lib_type}" STREQUAL "SHARED") AND NOT implib)
      message(FATAL_ERROR "The ${build_type} import library \"${DEP_${build_type}_NAME}\" was not found!")
    endif()

    # Only shared libraries use import libraries, so make sure implib
    # is set to empty when it is equals to `implib-NOTFOUND` (especially
    # for static libraries)
    if("${implib}" MATCHES "-NOTFOUND$")
      set(implib "")
    endif()

    # Add library properties for release
    cmake_path(GET lib FILENAME lib_name)
    set_target_properties("${DEP_IMPORT}" PROPERTIES
      IMPORTED_LOCATION_${build_type} "${lib}" # Only for '.so|.dll|.a|.lib'. For usage from source-tree
      IMPORTED_LOCATION_BUILD_${build_type} "" # Custom property for usage from build-tree
      IMPORTED_LOCATION_INSTALL_${build_type} "" # Custom property for usage from install-tree
      IMPORTED_IMPLIB_${build_type} "${implib}" # Only for '.dll.a|.a|.lib' on DLL platforms
      IMPORTED_SONAME_${build_type} "${lib_name}"
    )
    set_property(TARGET "${DEP_IMPORT}"
      APPEND PROPERTY IMPORTED_CONFIGURATIONS "${build_type}"
    )
  endforeach()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_dependency_add_include_directories)
  if(NOT DEFINED DEP_ADD_INCLUDE_DIRECTORIES)
    message(FATAL_ERROR "ADD_INCLUDE_DIRECTORIES argument is missing or need a value!")
  endif()
  if((NOT ${DEP_SET})
    AND (NOT ${DEP_APPEND}))
    message(FATAL_ERROR "SET|APPEND argument is missing!")
  endif()
  if(${DEP_SET} AND ${DEP_APPEND})
    message(FATAL_ERROR "SET|APPEND cannot be used together!")
  endif()
  if(NOT DEFINED DEP_PUBLIC)
    message(FATAL_ERROR "PUBLIC argument is missing or need a value!")
  endif()

  if(NOT TARGET "${DEP_ADD_INCLUDE_DIRECTORIES}")
    message(FATAL_ERROR "The target \"${DEP_ADD_INCLUDE_DIRECTORIES}\" does not exists!")
  endif()

  string_manip(EXTRACT_INTERFACE DEP_PUBLIC
    BUILD
    OUTPUT_VARIABLE include_dirs_build_interface
  )
  string_manip(EXTRACT_INTERFACE DEP_PUBLIC
    INSTALL
    OUTPUT_VARIABLE include_dirs_install_interface
  )
  if(${DEP_SET})
    set_property(TARGET "${DEP_ADD_INCLUDE_DIRECTORIES}"
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${include_dirs_build_interface}"
    )
    set_property(TARGET "${DEP_ADD_INCLUDE_DIRECTORIES}"
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES_BUILD "${include_dirs_build_interface}"
    )
    set_property(TARGET "${DEP_ADD_INCLUDE_DIRECTORIES}"
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES_INSTALL "${include_dirs_install_interface}"
    )
  elseif(${DEP_APPEND})
    set_property(TARGET "${DEP_ADD_INCLUDE_DIRECTORIES}" APPEND
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES "${include_dirs_build_interface}"
    )
    set_property(TARGET "${DEP_ADD_INCLUDE_DIRECTORIES}" APPEND
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES_BUILD "${include_dirs_build_interface}"
    )
    set_property(TARGET "${DEP_ADD_INCLUDE_DIRECTORIES}" APPEND
      PROPERTY INTERFACE_INCLUDE_DIRECTORIES_INSTALL "${include_dirs_install_interface}"
    )
  else()
    message(FATAL_ERROR "Wrong option!")
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_dependency_set_imported_location)
  if(NOT DEFINED DEP_SET_IMPORTED_LOCATION)
    message(FATAL_ERROR "SET_IMPORTED_LOCATION argument is missing or need a value!")
  endif()
  if("CONFIGURATION" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "CONFIGURATION argument is missing or need a value!")
  endif()
  if(NOT DEFINED DEP_PUBLIC)
    message(FATAL_ERROR "PUBLIC argument is missing or need a value!")
  endif()

  if(NOT TARGET "${DEP_SET_IMPORTED_LOCATION}")
    message(FATAL_ERROR "The target \"${DEP_SET_IMPORTED_LOCATION}\" does not exists!")
  endif()

  get_target_property(supported_config_types "${DEP_SET_IMPORTED_LOCATION}" IMPORTED_CONFIGURATIONS)
  string_manip(EXTRACT_INTERFACE DEP_PUBLIC
    BUILD
    OUTPUT_VARIABLE imp_loc_build_interface
  )
  string_manip(EXTRACT_INTERFACE DEP_PUBLIC
    INSTALL
    OUTPUT_VARIABLE imp_loc_install_interface
  )
  if(DEFINED DEP_CONFIGURATION)
    if(NOT "${DEP_CONFIGURATION}" IN_LIST supported_config_types)
      message(FATAL_ERROR "The build type \"${DEP_CONFIGURATION}\" is not a supported configuration!")
    endif()
    set_target_properties("${DEP_SET_IMPORTED_LOCATION}" PROPERTIES
      IMPORTED_LOCATION_${DEP_CONFIGURATION} "${imp_loc_build_interface}"
      IMPORTED_LOCATION_BUILD_${DEP_CONFIGURATION} "${imp_loc_build_interface}"
      IMPORTED_LOCATION_INSTALL_${DEP_CONFIGURATION} "${imp_loc_install_interface}"
    )
  else()
    foreach(build_type IN ITEMS ${supported_config_types})
      set_target_properties("${DEP_SET_IMPORTED_LOCATION}" PROPERTIES
        IMPORTED_LOCATION_${build_type} "${imp_loc_build_interface}"
        IMPORTED_LOCATION_BUILD_${build_type} "${imp_loc_build_interface}"
        IMPORTED_LOCATION_INSTALL_${build_type} "${imp_loc_install_interface}"
      )
    endforeach()
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_dependency_export)
  if(NOT DEFINED DEP_EXPORT)
    message(FATAL_ERROR "EXPORT arguments is missing or need a value!")
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
  foreach(lib_target_name IN ITEMS ${DEP_EXPORT})
    if(NOT TARGET "${lib_target_name}")
      message(FATAL_ERROR "The target \"${lib_target_name}\" does not exists!")
    endif()
  endforeach()
  if((NOT DEFINED CMAKE_BUILD_TYPE)
    OR ("${CMAKE_BUILD_TYPE}" STREQUAL ""))
    message(FATAL_ERROR "CMAKE_BUILD_TYPE is not set!")
  endif()

  # Set paths to export files
  cmake_path(SET export_dir "${CMAKE_CURRENT_BINARY_DIR}")
  cmake_path(SET export_file_template "${CMAKE_CURRENT_FUNCTION_LIST_DIR}")
  if(${DEP_BUILD_TREE})
    cmake_path(APPEND export_file_template "ImportBuildTreeLibTargets.cmake.in")
  elseif(${DEP_INSTALL_TREE})
    cmake_path(APPEND export_dir "cmake" "export")
    if(NOT EXISTS "${export_dir}")
      file(MAKE_DIRECTORY "${export_dir}")
    endif()
    cmake_path(APPEND export_file_template "ImportInstallTreeLibTargets.cmake.in")
  endif()
  set(export_file "${export_dir}/${DEP_OUTPUT_FILE}")

  # Read the template file once
  file(READ "${export_file_template}" template_content)

  # Sanitize the output file path to create a valid CMake property identifier
  cmake_path(GET export_file FILENAME sanitized_export_file)
  string(MAKE_C_IDENTIFIER "${sanitized_export_file}" sanitized_export_file)
  
  # List of previously generated intermediate files
  get_property(existing_export_parts GLOBAL PROPERTY "_EXPORT_PARTS_${sanitized_export_file}")

  # Throw an error if export command already specified for the file and 'APPEND' keyword is not used
  list(LENGTH existing_export_parts nb_parts)
  if((NOT ${nb_parts} EQUAL 0) AND (NOT ${DEP_APPEND}))
    message(FATAL_ERROR "Export command already specified for the file \"${DEP_OUTPUT_FILE}\". Did you miss 'APPEND' keyword?")
  endif()
  
  # List of intermediate files to concatenate later
  set(new_export_parts "")
  foreach(lib_target_name IN ITEMS ${DEP_EXPORT})
    # Set template file variables
    get_target_property(lib_target_type "${lib_target_name}" TYPE)
    if("${lib_target_type}" STREQUAL "STATIC_LIBRARY")
      set(lib_target_type "STATIC")
    elseif("${lib_target_type}" STREQUAL "SHARED_LIBRARY")
      set(lib_target_type "SHARED")
    else()
      message(FATAL_ERROR "Target type \"${lib_target_type}\" for target \"${lib_target_name}\" is unsupported by export command!")
    endif()
  
    # Substitute variable values referenced as @VAR@
    string(CONFIGURE "${template_content}" configured_content @ONLY)

    # Generate a per-target intermediate file with generator expressions
    set(new_part_file "${export_dir}/${lib_target_name}Targets-${lib_target_type}.part.cmake")
    if(NOT ("${new_part_file}" IN_LIST existing_export_parts))
      file(GENERATE OUTPUT "${new_part_file}"
        CONTENT "${configured_content}"
        TARGET "${lib_target_name}"
      )
      set_source_files_properties("${new_part_file}" PROPERTIES GENERATED TRUE)
      # Add generated files to the `clean` target
      set_property(DIRECTORY
        APPEND
        PROPERTY ADDITIONAL_CLEAN_FILES
        "${new_part_file}"
      )
      list(APPEND new_export_parts "${new_part_file}")
    else()
      message(FATAL_ERROR "Given target \"${lib_target_name}\" more than once!")
    endif()
  endforeach()

  # Append the generated intermediate files to the file's associated global property
  list(APPEND existing_export_parts "${new_export_parts}")
  set_property(GLOBAL PROPERTY "_EXPORT_PARTS_${sanitized_export_file}" "${existing_export_parts}")

  # Only define the output generation rule once
  set(unique_target_name "GenerateImportTargetFile_${sanitized_export_file}")

  # Build `add_custom_command()` for exporting
  set(output_part "")
  if(NOT TARGET ${unique_target_name})
    set(output_part "OUTPUT" "${export_file}")
  else()
    set(output_part "OUTPUT" "${export_file}" "APPEND")
  endif()

  set(comment_part "")
  set(command_part "")
  if(${DEP_APPEND})
    list(APPEND command_part
      "COMMAND" "${CMAKE_COMMAND}" "-E" "touch" "${export_file}")
    list(APPEND command_part
      "COMMAND" "${CMAKE_COMMAND}" "-E" "cat" ${new_export_parts} ">>" "${export_file}")
    set(comment_part
      "COMMENT" "Update the import file \"${export_file}\"")
  else()
    list(APPEND command_part
      "COMMAND" "${CMAKE_COMMAND}" "-E" "cat" ${new_export_parts} ">" "${export_file}")
    set(comment_part
      "COMMENT" "Overwrite the import file \"${export_file}\"")
  endif()

  add_custom_command(
    ${output_part}
    ${command_part}
    DEPENDS "${new_export_parts}"
    ${comment_part}
  )

  # Only true during the first invocation
  if(NOT TARGET "${unique_target_name}")
    # Create a unique generative target per output file to trigger the command
    add_custom_target("${unique_target_name}" ALL
      DEPENDS "${export_file}"
      VERBATIM
    )
  endif()
  if(${DEP_INSTALL_TREE})
    install(FILES "${export_file}"
      DESTINATION "cmake/export"
    )
  endif()
endmacro()