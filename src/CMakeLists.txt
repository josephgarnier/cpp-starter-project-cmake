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

###############################################################################
### 1. Binary target setup
###############################################################################

####################### Get target config #####################################
# The target directory path is the target config id
cmake_path(GET CMAKE_CURRENT_SOURCE_DIR FILENAME CONFIG_TARGET_ID)
message(VERBOSE "Getting target config associated to the path '${CONFIG_TARGET_ID}'")
cmake_targets_file(HAS_CONFIG target_has_config TARGET "${CONFIG_TARGET_ID}")
if(NOT ${target_has_config})
  message(FATAL_ERROR "No target config found with the path '${CONFIG_TARGET_ID}': a JSON object '${CONFIG_TARGET_ID}' must be configured in the object 'targets' in CMakeTargets.json!")
endif()

####################### Check the target identifier ###########################
cmake_targets_file(GET_VALUE CONFIG_TARGET_NAME
  TARGET "${CONFIG_TARGET_ID}" KEY "name"
)
validate_target_name(is_valid err_msg on "${CONFIG_TARGET_NAME}")

message(CHECK_START "Making the binary target '${CONFIG_TARGET_NAME}'")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

####################### Declare target metadata ###############################
set(BIN_TARGET_NAME                 "${CONFIG_TARGET_NAME}")

####################### Define and check target structure #####################
set(${BIN_TARGET_NAME}_TARGET_DIR   "${CMAKE_CURRENT_SOURCE_DIR}")
set(${BIN_TARGET_NAME}_BUILD_DIR    "${CMAKE_CURRENT_BINARY_DIR}")

if(("${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
  OR ("${CMAKE_CURRENT_BINARY_DIR}" STREQUAL "${CMAKE_BINARY_DIR}"))
  message(FATAL_ERROR "This CMakeLists.txt file must be in a subdirectory!")
endif()
print(VERBOSE "Target source-tree located in @rp@/" "${${BIN_TARGET_NAME}_TARGET_DIR}")
print(VERBOSE "Target build-tree located in @rp@/" "${${BIN_TARGET_NAME}_BUILD_DIR}")

###############################################################################
### 2. Binary target definition
###############################################################################
message(CHECK_START "Defining target")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

####################### Create the binary target ##############################
cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_TYPE
  TARGET "${CONFIG_TARGET_ID}" KEY "type"
)
set(${BIN_TARGET_NAME}_TYPE_IS_STATIC   off)
set(${BIN_TARGET_NAME}_TYPE_IS_SHARED   off)
set(${BIN_TARGET_NAME}_TYPE_IS_HEADER   off)
set(${BIN_TARGET_NAME}_TYPE_IS_EXEC     off)
if("${${BIN_TARGET_NAME}_TYPE}" STREQUAL "staticLib")
  message(VERBOSE "Adding the static library target \"${BIN_TARGET_NAME}\" to project")
  set(${BIN_TARGET_NAME}_TYPE_IS_STATIC on)
  binary_target(CREATE "${BIN_TARGET_NAME}" STATIC)
  add_library("${PROJECT_NAME}::${BIN_TARGET_NAME}" ALIAS "${BIN_TARGET_NAME}")
elseif("${${BIN_TARGET_NAME}_TYPE}" STREQUAL "sharedLib")
  message(VERBOSE "Adding the shared library target \"${BIN_TARGET_NAME}\" to project")
  set(${BIN_TARGET_NAME}_TYPE_IS_SHARED on)
  binary_target(CREATE "${BIN_TARGET_NAME}" SHARED)
  add_library("${PROJECT_NAME}::${BIN_TARGET_NAME}" ALIAS "${BIN_TARGET_NAME}")
elseif("${${BIN_TARGET_NAME}_TYPE}" STREQUAL "interfaceLib")
  message(VERBOSE "Adding the interface library target \"${BIN_TARGET_NAME}\" to project")
  set(${BIN_TARGET_NAME}_TYPE_IS_HEADER on)
  binary_target(CREATE "${BIN_TARGET_NAME}" HEADER)
  add_library("${PROJECT_NAME}::${BIN_TARGET_NAME}" ALIAS "${BIN_TARGET_NAME}")
elseif("${${BIN_TARGET_NAME}_TYPE}" STREQUAL "executable")
  message(VERBOSE "Adding the executable target \"${BIN_TARGET_NAME}\" to project")
  set(${BIN_TARGET_NAME}_TYPE_IS_EXEC on)
  binary_target(CREATE "${BIN_TARGET_NAME}" EXEC)
  add_executable("${PROJECT_NAME}::${BIN_TARGET_NAME}" ALIAS "${BIN_TARGET_NAME}")
