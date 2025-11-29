# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Finds and links an external dependency ``<dep-name>`` to the specified target
# ``<target-name>`` using the CMake rules file defined in the configuration
# associated with ``<config-target-dir-path>`` in ``CMakeTargets.json``.
#
# The function first maps dependency settings to CMake variables for use by
# the rules file, then invokes the rules file specified in the JSON
# configuration.
#
# Any variable corresponding to a setting not declared in the JSON is set to
# "NOT DEFINED". An error is raised if a required setting is missing from the
# JSON.
#
# Signature:
#   import_external_dependency(<target-name>
#                              <config-target-dir-path>
#                              <config-dep-name>)
#
# Parameters:
#   target-name             : The target to link the dependency to.
#   config-target-dir-path  : The directory path of the target's configuration.
#   dep-name                : The name of the external dependency to import and
#                             link.
#
# Returns:
#   <dep-name>_FOUND: A boolean value set to 1 if the dependency is found,
#                     or 0 otherwise.
#
# Errors:
#   If the specified target does not exist.
#   If a required setting is missing from the JSON configuration.
#
# Example:
#   import_external_dependency("fruit-salad" "src" "AppleLib")
#------------------------------------------------------------------------------
function(import_external_dependency target_name config_target_dir_path config_dep_name)
  if(NOT ${ARGC} EQUAL 3)
    message(FATAL_ERROR "import_external_dependency() requires exactly 3 arguments, got ${ARGC}!")
  endif()
  if("${target_name}" STREQUAL "")
    message(FATAL_ERROR "target_name argument is missing!")
  endif()
  if(NOT TARGET "${target_name}")
    message(FATAL_ERROR "The target \"${target_name}\" does not exist!")
  endif()
  if("${config_target_dir_path}" STREQUAL "")
    message(FATAL_ERROR "config_target_dir_path argument is missing!")
  endif()
  if("${config_dep_name}" STREQUAL "")
    message(FATAL_ERROR "config_dep_name argument is missing!")
  endif()

  # Set predefined variables for the CMake rules file
  set(CURRENT_TARGET_NAME "${target_name}")
  set(DEP_NAME "${config_dep_name}")
  _map_dep_settings_to_vars("${config_target_dir_path}" "${config_dep_name}")
  
  # Call the CMake rules file
  if("${${config_dep_name}_RULES_FILE}" STREQUAL "generic")
    set(rules_file_name "RulesGeneric.cmake")
    set(rules_file_path "${${PROJECT_NAME}_CMAKE_RULES_DIR}/${rules_file_name}")
  else()
    set(rules_file_name "${${config_dep_name}_RULES_FILE}")
    set(rules_file_path "${${PROJECT_NAME}_PROJECT_DIR}/${rules_file_name}")
  endif()
  include("${rules_file_path}")
  validate_dep_import_status(is_valid err_msg on
    "${config_dep_name}_FOUND" "${rules_file_name}")

  return(PROPAGATE "${config_dep_name}_FOUND")
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
# Maps the settings of the dependency ``<dep-name>`` defined for the target
# located at ``<config-target-dir-path>`` to CMake variables. These variables
# follow the naming pattern ``<dep-name>_<SETTING_NAME>``.
#
# Signature:
#   _map_dep_settings_to_vars(<config-target-dir-path> <config-dep-name>)
#
# Parameters:
#   config-target-dir-path  : The path to the target directory in the
#                             configuration file.
#   config-dep-name         : The name of the dependency in the configuration
#                             file.
#
# Returns:
#   <dep-name>_RULES_FILE
#   <dep-name>_PACKAGE_LOC_WIN
#   <dep-name>_PACKAGE_LOC_UNIX
#   <dep-name>_PACKAGE_LOC_MAC
#   <dep-name>_MIN_VERSION
#   <dep-name>_FETCH_AUTODOWNLOAD
#   <dep-name>_FETCH_KIND
#   <dep-name>_FETCH_KIND_IS_URL
#   <dep-name>_FETCH_KIND_IS_GIT
#   <dep-name>_FETCH_KIND_IS_SVN
#   <dep-name>_FETCH_KIND_IS_MERCURIAL
#   <dep-name>_FETCH_REPOSITORY
#   <dep-name>_FETCH_TAG
#   <dep-name>_FETCH_REVISION
#   <dep-name>_FETCH_HASH
#   <dep-name>_OPTIONAL
#   <dep-name>_CONFIG_COMPILE_FEATURES
#   <dep-name>_CONFIG_COMPILE_DEFINITIONS
#   <dep-name>_CONFIG_COMPILE_OPTIONS
#   <dep-name>_CONFIG_LINK_OPTIONS
#
# Erros:
#   If no configuration matching the target directory path is found in
#   ``CMakeTargets.json``.
#
# Example:
#   _map_dep_settings_to_vars("src" "AppleLib")
#------------------------------------------------------------------------------
function(_map_dep_settings_to_vars config_target_dir_path config_dep_name)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "_map_dep_settings_to_vars() requires exactly 2 arguments, got ${ARGC}!")
  endif()
  if("${config_target_dir_path}" STREQUAL "")
    message(FATAL_ERROR "config_target_dir_path argument is missing!")
  endif()
  if("${config_dep_name}" STREQUAL "")
    message(FATAL_ERROR "config_dep_name argument is missing!")
  endif()
  cmake_targets_file(HAS_CONFIG is_config_exists TARGET "${config_target_dir_path}")
  if(NOT ${is_config_exists})
    message(FATAL_ERROR "Cannot map dependency settings of '${config_dep_name}' to vars: no config found in CMakeTargets.json with the target directory path '${config_target_dir_path}'!")
  endif()

  # Set <dep-name>_RULES_FILE
  cmake_targets_file(GET_VALUE ${config_dep_name}_RULES_FILE
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.rulesFile"
  )
  if(NOT "${${config_dep_name}_RULES_FILE}" STREQUAL "generic")
    validate_dep_rules_file_path(is_valid err_msg on
      "${${PROJECT_NAME}_PROJECT_DIR}"
      "${${config_dep_name}_RULES_FILE}"
    )
  endif()

  # Set <dep-name>_PACKAGE_LOC_WIN
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_PACKAGE_LOC_WIN
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.packageLocation.windows"
  )
  _unset_var_if_not_found(${config_dep_name}_PACKAGE_LOC_WIN)

  # Set <dep-name>_PACKAGE_LOC_UNIX
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_PACKAGE_LOC_UNIX
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.packageLocation.unix"
  )
  _unset_var_if_not_found(${config_dep_name}_PACKAGE_LOC_UNIX)

  # Set <dep-name>_PACKAGE_LOC_MAC
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_PACKAGE_LOC_MAC
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.packageLocation.macos"
  )
  _unset_var_if_not_found(${config_dep_name}_PACKAGE_LOC_MAC)

  # Set <dep-name>_MIN_VERSION
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_MIN_VERSION
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.minVersion"
  )
  _unset_var_if_not_found(${config_dep_name}_MIN_VERSION)

  # Set <dep-name>_FETCH_AUTODOWNLOAD
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_FETCH_AUTODOWNLOAD
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.fetchInfo.autodownload"
  )
  _unset_var_if_not_found(${config_dep_name}_FETCH_AUTODOWNLOAD)

  # Set <dep-name>_FETCH_KIND
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_FETCH_KIND
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.fetchInfo.kind"
  )
  _unset_var_if_not_found(${config_dep_name}_FETCH_KIND)

  # Set
  #   <dep-name>_FETCH_KIND_IS_URL
  #   <dep-name>_FETCH_KIND_IS_GIT
  #   <dep-name>_FETCH_KIND_IS_SVN
  #   <dep-name>_FETCH_KIND_IS_MERCURIAL
  if(DEFINED ${config_dep_name}_FETCH_KIND)
    set(${config_dep_name}_FETCH_KIND_IS_URL off)
    set(${config_dep_name}_FETCH_KIND_IS_GIT off)
    set(${config_dep_name}_FETCH_KIND_IS_SVN off)
    set(${config_dep_name}_FETCH_KIND_IS_MERCURIAL off)
    if("${${config_dep_name}_FETCH_KIND}" STREQUAL "url")
      set(${config_dep_name}_FETCH_KIND_IS_URL on)
    elseif("${${config_dep_name}_FETCH_KIND}" STREQUAL "git")
      set(${config_dep_name}_FETCH_KIND_IS_GIT on)
    elseif("${${config_dep_name}_FETCH_KIND}" STREQUAL "svn")
      set(${config_dep_name}_FETCH_KIND_IS_SVN on)
    elseif("${${config_dep_name}_FETCH_KIND}" STREQUAL "mercurial")
      set(${config_dep_name}_FETCH_KIND_IS_MERCURIAL on)
    endif()
  endif()

  # Set <dep-name>_FETCH_REPOSITORY
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_FETCH_REPOSITORY
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.fetchInfo.repository"
  )
  _unset_var_if_not_found(${config_dep_name}_FETCH_REPOSITORY)

  # Set <dep-name>_FETCH_TAG
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_FETCH_TAG
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.fetchInfo.tag"
  )
  _unset_var_if_not_found(${config_dep_name}_FETCH_TAG)

  # Set <dep-name>_FETCH_REVISION
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_FETCH_REVISION
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.fetchInfo.revision"
  )
  _unset_var_if_not_found(${config_dep_name}_FETCH_REVISION)

  # Set <dep-name>_FETCH_HASH
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_FETCH_HASH
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.fetchInfo.hash"
  )
  _unset_var_if_not_found(${config_dep_name}_FETCH_HASH)

  # Set <dep-name>_OPTIONAL
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_OPTIONAL
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.optional"
  )
  _unset_var_if_not_found(${config_dep_name}_OPTIONAL)

  # Set <dep-name>_CONFIG_COMPILE_FEATURES
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_CONFIG_COMPILE_FEATURES
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.configuration.compileFeatures"
  )
  _unset_var_if_not_found(${config_dep_name}_CONFIG_COMPILE_FEATURES)

  # Set <dep-name>_CONFIG_COMPILE_DEFINITIONS
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_CONFIG_COMPILE_DEFINITIONS
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.configuration.compileDefinitions"
  )
  _unset_var_if_not_found(${config_dep_name}_CONFIG_COMPILE_DEFINITIONS)

  # Set <dep-name>_CONFIG_COMPILE_OPTIONS
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_CONFIG_COMPILE_OPTIONS
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.configuration.compileOptions"
  )
  _unset_var_if_not_found(${config_dep_name}_CONFIG_COMPILE_OPTIONS)

  # Set <dep-name>_CONFIG_LINK_OPTIONS
  cmake_targets_file(TRY_GET_VALUE ${config_dep_name}_CONFIG_LINK_OPTIONS
    TARGET "${config_target_dir_path}"
    KEY "dependencies.${config_dep_name}.configuration.linkOptions"
  )
  _unset_var_if_not_found(${config_dep_name}_CONFIG_LINK_OPTIONS)

  return(PROPAGATE
    "${config_dep_name}_RULES_FILE"
    "${config_dep_name}_PACKAGE_LOC_WIN"
    "${config_dep_name}_PACKAGE_LOC_UNIX"
    "${config_dep_name}_PACKAGE_LOC_MAC"
    "${config_dep_name}_MIN_VERSION"
    "${config_dep_name}_FETCH_AUTODOWNLOAD"
    "${config_dep_name}_FETCH_KIND"
    "${config_dep_name}_FETCH_KIND_IS_URL"
    "${config_dep_name}_FETCH_KIND_IS_GIT"
    "${config_dep_name}_FETCH_KIND_IS_SVN"
    "${config_dep_name}_FETCH_KIND_IS_MERCURIAL"
    "${config_dep_name}_FETCH_REPOSITORY"
    "${config_dep_name}_FETCH_TAG"
    "${config_dep_name}_FETCH_REVISION"
    "${config_dep_name}_FETCH_HASH"
    "${config_dep_name}_OPTIONAL"
    "${config_dep_name}_CONFIG_COMPILE_FEATURES"
    "${config_dep_name}_CONFIG_COMPILE_DEFINITIONS"
    "${config_dep_name}_CONFIG_COMPILE_OPTIONS"
    "${config_dep_name}_CONFIG_LINK_OPTIONS"
  )
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
# Unsets the specified variable if its value ends with the suffix "-NOTFOUND".
#
# Signature:
#   _unset_var_if_not_found(<var-name>)
#
# Parameters:
#   var_name: The name of the variable to check and unset if necessary.
#
# Returns:
#   None
#
# Example:
#   _unset_var_if_not_found(TARGET_NAME)
#------------------------------------------------------------------------------
function(_unset_var_if_not_found var_name)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "_unset_var_if_not_found() requires exactly 1 arguments, got ${ARGC}!")
  endif()
  if("${${var_name}}" MATCHES "-NOTFOUND$")
    unset("${var_name}" PARENT_SCOPE)
  endif()
endfunction()
