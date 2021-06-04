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

cmake_minimum_required(VERSION 3.20 FATAL_ERROR)

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
message("Base Generator Module settings:")
message(" - Build standard version: \"${PARAM_BUILD_STANDARD_VERSION}\"")
message(" - Build type: \"${PARAM_BUILD_TYPE}\"")
message(" - Main binary build target type: \"${PARAM_MAIN_BINARY_TARGET_TYPE}\"")
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



#------------------------------------------------------------------------------
# 1. Initialization of the generation of the project build-tree.
#------------------------------------------------------------------------------
message("")
message("")
message("== 1. Initialization of the generation of the project build-tree  ==")


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
set(${PROJECT_NAME}_PROJECT_DIR                 "${CMAKE_CURRENT_SOURCE_DIR}")
set(${PROJECT_NAME}_ASSETS_DIR                  "${${PROJECT_NAME}_PROJECT_DIR}/assets")
set(${PROJECT_NAME}_BIN_DIR                     "${${PROJECT_NAME}_PROJECT_DIR}/bin")
set(${PROJECT_NAME}_BUILD_DIR                   "${CMAKE_CURRENT_BINARY_DIR}")
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

# Build path must be in the `build/` directory.
if(NOT "${${PROJECT_NAME}_BUILD_DIR}" STREQUAL "${${PROJECT_NAME}_PROJECT_DIR}/build")
	message(FATAL_ERROR "The build directory \"${${PROJECT_NAME}_BUILD_DIR}\" is not under the project directory!")
endif()

message(STATUS "Source-tree directory is set to \"${${PROJECT_NAME}_PROJECT_DIR}\"")
message(STATUS "Build-tree directory is set to \"${${PROJECT_NAME}_BUILD_DIR}\"")
message(STATUS "Checking project structure - done")



#------------------------------------------------------------------------------
# 2. The Base Generator Module
#------------------------------------------------------------------------------
include(Print)
message("")
message("")
message("== 2. Execution of the Base Generator Module ==")

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
print(STATUS "Binary will be built in: @rp@" "${${PROJECT_NAME}_BIN_DIR}")

# Set the name of the system.
set(SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_SYSTEM_PROCESSOR}")
string(TOLOWER ${SYSTEM_NAME} SYSTEM_NAME)
message(STATUS "System name set to \"${SYSTEM_NAME}\"")

# Set the standard version for building binary targets.
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

# Set type of configuration for the build-tree.
if(("${PARAM_BUILD_TYPE}" STREQUAL "release"))
	set(CMAKE_BUILD_TYPE "RELEASE")
elseif("${PARAM_BUILD_TYPE}" STREQUAL "debug")
	set(CMAKE_BUILD_TYPE "DEBUG")
else()
	message(FATAL_ERROR "PARAM_BUILD_TYPE should be \"debug\" or \"release\"!")
endif()
message(STATUS "Targets will be build in \"${CMAKE_BUILD_TYPE}\" if a single-configuration generator is used")

# Defines the organization of the targets into directories for IDE project.
message(STATUS "Defines the organization of targets into directories.")
set(CMAKE_FOLDER "PredefinedTargets")
set_property(GLOBAL PROPERTY USE_FOLDERS on)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "${CMAKE_FOLDER}")