else()
  message(FATAL_ERROR "Unknown binary target type: ${${BIN_TARGET_NAME}_TYPE}. It must be 'staticLib' or 'sharedLib' or 'interfaceLib' or 'executable'!")
endif()

####################### Configure target settings #############################
cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_COMPILE_FEATURES
  TARGET "${CONFIG_TARGET_ID}" KEY "build.compileFeatures")
cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_COMPILE_DEFINITIONS
  TARGET "${CONFIG_TARGET_ID}" KEY "build.compileDefinitions")
cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_COMPILE_OPTIONS
  TARGET "${CONFIG_TARGET_ID}" KEY "build.compileOptions")
cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_LINK_OPTIONS
  TARGET "${CONFIG_TARGET_ID}" KEY "build.linkOptions")

print_string_list(VERBOSE
  "Applying compile features" "${${BIN_TARGET_NAME}_COMPILE_FEATURES}")
print_string_list(VERBOSE
  "Applying compile definitions" "${${BIN_TARGET_NAME}_COMPILE_DEFINITIONS}")
print_string_list(VERBOSE
  "Applying compile options" "${${BIN_TARGET_NAME}_COMPILE_OPTIONS}")
print_string_list(VERBOSE
  "Applying link options" "${${BIN_TARGET_NAME}_LINK_OPTIONS}")

binary_target(CONFIGURE_SETTINGS "${BIN_TARGET_NAME}"
  COMPILE_FEATURES "${${BIN_TARGET_NAME}_COMPILE_FEATURES}"
  COMPILE_DEFINITIONS "${${BIN_TARGET_NAME}_COMPILE_DEFINITIONS}"
  COMPILE_OPTIONS "${${BIN_TARGET_NAME}_COMPILE_OPTIONS}"
  LINK_OPTIONS "${${BIN_TARGET_NAME}_LINK_OPTIONS}"
)

####################### Collect source and header files #######################
# Get source and header files
message(VERBOSE "Collecting sources and headers")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_HEADER_POLICY
  TARGET "${CONFIG_TARGET_ID}" KEY "headerPolicy.mode"
)
set(directory_collect_args "PUBLIC_HEADERS_SEPARATED")
if("${${BIN_TARGET_NAME}_HEADER_POLICY}" STREQUAL "split")
  cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_INCLUDE_DIR
    TARGET "${CONFIG_TARGET_ID}" KEY "headerPolicy.includeDir"
  )
  list(APPEND directory_collect_args
    on
    "${${PROJECT_NAME}_PROJECT_DIR}/${${BIN_TARGET_NAME}_INCLUDE_DIR}"
  )
else()
  list(APPEND directory_collect_args off)
endif()
directory(COLLECT_SOURCES_BY_POLICY
  ${directory_collect_args}
  PRIVATE_SOURCE_DIR "${${BIN_TARGET_NAME}_TARGET_DIR}"
  PRIVATE_SOURCE_FILES ${BIN_TARGET_NAME}_PRIVATE_SOURCES
  PUBLIC_HEADER_DIR ${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR
  PUBLIC_HEADER_FILES ${BIN_TARGET_NAME}_PUBLIC_HEADERS
  PRIVATE_HEADER_DIR ${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR
  PRIVATE_HEADER_FILES ${BIN_TARGET_NAME}_PRIVATE_HEADERS
)

print_path_list(VERBOSE
  "Header files collected" "${${BIN_TARGET_NAME}_PRIVATE_HEADERS};${${BIN_TARGET_NAME}_PUBLIC_HEADERS}")
print_path_list(VERBOSE
  "Source files collected" "${${BIN_TARGET_NAME}_PRIVATE_SOURCES}")

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(VERBOSE "Collecting sources and headers - done")

####################### Assign source and header files ########################
# Add source and header files to target
binary_target(ADD_SOURCES "${BIN_TARGET_NAME}"
  SOURCE_FILES "${${BIN_TARGET_NAME}_PRIVATE_SOURCES}"
  PRIVATE_HEADER_FILES "${${BIN_TARGET_NAME}_PRIVATE_HEADERS}"
  PUBLIC_HEADER_FILES "${${BIN_TARGET_NAME}_PUBLIC_HEADERS}"
)

# Set the target "main file" var
cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_MAIN_FILE
  TARGET "${CONFIG_TARGET_ID}" KEY "mainFile"
)
set(${BIN_TARGET_NAME}_MAIN_FILE "${${PROJECT_NAME}_PROJECT_DIR}/${${BIN_TARGET_NAME}_MAIN_FILE}")
validate_main_file_path(is_valid err_msg on "${${BIN_TARGET_NAME}_MAIN_FILE}")
print(VERBOSE "Main file is @rp@" "${${BIN_TARGET_NAME}_MAIN_FILE}")

####################### Set up precompile header (PCH) ########################
cmake_targets_file(HAS_SETTING has_pch_setting
  TARGET "${CONFIG_TARGET_ID}" KEY "pchFile"
)
if(${has_pch_setting})
  cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_PCH_FILE
    TARGET "${CONFIG_TARGET_ID}" KEY "pchFile"
  )
  set(${BIN_TARGET_NAME}_PCH_FILE "${${PROJECT_NAME}_PROJECT_DIR}/${${BIN_TARGET_NAME}_PCH_FILE}")
  validate_pch_file_path(is_valid err_msg on
    "${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}" "${${BIN_TARGET_NAME}_PCH_FILE}")
  print(VERBOSE "Adding headers to precompile: @rp@" "${${BIN_TARGET_NAME}_PCH_FILE}")
  binary_target(ADD_PRECOMPILE_HEADER "${BIN_TARGET_NAME}"
    HEADER_FILE "${${BIN_TARGET_NAME}_PCH_FILE}"
  )
