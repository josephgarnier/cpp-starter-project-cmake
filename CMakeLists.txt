# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

# See /cmake/project/StandardOptions.txt for a list of options.

cmake_minimum_required(VERSION 3.16 FATAL_ERROR)

message("===============================================================")
message("    Build Lifecycle generator for \"${PARAM_PROJECT_NAME}\"    ")
message("===============================================================")
message("Global options settings:")
message(" - Project name: \"${PARAM_PROJECT_NAME}\"")
message(" - Project description: \"${PARAM_PROJECT_SUMMARY}\"")
message(" - Project author: \"${PARAM_PROJECT_VENDOR_NAME}\"")
message(" - Author contact: \"${PARAM_PROJECT_VENDOR_CONTACT}\"")
message(" - Project major version: \"${PARAM_PROJECT_VERSION_MAJOR}\"")
message(" - Project minor version: \"${PARAM_PROJECT_VERSION_MINOR}\"")
message(" - Project patch version: \"${PARAM_PROJECT_VERSION_PATCH}\"")
message(" - Build Lifecycle generator: \"${CMAKE_GENERATOR}\"")
message("Build Generator Module settings:")
message(" - Build standard version: \"${PARAM_BUILD_STANDARD_VERSION}\"")
message(" - Build type: \"${PARAM_BUILD_TYPE}\"")
message(" - Build target type: \"${PARAM_BUILD_TARGET_TYPE}\"")
message(" - Compile definitions: \"${PARAM_COMPILE_DEFINITIONS}\"")
message(" - Public headers separated: \"${PARAM_PUBLIC_HEADERS_SEPARATED}\"")
message(" - Use precompiled header: \"${PARAM_USE_PRECOMPILED_HEADER}\"")
message(" - Toolchain file used: \"${CMAKE_TOOLCHAIN_FILE}\"")
message("Test Generator Module settings:")
message(" - Enable this module: \"${PARAM_ENABLE_TEST_MODULE}\"")
message("Code Analysis Generator Module settings:")
message(" - Enable this module: \"${PARAM_ENABLE_CODE_ANALYSIS_MODULE}\"")
message("Doc Generator Module settings:")
message(" - Enable this module: \"${PARAM_ENABLE_DOC_MODULE}\"")
message("Export Generator Module settingss:")
message(" - Enable this module: \"${PARAM_ENABLE_EXPORT_MODULE}\"")
message(" - Export namespace: \"${PARAM_EXPORT_NAMESPACE}\"")
message(" - Install directory: \"${PARAM_INSTALL_DIRECTORY}\"")
message("Package Generator Module settings:")
message(" - Enable this module: \"${PARAM_ENABLE_PACKAGE_MODULE}\"")
message("Uninstall Generator Module settings:")
message(" - Enable this module: \"${PARAM_ENABLE_UNINSTALL_MODULE}\"")



#------------------------------------------------------------------------------
# 1. Initialization of the generation of the project build tree.
#------------------------------------------------------------------------------
message("")
message("")
message("== 1. Initialization of the generation of the project build tree  ==")


#---- Project declaration. ----
message(STATUS "Check the project name")
if(NOT DEFINED PARAM_PROJECT_NAME)
	message(FATAL_ERROR "PARAM_PROJECT_NAME must be specified!")
endif()
if("${PARAM_PROJECT_NAME}" MATCHES " ")
	message(FATAL_ERROR "PARAM_PROJECT_NAME cannot contain spaces!")
endif()

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

message(STATUS "Project declared with the name \"${PROJECT_NAME}\" and in the version ${${PROJECT_NAME}_VERSION}")


#---- Check project structure. ----
message(STATUS "Checking project structure")
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
set(${PROJECT_NAME}_TESTS_DIR                    "${${PROJECT_NAME}_PROJECT_DIR}/tests")

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
	"${${PROJECT_NAME}_TESTS_DIR}")

foreach(folder IN ITEMS ${${PROJECT_NAME}_PROJECT_DIRS})
	if((NOT EXISTS "${folder}") OR (NOT IS_DIRECTORY "${folder}"))
		message(FATAL_ERROR "Missing directory: \"${folder}\"!")
	endif()
endforeach()

# Build path should be in /build directory.
get_filename_component(build_directory "${${PROJECT_NAME}_BUILD_DIR}" DIRECTORY)
if((NOT "${${PROJECT_NAME}_BUILD_DIR}" STREQUAL "${${PROJECT_NAME}_PROJECT_DIR}/build")
	AND (NOT "${build_directory}" STREQUAL "${${PROJECT_NAME}_PROJECT_DIR}/build"))
	message(FATAL_ERROR "\"${${PROJECT_NAME}_BUILD_DIR}\" is not under the \"build\" directory!")
endif()

message(STATUS "Checking project structure - done")