#---- Add the main binary build target. ----
message("")
set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_STATIC   off)
set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_SHARED   off)
set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_HEADER   off)
set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_EXEC     off)
if("${PARAM_MAIN_BINARY_TARGET_TYPE}" STREQUAL "static")
	set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_STATIC   on)
	set(${PROJECT_NAME}_MAIN_BIN_TARGET             "${PROJECT_NAME}")
	message(STATUS "Add the main static library build target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
	add_library("${${PROJECT_NAME}_MAIN_BIN_TARGET}" STATIC)
elseif("${PARAM_MAIN_BINARY_TARGET_TYPE}" STREQUAL "shared")
	set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_SHARED   on)
	set(${PROJECT_NAME}_MAIN_BIN_TARGET             "${PROJECT_NAME}")
	# All libraries will be built shared unless the library was explicitly added as a static library.
	set(BUILD_SHARED_LIBS                           on)
	message(STATUS "Hide all exported symbols by default")
	set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS            off)
	set(CMAKE_CXX_VISIBILITY_PRESET                 "hidden")
	set(CMAKE_VISIBILITY_INLINES_HIDDEN             on)
	message(STATUS "Add the main shared library build target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
	add_library("${${PROJECT_NAME}_MAIN_BIN_TARGET}" SHARED)
elseif("${PARAM_MAIN_BINARY_TARGET_TYPE}" STREQUAL "header")
	set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_HEADER   on)
	set(${PROJECT_NAME}_MAIN_BIN_TARGET             "${PROJECT_NAME}")
	message(STATUS "Add the main header-only library build target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
	add_library("${${PROJECT_NAME}_MAIN_BIN_TARGET}" INTERFACE)
elseif("${PARAM_MAIN_BINARY_TARGET_TYPE}" STREQUAL "exec")
	set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_EXEC     on)
	set(${PROJECT_NAME}_MAIN_BIN_TARGET             "${PROJECT_NAME}")
	message(STATUS "Add the main executable build target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
	add_executable("${${PROJECT_NAME}_MAIN_BIN_TARGET}")
else()
	message(FATAL_ERROR "A binary build target type must be \"static\" or \"shared\" or \"header\" or \"exec\"!")
endif()

# Add the main binary build target in a folder for IDE project.
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES FOLDER "")


#---- Add the compiler features, compile definitions and compile options to the main binary build target. ----
# Add compiler features to the main binary build target.
message(STATUS "Add compile features to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_compile_features("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"cxx_std_${CMAKE_CXX_STANDARD}"
)

# Add compile definitions to the main binary build target.
set(${PROJECT_NAME}_COMPILE_DEFINITIONS "${PARAM_COMPILE_DEFINITIONS}")
message(STATUS "Add compile definitions to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_COMPILE_DEFINITIONS}"
)

# Add compile options to the main binary build target.
message(STATUS "Add compile options to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_compile_options("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		""
)

# Add link options to the main binary build target.
message(STATUS "Add link options to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_options("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		""
)


#---- Add source and header files to the main binary build target. ----
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
print(STATUS PATHS "${${PROJECT_NAME}_SOURCE_SRC_FILES}" INDENT)

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
	set(${PROJECT_NAME}_HEADER_PUBLIC_DIR      "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}")
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
print(STATUS PATHS "${${PROJECT_NAME}_HEADER_PRIVATE_FILES}" "${${PROJECT_NAME}_HEADER_PUBLIC_FILES}" INDENT)

# Add source and header files to the main binary build target.
message(STATUS "Add the found source and header files to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_sources("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_SOURCE_SRC_FILES}"
		"${${PROJECT_NAME}_HEADER_PRIVATE_FILES}"
		"${${PROJECT_NAME}_HEADER_PUBLIC_FILES}"
)
source_group(TREE "${${PROJECT_NAME}_PROJECT_DIR}"
	FILES
		${${PROJECT_NAME}_SOURCE_SRC_FILES}
		${${PROJECT_NAME}_HEADER_PRIVATE_FILES}
		${${PROJECT_NAME}_HEADER_PUBLIC_FILES}
)


#---- Add the precompiled header file to the main binary build target. ----
# Check precompiled header file.
if(NOT DEFINED ${PROJECT_NAME}_PRECOMPILED_HEADER_FILE)
	message(FATAL_ERROR "${PROJECT_NAME}_PRECOMPILED_HEADER_FILE must be specified!")
endif()

