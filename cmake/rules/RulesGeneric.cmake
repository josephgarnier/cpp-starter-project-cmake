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
#   <DEP_NAME>_FETCH_AUTODOWNLOAD
#   <DEP_NAME>_FETCH_KIND
#   <DEP_NAME>_FETCH_KIND_IS_URL
#   <DEP_NAME>_FETCH_KIND_IS_GIT
#   <DEP_NAME>_FETCH_KIND_IS_SVN
#   <DEP_NAME>_FETCH_KIND_IS_MERCURIAL
#   <DEP_NAME>_FETCH_REPOSITORY
#   <DEP_NAME>_FETCH_TAG
#   <DEP_NAME>_FETCH_REVISION
#   <DEP_NAME>_FETCH_HASH
#   <DEP_NAME>_OPTIONAL
#   <DEP_NAME>_CONFIG_COMPILE_FEATURES
#   <DEP_NAME>_CONFIG_COMPILE_DEFINITIONS
#   <DEP_NAME>_CONFIG_COMPILE_OPTIONS
#   <DEP_NAME>_CONFIG_LINK_OPTIONS
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

# Searches for prebuilt dependency in local and common directories, or downloads
# it to build it from sources if not found
find_package("${DEP_NAME}" "${${DEP_NAME}_MIN_VERSION}" NO_MODULE QUIET)
if(${${DEP_NAME}_FOUND})
  message(STATUS
    "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} found locally: ${${DEP_NAME}_CONFIG}"
  )
else()
  if(${${DEP_NAME}_FETCH_AUTODOWNLOAD})
    # Download the dependency sources and bring them into scope
    message(STATUS
      "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} not found locally, try to download it in the build-tree"
    )
    include(FetchContent)
    set(FETCHCONTENT_QUIET off)
    set(fetch_content_args "")
    if(${${DEP_NAME}_FETCH_KIND_IS_URL})
      list(APPEND fetch_content_args
        "URL" "${${DEP_NAME}_FETCH_REPOSITORY}"
        "URL_HASH" "${${DEP_NAME}_FETCH_HASH}"
      )
    elseif(${${DEP_NAME}_FETCH_KIND_IS_GIT})
      list(APPEND fetch_content_args
        "GIT_REPOSITORY" "${${DEP_NAME}_FETCH_REPOSITORY}"
        "GIT_TAG" "${${DEP_NAME}_FETCH_TAG}"
        "GIT_SHALLOW" "on"
        "GIT_PROGRESS" "on"
      )
    elseif(${${DEP_NAME}_FETCH_KIND_IS_SVN})
      list(APPEND fetch_content_args
        "SVN_REPOSITORY" "${${DEP_NAME}_FETCH_REPOSITORY}"
        "SVN_REVISION" "${${DEP_NAME}_FETCH_REVISION}"
      )
    elseif(${${DEP_NAME}_FETCH_KIND_IS_MERCURIAL})
      list(APPEND fetch_content_args
        "HG_REPOSITORY" "${${DEP_NAME}_FETCH_REPOSITORY}"
        "HG_TAG" "${${DEP_NAME}_FETCH_TAG}"
      )
    else()
      message(FATAL_ERROR "Unknown fetch method: ${${DEP_NAME}_FETCH_KIND}!")
    endif()
    FetchContent_Declare(
      "${DEP_NAME}"
      ${fetch_content_args}
      EXCLUDE_FROM_ALL
      SYSTEM
      STAMP_DIR "${${PROJECT_NAME}_BUILD_DIR}"
      DOWNLOAD_NO_PROGRESS off
      LOG_DOWNLOAD on
      LOG_UPDATE on
      LOG_PATCH on
      LOG_CONFIGURE on
      LOG_BUILD on
      LOG_INSTALL on
      LOG_TEST on
      LOG_MERGED_STDOUTERR on
      LOG_OUTPUT_ON_FAILURE on
      USES_TERMINAL_DOWNLOAD on
    )
    FetchContent_MakeAvailable("${DEP_NAME}")
    string(TOLOWER "${DEP_NAME}" DEP_NAME_LOWER)
    if(${${DEP_NAME_LOWER}_POPULATED})
      message(STATUS "${DEP_NAME} downloaded with success")
      set(${DEP_NAME}_FOUND 1)
    else()
      message(STATUS "${DEP_NAME} downloading failed")
      set(${DEP_NAME}_FOUND 0)
    endif()
  else()
    message(STATUS "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} not found locally")
  endif()
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

# Add compile features to the dependency
message(STATUS "Applying ${DEP_NAME} configuration")
target_compile_features("${DEP_NAME}"
  PRIVATE
    ${${DEP_NAME}_CONFIG_COMPILE_FEATURES} # don't add quote (yeah, the signature is inconsistent with other CMake target commands)
)

# Add compile definitions to the dependency
target_compile_definitions("${DEP_NAME}"
  PRIVATE
    "${${DEP_NAME}_CONFIG_COMPILE_DEFINITIONS}"
)

# Add compile options to the dependency
target_compile_options("${DEP_NAME}"
  PRIVATE
    "${${DEP_NAME}_CONFIG_COMPILE_OPTIONS}"
)

# Add link options to the dependency
get_target_property(dep_type "${DEP_NAME}" TYPE)
if(NOT dep_type STREQUAL "STATIC_LIBRARY")
  target_link_options("${DEP_NAME}"
    PRIVATE
      "${${DEP_NAME}_CONFIG_LINK_OPTIONS}"
  )
endif()

# Links the dependency to the current target being built
message(STATUS "Link ${DEP_NAME} to the target '${CURRENT_TARGET_NAME}'")
target_link_libraries("${CURRENT_TARGET_NAME}"
  PRIVATE
    "${DEP_NAME}::${DEP_NAME}"
)
