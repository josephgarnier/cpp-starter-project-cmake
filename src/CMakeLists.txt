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

####################### Load target settings ###############
reset_local_bin_target_settings()
include(MainBinTarget.cmake)
load_bin_target_settings()

message(CHECK_START "[Target Configuration] ${PARAM_BIN_TARGET_NAME} (v${${PROJECT_NAME}_VERSION})")

####################### Check the target identifier ###########################
message(CHECK_START "Validating target identifier: ${PARAM_BIN_TARGET_NAME}")
if(NOT DEFINED PARAM_BIN_TARGET_NAME)
	message(FATAL_ERROR "Target settings loading failed: PARAM_BIN_TARGET_NAME must be specified!")
endif()
if("${PARAM_BIN_TARGET_NAME}" MATCHES " ")
	message(FATAL_ERROR "PARAM_BIN_TARGET_NAME \"${PARAM_BIN_TARGET_NAME}\" cannot contain spaces!")
endif()
message(CHECK_PASS "done")

####################### Declare target metadata ###############################
message(CHECK_START "Initializing target metadata")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

set(BIN_TARGET_NAME                    "${PARAM_BIN_TARGET_NAME}")
set(${BIN_TARGET_NAME}_TARGET_DIR      "${CMAKE_CURRENT_SOURCE_DIR}")
set(${BIN_TARGET_NAME}_BUILD_DIR       "${CMAKE_CURRENT_BINARY_DIR}")
set(${BIN_TARGET_NAME}_SRC_DIR         "${CMAKE_CURRENT_SOURCE_DIR}")
set(${BIN_TARGET_NAME}_INCLUDE_DIR     "${${PROJECT_NAME}_INCLUDE_DIR}/${PARAM_PUBLIC_HEADERS_DIR}")
message(STATUS "Target source-tree is: ${${BIN_TARGET_NAME}_TARGET_DIR}")

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Create the binary target ##############################
message(CHECK_START "Configuring binary target")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
set(${BIN_TARGET_NAME}_BIN_TARGET_IS_STATIC   off)
set(${BIN_TARGET_NAME}_BIN_TARGET_IS_SHARED   off)
set(${BIN_TARGET_NAME}_BIN_TARGET_IS_HEADER   off)
set(${BIN_TARGET_NAME}_BIN_TARGET_IS_EXEC     off)
if("${PARAM_BIN_TARGET_TYPE}" STREQUAL "static")
	set(${BIN_TARGET_NAME}_BIN_TARGET_IS_STATIC   on)
	add_bin_target(TARGET_NAME "${BIN_TARGET_NAME}" STATIC)
elseif("${PARAM_BIN_TARGET_TYPE}" STREQUAL "shared")
	set(${BIN_TARGET_NAME}_BIN_TARGET_IS_SHARED   on)
	add_bin_target(TARGET_NAME "${BIN_TARGET_NAME}" SHARED)
elseif("${PARAM_BIN_TARGET_TYPE}" STREQUAL "header")
	set(${BIN_TARGET_NAME}_BIN_TARGET_IS_HEADER   on)
	add_bin_target(TARGET_NAME "${BIN_TARGET_NAME}" HEADER)
elseif("${PARAM_BIN_TARGET_TYPE}" STREQUAL "exec")
	set(${BIN_TARGET_NAME}_BIN_TARGET_IS_EXEC     on)
	add_bin_target(TARGET_NAME "${BIN_TARGET_NAME}" EXEC)
else()
	message(FATAL_ERROR "Unknown binary target type: ${PARAM_BIN_TARGET_TYPE}. A binary target type must be \"static\" or \"shared\" or \"header\" or \"exec\"!")
endif()

