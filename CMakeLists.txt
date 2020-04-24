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
# -DCMAKE_TOOLCHAIN_FILE: specifies toolchain file, see https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html
# -DCMAKE_GENERATOR: specifies CMake Generator, see https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
# -DPARAM_COMPILE_VERSION=[11|14|17 (default)|20]: specifies compiler version "11" or "14" or "17" or "20", see https://cmake.org/cmake/help/v3.1/variable/CMAKE_CXX_STANDARD.html
# -DPARAM_COMPILE_DEFINITIONS: specifies a semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty.
# -DPARAM_BUILD_TYPE=[(default) debug|release]: specifies type of build "debug" or "release"
# -DPARAM_ASSERT_ENABLE=[ON|OFF (default)]: specifies whether to use assert (optionally used in cmake/project/Dependencies.cmake)
# -DPARAM_BUILD_TARGET=[static|shared|exec (default)]: specified whether build static or shared library or as an executable
# -DPARAM_BUILD_TESTS=[ON|OFF (default)]: specifies whether build tests
# -DPARAM_BUILD_DOXYGEN_DOCS=[ON|OFF (default)]: specifies whether build documentation
# -DPARAM_EXPORT_NAMESPACE: name to prepend to the target name when it is written to the import file, see https://cmake.org/cmake/help/latest/command/install.html#export

cmake_minimum_required(VERSION 3.16)

#------------------------------------------------------------------------------
# Set parameters
#------------------------------------------------------------------------------
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
message(" - Toolchain file used: \"${CMAKE_TOOLCHAIN_FILE}\"")
message(" - Generator: \"${CMAKE_GENERATOR}\"")
message(" - Compile version: \"${PARAM_COMPILE_VERSION}\"")
message(" - Compile definitions: \"${PARAM_COMPILE_DEFINITIONS}\"")
message(" - Assert is enable: \"${PARAM_ASSERT_ENABLE}\"")
message(" - Build type: \"${PARAM_BUILD_TYPE}\"")
message(" - Build target: \"${PARAM_BUILD_TARGET}\"")
message(" - Build tests: \"${PARAM_BUILD_TESTS}\"")
message(" - Build doxygen documentation: \"${PARAM_BUILD_DOXYGEN_DOCS}\"")
message(" - Export namespace: \"${PARAM_EXPORT_NAMESPACE}\"")
message(" - Install directory: \"${PARAM_INSTALL_DIRECTORY}\"")
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

# Check build target option
if((NOT "${PARAM_BUILD_TARGET}" STREQUAL "static")
	AND (NOT "${PARAM_BUILD_TARGET}" STREQUAL "shared")
	AND (NOT "${PARAM_BUILD_TARGET}" STREQUAL "exec"))
	message(FATAL_ERROR "Compile version must be \"static\" or \"shared\" or \"exec\"!")
elseif("${PARAM_BUILD_TARGET}" STREQUAL "shared")
	# All libraries will be built shared unless the library was explicitly added as a static library
	set(BUILD_SHARED_LIBS on)
	message(STATUS "All libraries will be built as shared")
endif()

# Set CMake build-type.
if(("${PARAM_BUILD_TYPE}" STREQUAL "release"))
	set(CMAKE_BUILD_TYPE Release)
	message(STATUS "Building release version")
elseif("${PARAM_BUILD_TYPE}" STREQUAL "debug")
	set(CMAKE_BUILD_TYPE Debug)
	message(STATUS "Building debug version")
else()
	message(FATAL_ERROR "Build type should be \"debug\" or \"release\"!")
endif()

# Set compiler version flag
if(("${PARAM_COMPILE_VERSION}" STREQUAL "11")
	OR ("${PARAM_COMPILE_VERSION}" STREQUAL "14")
	OR ("${PARAM_COMPILE_VERSION}" STREQUAL "17")
	OR ("${PARAM_COMPILE_VERSION}" STREQUAL "20"))
	set(CMAKE_CXX_STANDARD "${PARAM_COMPILE_VERSION}")
	message(STATUS "Compile version set to ${CMAKE_CXX_STANDARD}")
else()
	message(FATAL_ERROR "Compile version must be 11 or 14 or 17 or 20")
endif()

