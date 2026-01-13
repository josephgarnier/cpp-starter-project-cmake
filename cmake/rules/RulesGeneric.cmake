# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.


# =============================================================================
# Script: RulesGeneric.cmake
#
# Description:
#   Generic rules file to find and link the dependency ``<DEP_NAME>`` to the target
#   ``<CURRENT_TARGET_NAME>``, configured with the setting ``rulesFile: generic``.
#   The final status must be set in ``<DEP_NAME>_FOUND`` (1: found, 0: not found).
#
#   The list of target configuration settings is available through the variables
#   listed under "Predefined variables". Variables corresponding to settings not
#   declared in the configuration JSON file are "NOT DEFINED".
#
# Environment read:
#   ENV{<DEP_NAME>}_DIR: The environment variable ``<PackageName>_DIR`` specifying
#                        the dependency directory.
#
# Globals read:
#   CMAKE_SYSTEM_NAME: The name of the operating system.
#
# Globals written:
#   CMAKE_PREFIX_PATH: List of directories specifying installation prefixes
#                      to be searched by the find_package().
#
# Predefined variables:
#   CURRENT_TARGET_NAME
#   DEP_NAME
#   <DEP_NAME>_RULES_FILE
#   <DEP_NAME>_PACKAGE_LOC_WIN
#   <DEP_NAME>_PACKAGE_LOC_UNIX
#   <DEP_NAME>_PACKAGE_LOC_MAC
#   <DEP_NAME>_MIN_VERSION
#   <DEP_NAME>_INTEGRATION_METHOD
#   <DEP_NAME>_DL_INFO_KIND
#   <DEP_NAME>_DL_INFO_KIND_IS_URL
#   <DEP_NAME>_DL_INFO_KIND_IS_GIT
#   <DEP_NAME>_DL_INFO_KIND_IS_SVN
#   <DEP_NAME>_DL_INFO_KIND_IS_MERCURIAL
#   <DEP_NAME>_DL_INFO_REPOSITORY
#   <DEP_NAME>_DL_INFO_TAG
#   <DEP_NAME>_DL_INFO_REVISION
#   <DEP_NAME>_DL_INFO_HASH
#   <DEP_NAME>_OPTIONAL
#   <DEP_NAME>_BUILD_COMPILE_FEATURES
#   <DEP_NAME>_BUILD_COMPILE_DEFINITIONS
#   <DEP_NAME>_BUILD_COMPILE_OPTIONS
#   <DEP_NAME>_BUILD_LINK_OPTIONS
#
# Outputs:
#   Link the dependency ``<DEP_NAME>`` to the target ``<CURRENT_TARGET_NAME>``.
#
# Returns:
#   <DEP_NAME>_FOUND: Set to "1" if the dependency was found, "0" otherwise. This
#                     variable may be initialized by ``find_package()``.
#
# Usage:
#   include(RulesGeneric)
# =============================================================================

###############################################################################
### Internal macros and functions
###############################################################################

