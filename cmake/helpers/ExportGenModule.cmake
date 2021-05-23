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
include(Print)


#---- Create the header file with macros for exporting. ----
# Generate the macro header file only for library build targets.
if(NOT ${${PROJECT_NAME}_MAIN_BIN_TARGET_IS_EXEC})
	# Set output files, directories and names.
	set(${PROJECT_NAME}_EXPORT_MACRO_BASE_NAME     "${PROJECT_NAME}")
	string_manip(SPLIT_TRANSFORM ${PROJECT_NAME}_EXPORT_MACRO_BASE_NAME C_IDENTIFIER_UPPER)
	set(${PROJECT_NAME}_INCLUDE_GUARD_NAME         "${${PROJECT_NAME}_EXPORT_MACRO_BASE_NAME}_EXPORT_H")
	set(${PROJECT_NAME}_EXPORT_MACRO_HEADER_FILE   "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}/${PROJECT_NAME}_export.h")

	# Generate the export macros in an header file.
	include(GenerateExportHeader)
	generate_export_header("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
		BASE_NAME "${${PROJECT_NAME}_EXPORT_MACRO_BASE_NAME}"
		EXPORT_FILE_NAME  "${${PROJECT_NAME}_EXPORT_MACRO_HEADER_FILE}"
		INCLUDE_GUARD_NAME "${${PROJECT_NAME}_INCLUDE_GUARD_NAME}"
		DEFINE_NO_DEPRECATED
	)
	print(STATUS "Header file with export macros generated: @rp@" "${${PROJECT_NAME}_EXPORT_MACRO_HEADER_FILE}")
	message("")
endif()


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
set(${PROJECT_NAME}_INSTALL_REALTIVE_BIN_DIR        "${CMAKE_INSTALL_BINDIR}")                        # in absolute: <CMAKE_INSTALL_PREFIX>/bin
set(${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR   "${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}")   # in absolute: <CMAKE_INSTALL_PREFIX>/share/<project-name>
set(${PROJECT_NAME}_INSTALL_RELATIVE_DOC_DIR        "${CMAKE_INSTALL_DOCDIR}")                        # in absolute: <CMAKE_INSTALL_PREFIX>/share/doc/<project-name>
set(${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR    "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}")    # in absolute: <CMAKE_INSTALL_PREFIX>/include/<project-name>
set(${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR    "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}")        # in absolute: <CMAKE_INSTALL_PREFIX>/lib/<project-name>

# Set the RPATH, see https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/RPATH-handling
set(CMAKE_SKIP_BUILD_RPATH              off) # Include RPATHs in the build-tree.
set(CMAKE_BUILD_WITH_INSTALL_RPATH      off) # Don't use the install RPATH already (but later on when installing)
set(CMAKE_INSTALL_RPATH_USE_LINK_PATH   on) # Add paths to linker search and installed rpath.
set(CMAKE_INSTALL_RPATH                 "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}") # The rpath to use for installed targets.

# Create a list of header files for INSTALL_INTERFACE of `target_sources()` command.
set(${PROJECT_NAME}_INSTALL_HEADER_FILES "${${PROJECT_NAME}_HEADER_PUBLIC_FILES}")
file_manip(STRIP_PATH ${PROJECT_NAME}_INSTALL_HEADER_FILES
	BASE_DIR "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}"
)
file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_HEADER_FILES
	BASE_DIR "${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}/${PROJECT_NAME}"
)

# Create a list of precompiled header files for INSTALL_INTERFACE of `target_precompile_headers()`
# command.
if(${PARAM_USE_PRECOMPILED_HEADER})
	set(${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
	file_manip(STRIP_PATH ${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE
		BASE_DIR "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}"
	)
	file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE
		BASE_DIR "${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}/${PROJECT_NAME}"
	)
endif()

# Create a list of library files for INSTALL_INTERFACE of `target_link_libraries()`.
set(${PROJECT_NAME}_INSTALL_LIBRARY_FILES "${${PROJECT_NAME}_LIBRARY_FILES}")
file_manip(STRIP_PATH ${PROJECT_NAME}_INSTALL_LIBRARY_FILES
	BASE_DIR "${${PROJECT_NAME}_LIB_DIR}"
)
file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_LIBRARY_FILES
	BASE_DIR "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}"
)

# Add usage requirements to the main binary build target for an import from the build-tree (BUILD_INTERFACE) or the install-tree (INSTALL_INTERFACE).
message(STATUS "Add usage requirements to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" for importing")

target_compile_features("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PUBLIC
		"$<BUILD_INTERFACE:cxx_std_${CMAKE_CXX_STANDARD}>"
		"$<INSTALL_INTERFACE:cxx_std_${CMAKE_CXX_STANDARD}>"
)
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_COMPILE_DEFINITIONS}>"
)
target_compile_options("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PUBLIC
		"$<BUILD_INTERFACE:>"
		"$<INSTALL_INTERFACE:>"
)
target_sources("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_HEADER_PUBLIC_FILES}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_HEADER_FILES}>"
)
if(${PARAM_USE_PRECOMPILED_HEADER})
	target_precompile_headers("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
		PUBLIC
			"$<BUILD_INTERFACE:${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}>"
			"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE}>"
	)
endif()
target_include_directories("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PUBLIC
		# For consummer within the current taget (header directory of the main binary build target).
		"$<BUILD_INTERFACE:$<FILTER:${${PROJECT_NAME}_HEADER_PUBLIC_DIR},EXCLUDE,${${PROJECT_NAME}_INCLUDE_DIR}.*>>" # exclude all subdirectories from `include/`
		# For consummer within the build (header directory of the libraries).
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_INCLUDE_DIR}>"
		# For consummer outside the build who import the current target after installation.
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}>"
)
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	PUBLIC
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_LIBRARY_FILES}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_LIBRARY_FILES}>"
)