#------------------------------------------------------------------------------
# Project settings
#------------------------------------------------------------------------------
message("\n== Project settings ==")
set(PROJECT_NAME                    "${PARAM_PROJECT_NAME}")
set(${PROJECT_NAME}_SUMMARY         "${PARAM_PROJECT_SUMMARY}")
set(${PROJECT_NAME}_VENDOR_NAME     "${PARAM_PROJECT_VENDOR_NAME}")
set(${PROJECT_NAME}_VENDOR_CONTACT  "${PARAM_PROJECT_VENDOR_CONTACT}")
set(${PROJECT_NAME}_VERSION_MAJOR   "${PARAM_PROJECT_VERSION_MAJOR}")
set(${PROJECT_NAME}_VERSION_MINOR   "${PARAM_PROJECT_VERSION_MINOR}")
set(${PROJECT_NAME}_VERSION_PATCH   "${PARAM_PROJECT_VERSION_PATCH}")
set(${PROJECT_NAME}_VERSION         "${${PROJECT_NAME}_VERSION_MAJOR}.${${PROJECT_NAME}_VERSION_MINOR}.${${PROJECT_NAME}_VERSION_PATCH}")
project("${PARAM_PROJECT_NAME}"
	VERSION "${${PROJECT_NAME}_VERSION}"
	DESCRIPTION "${${PROJECT_NAME}_SUMMARY}"
	HOMEPAGE_URL "${${PROJECT_NAME}_VENDOR_CONTACT}"
	LANGUAGES CXX)

message(STATUS "Set projet version with ${${PROJECT_NAME}_VERSION}")

#------------------------------------------------------------------------------
# Check project structure
#------------------------------------------------------------------------------
message("\n== Check project structure ==")
set(${PROJECT_NAME}_PROJECT_DIR                 "${CMAKE_SOURCE_DIR}")
set(${PROJECT_NAME}_ASSETS_DIR                  "${${PROJECT_NAME}_PROJECT_DIR}/assets")
set(${PROJECT_NAME}_BIN_DIR                     "${${PROJECT_NAME}_PROJECT_DIR}/bin")
set(${PROJECT_NAME}_BUILD_DIR                   "${CMAKE_BINARY_DIR}")
set(${PROJECT_NAME}_CMAKE_DIR                   "${${PROJECT_NAME}_PROJECT_DIR}/cmake")
set(${PROJECT_NAME}_CMAKE_HELPERS_DIR           "${${PROJECT_NAME}_CMAKE_DIR}/helpers")
set(${PROJECT_NAME}_CMAKE_MODULES_DIR           "${${PROJECT_NAME}_CMAKE_DIR}/modules")
set(${PROJECT_NAME}_CMAKE_PROJECT_DIR           "${${PROJECT_NAME}_CMAKE_DIR}/project")
set(${PROJECT_NAME}_CMAKE_TOOLCHAINS_DIR        "${${PROJECT_NAME}_CMAKE_DIR}/toolchains")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"
	"${${PROJECT_NAME}_CMAKE_HELPERS_DIR}"
	"${${PROJECT_NAME}_CMAKE_MODULES_DIR}"
	"${${PROJECT_NAME}_CMAKE_PROJECT_DIR}"
	"${${PROJECT_NAME}_CMAKE_TOOLCHAINS_DIR}")
set(${PROJECT_NAME}_CONFIG_DIR                  "${${PROJECT_NAME}_PROJECT_DIR}/config")
set(${PROJECT_NAME}_DOC_DIR                     "${${PROJECT_NAME}_PROJECT_DIR}/doc")
set(${PROJECT_NAME}_INCLUDE_DIR                 "${${PROJECT_NAME}_PROJECT_DIR}/include")
set(${PROJECT_NAME}_LIB_DIR                     "${${PROJECT_NAME}_PROJECT_DIR}/lib")
set(${PROJECT_NAME}_RESOURCES_DIR               "${${PROJECT_NAME}_PROJECT_DIR}/resources")
set(${PROJECT_NAME}_SRC_DIR                     "${${PROJECT_NAME}_PROJECT_DIR}/src")
set(${PROJECT_NAME}_TEST_DIR                    "${${PROJECT_NAME}_PROJECT_DIR}/tests")

