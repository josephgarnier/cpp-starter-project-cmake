# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

# Find Doxygen or auto-download it.
message(STATUS "Find Doxygen")
find_package(Doxygen)
if(NOT ${DOXYGEN_FOUND})
	message(STATUS "Doxygen not found, it will be auto-downloaded in the build-tree")
	include(FetchContent)
	set(FETCHCONTENT_QUIET off)
	FetchContent_Declare(doxygen
		GIT_REPOSITORY https://github.com/doxygen/doxygen.git
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
	FetchContent_MakeAvailable(doxygen)
else()
	message(STATUS "Doxygen found")
endif()

# Add package options.
# @see https://cmake.org/cmake/help/latest/module/FindDoxygen.html
# @see https://www.doxygen.nl/manual/config.html
message(STATUS "Add doc options")
include(DocOptions)
set(DOXYGEN_OUTPUT_DIRECTORY   "${${PROJECT_NAME}_DOC_DIR}")

# Generate a Doxygen config-file and add the doc target.
message(STATUS "Adding the doc target for generating documentation with Doxygen")
doxygen_add_docs(doc
	"${${PROJECT_NAME}_SRC_DIR};${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}"
	ALL
	WORKING_DIRECTORY "${${PROJECT_NAME}_DOC_DIR}"
	COMMENT "Generating documentation with Doxygen"
)
message(STATUS "Doc target added")
print(STATUS "Doxygen config-file generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/Doxyfile.doc")

# Add the generated documentation files to the `clean` target.
message(STATUS "Add the doc files to the clean target")
set_property(DIRECTORY "${${PROJECT_NAME}_PROJECT_DIR}"
	APPEND
	PROPERTY ADDITIONAL_CLEAN_FILES
	"${${PROJECT_NAME}_DOC_DIR}/html"
	"${${PROJECT_NAME}_DOC_DIR}/latex"
	"${${PROJECT_NAME}_BUILD_DIR}/CMakeDoxyfile.in"
	"${${PROJECT_NAME}_BUILD_DIR}/CMakeDoxygenDefaults.cmake"
	"${${PROJECT_NAME}_BUILD_DIR}/Doxyfile.doc"
)