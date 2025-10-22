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

message(STATUS "=================================================================")
message(STATUS "             🏗️  Buildsystem Generator Project                  ")
message(STATUS "                     of '${PARAM_PROJECT_NAME}'                ")
message(STATUS "=================================================================")
message(STATUS "⚙️  Loaded Options:")
message(STATUS "  🔧 Project Info:")
message(STATUS "     • Name              : ${PARAM_PROJECT_NAME}")
message(STATUS "     • Version           : ${PARAM_PROJECT_VERSION_MAJOR}.${PARAM_PROJECT_VERSION_MINOR}.${PARAM_PROJECT_VERSION_PATCH}")
message(STATUS "     • Author            : ${PARAM_PROJECT_VENDOR_NAME} (${PARAM_PROJECT_VENDOR_CONTACT})")
message(STATUS "     • Description       : ${PARAM_PROJECT_SUMMARY}")
message(STATUS "     • Generator         : ${CMAKE_GENERATOR}")
message(STATUS "  🔨 Build Settings:")
message(STATUS "     • C++ Standard      : ${PARAM_BUILD_STANDARD_VERSION}")
message(STATUS "     • Build Type        : ${CMAKE_BUILD_TYPE}")
message(STATUS "     • Toolchain File    : ${CMAKE_TOOLCHAIN_FILE}")
message(STATUS "     • Compile Commands  : ${PARAM_GENERATE_COMPILE_COMMANDS}")
message(STATUS "  🧪 Test Rules Generator:")
message(STATUS "     • Enabled           : ${PARAM_ENABLE_TEST_MODULE}")
message(STATUS "  📊 Code Analysis Rules Generator:")
message(STATUS "     • Enabled           : ${PARAM_ENABLE_CODE_ANALYSIS_MODULE}")
message(STATUS "  📚 Documentation Rules Generator:")
message(STATUS "     • Enabled           : ${PARAM_ENABLE_DOC_MODULE}")
message(STATUS "  📤 Export Rules Generator:")
message(STATUS "     • Enabled           : ${PARAM_ENABLE_EXPORT_MODULE}")
message(STATUS "     • Export Namespace  : ${PARAM_EXPORT_NAMESPACE}")
message(STATUS "     • Install Dir       : ${PARAM_INSTALL_DIRECTORY}")
message(STATUS "  📦 Packaging Rules Generator:")
message(STATUS "     • Enabled           : ${PARAM_ENABLE_PACKAGE_MODULE}")


###############################################################################
### 1. Buildsystem project setup
###############################################################################
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "🔨 [1/7] Buildsystem Project Setup")

####################### Check the project identifier ##########################
if(NOT DEFINED PARAM_PROJECT_NAME)
  message(FATAL_ERROR "Project identifier is not valid: PARAM_PROJECT_NAME must be specified!")
endif()
if("${PARAM_PROJECT_NAME}" MATCHES " ")
  message(FATAL_ERROR "Project identifier is not valid: PARAM_PROJECT_NAME '${PARAM_PROJECT_NAME}' cannot contain spaces!")
endif()
message(VERBOSE "Project identifier '${PARAM_PROJECT_NAME}' validated")

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
message(STATUS "Project declared")