list(APPEND ${PROJECT_NAME}_PROJECT_DIRS
	"${${PROJECT_NAME}_ASSETS_DIR}"
	"${${PROJECT_NAME}_BIN_DIR}"
	"${${PROJECT_NAME}_BUILD_DIR}"
	"${${PROJECT_NAME}_CMAKE_DIR}"
	"${${PROJECT_NAME}_CMAKE_HELPERS_DIR}"
	"${${PROJECT_NAME}_CMAKE_MODULES_DIR}"
	"${${PROJECT_NAME}_CMAKE_PROJECT_DIR}"
	"${${PROJECT_NAME}_CMAKE_TOOLCHAINS_DIR}"
	"${${PROJECT_NAME}_CONFIG_DIR}"
	"${${PROJECT_NAME}_DOC_DIR}"
	"${${PROJECT_NAME}_INCLUDE_DIR}"
	"${${PROJECT_NAME}_LIB_DIR}"
	"${${PROJECT_NAME}_RESOURCES_DIR}"
	"${${PROJECT_NAME}_SRC_DIR}"
	"${${PROJECT_NAME}_TEST_DIR}")

foreach(folder IN ITEMS ${${PROJECT_NAME}_PROJECT_DIRS})
	if((NOT EXISTS "${folder}") OR (NOT IS_DIRECTORY "${folder}"))
		message(FATAL_ERROR "missing directory: \"${folder}\"")
	endif()
endforeach()

# build path should be in /build directory
get_filename_component(build_directory "${${PROJECT_NAME}_BUILD_DIR}" DIRECTORY)
if((NOT "${${PROJECT_NAME}_BUILD_DIR}" STREQUAL "${${PROJECT_NAME}_PROJECT_DIR}/build")
	AND (NOT "${build_directory}" STREQUAL "${${PROJECT_NAME}_PROJECT_DIR}/build"))
	message(FATAL_ERROR "\"${${PROJECT_NAME}_BUILD_DIR}\" is not under build directory")
endif()

#------------------------------------------------------------------------------
# Set output names, output directories and global variables
#------------------------------------------------------------------------------
message("\n== Set output names and output directories ==")
include(StringManip)
if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

# Set utility variables
set(${PROJECT_NAME}_TARGET_IS_STATIC off)
set(${PROJECT_NAME}_TARGET_IS_SHARED off)
set(${PROJECT_NAME}_TARGET_IS_EXEC   off)
if("${PARAM_BUILD_TARGET}" STREQUAL "static")
	set(${PROJECT_NAME}_TARGET_IS_STATIC on)
elseif("${PARAM_BUILD_TARGET}" STREQUAL "shared")
	set(${PROJECT_NAME}_TARGET_IS_SHARED on)
elseif("${PARAM_BUILD_TARGET}" STREQUAL "exec")
	set(${PROJECT_NAME}_TARGET_IS_EXEC   on)
endif()

# Set directories and names for build
set(SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_SYSTEM_PROCESSOR}")
string(TOLOWER ${SYSTEM_NAME} SYSTEM_NAME)
if(${${PROJECT_NAME}_TARGET_IS_STATIC} OR ${${PROJECT_NAME}_TARGET_IS_SHARED})
	set(${PROJECT_NAME}_TARGET_NAME        "lib${PROJECT_NAME}")
	message(STATUS "Target library will be named \"${${PROJECT_NAME}_TARGET_NAME}\"")
else(${${PROJECT_NAME}_TARGET_IS_EXEC})
	set(${PROJECT_NAME}_TARGET_NAME        "${PROJECT_NAME}")
	message(STATUS "Target executable will be named \"${${PROJECT_NAME}_TARGET_NAME}\"")
endif()
set(${PROJECT_NAME}_TEST_NAME              "${PROJECT_NAME}_test-${${PROJECT_NAME}_VERSION}-${CMAKE_SYSTEM_NAME}")
string(TOLOWER "${${PROJECT_NAME}_TEST_NAME}" ${PROJECT_NAME}_TEST_NAME)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY         "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY         "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY         "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_STATIC_LIBRARY_PREFIX            "")
set(CMAKE_SHARED_LIBRARY_PREFIX            "")

