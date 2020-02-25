# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

# -DPARAM_PROJECT_NAME: specifies a name for project
# -DPARAM_PROJECT_SUMMARY: short description of the project
# -DPARAM_PROJECT_VENDOR_NAME: project author
# -DPARAM_PROJECT_VENDOR_CONTACT: author contact
# -DPARAM_PROJECT_VERSION_MAJOR: project major version
# -DPARAM_PROJECT_VERSION_MINOR: project minor version
# -DPARAM_PROJECT_VERSION_PATCH: project patch version
# -DPARAM_GENERATOR: see https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
# -DPARAM_COMPILE_VERSION=[11|14|17 (default)|20]: see https://cmake.org/cmake/help/v3.1/variable/CMAKE_CXX_STANDARD.html
# -DPARAM_BUILD_TYPE=[(default) debug|release]: set type of build
# -DPARAM_ASSERT_ENABLE=[ON|OFF (default)]: enable or disable assert
# -DPARAM_BUILD_SHARED_LIBS=[(default) ON|OFF]: build shared libraries instead of static
# -DPARAM_BUILD_EXEC=[(default) ON|OFF]: build an executable
# -DPARAM_BUILD_TESTS=[ON|OFF (default)]: build tests
# -DPARAM_BUILD_DOXYGEN_DOCS=[ON|OFF (default)]: build documentation

cmake_minimum_required (VERSION 3.12)

#------------------------------------------------------------------------------
# Set parameters
#------------------------------------------------------------------------------
set(PROJECT_NAME_DESC           "Specifies a name for project")
set(PROJECT_SUMMARY_DESC        "Short description of the project")
set(PROJECT_VENDOR_NAME_DESC    "Project author")
set(PROJECT_VENDOR_CONTACT_DESC "Author contact")
set(PROJECT_VERSION_MAJOR_DESC  "Project major version")
set(PROJECT_VERSION_MINOR_DESC  "Project minor version")
set(PROJECT_VERSION_PATCH_DESC  "Project patch version")
set(GENERATOR_DESC              "Specifies CMake Generator, see https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html")
set(COMPILE_VERSION_DESC        "Specifies compiler version \"11\" or \"14\" or \"17\" or \"20\"")
set(BUILD_TYPE_DESC             "Specifies type of build \"debug\" or \"release\"")
set(ASSERT_ENABLE_DESC          "Specifies whether to use assert")
set(BUILD_SHARED_LIBS_DESC      "Specifies whether build shared libraries instead of static")
set(BUILD_EXEC_DESC             "Specifies whether build an executable")
set(BUILD_TESTS_DESC            "Specifies whether build tests")
set(BUILD_DOXYGEN_DOCS_DESC     "Specifies whether build documentation")

set(PARAM_PROJECT_NAME          "project-name"      CACHE   STRING  "${PROJECT_NAME_DESC}")
set(PARAM_PROJECT_SUMMARY       "description"       CACHE   STRING  "${PROJECT_SUMMARY_DESC}")
set(PARAM_PROJECT_VENDOR_NAME   "your-name"         CACHE   STRING  "${PROJECT_VENDOR_NAME_DESC}")
set(PARAM_PROJECT_VENDOR_CONTACT"contact"           CACHE   STRING  "${PROJECT_VENDOR_CONTACT_DESC}")
set(PARAM_PROJECT_VERSION_MAJOR "0"                 CACHE   STRING  "${PROJECT_VERSION_MAJOR_DESC}")
set(PARAM_PROJECT_VERSION_MINOR "0"                 CACHE   STRING  "${PROJECT_VERSION_MINOR_DESC}")
set(PARAM_PROJECT_VERSION_PATCH "0"                 CACHE   STRING  "${PROJECT_VERSION_PATCH_DESC}")
set(PARAM_GENERATOR             "Unix Makefiles"    CACHE   STRING  "${GENERATOR_DESC}")
set(PARAM_COMPILE_VERSION       "17"                CACHE   STRING  "${COMPILE_VERSION_DESC}")
set(PARAM_BUILD_TYPE            "debug"             CACHE   STRING  "${BUILD_TYPE_DESC}")
set(PARAM_ASSERT_ENABLE         OFF                 CACHE   BOOL    "${ASSERT_ENABLE_DESC}")
set(PARAM_BUILD_SHARED_LIBS     OFF                 CACHE   BOOL    "${BUILD_SHARED_LIBS_DESC}")
set(PARAM_BUILD_EXEC            ON                  CACHE   BOOL    "${BUILD_EXEC_DESC}")
set(PARAM_BUILD_TESTS           OFF                 CACHE   BOOL    "${BUILD_TESTS_DESC}")
set(PARAM_BUILD_DOXYGEN_DOCS    OFF                 CACHE   BOOL    "${BUILD_DOXYGEN_DOCS_DESC}")