#---- Exporting from the Build-Tree. ----
# See: https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets.
# See: https://cmake.org/cmake/help/latest/command/export.html
# See: https://cmake.org/cmake/help/latest/guide/importing-exporting/#exporting-targets-from-the-build-tree
message("")
message(STATUS "Export the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" from the build-tree")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Set output files, directories and names.
set(${PROJECT_NAME}_EXPORT_NAME               "${PROJECT_NAME}")
string_manip(SPLIT_TRANSFORM ${PROJECT_NAME}_EXPORT_NAME START_CASE)
set(${PROJECT_NAME}_EXPORT_NAMESPACE          "${PARAM_EXPORT_NAMESPACE}")
set(${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME   "${${PROJECT_NAME}_EXPORT_NAME}Targets.cmake")
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES EXPORT_NAME "${${PROJECT_NAME}_EXPORT_NAME}")

# Generate the export script `Targets.cmake` for importing the main binary build target coming from the build-tree.
export(TARGETS "${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	FILE "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}"
	NAMESPACE "${${PROJECT_NAME}_EXPORT_NAMESPACE}::"
)
print(STATUS "Export script for the build-tree generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "The target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" of the build-tree is now importable")


#---- Exporting from the Install-Tree. ----
# See: https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets.
# See: https://cmake.org/cmake/help/latest/command/install.html#installing-exports
# See: https://cmake.org/cmake/help/latest/guide/importing-exporting/#exporting-targets
message("")
message(STATUS "Export the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" from the install-tree")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Generate the install-tree and the install rules.
message(STATUS "Generate the install-tree and the install rules")

# Rule for assets in `assets/`.
install(DIRECTORY "${${PROJECT_NAME}_ASSETS_DIR}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}"
)
# Rule for the binary in `bin/`
install(TARGETS "${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	ARCHIVE DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}"
	LIBRARY DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}"
	RUNTIME DESTINATION "${${PROJECT_NAME}_INSTALL_REALTIVE_BIN_DIR}"
	PUBLIC_HEADER DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}"
)
# Rule for config in `config/`.
install(DIRECTORY "${${PROJECT_NAME}_CONFIG_DIR}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}"
)
# Rule for doc in `doc/`.
install(DIRECTORY "${${PROJECT_NAME}_DOC_DIR}/"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DOC_DIR}"
)
# Rule for public header files in `include/<project-name>` or `src/`.
install(DIRECTORY "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}/"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}/${PROJECT_NAME}"
	FILES_MATCHING REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$"
)
# Rule for library header files in `include/<...>`
foreach(directory IN ITEMS ${${PROJECT_NAME}_LIBRARY_HEADER_DIRS})
	install(DIRECTORY "${directory}"
		DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}"
		FILES_MATCHING REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$"
	)
endforeach()
# Rule for externals libraries in `lib/`.
install(FILES ${${PROJECT_NAME}_LIBRARY_FILES}
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}"
)
# Rule for externals resources in `resources/`.
install(DIRECTORY "${${PROJECT_NAME}_RESOURCES_DIR}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}"
)
# Generate the export script `Targets.cmake` for importing the main binary build target coming from the install-tree, and its install rules.
install(EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	NAMESPACE "${${PROJECT_NAME}_EXPORT_NAMESPACE}::"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake"
	FILE "${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}"
)
print(STATUS "Export script for the install-tree generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/CMakeFiles/Export/${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake/${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "The target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" of the install-tree is now importable")


