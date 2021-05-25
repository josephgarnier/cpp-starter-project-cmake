# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

include(StringManip)


#---- Add the test binary build target. ----
set(${PROJECT_NAME}_TEST_BIN_TARGET "${PROJECT_NAME}_test")
message(STATUS "Add the test target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")
add_executable("${${PROJECT_NAME}_TEST_BIN_TARGET}" EXCLUDE_FROM_ALL)

# Add the test binary build target in a folder for IDE project.
set_target_properties("${${PROJECT_NAME}_TEST_BIN_TARGET}" PROPERTIES FOLDER "")


#---- Add the compiler features, compile definitions and compile options to the test binary build target. ----
# Add compiler features to the test binary build target.
message(STATUS "Add compile features to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")
target_compile_features("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	PRIVATE
		"cxx_std_${CMAKE_CXX_STANDARD}"
)

# Add compile definitions to the test binary build target.
message(STATUS "Add compile definitions to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")
target_compile_definitions("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_COMPILE_DEFINITIONS}"
)

# Add compile options to the test binary build target.
message(STATUS "Add compile options to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")
target_compile_options("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	PRIVATE
		"-O0;-g;-fprofile-arcs;-ftest-coverage"
)

# Add link options to the test binary build target.
message(STATUS "Add link options to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")
target_link_options("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	PRIVATE
		"-O0;-g;-fprofile-arcs;-ftest-coverage"
)


#---- Add source and header files to the test binary build target. ----
message(STATUS "Check source and header files")

set(${PROJECT_NAME}_SOURCE_TESTS_FILES "")
directory(SCAN ${PROJECT_NAME}_SOURCE_TESTS_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_TESTS_DIR}"
	INCLUDE_REGEX ".*[.]cpp$|.*[.]cc|.*[.]cxx$"
)
set(${PROJECT_NAME}_HEADER_TESTS_FILES "")
directory(SCAN ${PROJECT_NAME}_HEADER_TESTS_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_TESTS_DIR}"
	INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$"
)

message(STATUS "Found the following source files:")
print(STATUS PATHS "${${PROJECT_NAME}_SOURCE_TESTS_FILES}" INDENT)
message(STATUS "Found the following header files:")
print(STATUS PATHS "${${PROJECT_NAME}_HEADER_TESTS_FILES}" INDENT)

# Add source and header files to the test binary build target.
message(STATUS "Add the found source and header files to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")
target_sources("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_SOURCE_TESTS_FILES}"
		"${${PROJECT_NAME}_HEADER_TESTS_FILES}"
)
source_group(TREE "${${PROJECT_NAME}_PROJECT_DIR}"
	FILES
		${${PROJECT_NAME}_SOURCE_TESTS_FILES}
		${${PROJECT_NAME}_HEADER_TESTS_FILES}
)


#---- Add the header directories to the test binary build target. ----
# Add header directories to incude directories of the test binary build target.
message(STATUS "Add the following header directories to include directories of the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\":")
target_include_directories("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	PRIVATE
		"${${PROJECT_NAME}_TESTS_DIR}"
)
print(STATUS PATHS "${${PROJECT_NAME}_TESTS_DIR}" INDENT)