else()
  set(${BIN_TARGET_NAME}_PCH_FILE "")
  message(VERBOSE "Precompile header disabled")
endif()

####################### Add header include directories ########################
print(VERBOSE "Adding include directories: @rpl@" "${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}" "${${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR}")
binary_target(ADD_INCLUDE_DIRECTORIES "${BIN_TARGET_NAME}"
  INCLUDE_DIRECTORIES "$<$<BOOL:${${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR}>:${${BIN_TARGET_NAME}_PRIVATE_HEADER_DIR}>" "${${BIN_TARGET_NAME}_PUBLIC_HEADER_DIR}"
)

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

###############################################################################
### 3. Binary target deps linking
###############################################################################

####################### Import and link internal dependencies #################
message(CHECK_START "Linking internal dependencies")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# if(NOT DEFINED ${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES)
# 	message(FATAL_ERROR "${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES must be specified!")
# endif()

# foreach(imported_library IN ITEMS ${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES})
# 	if(NOT TARGET "${imported_library}")
# 		message(FATAL_ERROR "Library \"${imported_library}\" has not been imported!")
# 	endif()
# 	get_target_property(imported_library_header_dir "${imported_library}" INTERFACE_INCLUDE_DIRECTORIES)
# 	if(NOT EXISTS "${imported_library_header_dir}")
# 		message(FATAL_ERROR "Header directory of imported internal library \"${imported_library}\" cannot be found!")
# 	endif()
# endforeach()

# message(STATUS "Internal target libraries found:")
# print(STATUS LISTS "${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}" INDENT)

# target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
# 	PRIVATE
# 		"${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}"
# )
# target_include_directories("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
# 	PRIVATE
# 		"${${PROJECT_NAME}_INCLUDE_DIR}"
# )

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Import and link external dependencies #################
message(CHECK_START "Linking external dependencies")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

cmake_targets_file(GET_VALUE ${BIN_TARGET_NAME}_DEPENDENCIES
  TARGET "${CONFIG_TARGET_ID}" KEY "dependencies"
)
foreach(dep_name IN ITEMS ${${BIN_TARGET_NAME}_DEPENDENCIES})
  message(CHECK_START "Importing ${dep_name}")
  list(APPEND CMAKE_MESSAGE_INDENT "  ")

  validate_dep_name(is_valid err_msg on "${dep_name}")
  import_external_dependency("${BIN_TARGET_NAME}" "${CONFIG_TARGET_ID}" "${dep_name}")

  list(POP_BACK CMAKE_MESSAGE_INDENT)
  if(NOT ${${dep_name}_FOUND})
    message(CHECK_FAIL "failed (not found)")
  else()
    message(CHECK_PASS "done")
  endif()
endforeach()

###############################################################################
### 4. Binary target finalization
###############################################################################
generate_target_status_summary("${BIN_TARGET_NAME}" ${BIN_TARGET_NAME}_STATUS_SUMMARY)

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

return(PROPAGATE "${BIN_TARGET_NAME}_STATUS_SUMMARY")