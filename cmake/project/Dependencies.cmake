# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# Put in this file all instructions to include and link your library dependencies
# to your own library and own executable. All libraries (.dll or .so files) found by the
# `directory()` function will be automatically link, but to include their header
# file, you have to add this function. For each directory in `include/`,
# except for this containing your own headers, write the following instructions at
# the end of this file in remplacing `<library-name-directory>` by the name of
# directory where your library is:
# 
# set(${PROJECT_NAME}_LIBRARY_HEADER_DIRS "${${PROJECT_NAME}_INCLUDE_DIR}/<library-name-directory>")
#
# On the contrary, if you want to use an external library (e.g Qt) in using
# `find_package()` function, you don't need the previous code, but rather have
# to add your special instructions like `find_package()`, `target_sources()`,
# `target_include_directories()`, target_compile_definitions()` and
# `target_link_libraries()` at the end of file. You have to add these properties on
# the target : `${${PROJECT_NAME}_TARGET_NAME}`.
# To know how import a such library please read its documentation.
# Last thing, this is in this file that you will use the parameter `DPARAM_ASSERT_ENABLE`
# with a test like `if(${PARAM_ASSERT_ENABLE})`.
# An illustrated example for Qt, which you will have to delete, is proposed at the
# end of the file.
#
# Warning: if you use `find_package()` function, the don't forget to add
# your dependancies in the file cmake/project/PackageConfig.cmake.

include(Directory)
include(FileManip)

set(${PROJECT_NAME}_LIBRARY_FILES "")
directory(SCAN ${PROJECT_NAME}_LIBRARY_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_LIB_DIR}"
	INCLUDE_REGEX ".*\\${CMAKE_SHARED_LIBRARY_SUFFIX}.*|.*\\${CMAKE_STATIC_LIBRARY_SUFFIX}.*"
)

# Append each include directories of your libraries in this list
# (in this way `${${PROJECT_NAME}_INCLUDE_DIR}/<library-name-directory>`) or
# let it empty. They will be added to include directories of target and copied
# by `install()` command.
#  ||
#  V
set(${PROJECT_NAME}_LIBRARY_HEADER_DIRS "")



# Add your special instructions here


# Exemple with Qt (delete it if you don't need it)
# message("\n** Include Qt **")
# if(DEFINED ENV{Qt5_DIR}) 
# 	set(Qt5_DIR "$ENV{Qt5_DIR}")
# else()
# 	set(Qt5_DIR "/opt/Qt/5.12.6/gcc_64/lib/cmake/Qt5")
# endif()
# find_package(Qt5 COMPONENTS Widgets Gui Core Svg Concurrent REQUIRED)
# find_package(Qt5CoreMacrosCustom REQUIRED)
# find_package(Qt5WidgetsMacrosCustom REQUIRED)

# if (${Qt5Widgets_VERSION} VERSION_LESS 5.12.6
# 	OR ${Qt5Gui_VERSION} VERSION_LESS 5.12.6
# 	OR ${Qt5Core_VERSION} VERSION_LESS 5.12.6
# 	OR ${Qt5Svg_VERSION} VERSION_LESS 5.12.6
# 	OR ${Qt5Concurrent_VERSION} VERSION_LESS 5.12.6)
# 		message(FATAL_ERROR "Minimum supported Qt5 version is 5.12.6!")
# endif()

# set(QOBJECT_SOURCE_FILES "${${PROJECT_NAME}_SRC_DIR}/sub2/sub2.cpp")
# set(QOBJECT_HEADER_FILES "${${PROJECT_NAME}_SRC_DIR}/sub2/sub2.h")
# set(UI_FILES "")
# set(RESSOURCE_FILES "")

# qt5_wrap_cpp(MOC_HEADER_FILES ${QOBJECT_HEADER_FILES})
# qt5_wrap_ui_custom(UI_SOURCE_FILES ${UI_FILES})
# qt5_add_resources_custom(RESSOURCE_SRCS ${RESSOURCE_FILES})

# set(RELATIVE_QOBJECT_SOURCE_FILES "")
# file_manip(RELATIVE_PATH QOBJECT_SOURCE_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_QOBJECT_SOURCE_FILES)
# set(RELATIVE_QOBJECT_HEADER_FILES "")
# file_manip(RELATIVE_PATH QOBJECT_HEADER_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_QOBJECT_HEADER_FILES)
# set(RELATIVE_MOC_HEADER_FILES "")
# file_manip(RELATIVE_PATH MOC_HEADER_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_MOC_HEADER_FILES)
# set(RELATIVE_UI_FILES "")
# file_manip(RELATIVE_PATH UI_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_UI_FILES)
# set(RELATIVE_UI_SOURCE_FILES "")
# file_manip(RELATIVE_PATH UI_SOURCE_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_UI_SOURCE_FILES)
# set(RELATIVE_RESSOURCE_FILES "")
# file_manip(RELATIVE_PATH RESSOURCE_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_RESSOURCE_FILES)
# set(RELATIVE_RESSOURCE_SRCS "")
# file_manip(RELATIVE_PATH RESSOURCE_SRCS BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_RESSOURCE_SRCS)

# message(STATUS "QObject sources found:")
# foreach(file IN ITEMS ${RELATIVE_QOBJECT_SOURCE_FILES})
# 	message("    ${file}")
# endforeach()