message("=============================================")
message("      Build project ${PARAM_PROJECT_NAME}    ")
message("=============================================")

message("Summary of your options:")
message(" - Project name: \"${PARAM_PROJECT_NAME}\"")
message(" - Project description: \"${PARAM_PROJECT_SUMMARY}\"")
message(" - Project author: \"${PARAM_PROJECT_VENDOR_NAME}\"")
message(" - Author contact: \"${PARAM_PROJECT_VENDOR_CONTACT}\"")
message(" - Project major version: \"${PARAM_PROJECT_VERSION_MAJOR}\"")
message(" - Project minor version: \"${PARAM_PROJECT_VERSION_MINOR}\"")
message(" - Project patch version: \"${PARAM_PROJECT_VERSION_PATCH}\"")
message(" - Generator: \"${PARAM_GENERATOR}\"")
message(" - Compile version: \"${PARAM_COMPILE_VERSION}\"")
message(" - Build type: \"${PARAM_BUILD_TYPE}\"")
message(" - Assert is enable: \"${PARAM_ASSERT_ENABLE}\"")
message(" - Build shared libs: \"${PARAM_BUILD_SHARED_LIBS}\"")
message(" - Build executable: \"${PARAM_BUILD_EXEC}\"")
message(" - Build tests: \"${PARAM_BUILD_TESTS}\"")
message(" - Build doxygen documentation: \"${PARAM_BUILD_DOXYGEN_DOCS}\"")
message("")

#------------------------------------------------------------------------------
# Check options
#------------------------------------------------------------------------------
message("== Check options ==")

# Check if project name has been specified correctly.
if(NOT DEFINED PARAM_PROJECT_NAME)
	message(FATAL_ERROR "Project name must be specified!")
endif()
if("${PARAM_PROJECT_NAME}" MATCHES " ")
	message(FATAL_ERROR "Project name cannot contain spaces!")
endif()

# If present and true, this will cause all libraries to be built shared unless the library was explicitly added as a static library.
set(BUILD_SHARED_LIBS ${PARAM_BUILD_SHARED_LIBS})

# Set CMake build-type. If it not supplied by the user, the default built type is "Release".
if((NOT DEFINED PARAM_BUILD_TYPE) OR ("${PARAM_BUILD_TYPE}" STREQUAL "release"))
	set(CMAKE_BUILD_TYPE Release)
	message(STATUS "Building release version")
elseif("${PARAM_BUILD_TYPE}" STREQUAL "debug")
	set(CMAKE_BUILD_TYPE Debug)
	message(STATUS "Building debug version")
else()
	message(FATAL_ERROR "Build type should be \"debug\" or \"release\"!")
endif()

# Set compiler version flag
if((NOT DEFINED PARAM_COMPILE_VERSION) OR
	((NOT "${PARAM_COMPILE_VERSION}" STREQUAL "11")
	AND (NOT "${PARAM_COMPILE_VERSION}" STREQUAL "14")
	AND (NOT "${PARAM_COMPILE_VERSION}" STREQUAL "17")
	AND (NOT "${PARAM_COMPILE_VERSION}" STREQUAL "20")))
	message(FATAL_ERROR "Compile version must be 11 or 14 or 17 or 20")
else()
	set(CMAKE_CXX_STANDARD "${PARAM_COMPILE_VERSION}")
	message(STATUS "Compile version set to ${CMAKE_CXX_STANDARD}")
endif()

