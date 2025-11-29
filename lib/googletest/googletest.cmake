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
# Description:
#   Custom rules file to find and link the dependency ``<DEP_NAME>`` to the target
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
# Required user-defined variables:
#   <DEP_NAME>_FOUND: Must be set to "1" if the dependency was found, "0" otherwise.
#                     This variable may be initialized by ``find_package()``.
# =============================================================================

set(${DEP_NAME}_FOUND 0)
if(${${DEP_NAME}_FETCH_AUTODOWNLOAD})
  # Searches for prebuilt dependency in local and common directories, or downloads
  # it to build it from sources if not found
  message(STATUS
    "Trying to find ${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} locally or downloading it in the build-tree if not found"
  )
  include(FetchContent)
  set(FETCHCONTENT_QUIET off)
  FetchContent_Declare(
    "${DEP_NAME}"
    GIT_REPOSITORY "${${DEP_NAME}_FETCH_REPOSITORY}"
    GIT_TAG "${${DEP_NAME}_FETCH_TAG}"
    GIT_SHALLOW on
    GIT_PROGRESS on
    FIND_PACKAGE_ARGS "${${DEP_NAME}_MIN_VERSION}" NAMES "GTest"
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
  if(${${DEP_NAME}_FOUND})
    message(STATUS
      "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} found locally: ${${DEP_NAME}_CONFIG}"
    )
    set(${DEP_NAME}_TARGET_IMPORTED true)
  elseif(${${DEP_NAME_LOWER}_POPULATED})
    message(STATUS "${DEP_NAME} downloaded with success")
    set(${DEP_NAME}_SOURCE_DIR "${${DEP_NAME_LOWER}_SOURCE_DIR}")
    set(${DEP_NAME}_BINARY_DIR "${${DEP_NAME_LOWER}_BINARY_DIR}")
    set(${DEP_NAME}_TARGET_IMPORTED false)
    set(${DEP_NAME}_FOUND 1)
  else()
    message(STATUS "${DEP_NAME} downloading failed")
    set(${DEP_NAME}_FOUND 0)
  endif()
else()
  message(STATUS "Autodownload for ${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} is disabled")
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

if(${${DEP_NAME}_TARGET_IMPORTED})
  # Add the dependency targets in a folder for IDE project
  set_target_properties("GTest::gtest" "GTest::gtest_main" "GTest::gmock" "GTest::gmock_main" 
    PROPERTIES FOLDER "${CMAKE_FOLDER}/GTest"
  )
else()
  # Add the dependency targets in a folder for IDE project
  set_target_properties("gtest" "gtest_main" "gmock" "gmock_main"
    PROPERTIES FOLDER "${CMAKE_FOLDER}/GTest"
  )
  # Add compile definitions to the dependency
  foreach(dep_target IN ITEMS "gtest" "gtest_main" "gmock" "gmock_main")
    target_compile_definitions("${dep_target}"
      PRIVATE
        "GTEST_HAS_PTHREAD=0;GTEST_CREATE_SHARED_LIBRARY=1;GTEST_LINKED_AS_SHARED_LIBRARY=1"
    )
  endforeach()
endif()

# Links the dependency to the current target being built
message(STATUS "Link ${DEP_NAME} to the target '${CURRENT_TARGET_NAME}'")
target_link_libraries("${CURRENT_TARGET_NAME}"
  PRIVATE
    "GTest::gtest;GTest::gtest_main;GTest::gmock;GTest::gmock_main"
)