#------------------------------------------------------------------------------
# [Internal use only]
# Set CMAKE_PREFIX_PATH with 'packageLocation' setting values for adding custom
# directories to ``find_package()`` command.
#
# Signature:
#   add_search_path()
#
# Parameters:
#   None
#
# Globals read:
#   <DEP_NAME>_PACKAGE_LOC_WIN
#   <DEP_NAME>_PACKAGE_LOC_UNIX
#   <DEP_NAME>_PACKAGE_LOC_MAC
#
# Globals written:
#   <DEP_NAME>_DIR
#   CMAKE_PREFIX_PATH
#
# Returns:
#   None
#
# Example:
#   add_search_path()
#------------------------------------------------------------------------------
macro(add_search_path)
  # Set local dependency directory
  if(DEFINED ENV{${DEP_NAME}_DIR}) 
    set(${DEP_NAME}_DIR "$ENV{${DEP_NAME}_DIR}")
  elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows"
      AND DEFINED ${DEP_NAME}_PACKAGE_LOC_WIN)
    set(${DEP_NAME}_DIR "${${DEP_NAME}_PACKAGE_LOC_WIN}")
  elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux"
      AND DEFINED ${DEP_NAME}_PACKAGE_LOC_UNIX)
    set(${DEP_NAME}_DIR "${${DEP_NAME}_PACKAGE_LOC_UNIX}")
  elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin"
      AND DEFINED ${DEP_NAME}_PACKAGE_LOC_MAC)
    set(${DEP_NAME}_DIR "${${DEP_NAME}_PACKAGE_LOC_MAC}")
  endif()

  # Set search paths for find_package() command
  if(DEFINED ENV{CMAKE_PREFIX_PATH}) 
    set(CMAKE_PREFIX_PATH "$ENV{CMAKE_PREFIX_PATH}")
  else()
    set(CMAKE_PREFIX_PATH "${${DEP_NAME}_DIR}")
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
# Append to ``command-args-var`` a list of arguments for the commands
# ``fetch_content()`` and ``ExternalProject_Add()`` to defined how download the
# files.
#
# Signature:
#   append_download_options(<command-args-var>)
#
# Parameters:
#   command-args-var: The list of command args to complete.
#
# Globals read:
#   <DEP_NAME>_DL_INFO_KIND
#   <DEP_NAME>_DL_INFO_KIND_IS_URL
#   <DEP_NAME>_DL_INFO_KIND_IS_GIT
#   <DEP_NAME>_DL_INFO_KIND_IS_SVN
#   <DEP_NAME>_DL_INFO_KIND_IS_MERCURIAL
#   <DEP_NAME>_DL_INFO_REPOSITORY
#   <DEP_NAME>_DL_INFO_TAG
#   <DEP_NAME>_DL_INFO_REVISION
#   <DEP_NAME>_DL_INFO_HASH
#
# Returns:
#   command-args-var: The list of command args filled.
#
# Example:
#   append_download_options(fetch_content_args)
#------------------------------------------------------------------------------
function(append_download_options command_args_var)
  if(${${DEP_NAME}_DL_INFO_KIND_IS_URL})
    list(APPEND ${command_args_var}
      URL                  "${${DEP_NAME}_DL_INFO_REPOSITORY}"
      URL_HASH             "${${DEP_NAME}_DL_INFO_HASH}"
      DOWNLOAD_NO_PROGRESS "OFF"
    )
  elseif(${${DEP_NAME}_DL_INFO_KIND_IS_GIT})
    list(APPEND ${command_args_var}
      GIT_REPOSITORY "${${DEP_NAME}_DL_INFO_REPOSITORY}"
      GIT_TAG        "${${DEP_NAME}_DL_INFO_TAG}"
      GIT_SHALLOW    "ON"
      GIT_PROGRESS   "ON"
    )
  elseif(${${DEP_NAME}_DL_INFO_KIND_IS_SVN})
    list(APPEND ${command_args_var}
      SVN_REPOSITORY "${${DEP_NAME}_DL_INFO_REPOSITORY}"
      SVN_REVISION   "${${DEP_NAME}_DL_INFO_REVISION}"
    )
  elseif(${${DEP_NAME}_DL_INFO_KIND_IS_MERCURIAL})
    list(APPEND ${command_args_var}
      HG_REPOSITORY  "${${DEP_NAME}_DL_INFO_REPOSITORY}"
      HG_TAG         "${${DEP_NAME}_DL_INFO_TAG}"
    )
  else()
    message(FATAL_ERROR "Unknown fetch method: ${${DEP_NAME}_DL_INFO_KIND}!")
  endif()
  return(PROPAGATE "${command_args_var}")
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
# Append to ``command-args-var`` a list of arguments for the commands
# ``fetch_content()`` and ``ExternalProject_Add()`` to control logging.
#
# Signature:
#   append_logging_options(<command-args-var>)
#
# Parameters:
#   command-args-var: The list of command args to complete.
#
# Returns:
#   command-args-var: The list of command args filled.
#
# Example:
#   append_logging_options(fetch_content_args)
#------------------------------------------------------------------------------
function(append_logging_options command_args_var)
  list(APPEND ${command_args_var}
    LOG_DOWNLOAD ON
    LOG_UPDATE ON
    LOG_PATCH ON
    LOG_CONFIGURE ON
    LOG_BUILD ON
    LOG_INSTALL ON
    LOG_TEST ON
    LOG_MERGED_STDOUTERR ON
    LOG_OUTPUT_ON_FAILURE ON
  )
  return(PROPAGATE "${command_args_var}")
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
# Append to ``command-args-var`` a list of arguments for the commands
# ``fetch_content()`` and ``ExternalProject_Add()`` to define
# ``FIND_PACKAGE_ARGS``.
#
# Signature:
#   append_find_package_options(<command-args-var>)
#
# Globals read:
#   DEP_NAME
#   <DEP_NAME>_MIN_VERSION
#
# Parameters:
#   command-args-var: The list of command args to complete.
#
# Returns:
#   command-args-var: The list of command args filled.
#
# Example:
#   append_find_package_options(fetch_content_args)
#------------------------------------------------------------------------------
function(append_find_package_options command_args_var)
  list(APPEND ${command_args_var}
    FIND_PACKAGE_ARGS "${${DEP_NAME}_MIN_VERSION}" NO_MODULE NAMES "${DEP_NAME}"
  )
  return(PROPAGATE "${command_args_var}")
