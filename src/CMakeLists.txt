# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)

####################### Creating the main binary target ####################
message(CHECK_START "Setting up the binary target")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_STATIC   off)
set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_SHARED   off)
set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_HEADER   off)
set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_EXEC     off)
if("${PARAM_MAIN_BINARY_TARGET_TYPE}" STREQUAL "static")
	set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_STATIC   on)
	add_library("${${PROJECT_NAME}_MAIN_BIN_TARGET}" STATIC)
	message(STATUS "Binary target type set to: Static library")
elseif("${PARAM_MAIN_BINARY_TARGET_TYPE}" STREQUAL "shared")
	set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_SHARED   on)
	# All libraries will be built shared unless the library was explicitly added as a static library
	set(BUILD_SHARED_LIBS                           on)
	message(STATUS "All exported symbols are hidden by default")
	set(CMAKE_WINDOWS_EXPORT_ALL_SYMBOLS            off)
	set(CMAKE_CXX_VISIBILITY_PRESET                 "hidden")
	set(CMAKE_VISIBILITY_INLINES_HIDDEN             on)
	add_library("${${PROJECT_NAME}_MAIN_BIN_TARGET}" SHARED)
	message(STATUS "Binary target type set to: Shared library")
elseif("${PARAM_MAIN_BINARY_TARGET_TYPE}" STREQUAL "header")
	set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_HEADER   on)
	add_library("${${PROJECT_NAME}_MAIN_BIN_TARGET}" INTERFACE)
	message(STATUS "Binary target type set to: Header-only library")
elseif("${PARAM_MAIN_BINARY_TARGET_TYPE}" STREQUAL "exec")
	set(${PROJECT_NAME}_MAIN_BIN_TARGET_IS_EXEC     on)
	add_executable("${${PROJECT_NAME}_MAIN_BIN_TARGET}")
	message(STATUS "Binary target type set to: Executable")
else()
	message(FATAL_ERROR "Unknown binary target type: ${PARAM_MAIN_BINARY_TARGET_TYPE}. A binary target type must be \"static\" or \"shared\" or \"header\" or \"exec\"!")
endif()

# Add the main binary build target in a folder for IDE project.
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES FOLDER "")

# Set compile features (C++ standard)
target_compile_features("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"cxx_std_${CMAKE_CXX_STANDARD}"
)
message(STATUS "C++ standard enforced: C++${CMAKE_CXX_STANDARD}")

# Set compile definitions
set(${PROJECT_NAME}_COMPILE_DEFINITIONS "${PARAM_COMPILE_DEFINITIONS}")
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_COMPILE_DEFINITIONS}"
)
message(STATUS "Compile definitions: ${${PROJECT_NAME}_COMPILE_DEFINITIONS}")

# Set compile options
target_compile_options("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		""
)
message(STATUS "No extra compile options specified (empty)")

# Add link options
target_link_options("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		""
)
message(STATUS "No extra link options specified (empty)")

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")


####################### Validating and assigning source and header file to the
# main binary target ################
message(CHECK_START "Collecting source and header files")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

include(FuncFileManip)
include(HeadersAndSourcesOptions)

# Source files
if(NOT DEFINED ${PROJECT_NAME}_SOURCE_SRC_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_SOURCE_SRC_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_MAIN_SOURCE_FILE)
	message(FATAL_ERROR "${PROJECT_NAME}_MAIN_SOURCE_FILE must be specified!")
elseif((NOT ${PROJECT_NAME}_MAIN_SOURCE_FILE) OR (NOT EXISTS "${${PROJECT_NAME}_MAIN_SOURCE_FILE}"))
	message(FATAL_ERROR "Main file \"${${PROJECT_NAME}_MAIN_SOURCE_FILE}\" does not exist!")
endif()
message(STATUS "Source files collected:")
print(STATUS PATHS "${${PROJECT_NAME}_SOURCE_SRC_FILES}" INDENT)