#------------------------------------------------------------------------------
# Project settings
#------------------------------------------------------------------------------
message("\n== Project settings ==")
set(${PROJECT_NAME}_SUMMARY         "${PARAM_PROJECT_SUMMARY}")
set(${PROJECT_NAME}_VENDOR_NAME     "${PARAM_PROJECT_VENDOR_NAME}")
set(${PROJECT_NAME}_VENDOR_CONTACT  "${PARAM_PROJECT_VENDOR_CONTACT}")
set(${PROJECT_NAME}_VERSION_MAJOR   "${PARAM_PROJECT_VERSION_MAJOR}")
set(${PROJECT_NAME}_VERSION_MINOR   "${PARAM_PROJECT_VERSION_MINOR}")
set(${PROJECT_NAME}_VERSION_PATCH   "${PARAM_PROJECT_VERSION_PATCH}")
set(${PROJECT_NAME}_VERSION         "${${PROJECT_NAME}_VERSION_MAJOR}-${${PROJECT_NAME}_VERSION_MINOR}-${${PROJECT_NAME}_VERSION_PATCH}")
project("${PARAM_PROJECT_NAME}"
	VERSION "${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH}"
	DESCRIPTION "${${PROJECT_NAME}_SUMMARY}"
	HOMEPAGE_URL "${${PROJECT_NAME}_VENDOR_CONTACT}"
	LANGUAGES CXX)

message(STATUS "Set projet version with ${${PROJECT_NAME}_VERSION}")

#------------------------------------------------------------------------------
# Check project structure
#------------------------------------------------------------------------------
message("\n== Check project structure ==")
set(${PROJECT_NAME}_PROJECT_PATH                 "${CMAKE_SOURCE_DIR}")
set(${PROJECT_NAME}_ASSETS_PATH                  "${${PROJECT_NAME}_PROJECT_PATH}/assets")
set(${PROJECT_NAME}_BIN_PATH                     "${${PROJECT_NAME}_PROJECT_PATH}/bin")
set(${PROJECT_NAME}_BUILD_PATH                   "${CMAKE_BINARY_DIR}")
set(${PROJECT_NAME}_CMAKE_PATH                   "${${PROJECT_NAME}_PROJECT_PATH}/cmake")
set(${PROJECT_NAME}_CMAKE_HELPERS_PATH           "${${PROJECT_NAME}_CMAKE_PATH}/helpers")
set(${PROJECT_NAME}_CMAKE_MODULES_PATH           "${${PROJECT_NAME}_CMAKE_PATH}/modules")
set(${PROJECT_NAME}_CMAKE_PROJECT_PATH           "${${PROJECT_NAME}_CMAKE_PATH}/project")
set(${PROJECT_NAME}_CMAKE_TOOLCHAINS_PATH        "${${PROJECT_NAME}_CMAKE_PATH}/toolchains")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"
	"${${PROJECT_NAME}_CMAKE_HELPERS_PATH}"
	"${${PROJECT_NAME}_CMAKE_MODULES_PATH}"
	"${${PROJECT_NAME}_CMAKE_PROJECT_PATH}"
	"${${PROJECT_NAME}_CMAKE_TOOLCHAINS_PATH}")
set(${PROJECT_NAME}_CONFIG_PATH                  "${${PROJECT_NAME}_PROJECT_PATH}/config")
set(${PROJECT_NAME}_DOC_PATH                     "${${PROJECT_NAME}_PROJECT_PATH}/doc")
set(${PROJECT_NAME}_INCLUDE_PATH                 "${${PROJECT_NAME}_PROJECT_PATH}/include")
set(${PROJECT_NAME}_LIB_PATH                     "${${PROJECT_NAME}_PROJECT_PATH}/lib")
set(${PROJECT_NAME}_RESOURCES_PATH               "${${PROJECT_NAME}_PROJECT_PATH}/resources")
set(${PROJECT_NAME}_SRC_PATH                     "${${PROJECT_NAME}_PROJECT_PATH}/src")
set(${PROJECT_NAME}_TEST_PATH                    "${${PROJECT_NAME}_PROJECT_PATH}/tests")

