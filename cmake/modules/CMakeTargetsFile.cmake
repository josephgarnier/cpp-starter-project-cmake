# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
CMakeTargetsFile
----------------

Provide operations to configure binary targets using a JSON configuration file.
It requires CMake 3.20 or newer.

Introduction
^^^^^^^^^^^^

In a CMake build project, there is no native and straightforward way to
separate the declaration of a binary target from its definition. Both are
typically performed together when writing commands in a ``CMakeLists.txt``
file. However, in many use cases, the sequence of commands used to define
targets is identical across projects, with only the data changing. The
definition logic for the binary target remains the same, while only its
declarations (i.e., its configuration) change.

One option could be to declare the configuration with variables in the JSON of
:cmake:manual:`cmake-presets <cmake:manual:cmake-presets(7)>`, but it is not
possible to have structured properties and they would be difficult to read.

The purpose of this module is to simplify the automated creation of binary
targets by allowing their settings to be declared in a standardized JSON
configuration file. Thus, the `build specification <https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#target-build-specification>`_ of a target and its `usage
requirements <https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#target-usage-requirements>`_ can be easily defined. The structure of this file is defined
using a `JSON schema <https://json-schema.org/>`_. Various commands are
provided to read and interpret this configuration file.

The configuration file must be named ``CMakeTargets.json`` and can reside
anywhere in the project's directory.

.. note::

  CMake is currently developing the
  `Common Package Specification <https://cps-org.github.io/cps/index.html>`_
  to standardize the way packages are declared and to improve their
  integration via the
  `System Package Registry <https://cmake.org/cmake/help/git-master/manual/cmake-packages.7.html#system-package-registry>`_.
  It is therefore possible that this module may become obsolete in the
  future. In the meantime, it will continue to evolve to reflect updates
  introduced in upcoming versions.

Format
^^^^^^

The CMake targets declaration file is a JSON document with an object as the
root (:download:`click to download <../../../cmake/modules/CMakeTargets_sample.json>`):

.. literalinclude:: ../../../cmake/modules/CMakeTargets_sample.json
  :language: json

The JSON document must be conformed to the :download:`CMakeTargets.json schema <../../../cmake/modules/schema.json>` described below.

The root object recognizes the following fields:

``$schema``
  An optional string that provides a URI to the `JSON schema <https://json-schema.org/>`_
  that describes the structure of this JSON document. This field is used for
  validation and autocompletion in editors that support JSON schema. It doesn't
  affect the behavior of the document itself. If this field is not specified,
  the JSON document will still be valid, but tools that use JSON schema for
  validation and autocompletion may not function correctly. The module does
  not perform schema validation automatically. Use ``$schema`` to document the
  schema version or to enable external validation and tooling workflows.

``$id``
  An optional string that provides a unique identifier for the JSON document or
  the schema resource. The value must be a valid URI or a relative URI
  reference. When present, ``$id`` can be used by external tooling to
  disambiguate or resolve the schema/resource and to avoid collisions between
  different schema documents. The module stores this property but does not
  interpret or enforce any semantics associated with ``$id``.

``targets``
  The required root property containing the set of targets defined in the
  file. Its value is an object whose keys are unique directory paths that
  identify the parent folder containing the source files for each target.
  For example: ``src``, ``src/apple``.

  Each path must be relative to the project root and must not include a
  trailing slash. The directory path serves as the unique identifier for
  the target within the file because it is assumed that there can be no
  more than one target defined per folder.

  The value for each key is a target definition object as described in the
  following subsections. The key name (directory path) can be used internally
  to organize and retrieve target configurations during the CMake building
  process.

  Each entry of a ``targets`` is a JSON object that may contain the following
  properties:

  ``name``
    A required string specifying the human-meaningful name of the target.
    This name must be unique across all targets listed in the same
    ``targets`` object. Two targets within the same file must not share
    the same name, even if their directory paths differ. The name is used to
    create a CMake target.

  ``type``
    A required string specifying the kind of binary to generate for this
    target. Valid values are:

      * ``staticLib`` - a static library.
      * ``sharedLib`` - a shared (dynamic) library.
      * ``interfaceLib`` - a header-only library.
      * ``executable`` - an executable program.

    The type influences how the target is built and linked by the consuming
    CMake logic.

  ``build``
    A required object describing build settings. It contains the following
    array properties:

      ``compileFeatures``
        A list of compile features to pass to the target. Example:
        ``["cxx_std_20", "cxx_thread_local", "cxx_trailing_return_types"]``.
        It is intended to be used as a parameter for the
        :cmake:command:`target_compile_features() <cmake:command:target_compile_features>`
        command. The property is required, but the array can be empty.

      ``compileDefinitions``
        A list of preprocessor definitions applied when compiling this target.
        Example: ``["DEFINE_ONE=1", "DEFINE_TWO=2", "OPTION_1"]``. It is
        intended to be used as a parameter for the
        :cmake:command:`target_compile_definitions() <cmake:command:target_compile_definitions>`
        command. The property is required, but the array can be empty.

      ``compileOptions``
        A list of compiler options to pass when building this target. Example:
        ``["-Wall", "-Wextra", "/W4"]``. It is intended to be used as a
        parameter for the
        :cmake:command:`target_compile_options() <cmake:command:target_compile_options>`
        command. The property is required, but the array can be empty.

      ``linkOptions``
        A list of linker options to pass when building this target. Example:
        ``["-s", "-z", "/INCREMENTAL:NO"]``. It is intended to be used as a
        parameter for the
        :cmake:command:`target_link_options() <cmake:command:target_link_options>`
        command. The property is required, but the array can be empty.

    All four properties must be present. Lists may be empty to indicate no
    entries.

  ``mainFile``
    A required string specifying the path to the main source file for this
    target. The path must be relative to the project root. The file must exist
    and have a ``.cpp``, ``.cc``, or ``.cxx`` extension.

  ``pchFile``
    An optional string specifying the path to the precompiled header file
    (PCH) for this target. The path must be relative to the project root. If
    present, it must have one of the following extensions: ``.h``, ``.hpp``,
    ``.hxx``, ``.inl``, ``.tpp``. If not specified, the target is considered to
    have no PCH.

  ``headerPolicy``
    A required object describing how header files are organized within the
    project. It has the following properties:

      ``mode``
        A required string specifying whether all header files are grouped in a
        a single common folder or whether public headers are separated from
        private headers. Valid values are:

          * ``split`` - public headers are stored in a different folder
            (e.g., ``include/``) than private headers (e.g., ``src/``).
          * ``merged`` - public and private headers are in the same folder
            (e.g., ``src/``).

      ``includeDir``
        Required only if ``mode`` is ``split``. A path relative to the project
        root specifying the folder in ``include/`` where the public
        headers are located. The path must start with ``include`` (e.g.,
        ``include``, ``include/mylib``) and must not include a trailing slash.

  ``dependencies``
    The required object property specifying the set of dependencies needed by
    the target. Its value is an object whose keys are the names of the
    dependencies. A name is intended to be used as ``PackageName`` argument to
    :cmake:command:`find_package() <cmake:command:find_package>`. It must
    therefore be compatible with CMake's ``PackageName`` requirements. Each
    name must be unique within the ``dependencies`` object and cannot contain
    a space.

    Each entry of a ``dependencies`` object is a JSON object that may contain
    the following properties:

    ``rulesFile``
      A required property that specifies how to integrate the dependency into
      the build system. It can be either:

      * ``generic`` - use the predefined generic rules for integration.
      * a path to a ``.cmake`` file - the file must exist and contain the
        logic for handling the dependency.

    ``packageLocation``
      A required object when ``rulesFile`` is ``generic``, otherwise optional.
      It defines the location where the dependency package can be found. These
      values are intended to be used to set the ``<PackageName>_DIR`` variable
      for :cmake:command:`find_package() <cmake:command:find_package>`. It
      may contain the following properties:

      ``windows``
        An optional string representing the path to a directory containing
        the package for Windows.

      ``unix``
        An optional string representing the path to a directory containing
        the package for Unix. Whitespace is not allowed.

      ``macos``
        An optional string representing the path to a directory containing
        the package for macOS. Whitespace is not allowed.

    ``minVersion``
      A required string when ``rulesFile`` is ``generic``, otherwise optional,
      specifying the minimum acceptable version of the dependency. This value
      is intended to be used as the ``VERSION`` argument to
      :cmake:command:`find_package() <cmake:command:find_package>`
      calls for that dependency.

    ``fetchInfo``
      A required object when ``rulesFile`` is ``generic``, otherwise optional.
      It provides the information needed to download the dependency package if
      it is not available locally. Theses informations are intended to be used
      as argument to :cmake:command:`FetchContent_Declare() <cmake:command:FetchContent_Declare>`
      or :cmake:command:`ExternalProject_Add() <cmake:command:ExternalProject_Add>`.
      It has the following properties:

        ``autodownload``
          A required boolean indicating whether the dependency may be
          automatically downloaded if not found locally.

        ``kind``
          An required string specifying the download method to use when
          ``autodownload`` is ``true`` (otherwise optional). Valid values are
          ``url``, ``git``, ``svn``, and ``mercurial``. It support all download
          methods supported by `External Project <https://cmake.org/cmake/help/latest/module/ExternalProject.html#download-step-options>`_.

        ``repository``
          A required URL to the repository to use when ``autodownload`` is
          ``true`` (otherwise optional).

        ``tag``
          A required string specifying a branch name, tag, or commit identifier
          to checkout when ``kind`` is ``git`` or ``mercurial`` (otherwise
          optional).

        ``hash``
          A required string specifying a hash of the file to be downloaded when
          ``kind`` is ``url`` (otherwise optional).

        ``revision``
          A required string specifying a revision to checkout when ``kind`` is
          ``svn`` (otherwise optional).

    ``optional``
      A required boolean when ``rulesFile`` is ``generic``, otherwise optional,
      indicating whether the dependency is optional (``true``) or required
      (``false``).

    ``configuration``
      A required object when ``rulesFile`` is ``generic``, otherwise optional,
      specifying some additional settings applied to the dependency. It
      contains the following array properties:

        ``compileFeatures``
          A list of compile features that must be enabled or disabled when
          compiling code that consumes the dependency. Example:
          ``["cxx_std_20", "cxx_thread_local", "cxx_trailing_return_types"]``.
          It is intended to be used as a parameter for the
          :cmake:command:`target_compile_features() <cmake:command:target_compile_features>`
          command. The property is required when ``rulesFile`` is ``generic``,
          otherwise optional, but the array can be empty.

        ``compileDefinitions``
          A list of compile definitions that must be defined when compiling
          code that consumes the dependency. Example: ``["DEFINE_ONE=1",
          "DEFINE_TWO=2", "OPTION_1"]``. It is intended to be used as a
          parameter for the
          :cmake:command:`target_compile_definitions() <cmake:command:target_compile_definitions>`
          command. The property is required when ``rulesFile`` is ``generic``,
          otherwise optional, but the array can be empty.

        ``compileOptions``
          A list of compiler options that must be supplied to the compiler when
          compiling code that consumes the dependency. Example: ``["-Wall",
          "-Wextra", "/W4"]``. It is intended to be used as a parameter for the
          :cmake:command:`target_compile_options() <cmake:command:target_compile_options>`
          command. The property is required when ``rulesFile`` is ``generic``,
          otherwise optional, but the array can be empty.

        ``linkOptions``
          A list of linker options that must be enabled or disabled when
          linking code that consumes the dependency. Example: ``["-s", "-z",
          "/INCREMENTAL:NO"]``. It is intended to be used as a parameter for
          the
          :cmake:command:`target_link_options() <cmake:command:target_link_options>`
          command. The property is required when ``rulesFile`` is ``generic``,
          otherwise optional, but the array can be empty.