set(${PROJECT_NAME}_COMPILE_DEFINITIONS    "${PARAM_COMPILE_DEFINITIONS}")

# Set directories and names for documentation
set(${PROJECT_NAME}_DOXYGEN_TEMPLATE_CONFIG_FILE    "${${PROJECT_NAME}_DOC_DIR}/doxyfile.in")
set(${PROJECT_NAME}_DOXYGEN_CONFIG_FILE             "${${PROJECT_NAME}_DOC_DIR}/doxyfile")

# Set directories and names for packaging and exporting commands
set(${PROJECT_NAME}_PACKAGE_NAME                    "${PROJECT_NAME}")
string_manip(TRANSFORM ${PROJECT_NAME}_PACKAGE_NAME START_CASE)
set(${PROJECT_NAME}_PACKAGE_TEMPLATE_CONFIG_FILE    "${${PROJECT_NAME}_CMAKE_PROJECT_DIR}/PackageConfig.cmake.in")
set(${PROJECT_NAME}_PACKAGE_CONFIG_FILE             "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_PACKAGE_NAME}Config.cmake")
set(${PROJECT_NAME}_PACKAGE_VERSION_FILE            "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_PACKAGE_NAME}ConfigVersion.cmake")

set(${PROJECT_NAME}_EXPORT_NAME                     "${${PROJECT_NAME}_PACKAGE_NAME}")
set(${PROJECT_NAME}_EXPORT_NAMESPACE                "${PARAM_EXPORT_NAMESPACE}")
set(${PROJECT_NAME}_EXPORT_TARGET_FILE_NAME         "${${PROJECT_NAME}_EXPORT_NAME}Targets.cmake")
set(${PROJECT_NAME}_EXPORT_TARGET_FILE              "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_TARGET_FILE_NAME}")

# Set directories and names for install/uninstall commands
if(DEFINED PARAM_INSTALL_DIRECTORY AND IS_DIRECTORY "${PARAM_INSTALL_DIRECTORY}")
	set(CMAKE_INSTALL_PREFIX "${PARAM_INSTALL_DIRECTORY}")
	message(STATUS "Set the install directory to \"${CMAKE_INSTALL_PREFIX}\"")
endif()
include(GNUInstallDirs)
set(${PROJECT_NAME}_INSTALL_RUNTIME_DIR             "${CMAKE_INSTALL_FULL_BINDIR}")
set(${PROJECT_NAME}_INSTALL_LIBRARY_DIR             "${CMAKE_INSTALL_FULL_LIBDIR}/${PROJECT_NAME}")
set(${PROJECT_NAME}_INSTALL_ARCHIVE_DIR             "${CMAKE_INSTALL_FULL_LIBDIR}/${PROJECT_NAME}")
set(${PROJECT_NAME}_INSTALL_INCLUDE_DIR             "${CMAKE_INSTALL_FULL_INCLUDEDIR}/${PROJECT_NAME}")
set(${PROJECT_NAME}_INSTALL_CMAKE_DIR               "${CMAKE_INSTALL_FULL_LIBDIR}/${PROJECT_NAME}/cmake")

set(${PROJECT_NAME}_UNINSTALL_TEMPLATE_CONFIG_FILE  "${${PROJECT_NAME}_CMAKE_HELPERS_DIR}/Uninstall.cmake.in")
set(${PROJECT_NAME}_UNINSTALL_CONFIG_FILE           "${${PROJECT_NAME}_BUILD_DIR}/Uninstall.cmake")

# Set directories and names for package installers
set(${PROJECT_NAME}_CPACK_CONFIG_FILE               "${${PROJECT_NAME}_BUILD_DIR}/CPackConfig.cmake")
set(${PROJECT_NAME}_CPACK_SOURCE_CONFIG_FILE        "${${PROJECT_NAME}_BUILD_DIR}/CPackSourceConfig.cmake")
set(${PROJECT_NAME}_CPACK_TEMPLATE_OPTIONS_FILE     "${${PROJECT_NAME}_CMAKE_PROJECT_DIR}/CPackInstallerOptions.cmake.in")
set(${PROJECT_NAME}_CPACK_OPTIONS_FILE              "${${PROJECT_NAME}_BUILD_DIR}/CMakeCPackOptions.cmake")

