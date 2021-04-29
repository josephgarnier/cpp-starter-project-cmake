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


#---- Add usage requirements. ----

# Set output files, directories and names.
if(DEFINED PARAM_INSTALL_DIRECTORY AND IS_DIRECTORY "${PARAM_INSTALL_DIRECTORY}")
	set(CMAKE_INSTALL_PREFIX "${PARAM_INSTALL_DIRECTORY}")
	message(STATUS "Set the install directory to \"${CMAKE_INSTALL_PREFIX}\"")
else()
	message(STATUS "No install directory set or it doesn't exists. The default path \"${CMAKE_INSTALL_PREFIX}\" will be used")
endif()
print(STATUS "Install script will be generated in \"@rp@\"" "${${PROJECT_NAME}_BUILD_DIR}/cmake_install.cmake")
include(GNUInstallDirs)
set(${PROJECT_NAME}_INSTALL_BIN_DIR                "${CMAKE_INSTALL_FULL_BINDIR}")                              # <CMAKE_INSTALL_PREFIX>/bin
set(${PROJECT_NAME}_INSTALL_DATAROOT_DIR           "${CMAKE_INSTALL_FULL_DATAROOTDIR}/${PROJECT_NAME}")         # <CMAKE_INSTALL_PREFIX>/share/<project-name>
set(${PROJECT_NAME}_INSTALL_DOC_DIR                "${CMAKE_INSTALL_FULL_DOCDIR}")                              # <CMAKE_INSTALL_PREFIX>/share/doc/<project-name>
set(${PROJECT_NAME}_INSTALL_INCLUDE_DIR            "${CMAKE_INSTALL_FULL_INCLUDEDIR}/${PROJECT_NAME}")          # <CMAKE_INSTALL_PREFIX>/include/<project-name>
set(${PROJECT_NAME}_INSTALL_LIBRARY_DIR            "${CMAKE_INSTALL_FULL_LIBDIR}/${PROJECT_NAME}")              # <CMAKE_INSTALL_PREFIX>/lib/<project-name>

# Set the RPATH, see https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/RPATH-handling
set(CMAKE_SKIP_BUILD_RPATH              off) # Include RPATHs in the build tree.
set(CMAKE_BUILD_WITH_INSTALL_RPATH      off) # Don't use the install RPATH already (but later on when installing)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH   on) # Add paths to linker search and installed rpath.
set(CMAKE_INSTALL_RPATH                 "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}") # The rpath to use for installed targets.

# Create a list of header files for INSTALL_INTERFACE of `target_sources()` command.
set(${PROJECT_NAME}_INSTALL_HEADER_FILES "${${PROJECT_NAME}_HEADER_PUBLIC_FILES}")
file_manip(STRIP_PATH ${PROJECT_NAME}_INSTALL_HEADER_FILES
	BASE_DIR "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}"
)
file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_HEADER_FILES
	BASE_DIR "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}/${PROJECT_NAME}"
)

# Create a list of precompiled header file for INSTALL_INTERFACE of `target_precompile_headers()`
# command.
set(${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
file_manip(STRIP_PATH ${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE
	BASE_DIR "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}"
)
file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE
	BASE_DIR "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}"
)

# Create a list of library files for INSTALL_INTERFACE of `target_link_libraries()`.
set(${PROJECT_NAME}_INSTALL_LIBRARY_FILES "${${PROJECT_NAME}_LIBRARY_FILES}")
file_manip(STRIP_PATH ${PROJECT_NAME}_INSTALL_LIBRARY_FILES
	BASE_DIR "${${PROJECT_NAME}_LIB_DIR}"
)
file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_LIBRARY_FILES
	BASE_DIR "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
)

# Add usage requirements to the build target for an import from the build tree (BUILD_INTERFACE) or install tree (INSTALL_INTERFACE).
message(STATUS "Add usage requirements to the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\" for importing")

target_compile_features("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:cxx_std_${CMAKE_CXX_STANDARD}>"
		"$<INSTALL_INTERFACE:cxx_std_${CMAKE_CXX_STANDARD}>"
)
target_compile_definitions("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
)
target_compile_options("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:>"
		"$<INSTALL_INTERFACE:>"
)
target_sources("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_HEADER_PUBLIC_FILES}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_HEADER_FILES}>"
)
if(${PROJECT_NAME}_PRECOMPILED_HEADER_FILE)
	target_precompile_headers("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
		PUBLIC
			"$<BUILD_INTERFACE:${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}>"
			"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE}>"
	)
endif()
target_include_directories("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PUBLIC
		# For consummer within the build.
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_HEADER_PUBLIC_DIR}>"
		# For consummer outside the build who import the target after installation.
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}>"
)
target_link_libraries("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_LIBRARY_FILES}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_LIBRARY_FILES}>"
)


#---- Exporting from a Build Tree. ----
# See: https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets.
# See: https://cmake.org/cmake/help/latest/command/export.html
# See: https://cmake.org/cmake/help/latest/guide/importing-exporting/#exporting-targets-from-the-build-tree
message("")
message(STATUS "Export the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\" from the build tree")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Generate the export script `Targets.cmake` for importing the build target coming from the build tree,
set(${PROJECT_NAME}_EXPORT_NAME               "${PROJECT_NAME}Targets")
string_manip(TRANSFORM ${PROJECT_NAME}_EXPORT_NAME START_CASE)
set(${PROJECT_NAME}_EXPORT_NAMESPACE          "${PARAM_EXPORT_NAMESPACE}")
set(${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME   "${${PROJECT_NAME}_EXPORT_NAME}.cmake")
set_target_properties("${${PROJECT_NAME}_BUILD_TARGET_NAME}" PROPERTIES EXPORT_NAME "${${PROJECT_NAME}_EXPORT_NAME}")

export(TARGETS "${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	FILE "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}"
	NAMESPACE "${${PROJECT_NAME}_EXPORT_NAMESPACE}::"
)
print(STATUS "Export script for the build tree generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "The target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\" of the build tree is now importable")


