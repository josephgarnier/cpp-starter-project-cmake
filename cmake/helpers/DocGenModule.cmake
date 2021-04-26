# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

include(FetchContent)
find_package(Doxygen REQUIRED)
if(NOT DOXYGEN_FOUND)
	message(STATUS "Doxygen not found, it will be auto-downloaded in the build tree")
	set(FETCHCONTENT_QUIET off)
	FetchContent_Declare(
		doxygen
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
endif()

# Set output files, directories and names.
set(${PROJECT_NAME}_DOXYGEN_TEMPLATE_CONFIG_FILE   "${${PROJECT_NAME}_CMAKE_PROJECT_DIR}/DoxygenConfig.in")
set(${PROJECT_NAME}_DOXYGEN_CONFIG_FILE            "${${PROJECT_NAME}_BUILD_DIR}/doxyfile")

# Generate a Doxygen config-file.
configure_file(
	"${${PROJECT_NAME}_DOXYGEN_TEMPLATE_CONFIG_FILE}"
	"${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}"
	@ONLY
)
file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}")
message(STATUS "Doxygen config-file generated: ${relative_path}")

# Add `cmake --build build/ --target doc` command.
message(STATUS "Add the doc command")
add_custom_target(doc
	COMMAND ${DOXYGEN_EXECUTABLE} "${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}"
	SOURCES "${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}"
	WORKING_DIRECTORY "${${PROJECT_NAME}_DOC_DIR}"
	COMMENT "Generating documentation with Doxygen"
	VERBATIM
)

# Add uninstall target in a folder for IDE project generation.
get_cmake_property(target_folder PREDEFINED_TARGETS_FOLDER)
set_target_properties(doc PROPERTIES FOLDER "${target_folder}")
	
# Add the generated documentation files to `cmake --build . --target clean` command.
message(STATUS "Add the doc files to clean command")
set_property(DIRECTORY "${${PROJECT_NAME}_PROJECT_DIR}"
	APPEND
	PROPERTY ADDITIONAL_CLEAN_FILES
	"${${PROJECT_NAME}_DOC_DIR}/html"
	"${${PROJECT_NAME}_DOC_DIR}/latex"
	"${${PROJECT_NAME}_DOXYGEN_CONFIG_FILE}"
)