# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Dependency
----------

Operations to manipule dependencies. They mainly encapsulate the numerous
function calls required to
:cmake:guide:`import and export dependencies <guide:Importing and Exporting Guide>`.
It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  dependency(`BUILD`_ <lib-target-name> [...])
  dependency(`IMPORT`_ <lib-target-name> [...])
  dependency(`ADD_INCLUDE_DIRECTORIES`_ <lib-target-name> <SET|APPEND> INTERFACE <gen-expr>...)
  dependency(`SET_IMPORTED_LOCATION`_ <lib-target-name> [CONFIGURATION <config-type>] PUBLIC <gen-expr>...)
  dependency(`EXPORT`_ <lib-target-name>... <BUILD_TREE|INSTALL_TREE> [APPEND] OUTPUT_FILE <file-name>)

Usage
^^^^^

.. signature::
  dependency(IMPORT <lib-target-name> [...])

  Import a depedency:

  .. code-block:: cmake

    dependency(IMPORT <lib-target-name>
               TYPE <STATIC|SHARED>
               FIND_ROOT_DIR <dir-path>
               [FIND_RELEASE_FILE <lib-file-basename>]
               [FIND_DEBUG_FILE <lib-file-basename>])

  Create an imported library target named ``<lib-target-name>`` by locating its
  binary files in ``FIND_ROOT_DIR`` for ``RELEASE`` and/or ``DEBUG``, and set
  the necessary target properties. An aliased target is also created with the
  name ``<lib-target-name>::<lib-target-name>``.

  This command combines calls to :command:`directory(FIND_LIB)`,
  :cmake:command:`add_library(IMPORTED) <cmake:command:add_library(imported)>` and
  :cmake:command:`set_target_properties() <cmake:command:set_target_properties()>`.
  Its main purpose is to manually import a target from a package that does not
  provide a generated import script for the build-tree (with
  :cmake:command:`export(TARGETS) <cmake:command:export(targets)>`) or
  the install-tree (with :cmake:command:`install(EXPORT) <cmake:command:install(export)>`).

  The command requires a ``TYPE`` value to specify the type of library (
  ``STATIC`` or ``SHARED``). At least one of ``FIND_RELEASE_FILE <lib-file-basename>``
  or ``FIND_DEBUG_FILE <lib-file-basename>`` must be provided. Both can be used.
  These arguments determine which configurations of the library will be
  available, typically matching values in the
  :cmake:variable:`CMAKE_CONFIGURATION_TYPES <cmake:variable:CMAKE_CONFIGURATION_TYPES>` variable.

  The value of ``<lib-file-basename>`` should have no extension or prefixes; it
  should be the core name of the library file, stripped of:

  * Platform-specific prefixes (e.g. ``lib``).
  * Platform-specific extension suffixes (e.g. ``.so``, ``.dll``, ``.dll.a``,
    ``.a``, ``.lib``).

  The file will be resolved by scanning recursively all files in the given
  ``FIND_ROOT_DIR`` and attempting to match against expected filename patterns
  constructed using the relevant ``CMAKE_<CONFIG>_LIBRARY_PREFIX`` and
  ``CMAKE_<CONFIG>_LIBRARY_SUFFIX``, accounting for platform conventions
  and possible version-number noise in filenames. More specifically, it tries
  to do a matching between the ``<lib-file-basename>`` in format
  ``<CMAKE_STATIC_LIBRARY_PREFIX|CMAKE_SHARED_LIBRARY_PREFIX><lib-file-basename>
  <verions-numbers><CMAKE_STATIC_LIBRARY_SUFFIX|CMAKE_SHARED_LIBRARY_SUFFIX>``
  and each filename found striped from their numeric and special character
  version and their suffix and their prefix based on the plateform and the
  kind of library ``STATIC`` or ``SHARED``. See the command module
  :command:`directory(FIND_LIB)`, that is used internally, for full details.

  An error is raised if more than one file matches or no file is found.

  Once located, an imported target is created using :cmake:command:`add_library(IMPORTED) <cmake:command:add_library(imported)>` and
  appropriate properties for each available configuration (``RELEASE`` and/or
  ``DEBUG``) are set, including paths to the binary and import libraries (if
  applicable), as well as the soname.

  The following target properties are configured:

    ``INTERFACE_INCLUDE_DIRECTORIES``
      Set to an empty value. This property defines the include directories as
      a usage requirement to consumers of the imported target, so that it is
      automatically added to their header search paths when they link against
      it.

      In this context, the value is intended for source-tree usage, meaning
      that the directory path refers to headers available directly in the
      project source (rather than in an installed or exported package). See the
      `CMake doc <https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_INCLUDE_DIRECTORIES.html>`__
      for full details. Use :command:`dependency(ADD_INCLUDE_DIRECTORIES)` to
      populate this property.

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

  To provide maximum flexibility when importing a library with this command, it
  mirrors CMake's official requirements for ``FindXxx.cmake`` modules by
  initializing the
  :cmake:ref:`requires standard variables <cmake developer standard variable names>`.
  It also supports use in multiples :cmake:ref:`build configurations` contexts
  by replicating the behavior of the
  :cmake:module:`SelectLibraryConfigurations <cmake:module:SelectLibraryConfigurations>` 
  module.

  This command then returns the following result variables:

    ``<lib-target-name>_LIBRARY_RELEASE``
      The full absolute path to the ``Release`` build of the library. If no
      file found, its value is set to
      ``<lib-target-name>_LIBRARY_RELEASE-NOTFOUND``. The variable is undefined
      when the ``FIND_RELEASE_FILE`` argument is not provided.

    ``<lib-target-name>_LIBRARY_DEBUG``
      The full absolute path to the ``Debug`` build of the library. If no
      file found, its value is set to
      ``<lib-target-name>_LIBRARY_DEBUG-NOTFOUND``. The variable is undefined
      when the ``FIND_DEBUG_FILE`` argument is not provided.

    ``<lib-target-name>_IMP_LIBRARY_RELEASE``
      The full absolute path to the ``Release`` import build of the library. If
      no file found, its value is set to
      ``<lib-target-name>_IMP_LIBRARY_RELEASE-NOTFOUND``. The variable is
      undefined when the ``FIND_RELEASE_FILE`` argument is not provided.

    ``<lib-target-name>_IMP_LIBRARY_DEBUG``
      The full absolute path to the ``Debug`` import build of the library. If
      no file found, its value is set to
      ``<lib-target-name>_IMP_LIBRARY_DEBUG-NOTFOUND``. The variable is
      undefined when the ``FIND_DEBUG_FILE`` argument is not provided.

    ``<lib-target-name>_FOUND_RELEASE``
      Set to true if the ``Release`` library and import library has been found
      successfully, otherwise set to false. To be true, both
      ``<lib-target-name>_LIBRARY_RELEASE`` and
      ``<lib-target-name>_IMP_LIBRARY_RELEASE`` must not be set to
      ``-NOTFOUND``. The variable is undefined when the ``FIND_RELEASE_FILE``
      argument is not provided.

    ``<lib-target-name>_FOUND_DEBUG``
      Set to true if the ``Debug`` library and import library has been found
      successfully, otherwise set to false. To be true, both
      ``<lib-target-name>_LIBRARY_DEBUG`` and
      ``<lib-target-name>_IMP_LIBRARY_DEBUG`` must not be set to
      ``-NOTFOUND``. The variable is undefined when the ``FIND_DEBUG_FILE``
      argument is not provided.

    ``<lib-target-name>_FOUND``
      Set to false if ``<lib-target-name>_FOUND_RELEASE`` or
      ``<lib-target-name>_FOUND_DEBUG`` are defined and set to false. Otherwise,
      set to true.

    ``<lib-target-name>_LIBRARY``
      The value of ``<lib-target-name>_LIBRARY_RELEASE`` variable if found,
      otherwise it is set to the value of ``<lib-target-name>_LIBRARY_DEBUG``
      variable if found. If both are found, the release library value takes
      precedence. If both are not found, because
      ``<lib-target-name>_FOUND_RELEASE`` and ``<lib-target-name>_FOUND_DEBUG``
      are set to false, it is set to value ``<lib-target-name>_LIBRARY-NOTFOUND``.

      If the :cmake:manual:`CMake Generator <cmake:manual:cmake-generators(7)>`
      in use supports build configurations, then this variable will be a list
      of found libraries each prepended with the ``optimized`` or ``debug``
      keywords specifying which library should be linked for the given
      configuration.  These keywords are used by the
      :cmake:command:`target_link_libraries() <cmake:command:target_link_libraries>`
      command. If a build configuration has not been set or the generator in
      use does not support build configurations, then this variable value will
      not contain these keywords.

    ``<lib-target-name>_LIBRARIES``
      The same value as the ``<lib-target-name>_LIBRARY`` variable.

    ``<lib-target-name>_ROOT_DIR``
      The base directory absolute path where to look for the
      ``<lib-target-name>`` files. The value is set to the ``FIND_ROOT_DIR``
      argument.

  No library is added if ``<lib-target-name>_FOUND`` is set to false.

  Example usage:

  .. code-block:: cmake

    # Import shared lib
    dependency(IMPORT "my_shared_lib"
      TYPE SHARED
      FIND_ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      FIND_RELEASE_FILE "mylib_1.11.0"
      FIND_DEBUG_FILE "mylibd_1.11.0"
    )
    # Is equivalent to:
    add_library("my_shared_lib" SHARED IMPORTED)
    set_target_properties("my_shared_lib" PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ""
      INTERFACE_INCLUDE_DIRECTORIES_BUILD ""
      INTERFACE_INCLUDE_DIRECTORIES_INSTALL ""
    )
    directory(FIND_LIB lib
      FIND_IMPLIB implib
      NAME "mylib_1.11.0"
      SHARED
      RELATIVE off
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
    )
    cmake_path(GET lib FILENAME lib_name)
    set_target_properties("my_shared_lib" PROPERTIES
      IMPORTED_LOCATION_RELEASE "${lib}"
      IMPORTED_LOCATION_BUILD_RELEASE ""
      IMPORTED_LOCATION_INSTALL_RELEASE ""
      IMPORTED_IMPLIB_RELEASE "${implib}"
      IMPORTED_SONAME_RELEASE "${lib_name}"
    )
    set_property(TARGET "my_shared_lib"
      APPEND PROPERTY IMPORTED_CONFIGURATIONS "RELEASE"
    )
    directory(FIND_LIB lib
      FIND_IMPLIB implib
      NAME "mylibd_1.11.0"
      SHARED
      RELATIVE off
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
    )
    cmake_path(GET lib FILENAME lib_name)
    set_target_properties("my_shared_lib" PROPERTIES
      IMPORTED_LOCATION_DEBUG "${lib}"
      IMPORTED_LOCATION_BUILD_DEBUG ""
      IMPORTED_LOCATION_INSTALL_DEBUG ""
      IMPORTED_IMPLIB_DEBUG "${implib}"
      IMPORTED_SONAME_DEBUG "${lib_name}"
    )
    set_property(TARGET "my_shared_lib"
      APPEND PROPERTY IMPORTED_CONFIGURATIONS "DEBUG"
    )

    # Import static lib
    dependency(IMPORT "my_static_lib"
      TYPE STATIC
      FIND_ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      FIND_RELEASE_FILE "mylib_1.11.0"
      FIND_DEBUG_FILE "mylibd_1.11.0"
    )
    # Is equivalent to:
    add_library("my_static_lib" SHARED IMPORTED)
    set_target_properties("my_static_lib" PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES ""
      INTERFACE_INCLUDE_DIRECTORIES_BUILD ""
      INTERFACE_INCLUDE_DIRECTORIES_INSTALL ""
    )
    directory(FIND_LIB lib
      FIND_IMPLIB implib
      NAME "mylib_1.11.0"
      SHARED
      RELATIVE off
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
    )
    cmake_path(GET lib FILENAME lib_name)
    set_target_properties("my_static_lib" PROPERTIES
      IMPORTED_LOCATION_RELEASE "${lib}"
      IMPORTED_LOCATION_BUILD_RELEASE ""
      IMPORTED_LOCATION_INSTALL_RELEASE ""
      IMPORTED_IMPLIB_RELEASE "${implib}"
      IMPORTED_SONAME_RELEASE "${lib_name}"
    )
    set_property(TARGET "my_static_lib"
      APPEND PROPERTY IMPORTED_CONFIGURATIONS "RELEASE"
    )
    directory(FIND_LIB lib
      FIND_IMPLIB implib
      NAME "mylibd_1.11.0"
      SHARED
      RELATIVE off
      ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
    )
    cmake_path(GET lib FILENAME lib_name)
    set_target_properties("my_static_lib" PROPERTIES
      IMPORTED_LOCATION_DEBUG "${lib}"
      IMPORTED_LOCATION_BUILD_DEBUG ""
      IMPORTED_LOCATION_INSTALL_DEBUG ""
      IMPORTED_IMPLIB_DEBUG "${implib}"
      IMPORTED_SONAME_DEBUG "${lib_name}"
    )
    set_property(TARGET "my_static_lib"
      APPEND PROPERTY IMPORTED_CONFIGURATIONS "DEBUG"
    )

