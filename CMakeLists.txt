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

message("=================================================================")
message("               🏗️  Build System Configuration                    ")
message("                      of \"${PARAM_PROJECT_NAME}\"               ")
message("=================================================================")
message("🔧 Project: \"${PARAM_PROJECT_NAME}\" | Version: ${PARAM_PROJECT_VERSION_MAJOR}.${PARAM_PROJECT_VERSION_MINOR}.${PARAM_PROJECT_VERSION_PATCH}")
message("📄 Description: ${PARAM_PROJECT_SUMMARY}")
message("👤 Author: ${PARAM_PROJECT_VENDOR_NAME} (${PARAM_PROJECT_VENDOR_CONTACT})")
message("⚙️  Generator: ${CMAKE_GENERATOR}")
message("-----------------------------------------------------------------")
message("🔨 Build Step:")
message("   • Standard Version            : ${PARAM_BUILD_STANDARD_VERSION}")
message("   • Build Type                  : ${PARAM_BUILD_TYPE}")
message("   • Target Type                 : ${PARAM_MAIN_BINARY_TARGET_TYPE}")
message("   • Compile Definitions         : ${PARAM_COMPILE_DEFINITIONS}")
message("   • Public Headers Separated    : ${PARAM_PUBLIC_HEADERS_SEPARATED}")
message("   • PCH Used                    : ${PARAM_USE_PRECOMPILED_HEADER}")
message("   • Toolchain File              : ${CMAKE_TOOLCHAIN_FILE}")
message("   • Generate Compile Commands   : ${PARAM_GENERATE_COMPILE_COMMANDS}")
message("🧪 Test Step:")
message("   • Enabled                     : ${PARAM_ENABLE_TEST_MODULE}")
message("📊 Code Analysis Step:")
message("   • Enabled                     : ${PARAM_ENABLE_CODE_ANALYSIS_MODULE}")
message("📚 Documentation Step:")
message("   • Enabled                     : ${PARAM_ENABLE_DOC_MODULE}")
message("📤 Export Step:")
message("   • Enabled                     : ${PARAM_ENABLE_EXPORT_MODULE}")
message("   • Export Namespace            : ${PARAM_EXPORT_NAMESPACE}")
message("   • Install Dir                 : ${PARAM_INSTALL_DIRECTORY}")
message("📦 Packaging Step:")
message("   • Enabled                     : ${PARAM_ENABLE_PACKAGE_MODULE}")
message("=================================================================")


###############################################################################
### 1. Build system project setup
###############################################################################
message("")
message("")
message("🧱 ========== [1] Build System Project Setup ================")

####################### Check project identifier ##############################
message(CHECK_START "Validating project identifier: ${PARAM_PROJECT_NAME}")
if(NOT DEFINED PARAM_PROJECT_NAME)
	message(FATAL_ERROR "PARAM_PROJECT_NAME must be specified!")
endif()
if("${PARAM_PROJECT_NAME}" MATCHES " ")
	message(FATAL_ERROR "PARAM_PROJECT_NAME \"${PARAM_PROJECT_NAME}\" cannot contain spaces!")
endif()
message(CHECK_PASS "done")

####################### Declare project metadata ##############################
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

####################### Check project structure ###############################
message(CHECK_START "Defining and validating project structure")
set(${PROJECT_NAME}_PROJECT_DIR             "${CMAKE_CURRENT_SOURCE_DIR}")
set(${PROJECT_NAME}_ASSETS_DIR              "${${PROJECT_NAME}_PROJECT_DIR}/assets")
set(${PROJECT_NAME}_BIN_DIR                 "${${PROJECT_NAME}_PROJECT_DIR}/bin")
set(${PROJECT_NAME}_BUILD_DIR               "${CMAKE_CURRENT_BINARY_DIR}")
set(${PROJECT_NAME}_CMAKE_DIR               "${${PROJECT_NAME}_PROJECT_DIR}/cmake")
set(${PROJECT_NAME}_CMAKE_MODULES_DIR       "${${PROJECT_NAME}_CMAKE_DIR}/modules")
set(${PROJECT_NAME}_CMAKE_STEP_BUILD_DIR         "${${PROJECT_NAME}_CMAKE_DIR}/step_build")
set(${PROJECT_NAME}_CMAKE_STEP_CLEAN_DIR         "${${PROJECT_NAME}_CMAKE_DIR}/step_clean")
set(${PROJECT_NAME}_CMAKE_STEP_CODE_ANALYSIS_DIR "${${PROJECT_NAME}_CMAKE_DIR}/step_code_analysis")
set(${PROJECT_NAME}_CMAKE_STEP_DOC_DIR           "${${PROJECT_NAME}_CMAKE_DIR}/step_doc")
set(${PROJECT_NAME}_CMAKE_STEP_INSTALL_DIR       "${${PROJECT_NAME}_CMAKE_DIR}/step_install")
set(${PROJECT_NAME}_CMAKE_STEP_PACKAGE_DIR       "${${PROJECT_NAME}_CMAKE_DIR}/step_package")
set(${PROJECT_NAME}_CMAKE_STEP_TEST_DIR          "${${PROJECT_NAME}_CMAKE_DIR}/step_test")
set(${PROJECT_NAME}_CMAKE_STEP_UNINSTALL_DIR     "${${PROJECT_NAME}_CMAKE_DIR}/step_uninstall")
set(${PROJECT_NAME}_CMAKE_TOOLCHAINS_DIR         "${${PROJECT_NAME}_CMAKE_DIR}/toolchains")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"
	"${${PROJECT_NAME}_CMAKE_MODULES_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_BUILD_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_CLEAN_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_CODE_ANALYSIS_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_DOC_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_INSTALL_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_PACKAGE_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_TEST_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_UNINSTALL_DIR}"
	"${${PROJECT_NAME}_CMAKE_TOOLCHAINS_DIR}")