#------------------------------------------------------------------------------
# 2. Generate the `build` and `clean` phases
#------------------------------------------------------------------------------
include(Print)
message("")
message("")
message("== 2. Execution of the Build Generator Module ==")

if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
	message(STATUS "Processor architecture is ${CMAKE_SYSTEM_PROCESSOR}")
endif()

# Set output directories.
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_STATIC_LIBRARY_PREFIX              "")
set(CMAKE_SHARED_LIBRARY_PREFIX              "")
print(STATUS "Binary will be built in: @rp@" "${${PROJECT_NAME}_BIN_DIR}")

# Set the name of the system.
set(SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_SYSTEM_PROCESSOR}")
string(TOLOWER ${SYSTEM_NAME} SYSTEM_NAME)
message(STATUS "System name set to \"${SYSTEM_NAME}\"")

# Set build standard version for all targets.
if(("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "11")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "14")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "17")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "20")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "23"))
	set(CMAKE_CXX_STANDARD "${PARAM_BUILD_STANDARD_VERSION}")
else()
	message(FATAL_ERROR "PARAM_BUILD_STANDARD_VERSION must be 11 or 14 or 17 or 20 or 23!")
endif()
message(STATUS "Standard version set to \"${CMAKE_CXX_STANDARD}\" for all targets")

# Set build type.
if(("${PARAM_BUILD_TYPE}" STREQUAL "release"))
	set(CMAKE_BUILD_TYPE "Release")
elseif("${PARAM_BUILD_TYPE}" STREQUAL "debug")
	set(CMAKE_BUILD_TYPE "Debug")
else()
	message(FATAL_ERROR "PARAM_BUILD_TYPE should be \"debug\" or \"release\"!")
endif()
message(STATUS "Targets will be build in \"${CMAKE_BUILD_TYPE}\" if a single-configuration generator is used")


#---- Add the build target. ----
message("")
set(${PROJECT_NAME}_BUILD_TARGET_IS_STATIC   off)
set(${PROJECT_NAME}_BUILD_TARGET_IS_SHARED   off)
set(${PROJECT_NAME}_BUILD_TARGET_IS_HEADER   off)
set(${PROJECT_NAME}_BUILD_TARGET_IS_EXEC     off)
if("${PARAM_BUILD_TARGET_TYPE}" STREQUAL "static")
	set(${PROJECT_NAME}_BUILD_TARGET_IS_STATIC   on)
	set(${PROJECT_NAME}_BUILD_TARGET_NAME        "lib${PROJECT_NAME}")
	message(STATUS "Add the static library target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
	add_library("${${PROJECT_NAME}_BUILD_TARGET_NAME}" STATIC)
	add_library("${${PROJECT_NAME}_BUILD_TARGET_NAME}::${${PROJECT_NAME}_BUILD_TARGET_NAME}" ALIAS "${${PROJECT_NAME}_BUILD_TARGET_NAME}")
elseif("${PARAM_BUILD_TARGET_TYPE}" STREQUAL "shared")
	set(${PROJECT_NAME}_BUILD_TARGET_IS_SHARED   on)
	set(${PROJECT_NAME}_BUILD_TARGET_NAME        "lib${PROJECT_NAME}")
	# All libraries will be built shared unless the library was explicitly added as a static library.
	set(BUILD_SHARED_LIBS on)
	message(STATUS "Add the shared library target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
	add_library("${${PROJECT_NAME}_BUILD_TARGET_NAME}" SHARED)
	add_library("${${PROJECT_NAME}_BUILD_TARGET_NAME}::${${PROJECT_NAME}_BUILD_TARGET_NAME}" ALIAS "${${PROJECT_NAME}_BUILD_TARGET_NAME}")
elseif("${PARAM_BUILD_TARGET_TYPE}" STREQUAL "header")
	set(${PROJECT_NAME}_BUILD_TARGET_IS_HEADER   on)
	set(${PROJECT_NAME}_BUILD_TARGET_NAME        "${PROJECT_NAME}")
	message(STATUS "Add the header-only library target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
	add_library("${${PROJECT_NAME}_BUILD_TARGET_NAME}" INTERFACE)
	add_library("${${PROJECT_NAME}_BUILD_TARGET_NAME}::${${PROJECT_NAME}_BUILD_TARGET_NAME}" ALIAS "${${PROJECT_NAME}_BUILD_TARGET_NAME}")
elseif("${PARAM_BUILD_TARGET_TYPE}" STREQUAL "exec")
	set(${PROJECT_NAME}_BUILD_TARGET_IS_EXEC     on)
	set(${PROJECT_NAME}_BUILD_TARGET_NAME        "${PROJECT_NAME}")
	message(STATUS "Add the executable target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
	add_executable("${${PROJECT_NAME}_BUILD_TARGET_NAME}")
	add_executable("${${PROJECT_NAME}_BUILD_TARGET_NAME}::${${PROJECT_NAME}_BUILD_TARGET_NAME}" ALIAS "${${PROJECT_NAME}_BUILD_TARGET_NAME}")
else()
	message(FATAL_ERROR "Build target type must be \"static\" or \"shared\" or \"header\" or \"exec\"!")
endif()
message(STATUS "The build target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\" is now aliased as \"${${PROJECT_NAME}_BUILD_TARGET_NAME}::${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")


#---- Add the compiler features, compile definitions and compile options to the build target. ----

# Add compiler features to the build target.
message(STATUS "Add compile features to the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
target_compile_features("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PRIVATE
		"cxx_std_${CMAKE_CXX_STANDARD}"
)

# Add compile definitions to the build target.
set(${PROJECT_NAME}_COMPILE_DEFINITIONS "${PARAM_COMPILE_DEFINITIONS}")
message(STATUS "Add compile definitions to the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
target_compile_definitions("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PRIVATE
		"${${PROJECT_NAME}_COMPILE_DEFINITIONS}"
)

# Add compile options to the build target.
message(STATUS "Add compile options to the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
target_compile_options("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PRIVATE
		""
)


#---- Add source and header files to the build target. ----
message(STATUS "Check source and header files")

include(FileManip)
include(HeadersAndSourcesOptions)

# Check source files.
if(NOT DEFINED ${PROJECT_NAME}_SOURCE_SRC_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_SOURCE_SRC_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_MAIN_SOURCE_FILE)
	message(FATAL_ERROR "${PROJECT_NAME}_MAIN_SOURCE_FILE must be specified!")
elseif((NOT ${PROJECT_NAME}_MAIN_SOURCE_FILE) OR (NOT EXISTS "${${PROJECT_NAME}_MAIN_SOURCE_FILE}"))
	message(FATAL_ERROR "Main file \"${${PROJECT_NAME}_MAIN_SOURCE_FILE}\" doesn't exists!")
endif()

message(STATUS "Found the following source files:")
print(STATUS PATHS ${${PROJECT_NAME}_SOURCE_SRC_FILES} INDENT)

# Check header files.
if(NOT DEFINED ${PROJECT_NAME}_HEADER_SRC_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_HEADER_SRC_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_HEADER_INCLUDE_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_HEADER_INCLUDE_FILES must be specified!")
endif()

# Check if `include/<project-name>` directory exists, then set public and private header variables.
if(${PARAM_PUBLIC_HEADERS_SEPARATED} AND (NOT IS_DIRECTORY "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}"))
	message(FATAL_ERROR "\"include/<project-name>\" directory is missing! Needed when \"PARAM_PUBLIC_HEADERS_SEPARATED\" is set with on")
elseif(${PARAM_PUBLIC_HEADERS_SEPARATED})
	set(${PROJECT_NAME}_HEADER_PUBLIC_DIR      "${${PROJECT_NAME}_INCLUDE_DIR}")
	set(${PROJECT_NAME}_HEADER_PUBLIC_FILES    "${${PROJECT_NAME}_HEADER_INCLUDE_FILES}")
	set(${PROJECT_NAME}_HEADER_PRIVATE_DIR     "${${PROJECT_NAME}_SRC_DIR}")
	set(${PROJECT_NAME}_HEADER_PRIVATE_FILES   "${${PROJECT_NAME}_HEADER_SRC_FILES}")
	message(STATUS "Mark the headers in \"src/\" as privates and those in \"include/\" as publics.")
else()
	set(${PROJECT_NAME}_HEADER_PUBLIC_DIR      "${${PROJECT_NAME}_SRC_DIR}")
	set(${PROJECT_NAME}_HEADER_PUBLIC_FILES    "${${PROJECT_NAME}_HEADER_SRC_FILES}")
	set(${PROJECT_NAME}_HEADER_PRIVATE_DIR     "")
	set(${PROJECT_NAME}_HEADER_PRIVATE_FILES   "")
	message(STATUS "Mark the headers in \"src/\" as public and ignore those in \"include/\".")
endif()
message(STATUS "Found the following header files:")
print(STATUS PATHS ${${PROJECT_NAME}_HEADER_PRIVATE_FILES};${${PROJECT_NAME}_HEADER_PUBLIC_FILES} INDENT)

# Add source and header files to the build target.
message(STATUS "Add the found source and header files to the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
target_sources("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PRIVATE
		"${${PROJECT_NAME}_SOURCE_SRC_FILES}"
		"${${PROJECT_NAME}_HEADER_PRIVATE_FILES}"
		"${${PROJECT_NAME}_HEADER_PUBLIC_FILES}"
)


#---- Add the precompiled header file to the build target. ----

# Check precompiled header file.
if(NOT DEFINED ${PROJECT_NAME}_PRECOMPILED_HEADER_FILE)
	message(FATAL_ERROR "${PROJECT_NAME}_PRECOMPILED_HEADER_FILE must be specified!")
endif()

# Add the precompiled header file to the build target.
message(STATUS "Check precompiled header file")
if(${PARAM_USE_PRECOMPILED_HEADER})
	if((NOT ${PROJECT_NAME}_PRECOMPILED_HEADER_FILE) OR (NOT EXISTS "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}"))
		message(FATAL_ERROR "Precompiled header file \"${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}\" doesn't exists!")
	else()
		message(STATUS "Add the following precompiled header file to the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\":")
		target_precompile_headers("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
			PRIVATE
				"${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}"
		)
		print(STATUS PATHS ${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE} INDENT)
	endif()
else()
	set(CMAKE_DISABLE_PRECOMPILE_HEADERS off)
	set(${PROJECT_NAME}_PRECOMPILED_HEADER_FILE "")
	message(STATUS "Precompiled header file set off")
endif()


#---- Add the header directories to the build target. ----

# Add header directories to incude directories of the build target.
message(STATUS "Add the following header directories to include directories of the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\":")
target_include_directories("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	# see https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-specification-and-usage-requirements
	# and https://stackoverflow.com/questions/26243169/cmake-target-include-directories-meaning-of-scope
	# and https://cmake.org/pipermail/cmake/2017-October/066457.html.
	# If PRIVATE is specified for a certain option/property, then that option/property will only impact
	# the current target. If PUBLIC is specified, then the option/property impacts both the current
	# target and any others that link to it. If INTERFACE is specified, then the option/property does
	# not impact the current target but will propagate to other targets that link to it.
	PRIVATE
		# Used only when building the target.
		"$<$<BOOL:${${PROJECT_NAME}_HEADER_PRIVATE_DIR}>:${${PROJECT_NAME}_HEADER_PRIVATE_DIR}>"
		"${${PROJECT_NAME}_HEADER_PUBLIC_DIR}"
)
print(STATUS PATHS ${${PROJECT_NAME}_HEADER_PUBLIC_DIR};${${PROJECT_NAME}_HEADER_PRIVATE_DIR} INDENT)


#---- Add dependencies to the build target. ----
message("")
message(STATUS "Check dependencies")

include(DependenciesOptions)

# Check library files and header library files.
if(NOT DEFINED ${PROJECT_NAME}_LIBRARY_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_LIBRARY_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_LIBRARY_HEADER_DIRS)
	message(FATAL_ERROR "${PROJECT_NAME}_LIBRARY_HEADER_DIRS must be specified!")
endif()
if("${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}" IN_LIST ${PROJECT_NAME}_LIBRARY_HEADER_DIRS)
	print(FATAL_ERROR "@rp@ must be excluded!" "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}")
endif()
message(STATUS "Found the following library files in \"lib/\" directory:")
print(STATUS PATHS ${${PROJECT_NAME}_LIBRARY_FILES} INDENT)
message(STATUS "Found the following library header directories in \"include/\" directory:")
print(STATUS PATHS ${${PROJECT_NAME}_LIBRARY_HEADER_DIRS} INDENT)

# Link libraries to the build target.
message(STATUS "Link libraries found to the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
target_link_libraries("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PRIVATE
		"${${PROJECT_NAME}_LIBRARY_FILES}"
)

# Add `include/` directory to incude directories of the build target.
message(STATUS "Add \"include/\" directory to include-directories of the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\"")
target_include_directories("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PRIVATE
		# Ony need to add `include/` directory when PARAM_PUBLIC_HEADERS_SEPARATED is set to off because
		# `the previous call to target_include_directories()` already add it.
		"$<$<NOT:$<BOOL:${PARAM_PUBLIC_HEADERS_SEPARATED}>>:${${PROJECT_NAME}_INCLUDE_DIR}>"
)



#------------------------------------------------------------------------------
# 3. Generate the `test` phase
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_TEST_MODULE})
	message("")
	message("")
	message("== 3. Execution of the Test Generator Module ==")
	include(TestGenModule)
endif()

#------------------------------------------------------------------------------
# 5. Generate the `doc` phase
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_DOC_MODULE})
	message("")
	message("")
	message("== 5. Execution of the Doc Generator Module ==")
	include(DocGenModule)
endif()



#------------------------------------------------------------------------------
# 6. Generate the `install` phase
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_EXPORT_MODULE})
	message("")
	message("")
	message("== 6. Execution of the Export Generator Module ==")
	include(ExportGenModule)
endif()

#------------------------------------------------------------------------------
# 8. Generate the `uninstall` phases
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_UNINSTALL_MODULE})
	message("")
	message("")
	message("== 8. Execution of the Uninstall Generator Module ==")
	include(UninstallGenModule)
endif()
message("\n===== End project ${PROJECT_NAME} building =====\n")