#---- Add the precompiled header, header directories and dependencies of the main binary build target to the test binary build target. ----
message(STATUS "")
message(STATUS "Copy of the usage requirements of the target to be tested \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" into the test target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")

# Copy the sources property.
message(STATUS "Copy the sources property")
get_target_property(main_bin_target_sources "${${PROJECT_NAME}_MAIN_BIN_TARGET}" SOURCES)
if(main_bin_target_sources)
	string_manip(STRIP_INTERFACES main_bin_target_sources)
	target_sources("${${PROJECT_NAME}_TEST_BIN_TARGET}"
		PRIVATE
			# The main source file of the main binary build target is excluded from the test binary build target.
			"$<FILTER:${main_bin_target_sources},EXCLUDE,${${PROJECT_NAME}_MAIN_SOURCE_FILE}>"
	)
	source_group(TREE "${${PROJECT_NAME}_PROJECT_DIR}"
		FILES
			$<FILTER:${main_bin_target_sources},EXCLUDE,${${PROJECT_NAME}_MAIN_SOURCE_FILE}>
	)
endif()

# Copy the precompiled header file property.
if(${PARAM_USE_PRECOMPILED_HEADER})
	message(STATUS "Copy the precompiled header property")
	get_target_property(main_bin_target_precompiled_header "${${PROJECT_NAME}_MAIN_BIN_TARGET}" PRECOMPILE_HEADERS)
	string_manip(STRIP_INTERFACES main_bin_target_precompiled_header)
	target_precompile_headers("${${PROJECT_NAME}_TEST_BIN_TARGET}"
		PRIVATE
			"${main_bin_target_precompiled_header}"
	)
else()
	message(STATUS "No precompiled header file to copy")
endif()

# Copy the include directories property.
message(STATUS "Copy the include directories property")
get_target_property(main_bin_target_include_directories "${${PROJECT_NAME}_MAIN_BIN_TARGET}" INCLUDE_DIRECTORIES)
if(main_bin_target_include_directories)
	string_manip(STRIP_INTERFACES main_bin_target_include_directories)
	target_include_directories("${${PROJECT_NAME}_TEST_BIN_TARGET}"
		PRIVATE
			"${main_bin_target_include_directories}"
	)
endif()

# Copy the link libraries property.
message(STATUS "Copy the link libraries property")
get_target_property(main_bin_target_link_libraries "${${PROJECT_NAME}_MAIN_BIN_TARGET}" LINK_LIBRARIES)
if(main_bin_target_link_libraries)
	string_manip(STRIP_INTERFACES main_bin_target_link_libraries)
	target_link_libraries("${${PROJECT_NAME}_TEST_BIN_TARGET}"
		PRIVATE
			"${main_bin_target_link_libraries}"
	)
endif()
message(STATUS "Copy of the usage requirements of the target to be tested \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" into the test target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\" - done")


#---- Add GTest to the test binary build target. ----
message("")
message(STATUS "Add the test framework to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")

# Find GTest or auto-download it.
message(STATUS "Find GTest")
find_package(GTest)
if(NOT ${GTest_FOUND})
	message(STATUS "GTest not found, it will be auto-downloaded in the build-tree")
	include(FetchContent)
	set(FETCHCONTENT_QUIET off)
	FetchContent_Declare(googletest
		GIT_REPOSITORY https://github.com/google/googletest.git
		GIT_TAG master
		GIT_PROGRESS on
		STAMP_DIR "${${PROJECT_NAME}_BUILD_DIR}"
		DOWNLOAD_NO_PROGRESS off
		LOG_DOWNLOAD on
		LOG_UPDATE on
		LOG_PATCH on
		LOG_CONFIGURE on
		LOG_BUILD on
		LOG_INSTALL on
		LOG_TEST on
		LOG_MERGED_STDOUTERR on
		LOG_OUTPUT_ON_FAILURE on
		USES_TERMINAL_DOWNLOAD on
	)
	FetchContent_GetProperties(googletest)
	if(NOT ${googletest_POPULATED})
		FetchContent_Populate(googletest)
		add_subdirectory("${googletest_SOURCE_DIR}" "${googletest_BINARY_DIR}" EXCLUDE_FROM_ALL)
	endif()
else()
	message(STATUS "GTest found")
endif()

# Add the GTest targets in a folder for IDE project.
set_target_properties("gtest" "gtest_main" "gmock" "gmock_main" PROPERTIES FOLDER "${CMAKE_FOLDER}/GTest")

# Add GTest compile definitions to the test binary build target.
message(STATUS "Add GTest compile definitions to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")
target_compile_definitions("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	PRIVATE
		"GTEST_HAS_PTHREAD=0;GTEST_CREATE_SHARED_LIBRARY=1;GTEST_LINKED_AS_SHARED_LIBRARY=1"
)

# Link GTest to the test binary build target.
message(STATUS "Link GTest library to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	PRIVATE
		"GTest::gtest;GTest::gtest_main;GTest::gmock;GTest::gmock_main"
)

# Automatically add tests by querying the compiled test executable for available tests
message(STATUS "Discover and add tests to the target \"${${PROJECT_NAME}_TEST_BIN_TARGET}.\"")
gtest_discover_tests("${${PROJECT_NAME}_TEST_BIN_TARGET}"
	WORKING_DIRECTORY "${${PROJECT_NAME}_TESTS_DIR}"
)
