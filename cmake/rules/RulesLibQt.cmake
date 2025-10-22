# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

#------------------------------------------------------------------------------
# List of available custom variables:
# - CURRENT_TARGET
# - <dependency_name>_RULES_FILE
# - <dependency_name>_MIN_VERSION
# - <dependency_name>_AUTODOWNLOAD
# - <dependency_name>_OPTIONAL
#------------------------------------------------------------------------------

#---- Import and link Qt. ----
message(STATUS "Import and link Qt")
if(DEFINED ENV{Qt6_DIR}) 
  set(Qt6_DIR "$ENV{Qt6_DIR}")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
  set(Qt6_DIR "D:/Documents/Software_Libraries/Qt/6.8.0/mingw_64")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
  set(Qt6_DIR "/opt/Qt/6.8.0/gcc_64/lib/cmake")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
  set(Qt6_DIR "/opt/Qt/6.8.0/gcc_64/lib/cmake")
endif()
if(DEFINED ENV{CMAKE_PREFIX_PATH}) 
  set(CMAKE_PREFIX_PATH "$ENV{CMAKE_PREFIX_PATH}")
else()
  set(CMAKE_PREFIX_PATH "${Qt6_DIR}")
endif()

# Find Qt.
find_package(Qt6 6.8.0 COMPONENTS Widgets Gui Core Svg Concurrent REQUIRED)
if (${Qt6Widgets_VERSION} VERSION_LESS 6.8.0
  OR ${Qt6Gui_VERSION} VERSION_LESS 6.8.0
  OR ${Qt6Core_VERSION} VERSION_LESS 6.8.0
  OR ${Qt6Svg_VERSION} VERSION_LESS 6.8.0
  OR ${Qt6Concurrent_VERSION} VERSION_LESS 6.8.0)
    message(FATAL_ERROR "Minimum supported Qt6 version is 6.8.0!")
endif()

return()

set(QOBJECT_SOURCE_FILES
  ""
)
set(QOBJECT_HEADER_FILES
  ""
)
set(UI_FILES
  ""
)
set(RESSOURCE_FILES
  ""
)
# set(QOBJECT_SOURCE_FILES
#   "${${PROJECT_NAME}_SRC_DIR}/myQObject.cpp"
# )
# set(QOBJECT_HEADER_FILES
#   "${${PROJECT_NAME}_SRC_DIR}/myQObject.h"
# )
# set(UI_FILES
#   "${${PROJECT_NAME}_SRC_DIR}/myGUI.ui"
# )
# set(RESSOURCE_FILES
#   "${${PROJECT_NAME}_RESOURCES_DIR}/myResources.qrc"
# )

qt6_wrap_cpp(MOC_HEADER_FILES ${QOBJECT_HEADER_FILES} TARGET "${${PROJECT_NAME}_MAIN_BIN_TARGET}")
qt6_wrap_ui(UI_SOURCE_FILES ${UI_FILES})
qt6_add_resources(RESSOURCE_SOURCE_FILES ${RESSOURCE_FILES})

message(STATUS "Found the following QObject source files:")
print(STATUS PATHS "${QOBJECT_SOURCE_FILES}" INDENT)

message(STATUS "Found the following QObject header files:")
print(STATUS PATHS "${QOBJECT_HEADER_FILES}" INDENT)

message(STATUS "Found the following moc header files:")
print(STATUS PATHS "${MOC_HEADER_FILES}" INDENT)

message(STATUS "Found the following UI files:")
print(STATUS PATHS "${UI_FILES}" INDENT)

message(STATUS "Found the following UI source files:")
print(STATUS PATHS "${UI_SOURCE_FILES}" INDENT)

message(STATUS "Found the following resources files:")
print(STATUS PATHS "${RESSOURCE_FILES}" INDENT)

message(STATUS "Found the following resources source files:")
print(STATUS PATHS "${RESSOURCE_SOURCE_FILES}" INDENT)

# Add Qt source and header files to the main binary build target.
message(STATUS "Add the found Qt source and header files to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_sources("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PRIVATE
    "${QOBJECT_SOURCE_FILES}"
    "${MOC_HEADER_FILES}"
    "${UI_SOURCE_FILES}"
    "${RESSOURCE_SOURCE_FILES}"
)
source_group(TREE "${${PROJECT_NAME}_PROJECT_DIR}"
  FILES
    "${QOBJECT_SOURCE_FILES}"
    "${MOC_HEADER_FILES}"
    "${UI_SOURCE_FILES}"
    "${RESSOURCE_SOURCE_FILES}"
)

# Add Qt definitions to the main binary build target.
message(STATUS "Add Qt definitions to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
    "$<INSTALL_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
)

# Add Qt assert definitions to the main binary build target only for debug.
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:$<$<NOT:$<STREQUAL:${CMAKE_BUILD_TYPE},DEBUG>>:QT_NO_DEBUG>>"
    "$<INSTALL_INTERFACE:$<$<NOT:$<STREQUAL:${CMAKE_BUILD_TYPE},DEBUG>>:QT_NO_DEBUG>>"
)

# Link Qt to the main binary build target.
message(STATUS "Link Qt to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:Qt6::Widgets;Qt6::Gui;Qt6::Core;Qt6::Svg;Qt6::Concurrent>"
    "$<INSTALL_INTERFACE:Qt6::Widgets;Qt6::Gui;Qt6::Core;Qt6::Svg;Qt6::Concurrent>"
)

# Set Qt as a position-independent target.
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
target_compile_options("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>>"
    "$<INSTALL_INTERFACE:$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>>"
  PRIVATE
    "$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>"
)
message(STATUS "Import and link Qt - done")