set(${BIN_TARGET_NAME}_COMPILE_DEFINITIONS "${PARAM_COMPILE_DEFINITIONS}")
configure_bin_target_settings(
	TARGET_NAME "${BIN_TARGET_NAME}"
	COMPILE_DEFINITIONS "${${BIN_TARGET_NAME}_COMPILE_DEFINITIONS}"
)

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Validate and assign source and header files ###########
message(CHECK_START "Collecting source and header files")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# List of absolute paths to source files (.cpp) that are under `src/` directory
set(${BIN_TARGET_NAME}_SRC_SOURCE_FILES      "")
# Absolute path to `include/<target-name>/` or `src/` directory
set(${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR      "")
# List of absolute paths to header files (.h) that are under `include/<target-name>/` or `src/` directory
set(${BIN_TARGET_NAME}_PUBLIC_HEADER_FILES    "")
# Absolute path under a `src/` directory or empty
set(${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR     "")
# List of absolute paths to header files (.h) that are under `src/` directory or empty
set(${BIN_TARGET_NAME}_PRIVATE_HEADER_FILES   "")

# Get files and configure the header files policy
collect_source_files_by_policy(
	PUBLIC_HEADERS_SEPARATED ${PARAM_PUBLIC_HEADERS_SEPARATED} "${${BIN_TARGET_NAME}_INCLUDE_DIR}"
	SRC_DIR "${${BIN_TARGET_NAME}_SRC_DIR}"
	SRC_SOURCE_FILES ${BIN_TARGET_NAME}_SRC_SOURCE_FILES
	PUBLIC_HEADER_DIR ${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR
	PUBLIC_HEADER_FILES ${BIN_TARGET_NAME}_PUBLIC_HEADER_FILES
	PRIVATE_HEADER_DIR ${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR
	PRIVATE_HEADER_FILES ${BIN_TARGET_NAME}_PRIVATE_HEADER_FILES
)

# Print source files
message(STATUS "Source files collected:")
print(STATUS PATHS "${${BIN_TARGET_NAME}_SRC_SOURCE_FILES}" INDENT)

# Print header files
message(STATUS "Public headers located in: ${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}")
message(STATUS "Header files collected:")
print(STATUS PATHS "${${BIN_TARGET_NAME}_PRIVATE_HEADER_FILES}" "${${BIN_TARGET_NAME}_PUBLIC_HEADER_FILES}" INDENT)

# Set the absolute path to the "main" file
set(${BIN_TARGET_NAME}_MAIN_FILE "${${BIN_TARGET_NAME}_SRC_DIR}/${PARAM_MAIN_FILE}")
if(NOT DEFINED PARAM_MAIN_FILE)
	message(FATAL_ERROR "PARAM_MAIN_FILE must be specified!")
endif()
if(NOT EXISTS "${${BIN_TARGET_NAME}_MAIN_FILE}")
	message(FATAL_ERROR "Main file \"${${BIN_TARGET_NAME}_MAIN_FILE}\" does not exist!")
endif()
message(STATUS "Main file is: ${${BIN_TARGET_NAME}_MAIN_FILE}")

# Add source and header files
add_sources_to_target(
	TARGET_NAME "${BIN_TARGET_NAME}"
	SOURCE_FILES "${${BIN_TARGET_NAME}_SRC_SOURCE_FILES}"
	PRIVATE_HEADER_FILES "${${BIN_TARGET_NAME}_PRIVATE_HEADER_FILES}"
	PUBLIC_HEADER_FILES "${${BIN_TARGET_NAME}_PUBLIC_HEADER_FILES}"
	PROJECT_DIR "${${PROJECT_NAME}_PROJECT_DIR}"
)

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Set up precompiled header #############################
message(CHECK_START "Configuring precompiled header")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Set the absolute path to the precompiled header file
if(${PARAM_USE_PRECOMPILED_HEADER})
	if(NOT DEFINED PARAM_PRECOMPILED_FILE)
		message(FATAL_ERROR "PARAM_PRECOMPILED_FILE must be specified!")
	endif()
	set(${BIN_TARGET_NAME}_PRECOMPILED_HEADER_FILE "${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}/${PARAM_PRECOMPILED_FILE}")
	if(NOT "${${BIN_TARGET_NAME}_PRECOMPILED_HEADER_FILE}" MATCHES "${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}")
		print(FATAL_ERROR "Precompiled header file \"@rp@\" is not located in the header public directory!" "${${BIN_TARGET_NAME}_PRECOMPILED_HEADER_FILE}")
	endif()
	add_precompiled_header_to_target(
		TARGET_NAME "${BIN_TARGET_NAME}"
		HEADER_FILE "${${BIN_TARGET_NAME}_PRECOMPILED_HEADER_FILE}"
	)
	set(CMAKE_DISABLE_PRECOMPILE_HEADERS off)
	print(STATUS "Set precompiled header: @rp@" "${${BIN_TARGET_NAME}_PRECOMPILED_HEADER_FILE}")
else()
	set(CMAKE_DISABLE_PRECOMPILE_HEADERS on)
	message(STATUS "Precompiled headers disabled")
endif()

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Add header include directories ########################
message(CHECK_START "Setting up include directories")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

add_include_directories_to_target(
	TARGET_NAME "${BIN_TARGET_NAME}"
	# Generator expressions used only when building the target
	INCLUDE_DIRECTORIES "$<$<BOOL:${${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR}>:${${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR}>" "${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}"
)
message(STATUS "Include directories added:")
print(STATUS PATHS "${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}" "${${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR}" INDENT)

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Import and link internal dependencies #################
message(CHECK_START "Linking internal dependencies")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

link_internal_dependencies()

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Import and link external dependencies #################
message(CHECK_START "Linking external dependencies")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

set(CURRENT_TARGET      "${BIN_TARGET_NAME}")
set(CURRENT_TARGET_DIR  "${BIN_TARGET_NAME}_TARGET_DIR")
set(CURRENT_PROJECT_DIR "${PROJECT_DIR}")

link_external_dependencies()

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Sub-step summary ##########################################
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "   Main Binary Target: ${BIN_TARGET_NAME} (${PARAM_BIN_TARGET_TYPE})\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • Precompiled header       : ${${BIN_TARGET_NAME}_PRECOMPILED_HEADER_FILE}\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • Public headers directory : ${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • Private headers directory: ${${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR}\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • Internal libraries       : ${${BIN_TARGET_NAME}_IMPORTED_INTERNAL_LIBRARIES}\n")
string(APPEND ${PROJECT_NAME}_SUB_STEP_SUMMARY "     • External libraries       :")
set(${PROJECT_NAME}_SUB_STEP_SUMMARY "${${PROJECT_NAME}_SUB_STEP_SUMMARY}" PARENT_SCOPE)

message(CHECK_PASS "done")