list(APPEND ${PROJECT_NAME}_PROJECT_PATHS
	"${${PROJECT_NAME}_ASSETS_PATH}"
	"${${PROJECT_NAME}_BIN_PATH}"
	"${${PROJECT_NAME}_BUILD_PATH}"
	"${${PROJECT_NAME}_CMAKE_PATH}"
	"${${PROJECT_NAME}_CMAKE_HELPERS_PATH}"
	"${${PROJECT_NAME}_CMAKE_MODULES_PATH}"
	"${${PROJECT_NAME}_CMAKE_PROJECT_PATH}"
	"${${PROJECT_NAME}_CMAKE_TOOLCHAINS_PATH}"
	"${${PROJECT_NAME}_CONFIG_PATH}"
	"${${PROJECT_NAME}_DOC_PATH}"
	"${${PROJECT_NAME}_INCLUDE_PATH}"
	"${${PROJECT_NAME}_LIB_PATH}"
	"${${PROJECT_NAME}_RESOURCES_PATH}"
	"${${PROJECT_NAME}_SRC_PATH}"
	"${${PROJECT_NAME}_TEST_PATH}")

foreach(folder IN ITEMS ${${PROJECT_NAME}_PROJECT_PATHS})
	if((NOT EXISTS "${folder}") OR (NOT IS_DIRECTORY "${folder}"))
		message(FATAL_ERROR "missing directory: \"${folder}\"")
	endif()
endforeach()

# build path should be in /build directory
get_filename_component(build_directory "${${PROJECT_NAME}_BUILD_PATH}" DIRECTORY)
if(NOT ("${build_directory}" STREQUAL "${${PROJECT_NAME}_PROJECT_PATH}/build"))
	message(FATAL_ERROR "\"${${PROJECT_NAME}_BUILD_PATH}\" is not under build directory")
endif()

#------------------------------------------------------------------------------
# Set output names and output directories
#------------------------------------------------------------------------------
message("\n== Set output names and output directories ==")
if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

set(SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_SYSTEM_PROCESSOR}")
string(TOLOWER ${SYSTEM_NAME} SYSTEM_NAME)
set(${PROJECT_NAME}_LIB_NAME         "lib${PROJECT_NAME}")
set(${PROJECT_NAME}_EXEC_NAME        "${PROJECT_NAME}")
set(${PROJECT_NAME}_EXPORT_NAME      "export${PROJECT_NAME}")
set(${PROJECT_NAME}_PACKAGE_NAME     "${PROJECT_NAME}-${${PROJECT_NAME}_VERSION}-${CMAKE_SYSTEM_NAME}")
string(TOLOWER ${${PROJECT_NAME}_PACKAGE_NAME} ${PROJECT_NAME}_PACKAGE_NAME)
set(${PROJECT_NAME}_TEST_NAME        "${PROJECT_NAME}_test-${${PROJECT_NAME}_VERSION}-${CMAKE_SYSTEM_NAME}")
string(TOLOWER ${${PROJECT_NAME}_TEST_NAME} ${PROJECT_NAME}_TEST_NAME)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY   "${${PROJECT_NAME}_BIN_PATH}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY   "${${PROJECT_NAME}_BIN_PATH}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY   "${${PROJECT_NAME}_BIN_PATH}")
set(CMAKE_STATIC_LIBRARY_PREFIX      "")
set(CMAKE_SHARED_LIBRARY_PREFIX      "")

# Configure variables specifying the target directories. All destinations are
# relative to CMAKE_INSTALL_PREFIX
include(GNUInstallDirs)
set(${PROJECT_NAME}_INSTALL_RUNTIME_DIR "${CMAKE_INSTALL_BINDIR}")
set(${PROJECT_NAME}_INSTALL_LIBRARY_DIR "${CMAKE_INSTALL_LIBDIR}")
set(${PROJECT_NAME}_INSTALL_ARCHIVE_DIR "${CMAKE_INSTALL_LIBDIR}")
set(${PROJECT_NAME}_INSTALL_INCLUDE_DIR "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}")