#------------------------------------------------------------------------------
# Build project
#------------------------------------------------------------------------------
message("\n== Build project ==")
include(Cotire)
include(ProjectSrcFiles)
include(FileManip)
if(NOT DEFINED ${PROJECT_NAME}_PRECOMPILED_HEADER_FILE)
	message(FATAL_ERROR "${PROJECT_NAME}_PRECOMPILED_HEADER_FILE must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_PRECOMPILED_SOURCE_FILE)
	message(FATAL_ERROR "${PROJECT_NAME}_PRECOMPILED_SOURCE_FILE must be specified!")
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
if(NOT DEFINED ${PROJECT_NAME}_PUBLIC_HEADER_DIRS)
	message(FATAL_ERROR "${PROJECT_NAME}_PUBLIC_HEADER_DIRS must be specified!")
endif()

set(${PROJECT_NAME}_RELATIVE_SRC_ALL_FILES "")
file_manip(RELATIVE_PATH ${PROJECT_NAME}_SRC_ALL_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE ${PROJECT_NAME}_RELATIVE_SRC_ALL_FILES)

# Build as library or as executable
if(${${PROJECT_NAME}_TARGET_IS_STATIC})
	# Build static library
	message("")
	message(STATUS "Build as a static library")
	add_library("${${PROJECT_NAME}_TARGET_NAME}" STATIC)
elseif(${${PROJECT_NAME}_TARGET_IS_SHARED})
	# Build shared library
	message("")
	message(STATUS "Build as a shared library")
	add_library("${${PROJECT_NAME}_TARGET_NAME}" SHARED)
elseif(${${PROJECT_NAME}_TARGET_IS_EXEC})
	# Build executable
	message("")
	message(STATUS "Build as an executable")
	add_executable("${${PROJECT_NAME}_TARGET_NAME}")
endif()

# Add sources to target
message(STATUS "Add sources to target")
target_sources("${${PROJECT_NAME}_TARGET_NAME}"
	PRIVATE
		"${${PROJECT_NAME}_RELATIVE_SRC_ALL_FILES}"
)

# Add precompiled header to target
if(${PROJECT_NAME}_PRECOMPILED_HEADER_FILE)
	message(STATUS "Add precompiled header to target")
	set_target_properties("${${PROJECT_NAME}_TARGET_NAME}" PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
else()
	message(STATUS "Precompiled header disabled for target")
	set_target_properties("${${PROJECT_NAME}_TARGET_NAME}" PROPERTIES COTIRE_ENABLE_PRECOMPILED_HEADER FALSE)
endif()

# Set compiler version to target
message(STATUS "Set compiler version to target")
target_compile_features("${${PROJECT_NAME}_TARGET_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:cxx_std_${CMAKE_CXX_STANDARD}>"
		"$<INSTALL_INTERFACE:cxx_std_${CMAKE_CXX_STANDARD}>"
	PRIVATE
		"cxx_std_${CMAKE_CXX_STANDARD}"
)

# Add incude directories to target
message(STATUS "Add include directories to target")
target_include_directories("${${PROJECT_NAME}_TARGET_NAME}"
	# see https://cmake.org/cmake/help/v3.0/manual/cmake-buildsystem.7.html#build-specification-and-usage-requirements
	# and https://stackoverflow.com/questions/26243169/cmake-target-include-directories-meaning-of-scope
	# and https://cmake.org/pipermail/cmake/2017-October/066457.html
	PUBLIC
		# Used when the property is exported using export(), or when the target is used by another target in the same buildsystem
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_INCLUDE_DIR}>"
		# Used when installing using install(EXPORT)
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}>"
	PRIVATE
		# Used only when building the target
		"${${PROJECT_NAME}_SRC_DIR}"
)

# Add compile definitions to target
message(STATUS "Add compile definitions to target")
target_compile_definitions("${${PROJECT_NAME}_TARGET_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
	PRIVATE
		"${${PROJECT_NAME}_COMPILE_DEFINITIONS}"
)