set(${PROJECT_NAME}_CONFIG_DIR              "${${PROJECT_NAME}_PROJECT_DIR}/config")
set(${PROJECT_NAME}_DOC_DIR                 "${${PROJECT_NAME}_PROJECT_DIR}/doc")
set(${PROJECT_NAME}_INCLUDE_DIR             "${${PROJECT_NAME}_PROJECT_DIR}/include")
set(${PROJECT_NAME}_LIB_DIR                 "${${PROJECT_NAME}_PROJECT_DIR}/lib")
set(${PROJECT_NAME}_RESOURCES_DIR           "${${PROJECT_NAME}_PROJECT_DIR}/resources")
set(${PROJECT_NAME}_SRC_DIR                 "${${PROJECT_NAME}_PROJECT_DIR}/src")
set(${PROJECT_NAME}_TESTS_DIR               "${${PROJECT_NAME}_PROJECT_DIR}/tests")

list(APPEND ${PROJECT_NAME}_PROJECT_DIRS
	"${${PROJECT_NAME}_ASSETS_DIR}"
	"${${PROJECT_NAME}_BIN_DIR}"
	"${${PROJECT_NAME}_BUILD_DIR}"
	"${${PROJECT_NAME}_CMAKE_DIR}"
	"${${PROJECT_NAME}_CMAKE_MODULES_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_BUILD_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_CLEAN_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_CODE_ANALYSIS_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_DOC_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_INSTALL_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_PACKAGE_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_TEST_DIR}"
	"${${PROJECT_NAME}_CMAKE_STEP_UNINSTALL_DIR}"
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
		message(FATAL_ERROR "Missing directory: ${folder}!")
	endif()
endforeach()
message(CHECK_PASS "done")

####################### Validating build directory location ###################
# Build path must be in the `build/` directory.
message(CHECK_START "Validating build directory location")
if(NOT "${${PROJECT_NAME}_BUILD_DIR}" MATCHES "${${PROJECT_NAME}_PROJECT_DIR}/build")
	message(FATAL_ERROR "The build directory \"${${PROJECT_NAME}_BUILD_DIR}\" is not inside the project directory!")
endif()
message(CHECK_PASS "done")

message(STATUS "Step Summary:")
message("   • Declared project \"${PROJECT_NAME}\" (v${${PROJECT_NAME}_VERSION})")
message("   • Author        : ${${PROJECT_NAME}_VENDOR_NAME}")
message("   • Contact       : ${${PROJECT_NAME}_VENDOR_CONTACT}")
message("   • Description   : ${${PROJECT_NAME}_SUMMARY}")
message("   • Source-tree   : ${${PROJECT_NAME}_PROJECT_DIR}")
message("   • Build-tree    : ${${PROJECT_NAME}_BUILD_DIR}")
message("✅ Build System Project Setup - Completed")
###############################################################################


###############################################################################
### 2. Application binaries configuration (add app targets)
###############################################################################
include(FuncPrint)
message("")
message("")
message("🔧 ========== [2] Application Binaries Configuration =============")

message(CHECK_START "[Global Configuration]")

####################### Configuring system and architecture info ##############
message(CHECK_START "Detecting system architecture and build host")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

if(NOT CMAKE_SYSTEM_PROCESSOR)
	set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()
message(STATUS "Processor architecture is: ${CMAKE_SYSTEM_PROCESSOR}")
set(SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_SYSTEM_PROCESSOR}")
string(TOLOWER ${SYSTEM_NAME} SYSTEM_NAME)
message(STATUS "System name set to: ${SYSTEM_NAME}")

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Setting up output directories #########################
message(CHECK_START "Setting output directory")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
print(STATUS "Output directory set to: @rp@/" "${${PROJECT_NAME}_BIN_DIR}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

######### Setting build standard version and build type for binary targets ####
message(CHECK_START "Setting C++ build environment")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
if(("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "11")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "14")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "17")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "20")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "23")
	OR ("${PARAM_BUILD_STANDARD_VERSION}" STREQUAL "26"))
	set(CMAKE_CXX_STANDARD "${PARAM_BUILD_STANDARD_VERSION}")
else()
	message(FATAL_ERROR "PARAM_BUILD_STANDARD_VERSION must be 11, 14, 17, 20, 23, 26!")
endif()
message(STATUS "C++ standard version set to: C++${CMAKE_CXX_STANDARD}")

if(("${PARAM_BUILD_TYPE}" STREQUAL "release"))
	set(CMAKE_BUILD_TYPE "RELEASE")
elseif("${PARAM_BUILD_TYPE}" STREQUAL "debug")
	set(CMAKE_BUILD_TYPE "DEBUG")
else()
	message(FATAL_ERROR "PARAM_BUILD_TYPE should be \"debug\" or \"release\"!")
endif()
message(STATUS "Build type set to: ${CMAKE_BUILD_TYPE}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Organizing IDE folders and generator settings #########
message(CHECK_START "Configuring generator and IDE options")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
set(CMAKE_FOLDER "PredefinedTargets")
set_property(GLOBAL PROPERTY USE_FOLDERS on)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "${CMAKE_FOLDER}")

# Enable compile_commands.json if requested
set(CMAKE_EXPORT_COMPILE_COMMANDS "${PARAM_GENERATE_COMPILE_COMMANDS}")
message(STATUS "Generate compile commands: ${CMAKE_EXPORT_COMPILE_COMMANDS}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

list(POP_BACK CMAKE_MESSAGE_INDENT)
message(CHECK_PASS "done")

####################### Configuring the main binary target ####################
message(STATUS "-----------------------------------------------------------------")
set(${PROJECT_NAME}_MAIN_BIN_TARGET "${PROJECT_NAME}")
set(${PROJECT_NAME}_SUB_STEP_SUMMARY "")
message(CHECK_START "[Target Configuration] ${${PROJECT_NAME}_MAIN_BIN_TARGET}")
add_subdirectory(src)
message(CHECK_PASS "done")

####################### Step summary ##########################################
message(STATUS "-----------------------------------------------------------------")
message(STATUS "Step Summary:")
message("   Global Configuration:")
message("     • C++ standard             : C++${CMAKE_CXX_STANDARD}")
message("     • Build type               : ${CMAKE_BUILD_TYPE}")
message("     • Output directory         : ${${PROJECT_NAME}_BIN_DIR}")
message("   Main Binary Target: ${${PROJECT_NAME}_MAIN_BIN_TARGET} (${PARAM_MAIN_BINARY_TARGET_TYPE})")
message("${${PROJECT_NAME}_SUB_STEP_SUMMARY}")
message("✅ Application Binaries Configuration - Completed")
###############################################################################


###############################################################################
### 3. Test Step (add target "X")
###############################################################################
if(${PARAM_ENABLE_TEST_MODULE})
	message("")
	message("")
	message("🧪 ========== [3] Test Suite Configuration =======================")
	include(TestGenModule)
endif()
###############################################################################


###############################################################################
### 4. Code Analysis Step (add target "X")
###############################################################################
if(${PARAM_ENABLE_CODE_ANALYSIS_MODULE})
	message("")
	message("")
	message("📊 ========== [4] Code Analysis Configuration ====================")
	include(CodeAnalysisGenModule)
endif()
###############################################################################


###############################################################################
### 5. Documentation Step (add target "X")
###############################################################################
if(${PARAM_ENABLE_DOC_MODULE})
	message("")
	message("")
	message("📚 ========== [5] Documentation System Setup =====================")
	include(DocGenModule)
endif()
###############################################################################


###############################################################################
### 6. Export Step (add target "X")
###############################################################################
if(${PARAM_ENABLE_EXPORT_MODULE})
	message("")
	message("")
	message("📤 ========== [6] Install Rules & Export Definitions =============")
	include(ExportGenModule)
endif()
###############################################################################


###############################################################################
### 7. Packaging Step (add target "X")
###############################################################################
if(${PARAM_ENABLE_PACKAGE_MODULE})
	message("")
	message("")
	message("📦 ========== [7] Packaging Specification & Artifact Output ======")
	include(PackageGenModule)
endif()
###############################################################################


message("")
message("===== End of Build Lifecycle \"${PROJECT_NAME}\" generation =====")
message("")