Schema
^^^^^^

:download:`This file <../../../cmake/modules/schema.json>` provides a machine-
readable JSON schema for the ``CMakeTargets.json`` format.

Synopsis
^^^^^^^^

.. parsed-literal::

  `Loading`_
    cmake_targets_file(`LOAD`_ <json-file-path>)
    cmake_targets_file(`IS_LOADED`_ <output-var>)
    cmake_targets_file(`GET_LOADED_FILE`_ <output-var>)

  `Querying`_
    cmake_targets_file(`HAS_CONFIG`_ <output-var> TARGET <target-dir-path>)
    cmake_targets_file(`GET_SETTINGS`_ <output-map-var> TARGET <target-dir-path>)
    cmake_targets_file(`HAS_SETTING`_ <output-var> TARGET <target-dir-path> KEY <setting-name>)
    cmake_targets_file(`GET_KEYS`_ <output-list-var> TARGET <target-dir-path>)
    cmake_targets_file(`GET_VALUE`_ <output-var> TARGET <target-dir-path> KEY <setting-name>)
    cmake_targets_file(`TRY_GET_VALUE`_ <output-var> TARGET <target-dir-path> KEY <setting-name>)

  `Debugging`_
    cmake_targets_file(`PRINT_CONFIGS`_ [])
    cmake_targets_file(`PRINT_TARGET_CONFIG`_ <target-dir-path>)

Loading
^^^^^^^

.. signature::
  cmake_targets_file(LOAD <json-file-path>)

  Load and parses a targets configuration file in `JSON schema <https://json-schema.org/>`_.

  The ``<json-file-path>`` specifies the location of the configuration file to
  load. It must refer to an existing file on disk and must have a ``.json``
  extension. The file must conform to the :download:`CMakeTargets.json schema <../../../cmake/modules/schema.json>`.
  During loading, the command verifies that the JSON file if conform to the
  JSON schema.

  When this command is invoked, the JSON content is read into memory and stored
  in global properties for later retrieval. Each target entry described in the
  JSON file is parsed into an independent configuration :module:`Map`, keyed by its
  directory path. Both the original raw JSON and the list of target directory
  paths are preserved.

  The following global properties are initialized:

    ``TARGETS_CONFIG_<target-dir-path>``
      For each target directory path in the configuration file, stores the
      serialized key-value :module:`Map` of its parsed properties.

    ``TARGETS_CONFIG_RAW_JSON``
      Contains the loaded JSON file as text.

    ``TARGETS_CONFIG_LIST``
      Holds the list of all target directory paths defined in the file. They
      serve as value to get the target configurations stored in
      ``TARGETS_CONFIG_<target-dir-path>``.

    ``TARGETS_CONFIG_LOADED``
      Set to ``on`` once the configuration is successfully loaded, otherwise
      to ``off``.

  This command must be called exactly once before using any other
  module operation. If the configuration is already loaded, calling :command:`cmake_targets_file(LOAD)`
  again will replace the current configuration in memory.

  Each target's configuration is stored separately in a global property
  named ``TARGETS_CONFIG_<target-dir-path>`` as a :module:`Map`, where each
  target JSON block is represented as a *flat tree* list. Keys in the map are
  derived from the JSON property names. Nested properties are flattened by
  concatenating their successive parent keys, separated by a dot (``.``). For
  example, the JSON key ``rulesFile`` from the above example is stored in the
  map as ``dependencies.AppleLib.rulesFile``. The list of all keys for a target
  's map can be retrieved using the :command:`cmake_targets_file(GET_KEYS)`
  command.

  In this context, a setting is a key/value pair, and the set of settings for
  a target represents the configuration for that target. The key of a setting
  is named "setting name" and its value is named "setting value".

  Since CMake does not support two-dimensional arrays, and because a :module:`Map`
  is itself a particular type of list, JSON arrays are serialized before being
  stored. Elements in a serialized array are separated by a pipe (``|``)
  character. For example, the JSON array ``["DEFINE_ONE=1", "DEFINE_TWO=2",
  "OPTION_1"]`` become ``DEFINE_ONE=1|DEFINE_TWO=2|OPTION_1``. And to avoid
  conflicts, pipe characters (``|``) are first escaped with a slash (``\|``).

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(LOAD "${CMAKE_SOURCE_DIR}/CMakeTargets.json")
    get_property(raw_json GLOBAL PROPERTY "TARGETS_CONFIG_RAW_JSON")
    get_property(is_loaded GLOBAL PROPERTY "TARGETS_CONFIG_LOADED")
    get_property(paths_list GLOBAL PROPERTY "TARGETS_CONFIG_LIST")
    get_property(apple_config GLOBAL PROPERTY "TARGETS_CONFIG_src/apple")
    get_property(banana_config GLOBAL PROPERTY "TARGETS_CONFIG_src/banana")
    get_property(src_config GLOBAL PROPERTY "TARGETS_CONFIG_src")
    message("'src' array is: ${src_config}")
    # output is:
    #   'src' array is: name:fruit-salad;type:executable;mainFile:src/main.cpp;
    #   pchFile:include/fruit_salad_pch.h;build.compileFeatures:cxx_std_20;
    #   build.compileDefinitions:DEFINE_ONE=1|DEFINE_TWO=2|
    #   OPTION_1;build.compileOptions:;build.linkOptions:;
    #   headerPolicy.mode:split;...

.. signature::
  cmake_targets_file(IS_LOADED <output-var>)

  Set ``<output-var>`` to ``on`` if a targets configuration file has been
  loaded with success, or ``off`` otherwise. This checks the global property
  ``TARGETS_CONFIG_LOADED`` set by a successful invocation of the
  :command:`cmake_targets_file(LOAD)` command.

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(LOAD "${CMAKE_SOURCE_DIR}/CMakeTargets.json")
    cmake_targets_file(IS_LOADED is_file_loaded)
    message("file_loaded: ${is_file_loaded}")
    # output is:
    #   file_loaded: on

.. signature::
  cmake_targets_file(GET_LOADED_FILE <output-var>)

  Set ``<output-var>`` to the full JSON content of the currently loaded
  targets configuration file. The content is retrieved from the global property
  ``TARGETS_CONFIG_RAW_JSON``, which is set by a successful invocation of the
  :command:`cmake_targets_file(LOAD)` command.

  An error is raised if no configuration file is loaded.

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(GET_LOADED_FILE json_file_content)
    message("json_file_content: ${json_file_content}")
    # output is:
    #   json_file_content: {
    #     "$schema": "schema.json",
    #     "$id": "schema.json",
    #     "targets": {
    #       ...
    #     }
    #   }

Querying
^^^^^^^^

