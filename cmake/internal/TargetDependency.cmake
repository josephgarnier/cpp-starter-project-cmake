# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Import and link an internal dependency to the requesting target
function(import_internal_dependency)

endfunction()

#------------------------------------------------------------------------------
# Find and link a dependency ``<dep-name>`` located outside the project to the
# target ``<target-name>`` in using the CMake rules file defined in the
# configuration associated to ``<config-target-dir-path>`` in
# ``CMakeTargets.json``.
#
# The function firstly maps dependency settings to CMake variables for
# CMake rules files then calls the rules file defined in the JSON.
#
# A variable associated with a setting not declared in the JSON is set to "NOT
# DEFINED". An error is raised if a required setting is not declared in the
# JSON.
#
# Signature:
#   import_external_dependency(<target-name>
#                               <config-target-dir-path>
#                               <config-dep-name>)
#
# Parameters:
#   target-name: The target name to link.
#   config-target-dir-path: The target directory path.
#   dep-name: The dependency name to import and link.
#
# Returns:
#   <dep-name>_FOUND: A boolean value with 1 if the dependency is found;
#                     0 otherwise.
#
# Errors:
#   If the target does not exist.
#   If a required setting is not declared in the JSON.
#
# Exemple:
#   import_external_dependency("fruit-salad" "src" "AppleLib")
#------------------------------------------------------------------------------
function(import_external_dependency target_name config_target_dir_path config_dep_name)
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

  # Set CURRENT_TARGET_NAME
  set(CURRENT_TARGET_NAME "${target_name}")
  
  # Set DEP_NAME
  set(DEP_NAME "${config_dep_name}")

  # Map dependency settings to CMake variables ``<dep-name>_...``
  _map_dep_settings_to_vars("${config_target_dir_path}" "${config_dep_name}")
  
  # Call the CMake rules file
  if("${${config_dep_name}_RULES_FILE}" STREQUAL "generic")
    include("${${PROJECT_NAME}_CMAKE_RULES_DIR}/RulesGeneric.cmake")
    validate_dep_import_status(is_valid err_msg on
      "${config_dep_name}_FOUND" "RulesGeneric.cmake"
    )
  else()
    include("${${PROJECT_NAME}_PROJECT_DIR}/${${config_dep_name}_RULES_FILE}")
    validate_dep_import_status(is_valid err_msg on
      "${config_dep_name}_FOUND" "${${config_dep_name}_RULES_FILE}"
    )
  endif()

  return(PROPAGATE "${config_dep_name}_FOUND")
endfunction()

#------------------------------------------------------------------------------
# [Internal usage]
# Map settings of dependency ``<dep-name>`` defined in target
# ``<config-target-dir-path>`` to CMake variables. Theses variables are in the
# format ``<dep-name>_<SETTING_NAME>``.
#
# Signature:
#   _map_dep_settings_to_vars(<config-target-dir-path> <config-dep-name>)
#
# Parameters:
#   config-target-dir-path: The target directory path in configuration file.
#   config-dep-name: The dependency name in configuration file.
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
#   If no config found in CMakeTargets.json with the target directory path.
#
# Exemple:
#   _map_dep_settings_to_vars("src" "AppleLib")
#------------------------------------------------------------------------------
function(_map_dep_settings_to_vars config_target_dir_path config_dep_name)
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
      "${${PROJECT_NAME}_CMAKE_RULES_DIR}"
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
# [Internal usage]
# Unset a variable if its value ends with "-NOTFOUND".
#
# Signature:
#   _unset_var_if_not_found(<var-name>)
#
# Parameters:
#   var_name: The name of the variable to unset.
#
# Returns:
#   None
#
# Exemple:
#   _unset_var_if_not_found(TARGET_NAME)
#------------------------------------------------------------------------------
function(_unset_var_if_not_found var_name)
  if("${${var_name}}" MATCHES "-NOTFOUND$")
    unset("${var_name}" PARENT_SCOPE)
  endif()
endfunction()