####################### Define and check project structure ####################
set(${PROJECT_NAME}_PROJECT_DIR             "${CMAKE_CURRENT_SOURCE_DIR}")
set(${PROJECT_NAME}_ASSETS_DIR              "${${PROJECT_NAME}_PROJECT_DIR}/assets")
set(${PROJECT_NAME}_BIN_DIR                 "${${PROJECT_NAME}_PROJECT_DIR}/bin")
set(${PROJECT_NAME}_BUILD_DIR               "${CMAKE_CURRENT_BINARY_DIR}")
set(${PROJECT_NAME}_CMAKE_DIR               "${${PROJECT_NAME}_PROJECT_DIR}/cmake")
set(${PROJECT_NAME}_CMAKE_INTERNAL_DIR      "${${PROJECT_NAME}_CMAKE_DIR}/internal")
set(${PROJECT_NAME}_CMAKE_MODULES_DIR       "${${PROJECT_NAME}_CMAKE_DIR}/modules")
set(${PROJECT_NAME}_CMAKE_RULES_DIR         "${${PROJECT_NAME}_CMAKE_DIR}/rules")
set(${PROJECT_NAME}_CMAKE_TOOLCHAINS_DIR    "${${PROJECT_NAME}_CMAKE_DIR}/toolchains")
set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"
  "${${PROJECT_NAME}_CMAKE_INTERNAL_DIR}"
  "${${PROJECT_NAME}_CMAKE_MODULES_DIR}"
  "${${PROJECT_NAME}_CMAKE_RULES_DIR}"
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
  "${${PROJECT_NAME}_CMAKE_RULES_DIR}"
  "${${PROJECT_NAME}_CMAKE_TOOLCHAINS_DIR}"
  "${${PROJECT_NAME}_CONFIG_DIR}"
  "${${PROJECT_NAME}_DOC_DIR}"
  "${${PROJECT_NAME}_INCLUDE_DIR}"
  "${${PROJECT_NAME}_LIB_DIR}"
  "${${PROJECT_NAME}_RESOURCES_DIR}"
  "${${PROJECT_NAME}_SRC_DIR}"
  "${${PROJECT_NAME}_TESTS_DIR}")

if((NOT "${CMAKE_CURRENT_SOURCE_DIR}" STREQUAL "${CMAKE_SOURCE_DIR}")
  OR (NOT "${CMAKE_CURRENT_BINARY_DIR}" STREQUAL "${CMAKE_BINARY_DIR}"))
  message(FATAL_ERROR "Project structure is invalid: this CMakeLists.txt file must be in the project root directory!")
endif()
foreach(folder IN ITEMS ${${PROJECT_NAME}_PROJECT_DIRS})
  if((NOT EXISTS "${folder}") OR (NOT IS_DIRECTORY "${folder}"))
    message(FATAL_ERROR "Project structure is invalid: missing directory ${folder}!")
  endif()
endforeach()

message(VERBOSE "Project source-tree located in ${${PROJECT_NAME}_PROJECT_DIR}")
message(VERBOSE "Project build-tree located in ${${PROJECT_NAME}_BUILD_DIR}")

# Build folder must be in the `build/` directory
if(NOT "${${PROJECT_NAME}_BUILD_DIR}" MATCHES "^${${PROJECT_NAME}_PROJECT_DIR}/build")
  message(FATAL_ERROR "Project structure is invalid: the build folder '${${PROJECT_NAME}_BUILD_DIR}' must be inside the directory '<project-dir>/build/'!")
endif()

message(VERBOSE "Project structure validated")

####################### Import CMake functions and macros #####################
# CMake extra commands
include(Project)
include(TargetDependency)
include(UserInput)

# CMake modules
include(CMakePackageConfigHelpers)
include(FetchContent)
include(GenerateExportHeader)
include(GNUInstallDirs)

# Local modules
include(BinaryTarget)
include(CMakeTargetsFile)
include(Debug)
include(Dependency)
include(Directory)
include(FileManip)
include(Map)
include(Print)
include(StringManip)

message(STATUS "Project initialized")


###############################################################################
### 2. Application binaries configuration (add all app binary targets)
###############################################################################
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "🧱 [2/7] Binaries Configuration")

####################### Detect architecture and configure system infos ########
if(NOT CMAKE_SYSTEM_PROCESSOR)
  set(CMAKE_SYSTEM_PROCESSOR ${CMAKE_HOST_SYSTEM_PROCESSOR})
endif()
message(STATUS "Processor architecture is ${CMAKE_SYSTEM_PROCESSOR}")
set(SYSTEM_NAME "${CMAKE_SYSTEM_NAME}-${CMAKE_CXX_COMPILER_ID}-${CMAKE_SYSTEM_PROCESSOR}")
string(TOLOWER ${SYSTEM_NAME} SYSTEM_NAME)
message(STATUS "System name set to ${SYSTEM_NAME}")

####################### Set output directories ################################
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY           "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_DEBUG     "${${PROJECT_NAME}_BIN_DIR}")
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY_RELEASE   "${${PROJECT_NAME}_BIN_DIR}")
print(STATUS "Built files will be located into '@rp@/'" "${${PROJECT_NAME}_BIN_DIR}")