.. signature::
  cmake_targets_file(HAS_CONFIG <output-var> TARGET <target-dir-path>)

  Set ``<output-var>`` to ``on`` if a configuration exists for the given
  target directory path ``<target-dir-path>``, or ``off`` otherwise.

  Example usage :

  .. code-block:: cmake

    cmake_targets_file(HAS_CONFIG is_target_configured TARGET "src")
    message("is_target_configured (src): ${is_target_configured}")
    # output is:
    #   is_target_configured (src): on

.. signature::
  cmake_targets_file(GET_SETTINGS <output-map-var> TARGET <target-dir-path>)

  Retrieves the list of all settings defined for a given target configuration
  in the global property ``TARGETS_CONFIG_<target-dir-path>``.

  The ``<target-dir-path>`` specifies the directory path of the target whose
  configuration settings should be retrieved. This must correspond to a path
  listed in the global property ``TARGETS_CONFIG_LIST``, and must match one
  of the keys in the ``targets`` JSON object of the loaded configuration file.

  The result is stored in ``<output-var>`` as a :module:`Map`. The **values
  are serialized**, so to access a specific value, it is recommended to use
  the :command:`cmake_targets_file(GET_VALUE)` command, which deserializes
  the values.

  An error is raised if no configuration file has been previously loaded with
  the :command:`cmake_targets_file(LOAD)` command or if the ``TARGET`` does not
  exist in the loaded configuration file.

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(GET_SETTINGS target_config_map TARGET "src")
    message("target_config (src): ${target_config_map}")
    # output is:
    #   target_config (src): name:fruit-salad;type:executable;mainFile:
    #   src/main.cpp;pchFile:include/fruit_salad_pch.h;...

.. signature::
  cmake_targets_file(HAS_SETTING <output-var> TARGET <target-dir-path> KEY <setting-name>)

  Set ``<output-var>`` to ``on`` if the configuration of the given target
  contains the specified setting key ``<setting-name>``, or ``off`` otherwise.

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(HAS_SETTING has_setting_key TARGET "src" KEY "type")
    message("has_setting_key (type): ${has_setting_key}")
    # output is:
    #   has_setting_key (type): on

.. signature::
  cmake_targets_file(GET_KEYS <output-list-var> TARGET <target-dir-path>)

  Retrieves the list of all setting keys defined for a given target
  configuration in the global property ``TARGETS_CONFIG_<target-dir-path>``.

  The ``<target-dir-path>`` specifies the directory path of the target whose
  configuration settings should be retrieved. This must correspond to a path
  listed in the global property ``TARGETS_CONFIG_LIST``, and must match one
  of the keys in the ``targets`` JSON object of the loaded configuration file.

  The result is stored in ``<output-var>`` as a semicolon-separated list.

  An error is raised if no configuration file has been previously loaded with
  the :command:`cmake_targets_file(LOAD)` command or if the ``TARGET`` does not
  exist in the loaded configuration file.

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(GET_KEYS setting_keys TARGET "src")
    message("setting_keys: ${setting_keys}")
    # With the JSON example above, output is:
    #   setting_keys: name;type;mainFile;pchFile;build.compileFeatures;build.
    #   compileDefinitions;build.compileOptions;build.linkOptions;headerPolicy.
    #   mode;headerPolicy.includeDir...

.. signature::
  cmake_targets_file(GET_VALUE <output-var> TARGET <target-dir-path> KEY <setting-name>)

  Retrieves the value associated to a specific setting key ``<setting-name>``
  defined for a given target configuration in the global property
  ``TARGETS_CONFIG_<target-dir-path>``.

  The ``<target-dir-path>`` specifies the directory path of the target whose
  configuration setting should be retrieved. This must correspond to a path
  listed in the global property ``TARGETS_CONFIG_LIST``, and must match one
  of the keys in the ``targets`` JSON object of the loaded configuration file.

  The ``<setting-name>`` specifies the flattened key name as stored in the
  :module:`Map` ``TARGETS_CONFIG_<target-dir-path>``. Nested JSON properties
  are concatenated using a dot (``.``) separator (e.g.,
  ``build.compileDefinitions``).

  The result is stored in ``<output-var>`` as a value or a deserialized list.

  An error is raised if no configuration file has been previously loaded with
  the :command:`cmake_targets_file(LOAD)` command or if the ``TARGET`` does not
  exist in the loaded configuration file or if the ``KEY`` does not exist in
  the target configuration.

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(GET_VALUE setting_value TARGET "src" KEY "type")
    message("setting_value (type): ${setting_value}")
    # output is:
    #   setting_value (type): executable
    cmake_targets_file(GET_VALUE setting_value TARGET "src" KEY "build.compileDefinitions")
    message("setting_value (build.compileDefinitions): ${setting_value}")
    # output is:
    #   setting_value (build.compileDefinitions): DEFINE_ONE=1;DEFINE_TWO=2;
    #   OPTION_1
    cmake_targets_file(GET_VALUE setting_value TARGET "src" KEY "dependencies")
    message("setting_value (dependencies): ${setting_value}")
    # output is:
    #   setting_value (dependencies): AppleLib;BananaLib;CarrotLib;OrangeLib;
    #   PineappleLib

.. signature::
  cmake_targets_file(TRY_GET_VALUE <output-var> TARGET <target-dir-path> KEY <setting-name>)

  Try to retrieve the value associated to a specific setting key
  ``<setting-name>`` defined for a given target configuration in the global
  property ``TARGETS_CONFIG_<target-dir-path>``.

  The ``<target-dir-path>`` specifies the directory path of the target whose
  configuration setting should be retrieved. This must correspond to a path
  listed in the global property ``TARGETS_CONFIG_LIST``, and must match one
  of the keys in the ``targets`` JSON object of the loaded configuration file.

  The ``<setting-name>`` specifies the flattened key name as stored in the
  :module:`Map` ``TARGETS_CONFIG_<target-dir-path>``. Nested JSON properties
  are concatenated using a dot (``.``) separator (e.g.,
  ``build.compileDefinitions``).

  The result is stored in ``<output-var>`` as a value or a deserialized list.
  If the ``KEY`` does not exist in the target configuration, ``<output-var>``
  is set to ``<setting-name>-NOTFOUND``.

  An error is raised if no configuration file has been previously loaded with
  the :command:`cmake_targets_file(LOAD)` command or if the ``TARGET`` does not
  exist in the loaded configuration file.

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(TRY_GET_VALUE setting_value TARGET "src" KEY "type")
    message("setting_value (type): ${setting_value}")
    # output is:
    #   setting_value (type): executable
    cmake_targets_file(TRY_GET_VALUE setting_value TARGET "src" KEY "build.compileDefinitions")
    message("setting_value (build.compileDefinitions): ${setting_value}")
    # output is:
    #   setting_value (build.compileDefinitions): DEFINE_ONE=1;DEFINE_TWO=2;
    #   OPTION_1
    cmake_targets_file(TRY_GET_VALUE setting_value TARGET "src" KEY "dependencies")
    message("setting_value (dependencies): ${setting_value}")
    # output is:
    #   setting_value (dependencies): AppleLib;BananaLib;CarrotLib;OrangeLib;
    #   PineappleLib
    cmake_targets_file(TRY_GET_VALUE setting_value TARGET "src" KEY "nonexistent.setting")
    message("setting_value (nonexistent.setting): ${setting_value}")
    # output is:
    #   setting_value (nonexistent.setting): nonexistent.setting-NOTFOUND

Debugging
^^^^^^^^^

.. signature::
  cmake_targets_file(PRINT_CONFIGS [])

  Prints the configuration of all targets defined in the currently loaded
  configuration file. It is primarily intended for debugging or inspecting the
  parsed target settings after loading a configuration file.

  An error is raised if no configuration file has been previously loaded with
  the :command:`cmake_targets_file(LOAD)` command

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(PRINT_CONFIGS)
    # output is:
    #   -- Target: fruit-salad
    #   --   type: executable
    #   --   build.compileFeatures: cxx_std_20|cxx_thread_local|cxx_trailing_return_types
    #   --   build.compileDefinitions: DEFINE_ONE=1|DEFINE_TWO=2|OPTION_1
    #   --   build.compileOptions: -Wall|-Wextra
    #   --   build.linkOptions: -s|-z
    #   --   mainFile: src/main.cpp
    #   --   pchFile: include/fruit_salad_pch.h
    #   ...

.. signature::
  cmake_targets_file(PRINT_TARGET_CONFIG <target-dir-path>)

  Prints the configuration of a given target configuration in the global
  property ``TARGETS_CONFIG_<target-dir-path>``. It is primarily intended for
  debugging or inspecting a parsed target settings after loading a
  configuration file.

  The ``<target-dir-path>`` specifies the directory path of the target whose
  configuration setting should be retrieved. This must correspond to a path
  listed in the global property ``TARGETS_CONFIG_LIST``, and must match one
  of the keys in the ``targets`` JSON object of the loaded configuration file.

  An error is raised if no configuration file has been previously loaded with
  the :command:`cmake_targets_file(LOAD)` command.

  Example usage:

  .. code-block:: cmake

    cmake_targets_file(PRINT_TARGET_CONFIG "src")
    # output is:
    #   -- Target: fruit-salad
    #   --   type: executable
    #   --   build.compileFeatures: cxx_std_20|cxx_thread_local|cxx_trailing_return_types
    #   --   build.compileDefinitions: DEFINE_ONE=1|DEFINE_TWO=2|OPTION_1
    #   --   build.compileOptions: -Wall|-Wextra
    #   --   build.linkOptions: -s|-z
    #   --   mainFile: src/main.cpp
    #   --   pchFile: include/fruit_salad_pch.h
    #   ...