# Header files
if(NOT DEFINED ${PROJECT_NAME}_HEADER_SRC_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_HEADER_SRC_FILES must be specified!")
endif()
if(NOT DEFINED ${PROJECT_NAME}_HEADER_INCLUDE_FILES)
	message(FATAL_ERROR "${PROJECT_NAME}_HEADER_INCLUDE_FILES must be specified!")
endif()

# Check if `include/<project-name>` directory exists, then set the variables related to headers
if(${PARAM_PUBLIC_HEADERS_SEPARATED} AND (NOT IS_DIRECTORY "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}"))
	message(FATAL_ERROR "\"include/<project-name>\" directory missing while public headers separation is active (\"PARAM_PUBLIC_HEADERS_SEPARATED\" is set with on)!")
elseif(${PARAM_PUBLIC_HEADERS_SEPARATED})
	set(${PROJECT_NAME}_HEADER_PUBLIC_DIR      "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}")
	set(${PROJECT_NAME}_HEADER_PUBLIC_FILES    "${${PROJECT_NAME}_HEADER_INCLUDE_FILES}")
	set(${PROJECT_NAME}_HEADER_PRIVATE_DIR     "${${PROJECT_NAME}_SRC_DIR}")
	set(${PROJECT_NAME}_HEADER_PRIVATE_FILES   "${${PROJECT_NAME}_HEADER_SRC_FILES}")
	message(STATUS "Considering headers from \"include/\" as public and from \"src/\" as private")
else()
	set(${PROJECT_NAME}_HEADER_PUBLIC_DIR      "${${PROJECT_NAME}_SRC_DIR}")
	set(${PROJECT_NAME}_HEADER_PUBLIC_FILES    "${${PROJECT_NAME}_HEADER_SRC_FILES}")
	set(${PROJECT_NAME}_HEADER_PRIVATE_DIR     "")
	set(${PROJECT_NAME}_HEADER_PRIVATE_FILES   "")
	message(STATUS "Considering headers from \"src/\" as public, ignoring \"include/\"")
endif()
message(STATUS "Public headers located in: ${${PROJECT_NAME}_HEADER_PUBLIC_DIR}")
message(STATUS "Header files collected:")
print(STATUS PATHS "${${PROJECT_NAME}_HEADER_PRIVATE_FILES}" "${${PROJECT_NAME}_HEADER_PUBLIC_FILES}" INDENT)

# Adding source and header files
message(STATUS "Assigning sources and headers to the target")
target_sources("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_SOURCE_SRC_FILES}"
		"${${PROJECT_NAME}_HEADER_PRIVATE_FILES}"
		"${${PROJECT_NAME}_HEADER_PUBLIC_FILES}"
)
message(STATUS "Organizing files according to the project tree")
source_group(TREE "${${PROJECT_NAME}_PROJECT_DIR}"
	FILES
		${${PROJECT_NAME}_SOURCE_SRC_FILES}
		${${PROJECT_NAME}_HEADER_PRIVATE_FILES}
		${${PROJECT_NAME}_HEADER_PUBLIC_FILES}
)
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")


####################### Precompiled header setup for the main binary target ########
message(CHECK_START "Configuring precompiled header")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
if(NOT DEFINED ${PROJECT_NAME}_PRECOMPILED_HEADER_FILE)
	message(FATAL_ERROR "${PROJECT_NAME}_PRECOMPILED_HEADER_FILE must be specified!")
endif()

if(${PARAM_USE_PRECOMPILED_HEADER})
	if((NOT ${PROJECT_NAME}_PRECOMPILED_HEADER_FILE) OR (NOT EXISTS "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}"))
		message(FATAL_ERROR "Precompiled header file \"${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}\" does not exist!")
	elseif(NOT "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}" MATCHES "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}")
		print(FATAL_ERROR "Precompiled header file \"@rp@\" is not located in the header public directory!" "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
	else()
		target_precompile_headers("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
			PRIVATE
				"${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}"
		)
		print(STATUS "Using precompiled header: @rp@" "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
	endif()
else()
	set(CMAKE_DISABLE_PRECOMPILE_HEADERS off)
	message(STATUS "Precompiled headers disabled")
endif()
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")


####################### Adding header include directories to the main binary 
# target ##########################################
message(CHECK_START "Setting up include directories")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
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
message(STATUS "Include directories added:")
print(STATUS PATHS "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}" "${${PROJECT_NAME}_HEADER_PRIVATE_DIR}" INDENT)
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")


####################### Importing and linking internal dependencies to the main
# binary target ##########################################
message(CHECK_START "Linking internal dependencies")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
include(DependenciesInternalOptions)

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

message(STATUS "Internal target libraries found:")
print(STATUS LISTS "${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}" INDENT)

target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}"
)
target_include_directories("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_INCLUDE_DIR}"
)
message(STATUS "Linked internal libraries")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")


####################### Importing and linking external dependencies to the main
# binary target ##########################################
message(CHECK_START "Linking external dependencies")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
include(DependenciesExternalOptions)
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")


####################### Sub-step summary ##########################################
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • Precompiled header       : ${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • Public headers directory : ${${PROJECT_NAME}_HEADER_PUBLIC_DIR}\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • Private headers directory: ${${PROJECT_NAME}_HEADER_PRIVATE_DIR}\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • Internal libraries       : ${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • External libraries       :")
set(${PROJECT_NAME}_SUB_STEP_SUMMARY "${${PROJECT_NAME}_SUB_STEP_SUMMARY}" PARENT_SCOPE)