#------------------------------------------------------------------------------
# Build project
#------------------------------------------------------------------------------
message("\n== Build project ==")
include(Cotire)
include(ProjectSrcFiles)
if(NOT DEFINED ${PROJECT_NAME}_PRECOMPILED_HEADER_PATH)
	message(FATAL_ERROR "${PROJECT_NAME}_PRECOMPILED_HEADER_PATH must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_PRECOMPILED_SOURCE_PATH)
	message(FATAL_ERROR "${PROJECT_NAME}_PRECOMPILED_SOURCE_PATH must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_SRC_ALL_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_SRC_ALL_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_SRC_HEADER_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_SRC_HEADER_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_SRC_SOURCE_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_SRC_SOURCE_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_INCLUDE_HEADER_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_INCLUDE_HEADER_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_PUBLIC_HEADER_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_PUBLIC_HEADER_FILES must be specified!")
endif()

# Build library
if(${BUILD_SHARED_LIBS})
	message(STATUS "Build as a shared library")
	add_library("${${PROJECT_NAME}_LIB_NAME}" SHARED ${${PROJECT_NAME}_SRC_ALL_FILES})
else()
	message(STATUS "Build as a static library")
	add_library("${${PROJECT_NAME}_LIB_NAME}" STATIC ${${PROJECT_NAME}_SRC_ALL_FILES})
endif()

# Add precompiled header to library
if(${PROJECT_NAME}_PRECOMPILED_HEADER_PATH)
	message(STATUS "Add precompiled header to library")
	set_target_properties("${${PROJECT_NAME}_LIB_NAME}" PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "${${PROJECT_NAME}_PRECOMPILED_HEADER_PATH}")
endif()

# Set compiler version to library
message(STATUS "Set compiler version to library")
target_compile_features("${${PROJECT_NAME}_LIB_NAME}" PUBLIC "cxx_std_${CMAKE_CXX_STANDARD}")

# Add incude directories to library
message(STATUS "Add include directories to library")
target_include_directories("${${PROJECT_NAME}_LIB_NAME}"
	PUBLIC
		# Used when building the library
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_INCLUDE_PATH}>"
		# Used when installing the library
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}>"
	PRIVATE
		# Used only when building the library
		"${${PROJECT_NAME}_SRC_PATH}"
)

if(${PARAM_BUILD_EXEC})
	# Build executable
	message(STATUS "Build executable")
	add_executable("${${PROJECT_NAME}_EXEC_NAME}" ${${PROJECT_NAME}_SRC_ALL_FILES})

	# Add precompiled header to executable
	if(${PROJECT_NAME}_PRECOMPILED_HEADER_PATH)
		message(STATUS "Add precompiled header to executable")
		set_target_properties("${${PROJECT_NAME}_EXEC_NAME}" PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "${${PROJECT_NAME}_PRECOMPILED_HEADER_PATH}")
	endif()
	
	# Set compiler version to executable
	message(STATUS "Set compiler version to executable")
	target_compile_features("${${PROJECT_NAME}_EXEC_NAME}" PUBLIC "cxx_std_${CMAKE_CXX_STANDARD}")
	
	# Add incude directories to executable
	message(STATUS "Add include directories to executable")
	target_include_directories("${${PROJECT_NAME}_EXEC_NAME}"
		PUBLIC
			# Used when building the executable
			"$<BUILD_INTERFACE:${${PROJECT_NAME}_INCLUDE_PATH}>"
			# Used when installing the executable
			"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}>"
		PRIVATE
			# Used only when building the library
			"${${PROJECT_NAME}_SRC_PATH}"
	)
endif()

