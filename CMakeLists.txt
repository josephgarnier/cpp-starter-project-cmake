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

cmake_minimum_required(VERSION 3.16)

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
set(COMPILE_DEFINITIONS_DESC    "Specifies a semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty.")
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
set(PARAM_COMPILE_DEFINITIONS   ""                  CACHE   STRING  "${COMPILE_DEFINITIONS_DESC}")
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
message(" - Compile definitions: \"${PARAM_COMPILE_DEFINITIONS}\"")
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
if(NOT ("${build_directory}" STREQUAL "${${PROJECT_NAME}_PROJECT_DIR}/build"))
	message(FATAL_ERROR "\"${${PROJECT_NAME}_BUILD_DIR}\" is not under build directory")
endif()

#------------------------------------------------------------------------------
# Set output names and output directories
#------------------------------------------------------------------------------
message("\n== Set output names and output directories ==")
include(StringManip)
if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()

# Set build directories and names
set(SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_SYSTEM_PROCESSOR}")
string(TOLOWER ${SYSTEM_NAME} SYSTEM_NAME)
set(${PROJECT_NAME}_LIB_NAME               "lib${PROJECT_NAME}")
set(${PROJECT_NAME}_EXEC_NAME              "${PROJECT_NAME}")
set(${PROJECT_NAME}_TEST_NAME              "${PROJECT_NAME}_test-${${PROJECT_NAME}_VERSION}-${CMAKE_SYSTEM_NAME}")
string(TOLOWER "${${PROJECT_NAME}_TEST_NAME}" ${PROJECT_NAME}_TEST_NAME)

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY         "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY         "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY         "${${PROJECT_NAME}_BIN_DIR}")
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

set(${PROJECT_NAME}_EXPORT_NAME                     "${PROJECT_NAME}-targets")
set(${PROJECT_NAME}_EXPORT_TARGET_FILE_NAME         "${${PROJECT_NAME}_PACKAGE_NAME}Target.cmake")
set(${PROJECT_NAME}_EXPORT_TARGET_FILE              "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_TARGET_FILE_NAME}")

# Set directories relative to CMAKE_INSTALL_PREFIX and names for install/uninstall commands
include(GNUInstallDirs)
set(${PROJECT_NAME}_INSTALL_RUNTIME_DIR             "${CMAKE_INSTALL_BINDIR}")
set(${PROJECT_NAME}_INSTALL_LIBRARY_DIR             "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}")
set(${PROJECT_NAME}_INSTALL_ARCHIVE_DIR             "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}")
set(${PROJECT_NAME}_INSTALL_INCLUDE_DIR             "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}")
set(${PROJECT_NAME}_INSTALL_CMAKE_DIR               "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}/cmake")

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
if(NOT DEFINED ${PROJECT_NAME}_PUBLIC_HEADER_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_PUBLIC_HEADER_FILES must be specified!")
endif()

# Build library
if(${BUILD_SHARED_LIBS})
	message("")
	message(STATUS "Build as a shared library")
	add_library("${${PROJECT_NAME}_LIB_NAME}" SHARED ${${PROJECT_NAME}_SRC_ALL_FILES})
else()
	message("")
	message(STATUS "Build as a static library")
	add_library("${${PROJECT_NAME}_LIB_NAME}" STATIC ${${PROJECT_NAME}_SRC_ALL_FILES})
endif()

# Add precompiled header to library
if(${PROJECT_NAME}_PRECOMPILED_HEADER_FILE)
	message(STATUS "Add precompiled header to library")
	set_target_properties("${${PROJECT_NAME}_LIB_NAME}" PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
else()
	message(STATUS "Precompiled header disabled for library")
	set_target_properties("${${PROJECT_NAME}_LIB_NAME}" PROPERTIES COTIRE_ENABLE_PRECOMPILED_HEADER FALSE)
endif()

# Set compiler version to library
message(STATUS "Set compiler version to library")
target_compile_features("${${PROJECT_NAME}_LIB_NAME}" PUBLIC "cxx_std_${CMAKE_CXX_STANDARD}")

# Add incude directories to library
message(STATUS "Add include directories to library")
target_include_directories("${${PROJECT_NAME}_LIB_NAME}"
	PUBLIC
		# Used when building the library
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_INCLUDE_DIR}>"
		# Used when installing the library
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}>"
	PRIVATE
		# Used only when building the library
		"${${PROJECT_NAME}_SRC_DIR}"
)