endfunction()
###############################################################################


###############################################################################
### Main logic
###############################################################################
# Set search paths for find_package() command
if(("${${DEP_NAME}_INTEGRATION_METHOD}" STREQUAL "FIND_PACKAGE")
    OR ("${${DEP_NAME}_INTEGRATION_METHOD}" STREQUAL "FIND_AND_FETCH"))
  add_search_path()
endif()

# Integration with 'FIND_PACKAGE' method
if("${${DEP_NAME}_INTEGRATION_METHOD}" STREQUAL "FIND_PACKAGE")
  # Searches for prebuilt dependency in local and common directories
  find_package("${DEP_NAME}" "${${DEP_NAME}_MIN_VERSION}" NO_MODULE QUIET)
  if(${${DEP_NAME}_FOUND})
    message(STATUS
      "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} found locally: ${${DEP_NAME}_CONFIG}"
    )
  else()
    message(STATUS "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} not found locally")
  endif()

# Integration with 'FETCH_CONTENT' or 'FIND_AND_FETCH' method
elseif(("${${DEP_NAME}_INTEGRATION_METHOD}" STREQUAL "FETCH_CONTENT")
    OR ("${${DEP_NAME}_INTEGRATION_METHOD}" STREQUAL "FIND_AND_FETCH"))
  # Download the dependency sources and bring them into scope
  include(FetchContent)
  set(fetch_content_args "")
  append_download_options(fetch_content_args)
  append_logging_options(fetch_content_args)
  set(find_package_args "")
  # Specific arguments for 'FIND_AND_FETCH' method
  if("${${DEP_NAME}_INTEGRATION_METHOD}" STREQUAL "FIND_AND_FETCH")
    append_find_package_options(find_package_args)
  endif()
  FetchContent_Declare(
    "${DEP_NAME}"
    ${fetch_content_args}
    USES_TERMINAL_DOWNLOAD ON
    EXCLUDE_FROM_ALL
    SYSTEM
    ${find_package_args}
  )
  FetchContent_MakeAvailable("${DEP_NAME}")
  string(TOLOWER "${DEP_NAME}" DEP_NAME_LOWER)
  if(${${DEP_NAME}_FOUND})
    set(${DEP_NAME}_FOUND 1)
    message(STATUS
      "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} found locally: ${${DEP_NAME}_CONFIG}"
    )
  elseif(${${DEP_NAME_LOWER}_POPULATED})
    set(${DEP_NAME}_FOUND 1)
    set(${DEP_NAME}_SOURCE_DIR "${${DEP_NAME_LOWER}_SOURCE_DIR}")
    set(${DEP_NAME}_BINARY_DIR "${${DEP_NAME_LOWER}_BINARY_DIR}")
    message(STATUS
      "${DEP_NAME} downloaded with success in ${${DEP_NAME_LOWER}_SOURCE_DIR}"
    )
  else()
    set(${DEP_NAME}_FOUND 0)
    message(STATUS "${DEP_NAME} downloading failed")
  endif()

