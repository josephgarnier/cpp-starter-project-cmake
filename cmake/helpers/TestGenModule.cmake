# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.


#---- Add the test target. ----
set(${PROJECT_NAME}_TEST_TARGET_NAME "${PROJECT_NAME}_test")
message(STATUS "Add the test target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
add_executable("${${PROJECT_NAME}_TEST_TARGET_NAME}")


#---- Add the compiler features, compile definitions and compile options to the test target. ----

# Add compiler features to the test target.
message(STATUS "Add compile features to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
target_compile_features("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"cxx_std_${CMAKE_CXX_STANDARD}"
)

# Add compile definitions to the test target.
message(STATUS "Add compile definitions to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
target_compile_definitions("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"${${PROJECT_NAME}_COMPILE_DEFINITIONS}"
)

# Add compile options to the test target.
message(STATUS "Add compile options to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
target_compile_options("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"-O0;-g;-fprofile-arcs;-ftest-coverage"
)

# Add link options to the test target.
message(STATUS "Add link options to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
target_link_options("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"-O0;-g;-fprofile-arcs;-ftest-coverage"
)


#---- Add source and header files to the test target. ----
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

# Add source and header files to the test target.
message(STATUS "Add the found source and header files to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
target_sources("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"${${PROJECT_NAME}_SOURCE_TESTS_FILES}"
		"${${PROJECT_NAME}_HEADER_TESTS_FILES}"
)
message(STATUS "Add the source and header files to be tested to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
target_sources("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		# The main source file of the build target is excluded from the test target.
		"$<FILTER:${${PROJECT_NAME}_SOURCE_SRC_FILES},EXCLUDE,${${PROJECT_NAME}_MAIN_SOURCE_FILE}>"
		"${${PROJECT_NAME}_HEADER_PRIVATE_FILES}"
		"${${PROJECT_NAME}_HEADER_PUBLIC_FILES}"
)


#---- Add the precompiled header file to the test target. ----
message(STATUS "Check precompiled header file")
if(${PARAM_USE_PRECOMPILED_HEADER})
	message(STATUS "Add the precompiled header file to be tested to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
	target_precompile_headers("${${PROJECT_NAME}_TEST_TARGET_NAME}"
		PRIVATE
			"${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}"
	)
else()
	message(STATUS "Precompiled header file set off")
endif()


#---- Add the header directories to the test target. ----

# Add header directories to incude directories of the test target.
message(STATUS "Add the following header directories to include directories of the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\":")
target_include_directories("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"${${PROJECT_NAME}_TESTS_DIR}"
)
print(STATUS PATHS "${${PROJECT_NAME}_TESTS_DIR}" INDENT)
message(STATUS "Add the header directories to be tested to include directories of the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\":")
target_include_directories("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"$<$<BOOL:${${PROJECT_NAME}_HEADER_PRIVATE_DIR}>:${${PROJECT_NAME}_HEADER_PRIVATE_DIR}>"
		"${${PROJECT_NAME}_HEADER_PUBLIC_DIR}"
		"${${PROJECT_NAME}_INCLUDE_DIR}"
)


#---- Add GTest to the test target. ----
message("")

# Find GTest or auto-download it.
message(STATUS "Find GTest")
include(FetchContent)
find_package(GTest)
if(NOT GTEST_FOUND)
	message(STATUS "GTest not found, it will be auto-downloaded in the build-tree")
	set(FETCHCONTENT_QUIET off)
	FetchContent_Declare(
		googletest
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
	FetchContent_MakeAvailable(googletest)
else()
	message(STATUS "GTest found")
endif()

# Add GTest compile definitions to the test target.
message(STATUS "Add GTest compile definitions to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
target_compile_definitions("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"GTEST_HAS_PTHREAD=0;GTEST_CREATE_SHARED_LIBRARY=1;GTEST_LINKED_AS_SHARED_LIBRARY=1"
)

# Link GTest to the test target.
message(STATUS "Link GTest library to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
target_link_libraries("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	PRIVATE
		"GTest::gtest;GTest::gtest_main;GTest::gmock;GTest::gmock_main"
)

# Automatically add tests by querying the compiled test executable for available tests
message(STATUS "Discover and add tests to the target \"${${PROJECT_NAME}_TEST_TARGET_NAME}\"")
gtest_discover_tests("${${PROJECT_NAME}_TEST_TARGET_NAME}"
	WORKING_DIRECTORY "${${PROJECT_NAME}_TESTS_DIR}"
)