.. signature::
  dependency(ADD_INCLUDE_DIRECTORIES <lib-target-name> <SET|APPEND> INTERFACE <gen-expr>...)

  Set or append interface include directories required by the imported target
  ``<lib-target-name>`` to expose its headers to consumers. It specifies the
  list of directories published as usage requirements to consumers, and which
  are added to the compiler's header search path when another target links
  against it. In practice, this ensures that any consumer of the imported
  library automatically receives the correct include paths needed to compile
  against its headers.

  This command populate the target's :cmake:prop_tgt:`INTERFACE_INCLUDE_DIRECTORIES <cmake:prop_tgt:INTERFACE_INCLUDE_DIRECTORIES>`
  property and its derivatives to allow the target to be imported from the
  three contexts: source-tree, build-tree, and install-tree.

  This command copies the behavior of
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
  :cmake:ref:`how to write build specification with generator expressions <include directories and usage requirements>`).

  The ``INTERFACE`` visibility keyword indicates how the specified directories
  apply to the usage requirements of the target: they will not be used by the
  imported target but propagated to its consumers. The directories following it
  **must use generator expressions** like ``$<BUILD_INTERFACE:...>`` and
  ``$<INSTALL_INTERFACE:...>`` to distinguish between build and install phases.

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

      See the `CMake doc
      <https://cmake.org/cmake/help/latest/prop_tgt/INTERFACE_INCLUDE_DIRECTORIES.html>`__ for full details.

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

  To provide maximum flexibility when manaing a library with this module, this
  command mirrors CMake's official requirements for ``FindXxx.cmake`` modules
  by initializing a part of some
  :cmake:ref:`requires standard variables <cmake developer standard variable names>`.

  This command then returns the following result variables:

    ``<lib-target-name>_INCLUDE_DIR``
      The base directory absolute path where to find headers for using the
      library (or more accurately, the path that consumers of the library
      should add to their header search path).

    ``<lib-target-name>_INCLUDE_DIRS``
      The final set of include directories listed in one variable for use by
      client code.

  .. note::

    The ``dependency(ADD_INCLUDE_DIRECTORIES)`` command should be called after
    importing the target with :command:`dependency(IMPORT)` to ensure that
    the target properties and result variables are set correctly.

  Example usage:

  .. code-block:: cmake

    # Import libs
    dependency(IMPORT "my_shared_lib"
      TYPE SHARED
      FIND_ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      FIND_RELEASE_FILE "mylib_1.11.0"
      FIND_DEBUG_FILE "mylibd_1.11.0"
    )
    dependency(IMPORT "my_static_lib"
      TYPE STATIC
      FIND_ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      FIND_RELEASE_FILE "mylib_1.11.0"
      FIND_DEBUG_FILE "mylibd_1.11.0"
    )

    # Set include directories for shared lib
    dependency(ADD_INCLUDE_DIRECTORIES "my_shared_lib" SET
      INTERFACE
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
        "$<INSTALL_INTERFACE:include/mylib>"
    )
    # Is more or less equivalent to:
    target_include_directories(my_shared_lib
      INTERFACE
          "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
          "$<INSTALL_INTERFACE:include/mylib>"
    )

    # Set include directories for static lib
    dependency(ADD_INCLUDE_DIRECTORIES "my_static_lib" SET
      INTERFACE
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
        "$<INSTALL_INTERFACE:include/mylib>"
    )
    # Is more or less equivalent to:
    target_include_directories(my_static_lib
      INTERFACE
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

  .. note::

    The ``dependency(SET_IMPORTED_LOCATION)`` command should be called after
    importing the target with :command:`dependency(IMPORT)` to ensure that
    the target properties and result variables are set correctly.

  Example usage:

  .. code-block:: cmake

    # Import libs
    dependency(IMPORT "my_shared_lib"
      TYPE SHARED
      FIND_ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      FIND_RELEASE_FILE "mylib_1.11.0"
      FIND_DEBUG_FILE "mylibd_1.11.0"
    )
    dependency(IMPORT "my_static_lib"
      TYPE STATIC
      FIND_ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      FIND_RELEASE_FILE "mylib_1.11.0"
      FIND_DEBUG_FILE "mylibd_1.11.0"
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
  dependency(EXPORT <lib-target-name>... <BUILD_TREE|INSTALL_TREE> [APPEND] OUTPUT_FILE_NAME <file-name>)

  Creates a file ``<file-name>`` in :cmake:variable:`CMAKE_CURRENT_BINARY_DIR <cmake:variable:CMAKE_CURRENT_BINARY_DIR>`
  that may be included by outside projects to import targets in
  ``<lib-target-name>`` list from the current project's build-tree or install
  -tree. This command is functionally similar to using
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
  imported targets; only the export script ``OUTPUT_FILE_NAME`` itself is installed.

  If the ``APPEND`` keyword is specified, the generated code is appended to the
  existing file instead of overwriting it. This is useful for exporting
  multiple targets incrementally to a single file.

  The generated file defines all necessary target properties so that the
  imported targets can be used as if they were defined locally. The properties
  are identical to those set by the :command:`dependency(IMPORT)` command; see
  its documentation for additional details.

  .. note::

    The ``dependency(EXPORT)`` command should be called after importing the
    target with :command:`dependency(IMPORT)` to ensure that the target
    properties and result variables are set correctly.

  Example usage:

  .. code-block:: cmake

    # Import libs before exporting
    dependency(IMPORT "my_shared_lib"
      TYPE SHARED
      FIND_ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      FIND_RELEASE_FILE "mylib_1.11.0"
      FIND_DEBUG_FILE "mylibd_1.11.0"
    )
    dependency(ADD_INCLUDE_DIRECTORIES "my_shared_lib" SET
      INTERFACE
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
        "$<INSTALL_INTERFACE:include/mylib>"
    )
    dependency(IMPORT "my_static_lib"
      TYPE STATIC
      FIND_ROOT_DIR "${CMAKE_SOURCE_DIR}/lib"
      FIND_RELEASE_FILE "mylib_1.11.0"
      FIND_DEBUG_FILE "mylibd_1.11.0"
    )
    dependency(ADD_INCLUDE_DIRECTORIES "my_static_lib" SET
      INTERFACE
        "$<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/include/mylib>"
        "$<INSTALL_INTERFACE:include/mylib>"
    )

    # Export from Build-Tree
    dependency(EXPORT "my_shared_lib" "my_static_lib"
      BUILD_TREE
      OUTPUT_FILE_NAME "InternalDependencyTargets.cmake"
    )
    # Is more or less equivalent to:
    export(TARGETS "my_shared_lib" "my_static_lib"
      APPEND
      FILE "InternalDependencyTargets.cmake"
    )

    # Exporting from Install-Tree
    set(CMAKE_INSTALL_PREFIX "${CMAKE_CURRENT_BINARY_DIR}/install")
    dependency(EXPORT "my_shared_lib" "my_static_lib"
      INSTALL_TREE
      OUTPUT_FILE_NAME "InternalDependencyTargets.cmake"
    )
    # Is more or less equivalent to:
    install(TARGETS "my_shared_lib" "my_static_lib"
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

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)
include(Directory)
include(StringManip)

#------------------------------------------------------------------------------
# Public function of this module
function(dependency)
  set(options BUILD_TREE INSTALL_TREE SET APPEND)
  set(one_value_args IMPORT TYPE FIND_ROOT_DIR FIND_RELEASE_FILE FIND_DEBUG_FILE OUTPUT_FILE_NAME ADD_INCLUDE_DIRECTORIES SET_IMPORTED_LOCATION CONFIGURATION)
  set(multi_value_args EXPORT INTERFACE PUBLIC)
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
# [Internal use only]
macro(_dependency_import)
  if(NOT DEFINED DEP_IMPORT)
    message(FATAL_ERROR "IMPORT argument is missing or need a value!")
  endif()
  if(TARGET "${DEP_IMPORT}")
    message(FATAL_ERROR "The target \"${DEP_IMPORT}\" already exists!")
  endif()
  if((NOT DEFINED DEP_TYPE)
      OR (NOT "${DEP_TYPE}" MATCHES "^(SHARED|STATIC)$"))
    message(FATAL_ERROR "TYPE argument arguments is wrong!")
  endif()
  if(NOT DEFINED DEP_FIND_ROOT_DIR)
    message(FATAL_ERROR "FIND_ROOT_DIR argument is missing or need a value!")
  endif()
  if((NOT DEFINED DEP_FIND_RELEASE_FILE)
      AND (NOT DEFINED DEP_FIND_DEBUG_FILE))
    message(FATAL_ERROR "FIND_RELEASE_FILE|FIND_DEBUG_FILE argument is missing!")
  endif()
  if("FIND_RELEASE_FILE" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "FIND_RELEASE_FILE need a value!")
  endif()
  if("FIND_DEBUG_FILE" IN_LIST DEP_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "FIND_DEBUG_FILE need a value!")
  endif()

  set(return_vars
    "${DEP_IMPORT}_LIBRARY_RELEASE"
    "${DEP_IMPORT}_LIBRARY_DEBUG"
    "${DEP_IMPORT}_IMP_LIBRARY_RELEASE"
    "${DEP_IMPORT}_IMP_LIBRARY_DEBUG"
    "${DEP_IMPORT}_LIBRARY"
    "${DEP_IMPORT}_LIBRARIES"
    "${DEP_IMPORT}_ROOT_DIR"
    "${DEP_IMPORT}_FOUND"
    "${DEP_IMPORT}_FOUND_RELEASE"
    "${DEP_IMPORT}_FOUND_DEBUG"
  )

  # Find and get library and import library each build type (RELEASE or DEBUG)
  foreach(build_type IN ITEMS "RELEASE" "DEBUG")
    # Skip the loop if lib for this config is not requested
    if(NOT DEFINED DEP_FIND_${build_type}_FILE)
      continue()
    endif()

    set(${DEP_IMPORT}_FOUND_${build_type} false)
    directory(FIND_LIB ${DEP_IMPORT}_LIBRARY_${build_type}
      FIND_IMPLIB ${DEP_IMPORT}_IMP_LIBRARY_${build_type}
      NAME "${DEP_FIND_${build_type}_FILE}"
      "${DEP_TYPE}"
      RELATIVE off
      ROOT_DIR "${DEP_FIND_ROOT_DIR}"
    )
    # Because only shared libraries on Windows platform use import libraries,
    # implib is always equals to `implib-NOTFOUND` for other cases, so the value is
    # replaced to empty only for these other cases.
    if(NOT (WIN32 AND ("${DEP_TYPE}" STREQUAL "SHARED")))
      if(NOT ${DEP_IMPORT}_IMP_LIBRARY_${build_type})
        set(${DEP_IMPORT}_IMP_LIBRARY_${build_type} "")
      endif()
    endif()

    if((NOT "${${DEP_IMPORT}_LIBRARY_${build_type}}" MATCHES "-NOTFOUND$")
        AND (NOT "${${DEP_IMPORT}_IMP_LIBRARY_${build_type}}" MATCHES "-NOTFOUND$"))
      set(${DEP_IMPORT}_FOUND_${build_type} true)
    endif()
  endforeach()

  # Sets and adjusts library variables based on debug and release build
  # configurations. This code copies the behavior of the CMake module
  # `SelectLibraryConfigurations`.)
  get_property(is_multi_config GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
  if(${DEP_IMPORT}_FOUND_RELEASE AND ${DEP_IMPORT}_FOUND_DEBUG
      AND (NOT "${${DEP_IMPORT}_LIBRARY_RELEASE}" STREQUAL "${${DEP_IMPORT}_LIBRARY_DEBUG}")
      AND (is_multi_config OR CMAKE_BUILD_TYPE))
    # If the generator is multi-config or if CMAKE_BUILD_TYPE is set for
    # single-config generators, set optimized and debug libraries
    set(${DEP_IMPORT}_LIBRARY "")
    list(APPEND ${DEP_IMPORT}_LIBRARY optimized "${${DEP_IMPORT}_LIBRARY_RELEASE}")
    list(APPEND ${DEP_IMPORT}_LIBRARY debug "${${DEP_IMPORT}_LIBRARY_DEBUG}")
  elseif(${DEP_IMPORT}_FOUND_RELEASE)
    set(${DEP_IMPORT}_LIBRARY "${${DEP_IMPORT}_LIBRARY_RELEASE}")
  elseif(${DEP_IMPORT}_FOUND_DEBUG)
    set(${DEP_IMPORT}_LIBRARY "${${DEP_IMPORT}_LIBRARY_DEBUG}")
  else()
    set(${DEP_IMPORT}_LIBRARY "${DEP_IMPORT}_LIBRARY-NOTFOUND")
  endif()

  set(${DEP_IMPORT}_ROOT_DIR "${DEP_FIND_ROOT_DIR}")
  set(${DEP_IMPORT}_LIBRARY "${${DEP_IMPORT}_LIBRARY}")
  set(${DEP_IMPORT}_LIBRARIES "${${DEP_IMPORT}_LIBRARY}")
  if(DEFINED ${DEP_IMPORT}_FOUND_RELEASE AND NOT ${${DEP_IMPORT}_FOUND_RELEASE}
      OR DEFINED ${DEP_IMPORT}_FOUND_DEBUG AND NOT ${${DEP_IMPORT}_FOUND_DEBUG})
    set(${DEP_IMPORT}_FOUND false)
  else()
    set(${DEP_IMPORT}_FOUND true)
  endif()

  # Exit the function if no lib or implib has been found for one or both build
  # types
  if(NOT ${DEP_IMPORT}_FOUND)
    return(PROPAGATE ${return_vars})
  endif()

  # Create target
  add_library("${DEP_IMPORT}" "${DEP_TYPE}" IMPORTED)
  add_library("${DEP_IMPORT}::${DEP_IMPORT}" ALIAS "${DEP_IMPORT}")
  set_target_properties("${DEP_IMPORT}" PROPERTIES
    # For usage from source-tree
    INTERFACE_INCLUDE_DIRECTORIES ""
    # Custom property for usage from build-tree
    INTERFACE_INCLUDE_DIRECTORIES_BUILD ""
    # Custom property for usage from install-tree
    INTERFACE_INCLUDE_DIRECTORIES_INSTALL ""
  )

  # Add library properties for each build type (RELEASE or DEBUG)
  foreach(build_type IN ITEMS "RELEASE" "DEBUG")
    # Skip the loop if lib or implib is not found or build type is not set
    if(NOT ${DEP_IMPORT}_FOUND_${build_type})
      continue()
    endif()

    cmake_path(GET ${DEP_IMPORT}_LIBRARY_${build_type} FILENAME lib_file_name)
    set_target_properties("${DEP_IMPORT}" PROPERTIES
      # Only for '.so|.dll|.a|.lib'. For usage from source-tree
      IMPORTED_LOCATION_${build_type} "${${DEP_IMPORT}_LIBRARY_${build_type}}"
      # Custom property for usage from build-tree
      IMPORTED_LOCATION_BUILD_${build_type} ""
      # Custom property for usage from install-tree
      IMPORTED_LOCATION_INSTALL_${build_type} ""
      # Only for '.dll.a|.a|.lib' on DLL platforms
      IMPORTED_IMPLIB_${build_type} "${${DEP_IMPORT}_IMP_LIBRARY_${build_type}}"
      IMPORTED_SONAME_${build_type} "${lib_file_name}"
    )
    set_property(TARGET "${DEP_IMPORT}"
      APPEND PROPERTY IMPORTED_CONFIGURATIONS "${build_type}"
    )
  endforeach()

  return(PROPAGATE ${return_vars})
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
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
  if(NOT DEFINED DEP_INTERFACE)
    message(FATAL_ERROR "INTERFACE argument is missing or need a value!")
  endif()
  if(NOT TARGET "${DEP_ADD_INCLUDE_DIRECTORIES}")
    message(FATAL_ERROR "The target \"${DEP_ADD_INCLUDE_DIRECTORIES}\" does not exists!")
  endif()

  string_manip(EXTRACT_INTERFACE DEP_INTERFACE
    BUILD
    OUTPUT_VARIABLE include_dirs_build_interface
  )
  string_manip(EXTRACT_INTERFACE DEP_INTERFACE
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

  get_target_property(all_include_dirs "${DEP_ADD_INCLUDE_DIRECTORIES}" INTERFACE_INCLUDE_DIRECTORIES)
  set(${DEP_ADD_INCLUDE_DIRECTORIES}_INCLUDE_DIR "${include_dirs_build_interface}")
  set(${DEP_ADD_INCLUDE_DIRECTORIES}_INCLUDE_DIRS "${all_include_dirs}")
  return(PROPAGATE
    "${DEP_ADD_INCLUDE_DIRECTORIES}_INCLUDE_DIR"
    "${DEP_ADD_INCLUDE_DIRECTORIES}_INCLUDE_DIRS"
  )
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
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
# [Internal use only]
macro(_dependency_export_deprecated)
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
    cmake_path(APPEND export_file_template "ImportInstallTreeLibTargets.cmake.in")
    cmake_path(APPEND export_dir "cmake" "export") # This is where the export file to copy during install will be generated
    if(NOT EXISTS "${export_dir}")
      file(MAKE_DIRECTORY "${export_dir}")
    endif()
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
    message(FATAL_ERROR
      "Export command already specified for the file \"${DEP_OUTPUT_FILE}\". Did you miss 'APPEND' keyword?")
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
      message(FATAL_ERROR
        "Target type \"${lib_target_type}\" for target \"${lib_target_name}\" is unsupported by export command!")
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

  # Build a command to merge the intermediate files and a unique target to
  # trigger this command
  set(merge_command_args "")
  if(NOT TARGET ${unique_target_name})
    list(APPEND merge_command_args
      "OUTPUT" "${export_file}")
  else()
    list(APPEND merge_command_args
      "OUTPUT" "${export_file}" "APPEND")
  endif()
  if(${DEP_APPEND})
    list(APPEND merge_command_args
      "COMMAND" "${CMAKE_COMMAND}" "-E" "touch" "${export_file}"
      "COMMAND" "${CMAKE_COMMAND}" "-E" "cat" ${new_export_parts} ">>" "${export_file}"
      "DEPENDS" "${new_export_parts}"
      "COMMENT" "Update the import file \"${export_file}\"")
  else()
    list(APPEND merge_command_args
      "COMMAND" "${CMAKE_COMMAND}" "-E" "cat" ${new_export_parts} ">" "${export_file}"
      "DEPENDS" "${new_export_parts}"
      "COMMENT" "Overwrite the import file \"${export_file}\"")
  endif()
  add_custom_command(${merge_command_args})

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
      DESTINATION "cmake/export" # Path is relative to CMAKE_INSTALL_PREFIX
    )
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
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
  if(NOT DEFINED DEP_OUTPUT_FILE_NAME)
    message(FATAL_ERROR "OUTPUT_FILE_NAME argument is missing or need a value!")
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
  cmake_path(SET intermediate_export_dir "${CMAKE_BINARY_DIR}/CMakeFiles")
  if(${DEP_BUILD_TREE})
    cmake_path(APPEND intermediate_export_dir "ExportFromBuildTree")
  elseif(${DEP_INSTALL_TREE})
    cmake_path(APPEND intermediate_export_dir "ExportFromInstallTree")
    cmake_path(APPEND export_dir "cmake" "export") # This is where the export file to copy during install will be generated
    if(NOT EXISTS "${export_dir}")
      file(MAKE_DIRECTORY "${export_dir}")
    endif()
  endif()
  set(export_file "${export_dir}/${DEP_OUTPUT_FILE_NAME}")

  # Remove the files generated by a previous cmake command call
  if(EXISTS "${intermediate_export_dir}")
    file(REMOVE_RECURSE "${intermediate_export_dir}")
  endif()

  # Sanitize the output file path to create a valid CMake property identifier
  cmake_path(GET export_file FILENAME sanitized_export_file)
  string(MAKE_C_IDENTIFIER "${sanitized_export_file}" sanitized_export_file)

  # List of previously generated intermediate files
  if(${DEP_BUILD_TREE})
    get_property(existing_export_parts GLOBAL PROPERTY "_BUILD_EXPORT_PARTS_${sanitized_export_file}")
  elseif(${DEP_INSTALL_TREE})
    get_property(existing_export_parts GLOBAL PROPERTY "_INSTALL_EXPORT_PARTS_${sanitized_export_file}")
  endif()

  # Throw an error if this command has already been called and 'APPEND' keyword
  # is not used
  list(LENGTH existing_export_parts nb_parts)
  if((NOT ${nb_parts} EQUAL 0) AND (NOT ${DEP_APPEND}))
    message(FATAL_ERROR
      "Export command already specified for the file \"${DEP_OUTPUT_FILE_NAME}\". Did you miss 'APPEND' keyword?")
  endif()

  # List of intermediate part files to concatenate later
  set(new_export_parts "")

  # Code executed only at the first call to Dependency(EXPORT)
  if(${nb_parts} EQUAL 0)
    # Add CMake insall rules to move the export file
    if(${DEP_INSTALL_TREE})
      install(FILES "${export_file}"
        DESTINATION "cmake/export" # Path is relative to CMAKE_INSTALL_PREFIX
      )
    endif()

    # Generate the header intermediate file
    set(import_instructions "")
    _generate_import_header_code(import_instructions)
    set(header_part_file "${intermediate_export_dir}/header.part.cmake")
    file(GENERATE OUTPUT "${header_part_file}"
      CONTENT "${import_instructions}"
    )
    set_source_files_properties("${header_part_file}" PROPERTIES GENERATED TRUE)

    # Add generated files to the `clean` target
    set_property(DIRECTORY
      APPEND
      PROPERTY ADDITIONAL_CLEAN_FILES
      "${header_part_file}"
    )
    list(APPEND new_export_parts "${header_part_file}")
  endif()

  foreach(lib_target_name IN ITEMS ${DEP_EXPORT})
    # Generate a per-target intermediate file with generator expressions
    get_target_property(lib_target_type "${lib_target_name}" TYPE)
    set(new_part_file "${intermediate_export_dir}/${lib_target_name}Targets-${lib_target_type}.part.cmake")
    if(NOT ("${new_part_file}" IN_LIST existing_export_parts))
      set(import_instructions "")
      if(${DEP_BUILD_TREE})
        _generate_import_from_build_tree("${lib_target_name}" import_instructions)
      elseif(${DEP_INSTALL_TREE})
        _generate_import_from_install_tree("cmake/export" "${lib_target_name}" import_instructions)
      endif()

      # The ouptut file will be generated only one time after processing all of
      # a project's CMakeLists.txt files
      file(GENERATE OUTPUT "${new_part_file}"
        CONTENT "${import_instructions}"
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

  # Code executed only at the first call to Dependency(EXPORT)
  if(${nb_parts} EQUAL 0)
    # Generate the fotter intermediate file
    set(import_instructions "")
    _generate_import_footer_code(import_instructions)
    set(footer_part_file "${intermediate_export_dir}/footer.part.cmake")
    file(GENERATE OUTPUT "${footer_part_file}"
      CONTENT "${import_instructions}"
    )
    set_source_files_properties("${footer_part_file}" PROPERTIES GENERATED TRUE)

    # Add generated files to the `clean` target
    set_property(DIRECTORY
      APPEND
      PROPERTY ADDITIONAL_CLEAN_FILES
      "${footer_part_file}"
    )
    list(APPEND new_export_parts "${footer_part_file}")
    # Append the generated intermediate files to the file's associated global property
    list(APPEND existing_export_parts "${new_export_parts}")
  else()
    # Pop back the footer before adding the new intermediate files
    list(POP_BACK existing_export_parts footer_part_file)
    # Append the generated intermediate files to the file's associated global property
    list(APPEND existing_export_parts "${new_export_parts}")
    # Push back the footer after adding the new intermediate files
    list(APPEND existing_export_parts footer_part_file)
  endif()

  if(${DEP_BUILD_TREE})
    set_property(GLOBAL PROPERTY "_BUILD_EXPORT_PARTS_${sanitized_export_file}" "${existing_export_parts}")
  elseif(${DEP_INSTALL_TREE})
    set_property(GLOBAL PROPERTY "_INSTALL_EXPORT_PARTS_${sanitized_export_file}" "${existing_export_parts}")
  endif()

  # Build a command to merge the intermediate files and a unique target to
  # trigger this command
  set(unique_target_name "GenerateImportTargetFile_${sanitized_export_file}")
  set(merge_command_args "")
  if(NOT TARGET ${unique_target_name})
    list(APPEND merge_command_args
      "OUTPUT" "${export_file}")
  else()
    list(APPEND merge_command_args
      "OUTPUT" "${export_file}" "APPEND")
  endif()
  if(${DEP_APPEND})
    list(APPEND merge_command_args
      "COMMAND" "${CMAKE_COMMAND}" "-E" "touch" "${export_file}"
      "COMMAND" "${CMAKE_COMMAND}" "-E" "cat" ${new_export_parts} ">>" "${export_file}"
      "DEPENDS" "${new_export_parts}"
      "COMMENT" "Update the import file \"${export_file}\"")
  else()
    list(APPEND merge_command_args
      "COMMAND" "${CMAKE_COMMAND}" "-E" "cat" ${new_export_parts} ">" "${export_file}"
      "DEPENDS" "${new_export_parts}"
      "COMMENT" "Overwrite the import file \"${export_file}\"")
  endif()
  add_custom_command(${merge_command_args}) # TODO revoir cette commande toute pourrie qui me fait péter un cable ! Plutôt que de concaténer les parties à l'existant, il faudrait réécrire le fichier d'export à chaque appel (moins complexe à gérer)

  # Only true during the first invocation
  if(NOT TARGET "${unique_target_name}")
    # Create a unique generative target per output file to trigger the command
    add_custom_target("${unique_target_name}" ALL
      DEPENDS "${export_file}"
      VERBATIM
    )
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
function(_generate_import_header_code in_output_var)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "_generate_import_header_code() requires exactly 1 arguments, got ${ARGC}!")
  endif()
  if("${in_output_var}" STREQUAL "")
    message(FATAL_ERROR "in_output_var argument is empty!")
  endif()

  string(APPEND ${in_output_var}
"# Generated by the \"${PROJECT_NAME}\" project

#----------------------------------------------------------------
# Generated CMake lib target import file.
#----------------------------------------------------------------
"
  )
  return(PROPAGATE "${in_output_var}")
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_generate_import_from_build_tree lib_target_name in_output_var)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "_generate_import_from_build_tree() requires exactly 2 arguments, got ${ARGC}!")
  endif()
  if("${lib_target_name}" STREQUAL "")
    message(FATAL_ERROR "lib_target_name argument is empty!")
  endif()
  if("${in_output_var}" STREQUAL "")
    message(FATAL_ERROR "in_output_var argument is empty!")
  endif()

  # Creates the imported target
  get_target_property(lib_target_type "${lib_target_name}" TYPE)
  string(APPEND ${in_output_var}
"
# Create imported target \"$<TARGET_PROPERTY:NAME>\"
"
  )
  if("${lib_target_type}" STREQUAL "STATIC_LIBRARY")
    string(APPEND ${in_output_var}
"add_library(\"$<TARGET_PROPERTY:NAME>\" STATIC IMPORTED)
"
    )
  elseif("${lib_target_type}" STREQUAL "SHARED_LIBRARY")
    string(APPEND ${in_output_var}
"add_library(\"$<TARGET_PROPERTY:NAME>\" SHARED IMPORTED)
"
    )
  else()
    message(FATAL_ERROR
      "Target type \"${lib_target_type}\" for target \"${lib_target_name}\" is unsupported by export command!")
  endif()

  # Add usage requirements
  string(APPEND ${in_output_var}
"
# Import target \"$<TARGET_PROPERTY:NAME>\" for configuration \"$<CONFIG>\"
set_target_properties(\"$<TARGET_PROPERTY:NAME>\" PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES \"$<TARGET_PROPERTY:INTERFACE_INCLUDE_DIRECTORIES_BUILD>\"
  IMPORTED_LOCATION_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_LOCATION_BUILD_$<CONFIG>>\"
  IMPORTED_IMPLIB_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_IMPLIB_$<CONFIG>>\"
  IMPORTED_SONAME_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_SONAME_$<CONFIG>>\"
)
set_property(TARGET \"$<TARGET_PROPERTY:NAME>\" APPEND
  PROPERTY IMPORTED_CONFIGURATIONS \"$<CONFIG>\"
)
"
  )

  return(PROPAGATE "${in_output_var}")
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_generate_import_from_install_tree relative_export_dir_path lib_target_name in_output_var)
  if(NOT ${ARGC} EQUAL 3)
    message(FATAL_ERROR "_generate_import_from_install_tree() requires exactly 3 arguments, got ${ARGC}!")
  endif()
  if("${relative_export_dir_path}" STREQUAL "")
    message(FATAL_ERROR "relative_export_dir_path argument is empty!")
  endif()
  if("${lib_target_name}" STREQUAL "")
    message(FATAL_ERROR "lib_target_name argument is empty!")
  endif()
  if("${in_output_var}" STREQUAL "")
    message(FATAL_ERROR "in_output_var argument is empty!")
  endif()

  # Add the code to compute the installation prefix relative to the import
  # file location
  string(APPEND ${in_output_var}
"
# Compute the installation prefix relative to this file
get_filename_component(_IMPORT_PREFIX \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)
"
  )
  set(import_prefix "${relative_export_dir_path}")
  while((NOT "${import_prefix}" STREQUAL "${CMAKE_INSTALL_PREFIX}")
      AND (NOT "${import_prefix}" STREQUAL ""))
    string(APPEND ${in_output_var}
"get_filename_component(_IMPORT_PREFIX \"\${_IMPORT_PREFIX}\" PATH)
"
    )
    cmake_path(GET import_prefix PARENT_PATH import_prefix)
  endwhile()
  string(APPEND ${in_output_var}
"if(_IMPORT_PREFIX STREQUAL \"/\")
  set(_IMPORT_PREFIX \"\")
endif()
"
  )

  # Creates the imported target
  get_target_property(lib_target_type "${lib_target_name}" TYPE)
  string(APPEND ${in_output_var}
"
# Create imported target \"$<TARGET_PROPERTY:NAME>\"
"
  )
  if("${lib_target_type}" STREQUAL "STATIC_LIBRARY")
    string(APPEND ${in_output_var}
"add_library(\"$<TARGET_PROPERTY:NAME>\" STATIC IMPORTED)
"
    )
  elseif("${lib_target_type}" STREQUAL "SHARED_LIBRARY")
    string(APPEND ${in_output_var}
"add_library(\"$<TARGET_PROPERTY:NAME>\" SHARED IMPORTED)
"
    )
  else()
    message(FATAL_ERROR
      "Target type \"${lib_target_type}\" for target \"${lib_target_name}\" is unsupported by export command!")
  endif()

  # Add usage requirements
  string(APPEND ${in_output_var}
"
# Import target \"$<TARGET_PROPERTY:NAME>\" for configuration \"$<CONFIG>\"
set_target_properties(\"$<TARGET_PROPERTY:NAME>\" PROPERTIES
  INTERFACE_INCLUDE_DIRECTORIES \"\${_IMPORT_PREFIX}/$<TARGET_PROPERTY:INTERFACE_INCLUDE_DIRECTORIES_INSTALL>\"
  IMPORTED_LOCATION_$<CONFIG> \"\${_IMPORT_PREFIX}/$<TARGET_PROPERTY:IMPORTED_LOCATION_INSTALL_$<CONFIG>>\"
  IMPORTED_IMPLIB_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_IMPLIB_$<CONFIG>>\"
  IMPORTED_SONAME_$<CONFIG> \"$<TARGET_PROPERTY:IMPORTED_SONAME_$<CONFIG>>\"
)
set_property(TARGET \"$<TARGET_PROPERTY:NAME>\" APPEND
  PROPERTY IMPORTED_CONFIGURATIONS \"$<CONFIG>\"
)
"
  )

  # Add cleanup of temporary variables
  string(APPEND ${in_output_var}
"# Cleanup temporary variables.
set(_IMPORT_PREFIX)
"
  )

  return(PROPAGATE "${in_output_var}")
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_generate_import_footer_code in_output_var)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "_generate_import_footer_code() requires exactly 1 arguments, got ${ARGC}!")
  endif()
  if("${in_output_var}" STREQUAL "")
    message(FATAL_ERROR "in_output_var argument is empty!")
  endif()

  string(APPEND ${in_output_var}
"#----------------------------------------------------------------
"
  )
  return(PROPAGATE "${in_output_var}")
endfunction()