#------------------------------------------------------------------------------
# Add project dependencies
#------------------------------------------------------------------------------
message("\n== Add project dependencies ==")
include(Dependencies)
if(NOT DEFINED ${PROJECT_NAME}_LIBRARIES_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_LIBRARIES_FILES must be specified!")
endif()

set(${PROJECT_NAME}_INSTALL_LIBRARIES_FILES "")
list(LENGTH ${PROJECT_NAME}_LIBRARIES_FILES nb_files)
if(NOT nb_files EQUAL 0)
	file_manip(GET_COMPONENT ${${PROJECT_NAME}_LIBRARIES_FILES}
		MODE NAME
		OUTPUT_VARIABLE ${PROJECT_NAME}_INSTALL_LIBRARIES_FILES
	)
	file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_LIBRARIES_FILES
		BASE_DIR "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
	)
endif()

# Link externals libraries to target
message(STATUS "Link externals libraries to project target")
target_link_libraries("${${PROJECT_NAME}_TARGET_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_LIBRARIES_FILES}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_LIBRARIES_FILES}>"
	PRIVATE
		"${${PROJECT_NAME}_LIBRARIES_FILES}"
)

#------------------------------------------------------------------------------
# Speeds up the build process with Cotire
#------------------------------------------------------------------------------
message("\n== Speed up the build process with Cotire ==")
cotire("${${PROJECT_NAME}_TARGET_NAME}")

#------------------------------------------------------------------------------
# Build documentation
#------------------------------------------------------------------------------
if(${PARAM_BUILD_DOXYGEN_DOCS})
	message("\n== Build documentation ==")
	find_package(Doxygen REQUIRED)
	if(NOT DOXYGEN_FOUND)
		message(FATAL_ERROR "Doxygen is needed to build the documentation. Please make sure it is installed.")
	endif()

	configure_file(
		"${${PROJECT_NAME}_DOXYGEN_TEMPLATE_CONFIG_FILE}"
		"${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}"
		@ONLY
	)
	if(EXISTS "${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}")
		file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}")
		message(STATUS "Doxygen config file generated into \"${relative_path}\"")
	else()
		message(FATAL_ERROR "Doxygen config file can't be generate")
	endif()

	# Add `make docs` command
	add_custom_target(docs ALL
		COMMAND ${DOXYGEN_EXECUTABLE} "${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}"
		SOURCES "${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}"
		WORKING_DIRECTORY "${${PROJECT_NAME}_DOC_DIR}"
		COMMENT "Generating API documentation with Doxygen"
		VERBATIM
	)
	
	# Add the generated documentation files to `make clean` command
	set_property(DIRECTORY "${${PROJECT_NAME}_PROJECT_DIR}"
		APPEND
		PROPERTY ADDITIONAL_CLEAN_FILES
		"${${PROJECT_NAME}_DOC_DIR}/html"
		"${${PROJECT_NAME}_DOC_DIR}/latex"
		"${${PROJECT_NAME}_DOC_DIR}/doxyfile"
	)
endif()

#------------------------------------------------------------------------------
# Build tests
#------------------------------------------------------------------------------
if(${PARAM_BUILD_TESTS})
	message("\n== Build tests ==")
	include(CTest)
	add_test(NAME "${${PROJECT_NAME}_TEST_NAME}"
		WORKING_DIRECTORY "${${PROJECT_NAME}_TEST_DIR}"
		COMMAND "${${PROJECT_NAME}_TEST_DIR}/${${PROJECT_NAME}_TEST_NAME}")
endif()

#------------------------------------------------------------------------------
# Generate files for packaging and exporting
#------------------------------------------------------------------------------
message("\n== Generates files for packaging and exporting ==")
include(CMakePackageConfigHelpers)

# Generate a package config-file)
set(LOCAL_TARGET_NAME                  "${${PROJECT_NAME}_TARGET_NAME}")
set(LOCAL_EXPORT_TARGET_FILE_NAME      "${${PROJECT_NAME}_EXPORT_TARGET_FILE_NAME}")
set(LOCAL_PACKAGE_NAME                 "${${PROJECT_NAME}_PACKAGE_NAME}")
configure_package_config_file(
	"${${PROJECT_NAME}_PACKAGE_TEMPLATE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}"
	INSTALL_DESTINATION "${${PROJECT_NAME}_INSTALL_CMAKE_DIR}"
	INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}"
)
unset(LOCAL_TARGET_NAME)
unset(LOCAL_EXPORT_TARGET_FILE_NAME)
unset(LOCAL_PACKAGE_NAME)
if(EXISTS "${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}")
	file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}")
	message(STATUS "Package config-file generated into \"${relative_path}\"")