# message(STATUS "QObject headers found:")
# foreach(file IN ITEMS ${RELATIVE_QOBJECT_HEADER_FILES})
# 	message("    ${file}")
# endforeach()

# message(STATUS "QObject moc found:")
# foreach(file IN ITEMS ${RELATIVE_MOC_HEADER_FILES})
# 	message("    ${file}")
# endforeach()

# message(STATUS "UI files found:")
# foreach(file IN ITEMS ${RELATIVE_UI_FILES})
# 	message("    ${file}")
# endforeach()

# message(STATUS "UI sources found:")
# foreach(file IN ITEMS ${RELATIVE_UI_SOURCE_FILES})
# 	message("    ${file}")
# endforeach()

# message(STATUS "Ressources files found:")
# foreach(file IN ITEMS ${RELATIVE_RESSOURCE_FILES})
# 	message("    ${file}")
# endforeach()

# message(STATUS "Ressources sources found:")
# foreach(file IN ITEMS ${RELATIVE_RESSOURCE_SRCS})
# 	message("    ${file}")
# endforeach()
# message("")

# # Add Qt sources to target
# message(STATUS "Add Qt sources to target")
# target_sources("${${PROJECT_NAME}_TARGET_NAME}"
# 	PRIVATE
# 		"${RELATIVE_QOBJECT_SOURCE_FILES};${RELATIVE_MOC_HEADER_FILES};${RELATIVE_UI_SOURCE_FILES};${RELATIVE_RESSOURCE_SRCS}"
# )

# # Add Qt include directories to target
# message(STATUS "Add Qt include directories to target")
# target_include_directories("${${PROJECT_NAME}_TARGET_NAME}"
# 	PUBLIC
# 		"$<BUILD_INTERFACE:${Qt5Widgets_INCLUDE_DIRS};${Qt5Gui_INCLUDE_DIRS};${Qt5Core_INCLUDE_DIRS};${Qt5Svg_INCLUDE_DIRS};${Qt5Concurrent_INCLUDE_DIRS}>"
# 		"$<INSTALL_INTERFACE:${Qt5Widgets_INCLUDE_DIRS};${Qt5Gui_INCLUDE_DIRS};${Qt5Core_INCLUDE_DIRS};${Qt5Svg_INCLUDE_DIRS};${Qt5Concurrent_INCLUDE_DIRS}>"
# )

# # Add Qt definitions to target
# message(STATUS "Add Qt definitions to target")
# target_compile_definitions("${${PROJECT_NAME}_TARGET_NAME}"
# 	PUBLIC
# 		"$<BUILD_INTERFACE:${Qt5Widgets_COMPILE_DEFINITIONS};${Qt5Gui_COMPILE_DEFINITIONS};${Qt5Core_COMPILE_DEFINITIONS};${Qt5Svg_COMPILE_DEFINITIONS};${Qt5Concurrent_COMPILE_DEFINITIONS};QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
# 		"$<INSTALL_INTERFACE:${Qt5Widgets_COMPILE_DEFINITIONS};${Qt5Gui_COMPILE_DEFINITIONS};${Qt5Core_COMPILE_DEFINITIONS};${Qt5Svg_COMPILE_DEFINITIONS};${Qt5Concurrent_COMPILE_DEFINITIONS};QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
# )

# # Link Qt to target
# message(STATUS "Link Qt to target\n")
# get_target_property(Qt5Widgets_location ${Qt5Widgets_LIBRARIES} LOCATION)
# get_target_property(Qt5Gui_location ${Qt5Gui_LIBRARIES} LOCATION)
# get_target_property(Qt5Core_location ${Qt5Core_LIBRARIES} LOCATION)
# get_target_property(Qt5Svg_location ${Qt5Svg_LIBRARIES} LOCATION)
# get_target_property(Qt5Concurrent_location ${Qt5Concurrent_LIBRARIES} LOCATION)
# target_link_libraries("${${PROJECT_NAME}_TARGET_NAME}"
# 	PUBLIC
# 		"$<BUILD_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
# 		"$<INSTALL_INTERFACE:${Qt5Widgets_location};${Qt5Gui_location};${Qt5Core_location};${Qt5Svg_location};${Qt5Concurrent_location}>"
# )
# if(${${PROJECT_NAME}_TARGET_IS_EXEC})
# 	target_compile_options("${${PROJECT_NAME}_TARGET_NAME}"
# 		PUBLIC
# 			"$<BUILD_INTERFACE:-fPIC;-fPIE>"
# 			"$<INSTALL_INTERFACE:-fPIC;-fPIE>"
# 	)
# 	set_target_properties("${${PROJECT_NAME}_TARGET_NAME}" PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
# endif()

# if(${PARAM_ASSERT_ENABLE})
# 	message(STATUS "QtAssert enabled\n")
# else()
# 	# Add Qt assert definitions to target
# 	message(STATUS "Add Qt assert definitions to target")
# 	target_compile_definitions("${${PROJECT_NAME}_TARGET_NAME}"
# 		PUBLIC
# 			"$<BUILD_INTERFACE:QT_NO_DEBUG>"
# 			"$<INSTALL_INTERFACE:QT_NO_DEBUG>"
# 	)
# 	message(STATUS "QtAssert disabled\n")
# endif()