# Add the precompiled header file to the main binary build target.
message(STATUS "Check precompiled header file")
if(${PARAM_USE_PRECOMPILED_HEADER})
	if((NOT ${PROJECT_NAME}_PRECOMPILED_HEADER_FILE) OR (NOT EXISTS "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}"))
		message(FATAL_ERROR "Precompiled header file \"${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}\" doesn't exists!")
	elseif(NOT "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}" MATCHES "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}")
		print(FATAL_ERROR "Precompiled header file \"@rp@\" is not in the header public directory!" "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
	else()
		print(STATUS "Add the precompiled header file \"@rp@\" to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\":" "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
		target_precompile_headers("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
			PRIVATE
				"${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}"
		)
	endif()
else()
	set(CMAKE_DISABLE_PRECOMPILE_HEADERS off)
	message(STATUS "Precompiled header file set off")
endif()


#---- Add the header directories to the main binary build target. ----
# Add header directories to incude directories of the main binary build target.
message(STATUS "Add the following header directories to include directories of the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\":")
target_include_directories("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	# @see https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#build-specification-and-usage-requirements
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
print(STATUS PATHS "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}" "${${PROJECT_NAME}_HEADER_PRIVATE_DIR}" INDENT)


#---- Importing and linking internal dependencies to the main binary build target. ----
message("")
message(STATUS "Add internal dependencies")
include(DependenciesInternalOptions)

# Check imported internal library files and their header files.
if(NOT DEFINED ${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES)
	message(FATAL_ERROR "${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES must be specified!")
endif()
foreach(imported_library IN ITEMS ${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES})
	if(NOT TARGET "${imported_library}")
		message(FATAL_ERROR "Library \"${imported_library}\" has not been imported!")
	endif()
	get_target_property(imported_library_header_dir "${imported_library}" INTERFACE_INCLUDE_DIRECTORIES)
	if(NOT EXISTS "${imported_library_header_dir}")
		message(FATAL_ERROR "Header directory of imported internal library \"${imported_library}\" cannot be found!")
	endif()
endforeach()
message(STATUS "Found the following imported internal library targets:")
print(STATUS LISTS "${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}" INDENT)

# Link imported internal libraries targets to the main binary build target.
message(STATUS "Link imported internal library targets found to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}"
)

# Add `include/` directory to incude directories of the main binary build target.
message(STATUS "Add \"include/\" directory to include-directories of the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_include_directories("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_INCLUDE_DIR}"
)
message(STATUS "Add internal dependencies - done")


#---- Import and link external dependencies to the main binary build target. ----
message("")
message(STATUS "Add external dependencies")
include(DependenciesExternalOptions)
message(STATUS "Add external dependencies - done")



#------------------------------------------------------------------------------
# 3. The Test Generator Module
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_TEST_MODULE})
	message("")
	message("")
	message("== 3. Execution of the Test Generator Module ==")
	include(TestGenModule)
endif()



#------------------------------------------------------------------------------
# 4. The Code Analysis Generator Module
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_CODE_ANALYSIS_MODULE})
	message("")
	message("")
	message("== 4. Execution of the Code Analysis Generator Module ==")
	include(CodeAnalysisGenModule)
endif()



#------------------------------------------------------------------------------
# 5. The Doc Generator Module
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_DOC_MODULE})
	message("")
	message("")
	message("== 5. Execution of the Doc Generator Module ==")
	include(DocGenModule)
endif()



#------------------------------------------------------------------------------
# 6. The Export Generator Module
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_EXPORT_MODULE})
	message("")
	message("")
	message("== 6. Execution of the Export Generator Module ==")
	include(ExportGenModule)
endif()



#------------------------------------------------------------------------------
# 7. The Package Generator Module
#------------------------------------------------------------------------------
if(${PARAM_ENABLE_PACKAGE_MODULE})
	message("")
	message("")
	message("== 7. Execution of the Package Generator Module ==")
	include(PackageGenModule)
endif()



message("")
message("===== End of Build Lifecycle \"${PROJECT_NAME}\" generation =====")
message("")