else()
	message(FATAL_ERROR "Package config-file can't be generate")
endif()

# Generate a package version-file
write_basic_package_version_file(
	"${${PROJECT_NAME}_PACKAGE_VERSION_FILE}"
	VERSION "${${PROJECT_NAME}_VERSION}"
	COMPATIBILITY AnyNewerVersion
)
if(EXISTS "${${PROJECT_NAME}_PACKAGE_VERSION_FILE}")
	file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_PACKAGE_VERSION_FILE}")
	message(STATUS "Package version-file generated into \"${relative_path}\"")
else()
	message(FATAL_ERROR "Package version-file can't be generate")
endif()

# Generate the target file for exporting the library from the build tree (warning: it should never be installed).
# See: https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets
export(TARGETS "${${PROJECT_NAME}_TARGET_NAME}"
	FILE "${${PROJECT_NAME}_EXPORT_TARGET_FILE}"
	NAMESPACE "${${PROJECT_NAME}_EXPORT_NAMESPACE}::"
)
export(PACKAGE "${${PROJECT_NAME}_PACKAGE_NAME}")
file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_EXPORT_TARGET_FILE}")
message(STATUS "Export target file for the project library generated into \"${relative_path}\"")

#------------------------------------------------------------------------------
# Make install/uninstall rules and exporting
#------------------------------------------------------------------------------
message("\n== Generates make install/uninstall rules ==")

# Rename export name of target
set_target_properties ("${${PROJECT_NAME}_TARGET_NAME}" PROPERTIES EXPORT_NAME "${${PROJECT_NAME}_EXPORT_NAME}")

# Install the target and defined an export group
install(TARGETS "${${PROJECT_NAME}_TARGET_NAME}"
	EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	ARCHIVE DESTINATION "${${PROJECT_NAME}_INSTALL_ARCHIVE_DIR}"
	LIBRARY DESTINATION "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
	RUNTIME DESTINATION "${${PROJECT_NAME}_INSTALL_RUNTIME_DIR}"
)

# Install public header files in include directory
foreach(directory IN ITEMS ${${PROJECT_NAME}_PUBLIC_HEADER_DIRS})
	install(DIRECTORY "${directory}/"
		DESTINATION "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}"
		FILES_MATCHING REGEX ".*[.]h$"
	)
endforeach()

# Install externals libraries in lib directory
install(FILES ${${PROJECT_NAME}_LIBRARIES_FILES}
	DESTINATION "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
)

# Install the config-file and the config-version-file in cmake directory
install(FILES
	"${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_VERSION_FILE}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_CMAKE_DIR}"
)

# Generate a target file for exporting from the install tree and install it
install(EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	NAMESPACE "${${PROJECT_NAME}_EXPORT_NAMESPACE}::"
	DESTINATION "${${PROJECT_NAME}_INSTALL_CMAKE_DIR}"
	FILE "${${PROJECT_NAME}_EXPORT_TARGET_FILE_NAME}"
)

if(NOT TARGET uninstall)
	# Add uninstall rules
	set(LOCAL_BUILD_DIR "${${PROJECT_NAME}_BUILD_DIR}")
	set(LOCAL_INSTALL_INCLUDE_DIR "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}")
	set(LOCAL_INSTALL_LIBRARY_DIR "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}")
	configure_file(
		"${${PROJECT_NAME}_UNINSTALL_TEMPLATE_CONFIG_FILE}"
		"${${PROJECT_NAME}_UNINSTALL_CONFIG_FILE}"
		@ONLY
	)
	unset(LOCAL_BUILD_DIR)
	unset(LOCAL_INSTALL_INCLUDE_DIR)
	unset(LOCAL_INSTALL_LIBRARY_DIR)

	# Add `make uninstall` command
	add_custom_target(uninstall
		COMMAND ${CMAKE_COMMAND} -P "${${PROJECT_NAME}_UNINSTALL_CONFIG_FILE}"
	)

	# Add uninstall target in a folder for IDE project generation
	get_cmake_property(target_folder PREDEFINED_TARGETS_FOLDER)
	set_target_properties(uninstall PROPERTIES FOLDER "${target_folder}")