####################### Set C++ build environment #############################
validate_cxx_standard_version(is_valid err_msg on "${PARAM_BUILD_STANDARD_VERSION}")
set(CMAKE_CXX_STANDARD "${PARAM_BUILD_STANDARD_VERSION}")
set(CMAKE_CXX_STANDARD_REQUIRED on)
message(STATUS "C++ standard version set to C++${CMAKE_CXX_STANDARD}")

validate_build_type(is_valid err_msg on "${CMAKE_BUILD_TYPE}")
message(STATUS "Build type set to ${CMAKE_BUILD_TYPE}")

################### Organize IDE folders and configure generator settings #####
set(CMAKE_FOLDER "PredefinedTargets")
set_property(GLOBAL PROPERTY USE_FOLDERS on)
set_property(GLOBAL PROPERTY PREDEFINED_TARGETS_FOLDER "${CMAKE_FOLDER}")
message(STATUS "Predefined targets moved to folder '${CMAKE_FOLDER}'")

# Enable compile_commands.json if requested
set(CMAKE_EXPORT_COMPILE_COMMANDS "${PARAM_GENERATE_COMPILE_COMMANDS}")
if(${CMAKE_EXPORT_COMPILE_COMMANDS})
  message(STATUS "Compile commands export enabled (compile_commands.json will be generated)")
else()
  message(STATUS "Compile commands export disabled")
endif()

####################### Load target settings ##################################
message(CHECK_START "Loading CMakeTargets file")
cmake_targets_file(LOAD "${${PROJECT_NAME}_PROJECT_DIR}/CMakeTargets.json")
message(CHECK_PASS "done")

####################### Process subfolders ####################################
message(STATUS "Enter in directory 'src/'")
add_subdirectory(src)
message(STATUS "Leave directory 'src/'")
###############################################################################


###############################################################################
### 3. Test Step (add target "X")
###############################################################################
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "🧪 [3/7] Test Suite Configuration")
if(${PARAM_ENABLE_TEST_MODULE})
  include(TestGenModule)
else()
  message(STATUS "Test suite generation is disabled - skipping step")
endif()
###############################################################################


###############################################################################
### 4. Code Analysis Step (add target "X")
###############################################################################
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "📊 [4/7] Code Analysis Configuration")
if(${PARAM_ENABLE_CODE_ANALYSIS_MODULE})
  include(CodeAnalysisGenModule)
else()
  message(STATUS "Code analysis generation is disabled - skipping step")
endif()
###############################################################################


###############################################################################
### 5. Documentation Step (add target "X")
###############################################################################
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "📚 [5/7] Documentation System Setup")
if(${PARAM_ENABLE_DOC_MODULE})
  include(DocGenModule)
else()
  message(STATUS "Documentation generation is disabled - skipping step")
endif()
###############################################################################


###############################################################################
### 6. Export Step (add target "X")
###############################################################################
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "📤 [6/7] Install Rules & Export Definitions")
if(${PARAM_ENABLE_EXPORT_MODULE})
  include(ExportGenModule)
else()
  message(STATUS "Export generation is disabled - skipping step")
endif()
###############################################################################


###############################################################################
### 7. Packaging Step (add target "X")
###############################################################################
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "📦 [7/7] Packaging Specification & Artifact Output")
if(${PARAM_ENABLE_PACKAGE_MODULE})
  include(PackageGenModule)
else()
  message(STATUS "Packaging generation is disabled - skipping step")
endif()
###############################################################################


####################### Project summary ##########################################
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "📄 Project '${PROJECT_NAME}' Configuration Summary:")
list(APPEND CMAKE_MESSAGE_INDENT "  ")
message(STATUS "• C++ standard          : C++${CMAKE_CXX_STANDARD}")
message(STATUS "• Build configuration   : ${CMAKE_BUILD_TYPE} (${CMAKE_GENERATOR})")
message(STATUS "• Source-tree           : ${${PROJECT_NAME}_PROJECT_DIR}")
message(STATUS "• Build-tree            : ${${PROJECT_NAME}_BUILD_DIR}")
message(STATUS "• Output directory      : ${${PROJECT_NAME}_BIN_DIR}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
print_target_status_summaries()
message(STATUS "")
message(STATUS "=================================================================")
message(STATUS "✅ Buildsystem generation completed")