#---- Exporting from an Install Tree. ----
# See: https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets.
# See: https://cmake.org/cmake/help/latest/command/install.html#installing-exports
# See: https://cmake.org/cmake/help/latest/guide/importing-exporting/#exporting-targets
message("")
message(STATUS "Export the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\" from the install tree")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Generate the install tree and the install rules.
message(STATUS "Generate the install tree and the install rules")

# Rule for assets in `assets/`.
install(DIRECTORY "${${PROJECT_NAME}_ASSETS_DIR}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_DATAROOT_DIR}"
)
# Rule for the binary in `bin/`
install(TARGETS "${${PROJECT_NAME}_BUILD_TARGET_NAME}"
	EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	ARCHIVE DESTINATION "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
	LIBRARY DESTINATION "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
	RUNTIME DESTINATION "${${PROJECT_NAME}_INSTALL_BIN_DIR}"
	PUBLIC_HEADER DESTINATION "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}"
)
# Rule for config in `config/`.
install(DIRECTORY "${${PROJECT_NAME}_CONFIG_DIR}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_DATAROOT_DIR}"
)
# Rule for doc in `doc/`.
install(DIRECTORY "${${PROJECT_NAME}_DOC_DIR}/"
	DESTINATION "${${PROJECT_NAME}_INSTALL_DOC_DIR}"
)
# Rule for public header files in `include/<project-name>` or `src/`.
install(DIRECTORY "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}/"
	DESTINATION "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}/${PROJECT_NAME}"
	FILES_MATCHING REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$"
)
# Rule for library header files in `include/<...>`
foreach(directory IN ITEMS ${${PROJECT_NAME}_LIBRARY_HEADER_DIRS})
	install(DIRECTORY "${directory}"
		DESTINATION "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}"
		FILES_MATCHING REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$"
	)
endforeach()
# Rule for externals libraries in `lib/`.
install(FILES ${${PROJECT_NAME}_LIBRARY_FILES}
	DESTINATION "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}"
)
# Rule for externals resources in `resources/`.
install(DIRECTORY "${${PROJECT_NAME}_RESOURCES_DIR}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_DATAROOT_DIR}"
)
# Generate the export script `Targets.cmake` for importing the build target coming from the install tree, and its install rule.
install(EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	NAMESPACE "${${PROJECT_NAME}_EXPORT_NAMESPACE}::"
	DESTINATION "${${PROJECT_NAME}_INSTALL_DATAROOT_DIR}/cmake"
	FILE "${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}"
)
print(STATUS "Export script for the install tree generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/CMakeFiles/Export${${PROJECT_NAME}_INSTALL_DATAROOT_DIR}/cmake/${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "The target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\" of the install tree is now importable")


#---- Create the package configuration files for the `find_package()` command. ----
# See https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html
# See https://cmake.org/cmake/help/latest/guide/importing-exporting/#creating-a-package-configuration-file
# See https://cmake.org/cmake/help/latest/command/find_package.html#full-signature-and-config-mode
# See https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html
message("")
message(STATUS "Make the target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\" foundable with the find_package() command")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

include(CMakePackageConfigHelpers)

# Set output files, directories and names.
set(${PROJECT_NAME}_PACKAGE_NAME                   "${${PROJECT_NAME}_EXPORT_NAME}")
set(${PROJECT_NAME}_PACKAGE_TEMPLATE_CONFIG_FILE   "${${PROJECT_NAME}_CMAKE_PROJECT_DIR}/ExportConfig.cmake.in")
set(${PROJECT_NAME}_PACKAGE_CONFIG_FILE            "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_PACKAGE_NAME}Config.cmake")
set(${PROJECT_NAME}_PACKAGE_VERSION_FILE           "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_PACKAGE_NAME}ConfigVersion.cmake")

# Generate a package config-file.
set(LOCAL_BUILD_TARGET_NAME         "${${PROJECT_NAME}_BUILD_TARGET_NAME}")
set(LOCAL_EXPORT_CONFIG_FILE_NAME   "${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}")
configure_package_config_file(
	"${${PROJECT_NAME}_PACKAGE_TEMPLATE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}"
	INSTALL_DESTINATION "${${PROJECT_NAME}_INSTALL_DATAROOT_DIR}/cmake"
	INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}"
)
unset(LOCAL_BUILD_TARGET_NAME)
unset(LOCAL_EXPORT_CONFIG_FILE_NAME)
print(STATUS "Export config-file generated: @rp@" "${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}")

# Generate a package version-file.
write_basic_package_version_file(
	"${${PROJECT_NAME}_PACKAGE_VERSION_FILE}"
	VERSION "${${PROJECT_NAME}_VERSION}"
	COMPATIBILITY AnyNewerVersion
)
print(STATUS "Export version-file generated: @rp@" "${${PROJECT_NAME}_PACKAGE_VERSION_FILE}")

# Store the current build directory in the CMake user package registry.
# See https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#user-package-registry
message(STATUS "Store the build directory in the user package registry")
export(PACKAGE "${${PROJECT_NAME}_PACKAGE_NAME}")

# Install the config-file and the version-file in cmake directory.
message(STATUS "Generate the install rules for config-file and version-file")
install(FILES
	"${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_VERSION_FILE}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_DATAROOT_DIR}/cmake"
)
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "The target \"${${PROJECT_NAME}_BUILD_TARGET_NAME}\" can now be imported with the find_package() command")