#---- Create the package configuration files for the `find_package()` command. ----
# See https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html
# See https://cmake.org/cmake/help/latest/guide/importing-exporting/#creating-a-package-configuration-file
# See https://cmake.org/cmake/help/latest/command/find_package.html#full-signature-and-config-mode
# See https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html
message("")
message(STATUS "Make the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" foundable with the find_package() command")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

include(CMakePackageConfigHelpers)

# Set output files, directories and names.
set(${PROJECT_NAME}_PACKAGE_NAME                   "${${PROJECT_NAME}_EXPORT_NAME}")
set(${PROJECT_NAME}_PACKAGE_TEMPLATE_CONFIG_FILE   "${${PROJECT_NAME}_CMAKE_PROJECT_DIR}/ExportConfig.cmake.in")
set(${PROJECT_NAME}_PACKAGE_CONFIG_FILE            "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_PACKAGE_NAME}Config.cmake")
set(${PROJECT_NAME}_PACKAGE_VERSION_FILE           "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_PACKAGE_NAME}ConfigVersion.cmake")

# Generate a package config-file.
set(LOCAL_MAIN_BIN_TARGET           "${${PROJECT_NAME}_MAIN_BIN_TARGET}")
set(LOCAL_EXPORT_CONFIG_FILE_NAME   "${${PROJECT_NAME}_EXPORT_CONFIG_FILE_NAME}")
configure_package_config_file(
	"${${PROJECT_NAME}_PACKAGE_TEMPLATE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}"
	INSTALL_DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake"
	INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}"
)
unset(LOCAL_MAIN_BIN_TARGET)
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
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake"
)
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "The target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" can now be imported with the find_package() command")


#---- Generate the uninstall target. ----
if(NOT TARGET uninstall)
	message("")

	# Set output files, directories and names.
	set(${PROJECT_NAME}_UNINSTALL_TEMPLATE_SCRIPT_FILE  "${${PROJECT_NAME}_CMAKE_HELPERS_DIR}/cmake_uninstall.cmake.in")
	set(${PROJECT_NAME}_UNINSTALL_SCRIPT_FILE           "${${PROJECT_NAME}_BUILD_DIR}/cmake_uninstall.cmake")
	
	# Add uninstall rules.
	message(STATUS "Generate the uninstall rules")
	set(LOCAL_BUILD_DIR "${${PROJECT_NAME}_BUILD_DIR}")
	set(LOCAL_INSTALL_RELATIVE_DATAROOT_DIR   "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}")
	set(LOCAL_INSTALL_RELATIVE_DOC_DIR        "${${PROJECT_NAME}_INSTALL_RELATIVE_DOC_DIR}")
	set(LOCAL_INSTALL_RELATIVE_INCLUDE_DIR    "${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}")
	set(LOCAL_INSTALL_RELATIVE_LIBRARY_DIR    "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}")
	configure_file(
		"${${PROJECT_NAME}_UNINSTALL_TEMPLATE_SCRIPT_FILE}"
		"${${PROJECT_NAME}_UNINSTALL_SCRIPT_FILE}"
		@ONLY
	)
	unset(LOCAL_BUILD_DIR)
	unset(LOCAL_INSTALL_RELATIVE_DATAROOT_DIR)
	unset(LOCAL_INSTALL_RELATIVE_DOC_DIR)
	unset(LOCAL_INSTALL_RELATIVE_INCLUDE_DIR)
	unset(LOCAL_INSTALL_RELATIVE_LIBRARY_DIR)
	print(STATUS "Uninstall script generated: @rp@" "${${PROJECT_NAME}_UNINSTALL_SCRIPT_FILE}")
	
	# Add the uninstall target.
	message(STATUS "Add the uninstall target")
	add_custom_target("uninstall"
		COMMAND ${CMAKE_COMMAND} -P "${${PROJECT_NAME}_UNINSTALL_SCRIPT_FILE}"
		WORKING_DIRECTORY "${${PROJECT_NAME}_BUILD_DIR}"
		COMMENT "Uninstall the project..."
		VERBATIM
	)
else()
	message(STATUS "Uninstall target already exists, don't need to generate it again")
endif()