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

# Searches for the dependency in local and common directories
find_package("${DEP_NAME}" "${${DEP_NAME}_MIN_VERSION}" COMPONENTS Widgets Gui Core Svg Concurrent REQUIRED)
if(${${DEP_NAME}_FOUND})
  message(STATUS
    "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} found locally: ${${DEP_NAME}_CONFIG}"
  )
else()
  message(STATUS "${DEP_NAME} v${${DEP_NAME}_MIN_VERSION} not found locally")
  set(message_mode "WARNING")
  if(NOT ${${DEP_NAME}_OPTIONAL})
    set(message_mode "FATAL_ERROR")
  endif()
  message(${message_mode}
    "Please install the ${DEP_NAME} (v${${DEP_NAME}_MIN_VERSION}) package!"
  )
  return()
endif()

set(QOBJECT_SOURCE_FILES
  ""
  # "${CMAKE_CURRENT_SOURCE_DIR}/myQObject.cpp"
)
set(QOBJECT_HEADER_FILES
  ""
  # "${CMAKE_CURRENT_SOURCE_DIR}/myQObject.h"
)
set(UI_FILES
  ""
  # "${CMAKE_CURRENT_SOURCE_DIR}/myGUI.ui"
)
set(RESSOURCE_FILES
  ""
  # "${${PROJECT_NAME}_RESOURCES_DIR}/myResources.qrc"
)

qt6_wrap_cpp(MOC_HEADER_FILES ${QOBJECT_HEADER_FILES} TARGET "${CURRENT_TARGET_NAME}")
qt6_wrap_ui(UI_SOURCE_FILES ${UI_FILES})
qt6_add_resources(RESSOURCE_SOURCE_FILES ${RESSOURCE_FILES})

list(LENGTH MOC_HEADER_FILES nb_header_files)
if(${nb_header_files} GREATER 0)
  print(VERBOSE "Moc header files generated: @rpl@" "${MOC_HEADER_FILES}")
else()
  message(VERBOSE "Moc header files generated: (none)")
endif()
list(LENGTH UI_SOURCE_FILES nb_ui_source_files)
if(${nb_ui_source_files} GREATER 0)
  print(VERBOSE "UI source files generated: @rpl@" "${UI_SOURCE_FILES}")
else()
  message(VERBOSE "UI source files generated: (none)")
endif()
list(LENGTH RESSOURCE_SOURCE_FILES nb_res_source_files)
if(${nb_res_source_files} GREATER 0)
  print(VERBOSE "Resources source files generated: @rpl@" "${RESSOURCE_SOURCE_FILES}")
else()
  message(VERBOSE "Resources source files generated: (none)")
endif()

# Attach files to the current target being built and structure source groups to match
# project tree
target_sources("${CURRENT_TARGET_NAME}"
  PRIVATE
    "${QOBJECT_SOURCE_FILES}"
    "${MOC_HEADER_FILES}"
    "${UI_SOURCE_FILES}"
    "${RESSOURCE_SOURCE_FILES}"
)
source_group(TREE "${CMAKE_SOURCE_DIR}"
  FILES
    "${QOBJECT_SOURCE_FILES}"
    "${MOC_HEADER_FILES}"
    "${UI_SOURCE_FILES}"
    "${RESSOURCE_SOURCE_FILES}"
)

# Add Qt compile definitions to the current target being built
message(STATUS "Applying ${DEP_NAME} definitions to the target '${CURRENT_TARGET_NAME}'")
target_compile_definitions("${CURRENT_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
    "$<INSTALL_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
)

# Add Qt assert compile definitions to the current target being built, only for
# debug
target_compile_definitions("${CURRENT_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:$<$<NOT:$<STREQUAL:${CMAKE_BUILD_TYPE},DEBUG>>:QT_NO_DEBUG>>"
    "$<INSTALL_INTERFACE:$<$<NOT:$<STREQUAL:${CMAKE_BUILD_TYPE},DEBUG>>:QT_NO_DEBUG>>"
)

# Link Qt to the current target being built
message(STATUS "Link ${DEP_NAME} to the target '${CURRENT_TARGET_NAME}'")
target_link_libraries("${CURRENT_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:Qt6::Widgets;Qt6::Gui;Qt6::Core;Qt6::Svg;Qt6::Concurrent>"
    "$<INSTALL_INTERFACE:Qt6::Widgets;Qt6::Gui;Qt6::Core;Qt6::Svg;Qt6::Concurrent>"
)

# Set Qt as a position-independent target
message(STATUS "Setting ${DEP_NAME} as a position-independent target")
set_target_properties("${CURRENT_TARGET_NAME}"
  PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON
)
target_compile_options("${CURRENT_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>>"
    "$<INSTALL_INTERFACE:$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>>"
  PRIVATE
    "$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>"
)
