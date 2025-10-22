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
# Description :
#   Custom rules file to find and link the dependency ``<DEP_NAME>`` to the target
#   ``<CURRENT_TARGET_NAME>``. The final status must be set in ``<DEP_NAME>_FOUND``
#   (1: found, 0: not found).
#
#   The list of target configuration settings can be accessed from the variables
#   listed in "Predefined variables". The value of a variable associated with a
#   setting not declared in the configuration JSON file is "NOT DEFINED".
#
# Environment read:
#   ENV{<DEP_NAME>}_DIR: The ``<PackageName>_DIR`` environment variable.
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
#   <DEP_NAME>_FOUND: Must be set to indicate the final status "1" if dependency
#                     is found, "0" if not found. The command find_package() can
#                     initialize this variable.
#
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

# Set search paths for find_package() commands
if(DEFINED ENV{CMAKE_PREFIX_PATH}) 
  set(CMAKE_PREFIX_PATH "$ENV{CMAKE_PREFIX_PATH}")
else()
  set(CMAKE_PREFIX_PATH "${${DEP_NAME}_DIR}")
endif()

# Try to find the dependency in local and common directories
# find_package("${DEP_NAME}" "${${DEP_NAME}_MIN_VERSION}" NO_MODULE QUIET)
# if(${${DEP_NAME}_FOUND})
#   message(FATAL_ERROR "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} not found locally!")
# endif()

# message(STATUS "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} found locally: ${${DEP_NAME}_CONFIG}")

#####   <YOUR CODE HERE>   #####
#####   (remove or uncomment the code above and below is you need to)   #####

# Link the dependency to the binary build target
# message(STATUS "Link ${DEP_NAME} to the target '${CURRENT_TARGET_NAME}'")
# target_link_libraries("${CURRENT_TARGET_NAME}"
#   PRIVATE
#     "${DEP_NAME}::${DEP_NAME}"
# )