#]=======================================================================]

include_guard()

cmake_minimum_required (VERSION 3.20 FATAL_ERROR)
include(Map)

#------------------------------------------------------------------------------
# Public function of this module
function(cmake_targets_file)
  set(options PRINT_CONFIGS)
  set(one_value_args LOAD IS_LOADED GET_LOADED_FILE GET_VALUE TRY_GET_VALUE TARGET KEY GET_SETTINGS GET_KEYS PRINT_TARGET_CONFIG HAS_CONFIG HAS_SETTING)
  set(multi_value_args "")
  cmake_parse_arguments(CTF "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(DEFINED CTF_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${CTF_UNPARSED_ARGUMENTS}\"")
  endif()
  if(DEFINED CTF_LOAD)
    _cmake_targets_file_load()
  elseif(DEFINED CTF_IS_LOADED)
    _cmake_targets_file_is_loaded()
  elseif(DEFINED CTF_GET_LOADED_FILE)
    _cmake_targets_file_get_loaded_file()
  elseif(DEFINED CTF_HAS_CONFIG)
    _cmake_targets_file_has_config()
  elseif(DEFINED CTF_GET_VALUE)
    _cmake_targets_file_get_value()
  elseif(DEFINED CTF_TRY_GET_VALUE)
    _cmake_targets_file_try_get_value()
  elseif(DEFINED CTF_GET_SETTINGS)
    _cmake_targets_file_get_settings()
  elseif(DEFINED CTF_HAS_SETTING)
    _cmake_targets_file_has_setting()
  elseif(DEFINED CTF_GET_KEYS)
    _cmake_targets_file_get_keys()
  elseif(${CTF_PRINT_CONFIGS})
    _cmake_targets_file_print_configs()
  elseif(DEFINED CTF_PRINT_TARGET_CONFIG)
    _cmake_targets_file_print_target_config()
  else()
    message(FATAL_ERROR "The operation name or arguments are missing!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_load)
  if(NOT DEFINED CTF_LOAD)
    message(FATAL_ERROR "LOAD argument is missing or need a value!")
  endif()
  if((NOT EXISTS "${CTF_LOAD}")
      OR (IS_DIRECTORY "${CTF_LOAD}"))
    message(FATAL_ERROR "Given path: ${CTF_LOAD} does not refer to an existing path or file on disk!")
  endif()
  if(NOT "${CTF_LOAD}" MATCHES "\\.json$")
    message(FATAL_ERROR "Given path: ${CTF_LOAD} is not a json file!")
  endif()

  # Read the JSON file
  file(READ "${CTF_LOAD}" json_file_content)

  # Extract and parse the list of target paths (keys of the "targets" object)
  # Use '_get_json_object' because the property keys of 'targets'
  # (target paths) are of type 'pattern property' (set by user)
  _get_json_object(targets_map "${json_file_content}" "targets" on)
  map(KEYS targets_map target_paths)
  foreach(target_path IN ITEMS ${target_paths})
    _validate_json_string(PROP_PATH "targets;${target_path}" PROP_VALUE "${target_path}" PATTERN "^[A-Za-z0-9_]+(/.+)?$")
  
    set(target_config_map "")
    map(GET targets_map "${target_path}" target_json_block)

    # Extract all top-level and required primitive properties
    _get_json_value(name "${target_json_block}" "name" "STRING" on)
    _validate_json_string(PROP_PATH "name" PROP_VALUE "${name}" MIN_LENGTH "1")
    map(ADD target_config_map "name" "${name}")

    _get_json_value(type "${target_json_block}" "type" "STRING" on)
    _validate_json_string(PROP_PATH "type" PROP_VALUE "${type}" PATTERN "^(staticLib|sharedLib|interfaceLib|executable)$")
    map(ADD target_config_map "type" "${type}")

    _get_json_value(main_file "${target_json_block}" "mainFile" "STRING" on)
    _validate_json_string(PROP_PATH "mainFile" PROP_VALUE "${main_file}" PATTERN "(.+/)?[^/]+\\.(cpp|cc|cxx)$")
    map(ADD target_config_map "mainFile" "${main_file}")

    # Extract all top-level and optional primitive properties
    _get_json_value(pch_file "${target_json_block}" "pchFile" "STRING" off)
    if(NOT "${pch_file}" MATCHES "-NOTFOUND$")
      _validate_json_string(PROP_PATH "pchFile" PROP_VALUE "${pch_file}" PATTERN "(.+/)?[^/]+\\.(h|hpp|hxx|inl|tpp)$")
      map(ADD target_config_map "pchFile" "${pch_file}")
    endif()

    # Extract nested 'build' object properties
    _get_json_value(build_json_block "${target_json_block}" "build" "OBJECT" on)
    foreach(prop_key "compileFeatures" "compileDefinitions" "compileOptions" "linkOptions")
      _get_json_array(build_settings_list "${build_json_block}" "${prop_key}" on)
      _serialize_list(serialized_list "${build_settings_list}")
      map(ADD target_config_map "build.${prop_key}" "${serialized_list}")
    endforeach()

    # Extract nested 'header policy' object properties
    _get_json_value(header_policy_mode "${target_json_block}" "headerPolicy;mode" "STRING" on)
    _validate_json_string(PROP_PATH "headerPolicy;mode" PROP_VALUE "${header_policy_mode}" PATTERN "^(split|merged)$")
    map(ADD target_config_map "headerPolicy.mode" "${header_policy_mode}")
    if("${header_policy_mode}" STREQUAL "split")
      # 'includeDir' is required when mode is 'split'
      _get_json_value(include_dir
        "${target_json_block}" "headerPolicy;includeDir" "STRING" on)
      _validate_json_string(PROP_PATH "headerPolicy;includeDir" PROP_VALUE "${include_dir}" PATTERN "^include(/.+)?$")
      map(ADD target_config_map "headerPolicy.includeDir" "${include_dir}")
    endif()

    # Extract nested 'dependencies' object properties
    # Use '_get_json_object' because the property keys of 'dependencies'
    # (dep. names) are of type 'pattern property' (set by user)
    _get_json_object(deps_map "${target_json_block}" "dependencies" on)
    map(KEYS deps_map dep_names)
    _serialize_list(serialized_dep_names "${dep_names}")
    map(ADD target_config_map "dependencies" "${serialized_dep_names}")
    foreach(dep_name IN ITEMS ${dep_names})
      _validate_json_string(PROP_PATH "dependencies;${dep_name}" PROP_VALUE "${target_path}" PATTERN "^[^ \t\r\n]+$")
      map(GET deps_map "${dep_name}" dep_json_block)

      # Only 'rulesFile' is required, others properties are required only if
      # rulesFile is 'generic'
      _get_json_value(dep_rules_file "${dep_json_block}" "rulesFile" "STRING" on)
      _validate_json_string(PROP_PATH "rulesFile" PROP_VALUE "${dep_rules_file}" PATTERN "^((.+/)?[^/]+\\.cmake|generic)$")
      map(ADD target_config_map "dependencies.${dep_name}.rulesFile" "${dep_rules_file}")
      # Required flag (true/false depending on rulesFile)
      set(is_generic off)
      if("${dep_rules_file}" STREQUAL "generic")
        set(is_generic on)
      endif()

      # Extract all top-level primitive properties
      _get_json_value(dep_min_version "${dep_json_block}" "minVersion" "STRING" ${is_generic})
      if(NOT "${dep_min_version}" MATCHES "-NOTFOUND$")
        map(ADD target_config_map "dependencies.${dep_name}.minVersion" "${dep_min_version}")
      endif()
      _get_json_value(dep_optional "${dep_json_block}" "optional" "BOOLEAN" ${is_generic})
      if(NOT "${dep_optional}" MATCHES "-NOTFOUND$")
        map(ADD target_config_map "dependencies.${dep_name}.optional" "${dep_optional}")
      endif()

      # Extract nested 'packageLocation' object properties
      _get_json_value(dep_package_loc_json_block
        "${dep_json_block}" "packageLocation" "OBJECT" ${is_generic})
      if(NOT "${dep_package_loc_json_block}" MATCHES "-NOTFOUND$")
        foreach(prop_key "windows" "unix" "macos")
          _get_json_value(prop_value
            "${dep_package_loc_json_block}" "windows" "STRING" off)
          if(NOT "${prop_value}" MATCHES "-NOTFOUND$")
            _validate_json_string(PROP_PATH "packageLocation.windows" PROP_VALUE "${prop_value}" PATTERN "^[A-Za-z]:[/]([^<>:\"/\\\\|?*]+[/]?)*$")
            map(ADD target_config_map "dependencies.${dep_name}.packageLocation.windows" "${prop_value}")
          endif()

          _get_json_value(prop_value
            "${dep_package_loc_json_block}" "unix" "STRING" off)
          if(NOT "${prop_value}" MATCHES "-NOTFOUND$")
            _validate_json_string(PROP_PATH "packageLocation.unix" PROP_VALUE "${prop_value}" PATTERN "^(/[^/ \t\r\n]+)+/?$")
            map(ADD target_config_map "dependencies.${dep_name}.packageLocation.unix" "${prop_value}")
          endif()

          _get_json_value(prop_value
            "${dep_package_loc_json_block}" "macos" "STRING" off)
          if(NOT "${prop_value}" MATCHES "-NOTFOUND$")
            _validate_json_string(PROP_PATH "packageLocation.macos" PROP_VALUE "${prop_value}" PATTERN "^(/[^/ \t\r\n]+)+/?$")
            map(ADD target_config_map "dependencies.${dep_name}.packageLocation.macos" "${prop_value}")
          endif()
        endforeach()
      endif()
      
      # Extract nested 'fetchInfo' object properties
      _get_json_value(dep_fetch_info_json_block "${dep_json_block}" "fetchInfo" "OBJECT" ${is_generic})
      if(NOT "${dep_fetch_info_json_block}" MATCHES "-NOTFOUND$")
        # Only 'autodownload' is required in fetchInfo when rulesFile is 'generic',
        # others properties are required only if autodownload is 'true'
        _get_json_value(dep_fetch_autodownload "${dep_fetch_info_json_block}" "autodownload" "BOOLEAN" ${is_generic})
        if(NOT "${dep_fetch_autodownload}" MATCHES "-NOTFOUND$")
          map(ADD target_config_map "dependencies.${dep_name}.fetchInfo.autodownload" "${dep_fetch_autodownload}")
        endif()

        # Required flag (true/false depending on autodownload)
        set(is_autodownload_true off)
        if(${dep_fetch_autodownload})
          set(is_autodownload_true on)
        endif()

        # Others properties depends on 'kind'
        _get_json_value(dep_fetch_kind "${dep_fetch_info_json_block}" "kind" "STRING" ${is_autodownload_true})
        if(NOT "${dep_fetch_kind}" MATCHES "-NOTFOUND$")
            _validate_json_string(PROP_PATH "fetchInfo;kind" PROP_VALUE "${dep_fetch_kind}" PATTERN "^(url|git|svn|mercurial)$")
            map(ADD target_config_map "dependencies.${dep_name}.fetchInfo.kind" "${dep_fetch_kind}")
            if("${dep_fetch_kind}" MATCHES "^(git|mercurial)$")
              foreach(prop_key "repository" "tag")
                _get_json_value(prop_value "${dep_fetch_info_json_block}" "${prop_key}" "STRING" on)
                map(ADD target_config_map "dependencies.${dep_name}.fetchInfo.${prop_key}" "${prop_value}")
              endforeach()
            endif()
            if("${dep_fetch_kind}" STREQUAL "url")
              foreach(prop_key "repository" "hash")
                _get_json_value(prop_value "${dep_fetch_info_json_block}" "${prop_key}" "STRING" on)
                map(ADD target_config_map "dependencies.${dep_name}.fetchInfo.${prop_key}" "${prop_value}")
              endforeach()
            endif()
            if("${dep_fetch_kind}" STREQUAL "svn")
              foreach(prop_key "repository" "revision")
                _get_json_value(prop_value "${dep_fetch_info_json_block}" "${prop_key}" "STRING" on)
                map(ADD target_config_map "dependencies.${dep_name}.fetchInfo.${prop_key}" "${prop_value}")
              endforeach()
            endif()
        endif()
      endif()

      # Extract nested 'configuration' object properties
      _get_json_value(dep_config_json_block "${dep_json_block}" "configuration" "OBJECT" ${is_generic})
      if(NOT "${dep_config_json_block}" MATCHES "-NOTFOUND$")
        foreach(prop_key "compileFeatures" "compileDefinitions" "compileOptions" "linkOptions")
          _get_json_array(dep_configs_list "${dep_config_json_block}" "${prop_key}" ${is_generic})
          if(NOT "${dep_configs_list}" MATCHES "-NOTFOUND$")
            _serialize_list(serialized_list "${dep_configs_list}")
            map(ADD target_config_map "dependencies.${dep_name}.configuration.${prop_key}" "${serialized_list}")
          endif()
        endforeach()
      endif()
    endforeach()
    
    # Store the target configuration
    set_property(GLOBAL PROPERTY "TARGETS_CONFIG_${target_path}" "${target_config_map}")
  endforeach()

  # Mark the configuration as loaded and store the raw JSON content and the
  # list of targets
  set_property(GLOBAL PROPERTY TARGETS_CONFIG_RAW_JSON "${json_file_content}")
  set_property(GLOBAL PROPERTY TARGETS_CONFIG_LIST "${target_paths}")
  set_property(GLOBAL PROPERTY TARGETS_CONFIG_LOADED on)
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
function(_has_json_property output_var json_block json_path_list)
  if(NOT ${ARGC} EQUAL 3)
    message(FATAL_ERROR "_has_json_property() requires exactly 3 arguments, got ${ARGC}!")
  endif()
  if("${output_var}" STREQUAL "")
    message(FATAL_ERROR "output_var argument is empty!")
  endif()
  if("${json_block}" STREQUAL "")
    message(FATAL_ERROR "json_block argument is empty!")
  endif()

  string(JSON json_value ERROR_VARIABLE err GET "${json_block}" ${json_path_list})
  if(err)
    set(${output_var} off PARENT_SCOPE)
  else()
    set(${output_var} on PARENT_SCOPE)
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_get_json_value output_var json_block json_path_list json_type is_required)
  if(NOT ${ARGC} EQUAL 5)
    message(FATAL_ERROR "_get_json_value() requires exactly 5 arguments, got ${ARGC}!")
  endif()
  if("${output_var}" STREQUAL "")
    message(FATAL_ERROR "output_var argument is empty!")
  endif()
  if("${json_block}" STREQUAL "")
    message(FATAL_ERROR "json_block argument is empty!")
  endif()
  if(NOT "${json_type}" MATCHES "^(NULL|STRING|NUMBER|BOOLEAN|ARRAY|OBJECT)$")
    message(FATAL_ERROR "json_type must be \"NULL\", \"STRING\", \"NUMBER\", \"BOOLEAN\", \"ARRAY\" or \"OBJECT\"!")
  endif()
  if(NOT "${is_required}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "is_required must be \"on\" or \"off\"")
  endif()

  string(JSON json_block_type ERROR_VARIABLE err TYPE "${json_block}" ${json_path_list})
  if(err)
    if(${is_required})
      list(JOIN json_path_list "." joined)
      message(FATAL_ERROR "Missing required JSON property '${joined}'!")
    else()
      set(${output_var} "${json_block_type}" PARENT_SCOPE) # will be <json-path...->-NOTFOUND
      return()
    endif()
  endif()
  if(NOT "${json_block_type}" STREQUAL "${json_type}")
    message(FATAL_ERROR "Given JSON block is not an ${json_type}, but a ${json_block_type}!")
  endif()

  string(JSON json_value GET "${json_block}" ${json_path_list})
  set(${output_var} "${json_value}" PARENT_SCOPE)
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_get_json_array output_list_var json_block json_path_list is_required)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "_get_json_array() requires exactly 4 arguments, got ${ARGC}!")
  endif()
  if("${output_list_var}" STREQUAL "")
    message(FATAL_ERROR "output_list_var argument is empty!")
  endif()
  if("${json_block}" STREQUAL "")
    message(FATAL_ERROR "json_block argument is empty!")
  endif()
  if(NOT "${is_required}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "is_required must be \"on\" or \"off\"")
  endif()

  string(JSON json_block_type ERROR_VARIABLE err TYPE "${json_block}" ${json_path_list})
  if(err)
    if(${is_required})
      list(JOIN json_path_list "." joined)
      message(FATAL_ERROR "Missing required JSON property '${joined}'!")
    else()
      set(${output_list_var} "${json_block_type}" PARENT_SCOPE) # will be <json-path...->-NOTFOUND
      return()
    endif()
  endif()
  if(NOT "${json_block_type}" STREQUAL "ARRAY")
    message(FATAL_ERROR "Given JSON block is not an ARRAY, but a ${json_block_type}!")
  endif()

  set(elements_list "")
  string(JSON json_array GET "${json_block}" ${json_path_list})
  _json_array_to_list(elements_list "${json_array}")
  set(${output_list_var} "${elements_list}" PARENT_SCOPE)
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_json_array_to_list output_list_var json_array)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "_json_array_to_list() requires exactly 2 arguments, got ${ARGC}!")
  endif()
  if("${output_list_var}" STREQUAL "")
    message(FATAL_ERROR "output_list_var argument is empty!")
  endif()
  if("${json_array}" STREQUAL "")
    message(FATAL_ERROR "json_array argument is empty!")
  endif()
  string(JSON json_block_type TYPE "${json_array}")
  if(NOT "${json_block_type}" STREQUAL "ARRAY")
    message(FATAL_ERROR "Given JSON block is not an ARRAY, but a ${json_block_type}!")
  endif()

  set(elements_list "")
  string(JSON nb_elem LENGTH "${json_array}")
  if (nb_elem GREATER 0)
    math(EXPR last_index "${nb_elem} - 1")
    foreach(i RANGE 0 ${last_index})
      string(JSON elem GET "${json_array}" ${i})
      list(APPEND elements_list "${elem}")
    endforeach()
  endif()
  set(${output_list_var} "${elements_list}" PARENT_SCOPE)
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_get_json_object output_map_var json_block json_path_list is_required)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "_get_json_object() requires exactly 4 arguments, got ${ARGC}!")
  endif()
  if("${output_map_var}" STREQUAL "")
    message(FATAL_ERROR "output_map_var argument is empty!")
  endif()
  if("${json_block}" STREQUAL "")
    message(FATAL_ERROR "json_block argument is empty!")
  endif()
  if(NOT "${is_required}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "is_required must be \"on\" or \"off\"")
  endif()

  string(JSON json_block_type ERROR_VARIABLE err TYPE "${json_block}" ${json_path_list})
  if(err)
    if(${is_required})
      list(JOIN json_path_list "." joined)
      message(FATAL_ERROR "Missing required JSON property '${joined}'!")
    else()
      set(${output_map_var} "${json_block_type}" PARENT_SCOPE) # will be <json-path...->-NOTFOUND
      return()
    endif()
  endif()
  if(NOT "${json_block_type}" STREQUAL "OBJECT")
    message(FATAL_ERROR "Given JSON block is not an OBJECT, but a ${json_block_type}!")
  endif()

  set(objects_map "")
  string(JSON json_object GET "${json_block}" ${json_path_list})
  _json_object_to_map(objects_map "${json_object}")
  set(${output_map_var} "${objects_map}" PARENT_SCOPE)
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_json_object_to_map output_map_var json_object)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "_json_object_to_map() requires exactly 2 arguments, got ${ARGC}!")
  endif()
  if("${output_map_var}" STREQUAL "")
    message(FATAL_ERROR "output_map_var argument is empty!")
  endif()
  if("${json_object}" STREQUAL "")
    message(FATAL_ERROR "json_object argument is empty!")
  endif()
  string(JSON json_block_type TYPE "${json_object}")
  if(NOT "${json_block_type}" STREQUAL "OBJECT")
    message(FATAL_ERROR "Given JSON block is not an OBJECT, but a ${json_block_type}!")
  endif()

  set(objects_map "")
  string(JSON nb_objects LENGTH "${json_object}")
  if(nb_objects GREATER 0)
    math(EXPR last_index "${nb_objects} - 1")
    foreach(i RANGE 0 ${last_index})
      string(JSON prop_key MEMBER "${json_object}" ${i})
      string(JSON prop_value GET "${json_object}" "${prop_key}")
      map(ADD objects_map "${prop_key}" "${prop_value}")
    endforeach()
  endif()
  set(${output_map_var} "${objects_map}" PARENT_SCOPE)
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_serialize_list output_var input_list)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "_serialize_list() requires exactly 2 arguments, got ${ARGC}!")
  endif()
  if("${output_var}" STREQUAL "")
    message(FATAL_ERROR "output_var argument is empty!")
  endif()

  list(TRANSFORM input_list REPLACE "\\|" "\\\\|")
  list(JOIN input_list "|" joined)
  set(${output_var} "${joined}" PARENT_SCOPE)
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_deserialize_list output_list_var encoded_string)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "_deserialize_list() requires exactly 2 arguments, got ${ARGC}!")
  endif()
  if("${output_list_var}" STREQUAL "")
    message(FATAL_ERROR "output_list_var argument is empty!")
  endif()

  string(REPLACE "\\|" "<PIPE_ESC>" result "${encoded_string}")
  string(REPLACE "|" ";" result "${result}")
  string(REPLACE "<PIPE_ESC>" "|" result "${result}")
  set(${output_list_var} "${result}" PARENT_SCOPE)
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_is_serialized_list output_var input_string)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "_is_serialized_list() requires exactly 2 arguments, got ${ARGC}!")
  endif()
  if("${output_var}" STREQUAL "")
    message(FATAL_ERROR "output_var argument is empty!")
  endif()

  string(REPLACE "\\|" "<PIPE_ESC>" result "${input_string}")
  string(FIND "${result}" "|" pos)
  if(${pos} EQUAL -1)
    set(${output_var} off PARENT_SCOPE)
  else()
    set(${output_var} on PARENT_SCOPE)
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
# Validates a JSON string property.
#
# Signature:
#   _validate_json_string(PROP_PATH [<prop-key>...]
#                         PROP_VALUE [<string>]
#                         [MIN_LENGTH <number>]
#                         [MAX_LENGTH <number>]
#                         [PATTERN <regex>])
#
# Parameters:
#   PROP_PATH   : The path (as list of keys) to the property to validate.
#   PROP_VALUE  : The string coming from the property to validate. The value 
#                 must be a string of text.
#   MIN_LENGTH  : The minimum length of the string for the PROP_VALUE. The
#                 value MUST be a non-negative integer. To be valid, the length
#                 of PROP_VALUE must be greater than, or equal to, MIN_LENGTH.
#   MAX_LENGTH  : The maximum length of the string for the PROP_VALUE. The
#                 value MUST be a non-negative integer. To be valid, the length
#                 of PROP_VALUE must be less than, or equal to, MAX_LENGTH.
#   PATTERN     : The regular expression that the PROP_VALUE must match. The
#                 value MUST be a string. This string SHOULD be a valid regular
#                 expression, according to the CMake regular expression dialect.
#                 To be valid, PROP_VALUE must match the regular expression
#                 matches successfully.
#
# Returns:
#   None
#
# Example:
#   _validate_json_string(PROP_PATH "name"
#                         PROP_VALUE "${name}"
#                         PATTERN "^[A-Za-z0-9_]+$")
#------------------------------------------------------------------------------
function(_validate_json_string)
  set(options "")
  set(one_value_args PROP_VALUE MIN_LENGTH MAX_LENGTH PATTERN)
  set(multi_value_args PROP_PATH)
  cmake_parse_arguments(VJS "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(DEFINED VJS_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${VJS_UNPARSED_ARGUMENTS}\"")
  endif()
  if((NOT DEFINED VJS_PROP_PATH)
      AND (NOT "PROP_PATH" IN_LIST VJS_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "PROP_PATH argument is missing or need a value!")
  endif()
  if((NOT DEFINED VJS_PROP_VALUE)
      AND (NOT "PROP_VALUE" IN_LIST VJS_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "PROP_VALUE argument is missing or need a value!")
  endif()
  if("MIN_LENGTH" IN_LIST VJS_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "MIN_LENGTH argument is missing or need a value!")
  endif()
  if("MAX_LENGTH" IN_LIST VJS_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "MAX_LENGTH argument is missing or need a value!")
  endif()
  if("PATTERN" IN_LIST VJS_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "PATTERN argument is missing or need a value!")
  endif()

  # Join path for errors
  list(JOIN VJS_PROP_PATH "." prop_path_joined)

  # Check the value is a positive integer:
  #   ^ and $ -> start and end of the string (avoid false positives).
  #   +? -> optional sign.
  #   [0-9] -> first mandatory digit.
  #   [0-9]* -> optional additional digits.
  set(is_positive_integer_regex "^\\+?[1-9][0-9]*$")

  # Check length "min length" constraint
  if(DEFINED VJS_MIN_LENGTH)
    if(NOT ${VJS_MIN_LENGTH} MATCHES "${is_positive_integer_regex}")
      message(FATAL_ERROR "MIN_LENGTH argument is not an integer strictly greater than 0!")
    endif()
  
    string(LENGTH "${VJS_PROP_VALUE}" string_length)
    if(NOT ${string_length} GREATER_EQUAL ${VJS_MIN_LENGTH})
      message(FATAL_ERROR "Incorrect value for '${prop_path_joined}'. ${VJS_PROP_VALUE} is shorter than the minimum length of ${VJS_MIN_LENGTH}!")
    endif()
  endif()

  # Check length "max length" constraint
  if(DEFINED VJS_MAX_LENGTH)
    if(NOT ${VJS_MAX_LENGTH} MATCHES "${is_positive_integer_regex}")
      message(FATAL_ERROR "MAX_LENGTH argument is not an integer strictly greater than 0!")
    endif()

    string(LENGTH "${VJS_PROP_VALUE}" string_length)
    if(NOT ${string_length} LESS_EQUAL ${VJS_MAX_LENGTH})
      message(FATAL_ERROR "Incorrect value for '${prop_path_joined}'. ${VJS_PROP_VALUE} is longer than the maximum length of ${VJS_MAX_LENGTH}!")
    endif()
  endif()

  # Check regular expression "pattern" constraint
  if(DEFINED VJS_PATTERN)
    if(NOT "${VJS_PROP_VALUE}" MATCHES ${VJS_PATTERN})
      message(FATAL_ERROR "Incorrect value for '${prop_path_joined}'. ${VJS_PROP_VALUE} does not match the pattern of ${VJS_PATTERN}!")
    endif()
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
# Validates a JSON boolean property.
#
# Signature:
#   _validate_json_boolean(PROP_PATH [<prop-key>...]
#                          PROP_VALUE <number>)
#
# Parameters:
#   PROP_PATH   : The path (as list of keys) to the property to validate.
#   PROP_VALUE  : The boolean coming from the property to validate. The value
#                 must be 'ON' or 'OFF'.
#
# Returns:
#   None
#
# Example:
#   _validate_json_boolean(PROP_PATH "isDefined"
#                          PROP_VALUE "${isDefined}")
#------------------------------------------------------------------------------
function(_validate_json_boolean)
  set(options "")
  set(one_value_args PROP_VALUE)
  set(multi_value_args PROP_PATH)
  cmake_parse_arguments(VJB "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(DEFINED VJB_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${VJB_UNPARSED_ARGUMENTS}\"")
  endif()
  if((NOT DEFINED VJB_PROP_PATH)
      AND (NOT "PROP_PATH" IN_LIST VJB_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "PROP_PATH argument is missing or need a value!")
  endif()
  if(NOT DEFINED VJB_PROP_VALUE)
    message(FATAL_ERROR "PROP_VALUE argument is missing or need a value!")
  endif()
  
  if(NOT "${VJB_PROP_VALUE}" MATCHES "^(ON|OFF)$")
    list(JOIN VJB_PROP_PATH "." prop_path_joined)
    message(FATAL_ERROR "Incorrect type for '${prop_path_joined}'. Expected 'boolean'!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
# This function validates a JSON number property.
#
# Signature:
#   _validate_json_number(PROP_PATH [<prop-key>...]
#                         PROP_VALUE <number>
#                         [MULTIPLE_OF <number>]
#                         [MIN <number>]
#                         [EXCLU_MIN <number>]
#                         [MAX <number>]
#                         [EXCLU_MAX <number>])
#
# Parameters:
#   PROP_PATH    : The path (as list of keys) to the property to validate.
#   PROP_VALUE   : The number coming from the property to validate. Can be an
#                  integer (e.g. 1) or floating-point (e.g. 1.0) value.
#   MULTIPLE_OF  : The multiple of which the PROP_VALUE must be a multiple. The
#                  value MUST be an integer, strictly greater than 0.
#   MIN          : The minimum value allowed for the PROP_VALUE. The value MUST
#                  be a number, representing an inclusive lower limit. To be
#                  valid, PROP_VALUE >= MIN must be true.
#   EXCLU_MIN    : The minimum exclusive value allowed for the PROP_VALUE. The
#                  value MUST be a number, representing an exclusive lower
#                  limit. To be valid, PROP_VALUE > EXCLU_MIN must be true.
#   MAX          : The maximum value allowed for the PROP_VALUE. The value MUST
#                  be a number, representing an inclusive upper limit. To be
#                  valid, PROP_VALUE <= MAX must be true.
#   EXCLU_MAX    : The maximum exclusive value allowed for the PROP_VALUE. The
#                  value MUST be a number, representing an exclusive upper
#                  limit. To be valid, PROP_VALUE < EXCLU_MAX must be true.
#
# Returns:
#   None
#
# Example:
#   _validate_json_number(PROP_PATH "age"
#                         PROP_VALUE "${age}"
#                         MIN 0
#                         MAX 150)
#------------------------------------------------------------------------------
function(_validate_json_number)
  set(options "")
  set(one_value_args PROP_VALUE MULTIPLE_OF MIN MAX EXCLU_MIN EXCLU_MAX)
  set(multi_value_args PROP_PATH)
  cmake_parse_arguments(VJN "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

  if(DEFINED VJN_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${VJN_UNPARSED_ARGUMENTS}\"")
  endif()
  if((NOT DEFINED VJN_PROP_PATH)
      AND (NOT "PROP_PATH" IN_LIST VJN_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "PROP_PATH argument is missing or need a value!")
  endif()
  if(NOT DEFINED VJN_PROP_VALUE)
    message(FATAL_ERROR "PROP_VALUE argument is missing or need a value!")
  endif()
  if("MULTIPLE_OF" IN_LIST VJN_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "MULTIPLE_OF argument is missing or need a value!")
  endif()
  if("MIN" IN_LIST VJN_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "MIN argument is missing or need a value!")
  endif()
  if("MAX" IN_LIST VJN_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "MAX argument is missing or need a value!")
  endif()
  if("EXCLU_MIN" IN_LIST VJN_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "EXCLU_MIN argument is missing or need a value!")
  endif()
  if("EXCLU_MAX" IN_LIST VJN_KEYWORDS_MISSING_VALUES)
    message(FATAL_ERROR "EXCLU_MAX argument is missing or need a value!")
  endif()

  # Join path for errors
  list(JOIN VJN_PROP_PATH "." prop_path_joined)

  # Check the value is a number:
  #   ^ and $ -> start and end of the string (avoid false positives).
  #   [+-]? -> optional sign.
  #   [0-9]+ -> at least one mandatory digit.
  #   ([.][0-9]+)? -> optional fractional part with a point followed by at
  #                   least one digit.
  set(is_number_regex "^[\\+-]?[0-9]+([.][0-9]+)?$")
  if(NOT ${VJN_PROP_VALUE} MATCHES "${is_number_regex}")
    message(FATAL_ERROR "Incorrect type for '${prop_path_joined}'. Expected 'number'!")
  endif()

  # Check "multiple of" constraint
  if(DEFINED VJN_MULTIPLE_OF)
    # Check the value is a positive integer:
    #   ^ and $ -> start and end of the string (avoid false positives).
    #   +? -> optional sign.
    #   [0-9] -> first mandatory digit.
    #   [0-9]* -> optional additional digits.
    set(is_positive_integer_regex "^\\+?[1-9][0-9]*$")
    if(NOT ${VJN_MULTIPLE_OF} MATCHES "${is_positive_integer_regex}")
      message(FATAL_ERROR "MULTIPLE_OF argument is not an integer strictly greater than 0!")
    endif()
    # Prevent division by zero
    set(is_zero_regex "^[\\+-]?(0+)(\\.0+)?$")
    if(${VJN_MULTIPLE_OF} MATCHES "${is_zero_regex}")
      message(FATAL_ERROR "MULTIPLE_OF argument is an incorrect value. Division by 0 is not allowed!")
    endif()

    # Perform scaled division to simulate floating point support
    math(EXPR scaled_div "(${VJN_PROP_VALUE} * 1000000) / ${VJN_MULTIPLE_OF}")

    # Check if the division result is an integer by testing modulo 1e6
    math(EXPR mod "${scaled_div} % 1000000")
    if(NOT ${mod} EQUAL 0)
      message(FATAL_ERROR "Incorrect value for '${prop_path_joined}'. ${VJN_PROP_VALUE} is not divisible by ${VJN_MULTIPLE_OF}!")
    endif()
  endif()

  # Check range "min" constraint
  if(DEFINED VJN_MIN)
    if(NOT ${VJN_MIN} MATCHES "${is_number_regex}")
      message(FATAL_ERROR "MIN argument is not a number!")
    endif()
    if(NOT ${VJN_PROP_VALUE} GREATER_EQUAL ${VJN_MIN})
      message(FATAL_ERROR "Incorrect value for '${prop_path_joined}'. ${VJN_PROP_VALUE} is below the minimum of ${VJN_MIN}!")
    endif()
  endif()

  # Check range "min exclusive" constraint
  if(DEFINED VJN_EXCLU_MIN)
    if(NOT ${VJN_EXCLU_MIN} MATCHES "${is_number_regex}")
      message(FATAL_ERROR "EXCLU_MIN argument is not a number!")
    endif()
    if(NOT ${VJN_PROP_VALUE} GREATER ${VJN_EXCLU_MIN})
      message(FATAL_ERROR "Incorrect value for '${prop_path_joined}'. ${VJN_PROP_VALUE} is below the exclusive minimum of ${VJN_EXCLU_MIN}!")
    endif()
  endif()

  # Check range "max" constraint
  if(DEFINED VJN_MAX)
    if(NOT ${VJN_MAX} MATCHES "${is_number_regex}")
      message(FATAL_ERROR "MAX argument is not a number!")
    endif()
    if(NOT ${VJN_PROP_VALUE} LESS_EQUAL ${VJN_MAX})
      message(FATAL_ERROR "Incorrect value for '${prop_path_joined}'. ${VJN_PROP_VALUE} is above the maximum of ${VJN_MAX}!")
    endif()
  endif()

  # Check range "max exclusive" constraint
  if(DEFINED VJN_EXCLU_MAX)
    if(NOT ${VJN_EXCLU_MAX} MATCHES "${is_number_regex}")
      message(FATAL_ERROR "EXCLU_MAX argument is not a number!")
    endif()
    if(NOT ${VJN_PROP_VALUE} LESS ${VJN_EXCLU_MAX})
      message(FATAL_ERROR "Incorrect value for '${prop_path_joined}'. ${VJN_PROP_VALUE} is above the exclusive maximum of ${VJN_EXCLU_MAX}!")
    endif()
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_is_loaded)
  if(NOT DEFINED CTF_IS_LOADED)
    message(FATAL_ERROR "IS_LOADED argument is missing or need a value!")
  endif()

  get_property(is_file_loaded GLOBAL PROPERTY "TARGETS_CONFIG_LOADED")
  if(NOT "${is_file_loaded}" STREQUAL "on")
    set(${CTF_IS_LOADED} off PARENT_SCOPE)
  else()
    set(${CTF_IS_LOADED} on PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_get_loaded_file)
  if(NOT DEFINED CTF_GET_LOADED_FILE)
    message(FATAL_ERROR "GET_LOADED_FILE argument is missing or need a value!")
  endif()
  _assert_config_file_loaded()

  get_property(is_set GLOBAL PROPERTY "TARGETS_CONFIG_RAW_JSON" SET)
  if(NOT ${is_set})
    message(FATAL_ERROR "No JSON configuration file loaded!")
  endif()

  get_property(loaded_file_content GLOBAL PROPERTY "TARGETS_CONFIG_RAW_JSON")
  set(${CTF_GET_LOADED_FILE} "${loaded_file_content}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_has_config)
  if(NOT DEFINED CTF_HAS_CONFIG)
    message(FATAL_ERROR "HAS_CONFIG argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_TARGET)
    message(FATAL_ERROR "TARGET argument is missing or need a value!")
  endif()
  _assert_config_file_loaded()

  get_property(does_config_exist GLOBAL PROPERTY "TARGETS_CONFIG_${CTF_TARGET}" SET)
  if(${does_config_exist})
    set(${CTF_HAS_CONFIG} on PARENT_SCOPE)
  else()
    set(${CTF_HAS_CONFIG} off PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_get_value)
  if(NOT DEFINED CTF_GET_VALUE)
    message(FATAL_ERROR "GET_VALUE argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_TARGET)
    message(FATAL_ERROR "TARGET argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_KEY)
    message(FATAL_ERROR "KEY argument is missing or need a value!")
  endif()
  _assert_config_file_loaded()
  _assert_target_config_exists("${CTF_TARGET}")
  
  get_property(target_config_map GLOBAL PROPERTY "TARGETS_CONFIG_${CTF_TARGET}")

  # Check if the key exists
  map(HAS_KEY target_config_map "${CTF_KEY}" has_setting_key)
  if(NOT ${has_setting_key})
    message(FATAL_ERROR "Target ${CTF_TARGET} has no setting key '${CTF_KEY}'!")
  endif()

  # Get the value
  map(GET target_config_map "${CTF_KEY}" setting_value)
  
  # Deserialize the value if needed
  _is_serialized_list(is_serialized "${setting_value}")
  if(${is_serialized})
    _deserialize_list(setting_value "${setting_value}")
  endif()
  set(${CTF_GET_VALUE} "${setting_value}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_try_get_value)
  if(NOT DEFINED CTF_TRY_GET_VALUE)
    message(FATAL_ERROR "TRY_GET_VALUE argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_TARGET)
    message(FATAL_ERROR "TARGET argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_KEY)
    message(FATAL_ERROR "KEY argument is missing or need a value!")
  endif()
  _assert_config_file_loaded()
  _assert_target_config_exists("${CTF_TARGET}")
  
  get_property(target_config_map GLOBAL PROPERTY "TARGETS_CONFIG_${CTF_TARGET}")

  map(FIND target_config_map "${CTF_KEY}" setting_value)
  if(NOT "${setting_value}" MATCHES "-NOTFOUND$")
    # Deserialize the value if needed
    _is_serialized_list(is_serialized "${setting_value}")
    if(${is_serialized})
      _deserialize_list(setting_value "${setting_value}")
    endif()
  endif()

  set(${CTF_TRY_GET_VALUE} "${setting_value}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_get_settings)
  if(NOT DEFINED CTF_GET_SETTINGS)
    message(FATAL_ERROR "GET_SETTINGS argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_TARGET)
    message(FATAL_ERROR "TARGET argument is missing or need a value!")
  endif()
  _assert_config_file_loaded()
  _assert_target_config_exists("${CTF_TARGET}")

  get_property(target_config_map GLOBAL PROPERTY "TARGETS_CONFIG_${CTF_TARGET}")
  set(${CTF_GET_SETTINGS} "${target_config_map}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_has_setting)
  if(NOT DEFINED CTF_HAS_SETTING)
    message(FATAL_ERROR "HAS_SETTING argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_TARGET)
    message(FATAL_ERROR "TARGET argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_KEY)
    message(FATAL_ERROR "KEY argument is missing or need a value!")
  endif()
  _assert_config_file_loaded()
  _assert_target_config_exists("${CTF_TARGET}")
  
  get_property(target_config_map GLOBAL PROPERTY "TARGETS_CONFIG_${CTF_TARGET}")
  map(HAS_KEY target_config_map "${CTF_KEY}" has_setting_key)
  if(${has_setting_key})
    set(${CTF_HAS_SETTING} on PARENT_SCOPE)
  else()
    set(${CTF_HAS_SETTING} off PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_get_keys)
  if(NOT DEFINED CTF_GET_KEYS)
    message(FATAL_ERROR "GET_KEYS argument is missing or need a value!")
  endif()
  if(NOT DEFINED CTF_TARGET)
    message(FATAL_ERROR "TARGET argument is missing or need a value!")
  endif()
  _assert_config_file_loaded()
  _assert_target_config_exists("${CTF_TARGET}")

  get_property(target_config_map GLOBAL PROPERTY "TARGETS_CONFIG_${CTF_TARGET}")
  map(KEYS target_config_map setting_keys)
  set(${CTF_GET_KEYS} "${setting_keys}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_print_configs)
  if(NOT ${CTF_PRINT_CONFIGS})
    message(FATAL_ERROR "PRINT_CONFIGS arguments is missing!")
  endif()
  _assert_config_file_loaded()

  get_property(target_paths GLOBAL PROPERTY "TARGETS_CONFIG_LIST")
  foreach(target_path IN ITEMS ${target_paths})
    set(CTF_PRINT_TARGET_CONFIG "${target_path}")
    _cmake_targets_file_print_target_config()
  endforeach()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_cmake_targets_file_print_target_config)
  if(NOT DEFINED CTF_PRINT_TARGET_CONFIG)
    message(FATAL_ERROR "PRINT_TARGET_CONFIG argument is missing or need a value!")
  endif()
  _assert_config_file_loaded()
  _assert_target_config_exists("${CTF_PRINT_TARGET_CONFIG}")

  get_property(target_config_map GLOBAL PROPERTY "TARGETS_CONFIG_${CTF_PRINT_TARGET_CONFIG}")
  map(GET target_config_map "name" target_name)
  message(STATUS "Target: ${target_name}")

  # Print all top-level properties
  foreach(setting_key "type" "build.compileFeatures" "build.compileDefinitions" "build.compileOptions" "build.linkOptions" "mainFile" "pchFile" "headerPolicy.mode" "headerPolicy.includeDir")
    map(HAS_KEY target_config_map "${setting_key}" has_setting_key)
    if(${has_setting_key})
      map(GET target_config_map "${setting_key}" setting_value)
      message(STATUS "  ${setting_key}: ${setting_value}")
    endif()
  endforeach()

  # Print nested 'dependencies' object properties
  message(STATUS "  Dependencies:")
  map(GET target_config_map "dependencies" dep_names)
  _deserialize_list(dep_names "${dep_names}")
  foreach(dep_name IN ITEMS ${dep_names})
    message(STATUS "    ${dep_name}:")
    foreach(dep_prop_key "rulesFile" "packageLocation.windows" "packageLocation.unix" "packageLocation.macos" "minVersion" "fetchInfo.autodownload" "fetchInfo.kind" "fetchInfo.repository" "fetchInfo.tag" "fetchInfo.hash" "fetchInfo.revision" "optional" "configuration.compileFeatures" "configuration.compileDefinitions" "configuration.compileOptions" "configuration.linkOptions")
      map(HAS_KEY target_config_map "dependencies.${dep_name}.${dep_prop_key}" has_setting_key)
      if(${has_setting_key})
        map(GET target_config_map "dependencies.${dep_name}.${dep_prop_key}" dep_prop_value)
        message(STATUS "      ${dep_prop_key}: ${dep_prop_value}")
      endif()
    endforeach()
  endforeach()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
function(_assert_config_file_loaded)
  if(NOT ${ARGC} EQUAL 0)
    message(FATAL_ERROR "_assert_config_file_loaded() requires exactly 0 arguments, got ${ARGC}!")
  endif()
  get_property(is_file_loaded GLOBAL PROPERTY "TARGETS_CONFIG_LOADED")
  if(NOT "${is_file_loaded}" STREQUAL "on")
    message(FATAL_ERROR "Targets configuration not loaded. Call cmake_targets_file(LOAD) first!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
function(_assert_target_config_exists target_dir_path)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "_assert_target_config_exists() requires exactly 1 arguments, got ${ARGC}!")
  endif()
  if("${target_dir_path}" STREQUAL "")
    message(FATAL_ERROR "target_dir_path argument is empty!")
  endif()

  get_property(does_config_exist GLOBAL PROPERTY "TARGETS_CONFIG_${target_dir_path}" SET)
  if(NOT ${does_config_exist})
    message(FATAL_ERROR "No configuration found with the target path ${target_dir_path}!")
  endif()
endfunction()