endif()

#------------------------------------------------------------------------------
# Generate binary and source package installers
#------------------------------------------------------------------------------
message("\n== Generate binary and source package installers ==")
include(CPackInstallerConfig)

# Add the generated installers files to `make clean` command
set_property(DIRECTORY "${${PROJECT_NAME}_PROJECT_DIR}"
	APPEND
	PROPERTY ADDITIONAL_CLEAN_FILES
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.zip"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_SOURCE_PACKAGE_FILE_NAME}.zip"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.exe"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_SOURCE_PACKAGE_FILE_NAME}.exe"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.nsi"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_SOURCE_PACKAGE_FILE_NAME}.nsi"
)

# Fill the generator config file loaded at the beginning of cpack time
configure_file(
	"${${PROJECT_NAME}_CPACK_TEMPLATE_OPTIONS_FILE}"
	"${${PROJECT_NAME}_CPACK_OPTIONS_FILE}"
	@ONLY
)
set(CPACK_PROJECT_CONFIG_FILE "${${PROJECT_NAME}_CPACK_OPTIONS_FILE}")

# Generate installers
include(CPack)
if(EXISTS "${${PROJECT_NAME}_CPACK_CONFIG_FILE}")
	file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_CPACK_CONFIG_FILE}")
	message(STATUS "Binary package installer config file generated into \"${relative_path}\"")
else()
	message(FATAL_ERROR "Binary package installer config file can't be generate")
endif()
if(EXISTS "${${PROJECT_NAME}_CPACK_SOURCE_CONFIG_FILE}")
	file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_CPACK_SOURCE_CONFIG_FILE}")
	message(STATUS "Source package installer config file generated into \"${relative_path}\"")
else()
	message(FATAL_ERROR "Source package installer config file can't be generate")
endif()

#------------------------------------------------------------------------------
# Customize the solution explorer structure for IDE project generation
#------------------------------------------------------------------------------
message("\n== Customize the solution explorer structure for IDE project generation ==")

# Get content of of SOURCES property
get_target_property(sources_target_property "${${PROJECT_NAME}_TARGET_NAME}" SOURCES)

# Get content of BUILD_INTERFACE generator expression of SOURCES property
string(REGEX MATCHALL "\\$<BUILD_INTERFACE\\:[^\\>]*" build_interface_sources_target_property "${sources_target_property}")
string(REPLACE "$<BUILD_INTERFACE:" "" build_interface_sources_target_property "${build_interface_sources_target_property}")

# Get content of INSTALL_INTERFACE generator expression of SOURCES property
string(REGEX MATCHALL "\\$<INSTALL_INTERFACE\\:[^\\>]*" install_interface_sources_target_property "${sources_target_property}")
string(REPLACE "$<INSTALL_INTERFACE:" "" install_interface_sources_target_property "${install_interface_sources_target_property}")

# Get content of private SOURCE property
string(REGEX MATCH "^[^\\$]*" private_sources_target_property "${sources_target_property}")

# Concatenate previous lists, remove duplicated items and group them
set(sources_target_property "${private_sources_target_property}")
list(APPEND sources_target_property ${build_interface_sources_target_property})
list(APPEND sources_target_property ${install_interface_sources_target_property})
list(REMOVE_DUPLICATES sources_target_property)
source_group(TREE "${${PROJECT_NAME}_PROJECT_DIR}" FILES ${sources_target_property})

# Group other source files
set(project_all_files "")
directory(SCAN project_all_files
	LIST_DIRECTORIES off
	RELATIVE on
	ROOT_DIR "${${PROJECT_NAME}_PROJECT_DIR}"
	EXCLUDE_REGEX "build|.git|.vscode"
)
list(REMOVE_ITEM project_all_files ${sources_target_property})
target_sources("${${PROJECT_NAME}_TARGET_NAME}"
	PRIVATE
		"${project_all_files}"
)
source_group(TREE "${${PROJECT_NAME}_PROJECT_DIR}" FILES ${project_all_files})

message("\n===== End project ${PROJECT_NAME} building =====\n")