# Add compile definitions to library
message(STATUS "Add compile definitions to library")
target_compile_definitions("${${PROJECT_NAME}_LIB_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
)

if(${PARAM_BUILD_EXEC})
	# Build executable
	message("")
	message(STATUS "Build executable")
	add_executable("${${PROJECT_NAME}_EXEC_NAME}" ${${PROJECT_NAME}_SRC_ALL_FILES})

	# Add precompiled header to executable
	if(${PROJECT_NAME}_PRECOMPILED_HEADER_FILE)
		message(STATUS "Add precompiled header to executable")
		set_target_properties("${${PROJECT_NAME}_EXEC_NAME}" PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
	else()
		message(STATUS "Precompiled header disabled for executable")
		set_target_properties("${${PROJECT_NAME}_EXEC_NAME}" PROPERTIES COTIRE_ENABLE_PRECOMPILED_HEADER FALSE)
	endif()
	
	# Set compiler version to executable
	message(STATUS "Set compiler version to executable")
	target_compile_features("${${PROJECT_NAME}_EXEC_NAME}" PUBLIC "cxx_std_${CMAKE_CXX_STANDARD}")
	
	# Add incude directories to executable
	message(STATUS "Add include directories to executable")
	target_include_directories("${${PROJECT_NAME}_EXEC_NAME}"
		PUBLIC
			# Used when building the executable
			"$<BUILD_INTERFACE:${${PROJECT_NAME}_INCLUDE_DIR}>"
			# Used when installing the executable
			"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}>"
		PRIVATE
			# Used only when building the library
			"${${PROJECT_NAME}_SRC_DIR}"
	)
	
	# Add compile definitions to library
	message(STATUS "Add compile definitions to executable")
	target_compile_definitions("${${PROJECT_NAME}_EXEC_NAME}"
		PUBLIC
			"$<BUILD_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
			"$<INSTALL_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
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
message("\n== Speed up the build process with Cotire ==")
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

# Generate a package config-file
set(LOCAL_INSTALL_LIBRARY_DIR "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}")
set(LOCAL_INSTALL_INCLUDE_DIR "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}")
configure_package_config_file(
	"${${PROJECT_NAME}_PACKAGE_TEMPLATE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}"
	INSTALL_DESTINATION "${PROJECT_NAME}_INSTALL_CMAKE_DIR"
	PATH_VARS LOCAL_INSTALL_LIBRARY_DIR LOCAL_INSTALL_INCLUDE_DIR
)
unset(LOCAL_INSTALL_LIBRARY_DIR)
unset(LOCAL_INSTALL_INCLUDE_DIR)
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
export(TARGETS "${${PROJECT_NAME}_LIB_NAME}"
	FILE "${${PROJECT_NAME}_EXPORT_TARGET_FILE}"
	NAMESPACE ""
)
export(PACKAGE "${${PROJECT_NAME}_PACKAGE_NAME}")
file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_EXPORT_TARGET_FILE}")
message(STATUS "Export target file for the project library generated into \"${relative_path}\"")

#------------------------------------------------------------------------------
# Make install/uninstall rules and exporting
#------------------------------------------------------------------------------
message("\n== Generates make install/uninstall rules ==")

# Install the library and defined an export group
install(TARGETS "${${PROJECT_NAME}_LIB_NAME}"
	EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	LIBRARY DESTINATION "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
	ARCHIVE DESTINATION "${${PROJECT_NAME}_INSTALL_ARCHIVE_DIR}"
)

if(${PARAM_BUILD_EXEC})
	# Install the executable
	install(TARGETS "${${PROJECT_NAME}_EXEC_NAME}"
		RUNTIME DESTINATION "${${PROJECT_NAME}_INSTALL_RUNTIME_DIR}"
	)
endif()

# Install public header files in include directory
install(FILES ${${PROJECT_NAME}_PUBLIC_HEADER_FILES}
	DESTINATION "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}"
)

# Install the config-file and the config-version-file in cmake directory
install(FILES
	"${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_VERSION_FILE}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_CMAKE_DIR}"
)

# Generate a target file for exporting from the install tree and install it
install(EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	NAMESPACE ""
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

	# Add uninstall target in a folder
	get_property(target_folder GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER)
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

message("\n===== End project ${PROJECT_NAME} building =====\n")