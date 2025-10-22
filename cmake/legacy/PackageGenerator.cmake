# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

# Add package options.
# @see https://cmake.org/cmake/help/latest/module/CPack.html
# @see https://cmake.org/cmake/help/latest/module/CPackComponent.html
# @see https://gitlab.kitware.com/cmake/community/-/wikis/doc/cpack/Packaging-With-CPack
# @see https://gitlab.kitware.com/cmake/community/-/wikis/doc/cpack/Component-Install-With-CPack
message(STATUS "Add packages options")
set(CPACK_OUTPUT_CONFIG_FILE_OLD "${CPACK_OUTPUT_CONFIG_FILE}")
set(CPACK_SOURCE_OUTPUT_CONFIG_FILE_OLD "${CPACK_SOURCE_OUTPUT_CONFIG_FILE}")
include(PackageOptions)
if((NOT "${CPACK_OUTPUT_CONFIG_FILE}" STREQUAL "${CPACK_OUTPUT_CONFIG_FILE_OLD}")
	OR (NOT "${CPACK_SOURCE_OUTPUT_CONFIG_FILE}" STREQUAL "${CPACK_SOURCE_OUTPUT_CONFIG_FILE_OLD}"))
	message(FATAL_ERROR "CPACK_OUTPUT_CONFIG_FILE or CPACK_SOURCE_OUTPUT_CONFIG_FILE don't have to be changed!")
endif()

# Set output files, directories and names.
# @see https://cmake.org/cmake/help/latest/manual/cpack.1.html
# @see https://cmake.org/cmake/help/latest/manual/cpack-generators.7.html
# @see https://github.com/Kitware/CMake/blob/master/CMakeCPackOptions.cmake.in
set(${PROJECT_NAME}_PACKAGE_GENERATOR_TEMPLATE_CONFIG_FILE   "${${PROJECT_NAME}_CMAKE_PROJECT_DIR}/PackageGeneratorConfig.cmake.in")
set(${PROJECT_NAME}_PACKAGE_GENERATOR_CONFIG_FILE            "${${PROJECT_NAME}_BUILD_DIR}/PackageGeneratorConfig.cmake")

# Generate the CPack config-file that will be loaded at the beginning of cpack time.
configure_file(
	"${${PROJECT_NAME}_PACKAGE_GENERATOR_TEMPLATE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_GENERATOR_CONFIG_FILE}"
	@ONLY
)
print(STATUS "Package generator config-file generated: @rp@" "${${PROJECT_NAME}_PACKAGE_GENERATOR_CONFIG_FILE}")
set(CPACK_PROJECT_CONFIG_FILE "${${PROJECT_NAME}_PACKAGE_GENERATOR_CONFIG_FILE}")

# Add the generated package files to the `clean` target
# (must be called before CPack because this one change the variables listed here).
message(STATUS "Add the package files to clean target")
set_property(DIRECTORY "${${PROJECT_NAME}_PROJECT_DIR}"
	APPEND
	PROPERTY ADDITIONAL_CLEAN_FILES
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.zip"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_SOURCE_PACKAGE_FILE_NAME}.zip"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.exe"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_SOURCE_PACKAGE_FILE_NAME}.exe"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_PACKAGE_FILE_NAME}.nsi"
	"${CPACK_PACKAGE_DIRECTORY}/${CPACK_SOURCE_PACKAGE_FILE_NAME}.nsi"
)

# Generate the CPack configuration file to create a binary package or a source package.
include(CPack)
print(STATUS "Binary package config-file generated: @rp@" "${CPACK_OUTPUT_CONFIG_FILE}")
print(STATUS "Source package config-file generated: @rp@" "${CPACK_SOURCE_OUTPUT_CONFIG_FILE}")