#------------------------------------------------------------------------------
# Add project dependances
#------------------------------------------------------------------------------
message("\n== Add project dependancies ==")
include(Dependencies)
if(NOT DEFINED ${PROJECT_NAME}_LIBRARIES_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_LIBRARIES_FILES must be specified!")
endif()

# Link externals libraries to library
message(STATUS "Link externals libraries to project library")
target_link_libraries("${${PROJECT_NAME}_LIB_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_LIBRARIES_FILES}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_LIBRARIES_FILES}>"
)

# Link externals libraries to executable
if(${PARAM_BUILD_EXEC})
	message(STATUS "Link externals libraries to project executable")
	target_link_libraries("${${PROJECT_NAME}_EXEC_NAME}"
		PUBLIC
			"$<BUILD_INTERFACE:${${PROJECT_NAME}_LIBRARIES_FILES}>"
			"$<INSTALL_INTERFACE:${${PROJECT_NAME}_LIBRARIES_FILES}>"
	)
endif()

#------------------------------------------------------------------------------
# Speeds up the build process with Cotire
#------------------------------------------------------------------------------
cotire("${${PROJECT_NAME}_LIB_NAME}")
if(${PARAM_BUILD_EXEC})
	cotire("${${PROJECT_NAME}_EXEC_NAME}")
endif()

#------------------------------------------------------------------------------
# Build documentation
#------------------------------------------------------------------------------
if(${PARAM_BUILD_DOXYGEN_DOCS})
	message("\n== Build documentation ==")
	find_package(Doxygen REQUIRED)
	if(NOT DOXYGEN_FOUND)
		message(FATAL_ERROR "Doxygen is needed to build the documentation. Please make sure it is installed.")
	endif()

	# Set input and output files
	set(DOXYGEN_IN "${${PROJECT_NAME}_DOC_PATH}/doxyfile.in")
	set(DOXYGEN_OUT "${${PROJECT_NAME}_DOC_PATH}/doxyfile")

	# Request to configure the file
	configure_file(${DOXYGEN_IN} ${DOXYGEN_OUT} @ONLY)
	message(STATUS "Doxygen build started")

	# Note the option ALL which allows to build the docs together with the application
	add_custom_target(doxygen_docs ALL
		COMMAND ${DOXYGEN_EXECUTABLE} "${DOXYGEN_OUT}"
		SOURCES "${DOXYGEN_OUT}"
		WORKING_DIRECTORY "${${PROJECT_NAME}_DOC_PATH}"
		COMMENT "Generating API documentation with Doxygen"
		VERBATIM)
endif()

#------------------------------------------------------------------------------
# Build tests
#------------------------------------------------------------------------------
if(${PARAM_BUILD_TESTS})
	message("\n== Build tests ==")
	include(CTest)
	add_test(NAME "${${PROJECT_NAME}_TEST_NAME}"
		WORKING_DIRECTORY "${${PROJECT_NAME}_TEST_PATH}"
		COMMAND "${${PROJECT_NAME}_TEST_PATH}/${${PROJECT_NAME}_TEST_NAME}")
endif()

#------------------------------------------------------------------------------
# Make install/uninstall rules
#------------------------------------------------------------------------------
message("\n== Generates make install/uninstall rules ==")
install(TARGETS "${${PROJECT_NAME}_LIB_NAME}"
	EXPORT "${PROJECT_NAME}_EXPORT_NAME"
	LIBRARY DESTINATION "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
	ARCHIVE DESTINATION "${${PROJECT_NAME}_INSTALL_ARCHIVE_DIR}"
)
install(TARGETS "${${PROJECT_NAME}_EXEC_NAME}"
	RUNTIME DESTINATION "${${PROJECT_NAME}_INSTALL_RUNTIME_DIR}"
)

install(DIRECTORY ${${PROJECT_NAME}_SRC_PATH} ${${PROJECT_NAME}_INCLUDE_PATH}
	DESTINATION "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}"
	FILES_MATCHING PATTERN "*.h"
)

if(NOT TARGET uninstall)
	configure_file(
		"${${PROJECT_NAME}_CMAKE_HELPERS_PATH}/Uninstall.cmake.in"
		"${${PROJECT_NAME}_BUILD_PATH}/Uninstall.cmake"
		@ONLY
	)
	# call twice to substitute nested variable
	configure_file(
		"${${PROJECT_NAME}_BUILD_PATH}/Uninstall.cmake"
		"${${PROJECT_NAME}_BUILD_PATH}/Uninstall.cmake"
		@ONLY
	)
	
	add_custom_target(uninstall
		COMMAND ${CMAKE_COMMAND} -P "${${PROJECT_NAME}_BUILD_PATH}/Uninstall.cmake"
	)
endif()

# -------------------- Packager --------------------------

message("\n== Pack project ==")
set(CPACK_SYSTEM_NAME                   "${SYSTEM_NAME}")
set(CPACK_TOPLEVEL_TAG                  "")
set(CPACK_PACKAGE_NAME                  "${${PROJECT_NAME}_PACKAGE_NAME}")
set(CPACK_PACKAGE_DESCRIPTION_SUMMARY   "${${PROJECT_NAME}_SUMMARY}")
set(CPACK_PACKAGE_VENDOR                "${${PROJECT_NAME}_VENDOR_NAME}")
set(CPACK_PACKAGE_DESCRIPTION_FILE      "${${PROJECT_NAME}_PROJECT_PATH}/README.md")
set(CPACK_RESOURCE_FILE_LICENSE         "${${PROJECT_NAME}_PROJECT_PATH}/LICENSE.md")
set(CPACK_PACKAGE_VERSION_MAJOR         "${${PROJECT_NAME}_VERSION_MAJOR}")
set(CPACK_PACKAGE_VERSION_MINOR         "${${PROJECT_NAME}_VERSION_MINOR}")
set(CPACK_PACKAGE_VERSION_PATCH         "${${PROJECT_NAME}_VERSION_PATCH}")
set(CPACK_PACKAGE_FILE_NAME             "${${PROJECT_NAME}_PACKAGE_NAME}")
set(CPACK_PACKAGE_INSTALL_DIRECTORY     "${${PROJECT_NAME}_BIN_PATH}")
set(CPACK_PACKAGE_DIRECTORY             "${${PROJECT_NAME}_BIN_PATH}")
set(CPACK_SOURCE_PACKAGE_FILE_NAME      "${${PROJECT_NAME}_PACKAGE_NAME}-source")
set(CPACK_SOURCE_IGNORE_FILES           "")

if(WIN32)
	set(CPACK_GENERATOR         "NSIS")
	set(CPACK_SOURCE_GENERATOR  "NSIS")
	set(CPACK_NSIS_DISPLAY_NAME "${CPACK_PACKAGE_NAME}")
	set(CPACK_NSIS_CONTACT      "${${PROJECT_NAME}_VENDOR_CONTACT}")
	set(CPACK_NSIS_MODIFY_PATH  ON)
elseif(UNIX)
	set(CPACK_GENERATOR         "ZIP")
	set(CPACK_SOURCE_GENERATOR  "ZIP")
elseif(APPLE)
	set(CPACK_GENERATOR         "ZIP")
	set(CPACK_SOURCE_GENERATOR  "ZIP")
endif()
include(CPack)

message("\n===== End project ${PROJECT_NAME} building =====\n")


message("=== Start of debug messages ===")
include(DumpCMakeVariables)
dump_cmake_variables()

# cmake_print_properties(
# 	TARGETS "${${PROJECT_NAME}_EXEC_NAME}"
# 	PROPERTIES
# 		COTIRE_CXX_PREFIX_HEADER_INIT
# 		INCLUDE_DIRECTORIES
# 		INSTALL_NAME_DIR
# 		INSTALL_REMOVE_ENVIRONMENT_RPATH
# 		INSTALL_RPATH
# 		INSTALL_RPATH_USE_LINK_PATH
# 		INTERFACE_AUTOUIC_OPTIONS
# 		INTERFACE_COMPILE_DEFINITIONS
# 		INTERFACE_COMPILE_FEATURES
# 		INTERFACE_COMPILE_OPTIONS
# 		INTERFACE_INCLUDE_DIRECTORIES
# 		INTERFACE_LINK_DEPENDS
# 		INTERFACE_LINK_DIRECTORIES
# 		INTERFACE_LINK_LIBRARIES
# 		INTERFACE_LINK_OPTIONS
# 		INTERFACE_PRECOMPILE_HEADERS
# 		INTERFACE_POSITION_INDEPENDENT_CODE
# 		INTERFACE_SOURCES
# 		INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
# )
# cmake_print_properties(
# 	TARGETS
# 		"${${PROJECT_NAME}_LIB_NAME}"
# 	PROPERTIES
# 		COTIRE_CXX_PREFIX_HEADER_INIT
# 		INCLUDE_DIRECTORIES
# 		INSTALL_NAME_DIR
# 		INSTALL_REMOVE_ENVIRONMENT_RPATH
# 		INSTALL_RPATH
# 		INSTALL_RPATH_USE_LINK_PATH
# 		INTERFACE_AUTOUIC_OPTIONS
# 		INTERFACE_COMPILE_DEFINITIONS
# 		INTERFACE_COMPILE_FEATURES
# 		INTERFACE_COMPILE_OPTIONS
# 		INTERFACE_INCLUDE_DIRECTORIES
# 		INTERFACE_LINK_DEPENDS
# 		INTERFACE_LINK_DIRECTORIES
# 		INTERFACE_LINK_LIBRARIES
# 		INTERFACE_LINK_OPTIONS
# 		INTERFACE_PRECOMPILE_HEADERS
# 		INTERFACE_POSITION_INDEPENDENT_CODE
# 		INTERFACE_SOURCES
# 		INTERFACE_SYSTEM_INCLUDE_DIRECTORIES
# )
# message("=== End of debug messages ===")