# Integration with 'EXTERNAL_PROJECT' method
elseif("${${DEP_NAME}_INTEGRATION_METHOD}" STREQUAL "EXTERNAL_PROJECT")
  message(FATAL_ERROR "EXTERNAL_PROJECT integration method not supported yet!")
  # include(ExternalProject)
  # set(external_project_args "")
  # append_download_options(external_project_args)
  # append_logging_options(external_project_args)
  # ExternalProject_Add(
  #   "${DEP_NAME}"
  #   ${external_project_args}
  #   USES_TERMINAL_DOWNLOAD ON
  #   EXCLUDE_FROM_ALL
  # )
  # ExternalProject_Get_Property("${DEP_NAME}" SOURCE_DIR BINARY_DIR INSTALL_DIR)
  # set(${DEP_NAME}_SOURCE_DIR "${SOURCE_DIR}")
  # set(${DEP_NAME}_BINARY_DIR "${BINARY_DIR}")
  # set(${DEP_NAME}_INSTALL_DIR "${INSTALL_DIR}")
  # set(${DEP_NAME}_FOUND 1)
  # message(STATUS "${DEP_NAME} will be downloaded in ${SOURCE_DIR}")
else()
  message(FATAL_ERROR "Unknown integration method: ${${DEP_NAME}_INTEGRATION_METHOD}!")
endif()

if(NOT ${${DEP_NAME}_FOUND})
  set(message_mode "WARNING")
  if(NOT ${${DEP_NAME}_OPTIONAL})
    set(message_mode "FATAL_ERROR")
  endif()
  message(${message_mode}
    "Please install the ${DEP_NAME} (v${${DEP_NAME}_MIN_VERSION}) package!"
  )
  return()
endif()

get_target_property(dep_imported "${DEP_NAME}::${DEP_NAME}" IMPORTED)
# Add compile features to the dependency
if(NOT ${dep_imported})
  message(STATUS "Applying ${DEP_NAME} configuration")
  target_compile_features("${DEP_NAME}"
    PRIVATE
      ${${DEP_NAME}_BUILD_COMPILE_FEATURES}
  )
endif()

# Add compile definitions to the dependency
if(NOT ${dep_imported})
  target_compile_definitions("${DEP_NAME}"
    PRIVATE
      ${${DEP_NAME}_BUILD_COMPILE_DEFINITIONS}
  )
endif()

# Add compile options to the dependency
if(NOT ${dep_imported})
  target_compile_options("${DEP_NAME}"
    PRIVATE
      ${${DEP_NAME}_BUILD_COMPILE_OPTIONS}
  )
endif()

# Add link options to the dependency
if(NOT ${dep_imported})
  get_target_property(dep_type "${DEP_NAME}" TYPE)
  if(NOT "${dep_type}" STREQUAL "STATIC_LIBRARY")
    target_link_options("${DEP_NAME}"
      PRIVATE
        ${${DEP_NAME}_BUILD_LINK_OPTIONS}
    )
  endif()
endif()

# Links the dependency to the current target being built
message(STATUS "Link ${DEP_NAME} to the target '${CURRENT_TARGET_NAME}'")
target_link_libraries("${CURRENT_TARGET_NAME}"
  PRIVATE
    "${DEP_NAME}::${DEP_NAME}"
)
