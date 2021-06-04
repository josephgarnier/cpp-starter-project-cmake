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


#---- Add usage requirements for Build-Tree and Install-Tree. ----
# Set output files, directories and names.
if(DEFINED PARAM_INSTALL_DIRECTORY AND IS_DIRECTORY "${PARAM_INSTALL_DIRECTORY}")
	set(CMAKE_INSTALL_PREFIX "${PARAM_INSTALL_DIRECTORY}")
endif()
message(STATUS "Install-tree directory is set to \"${CMAKE_INSTALL_PREFIX}\"")
print(STATUS "Install script will be generated in \"@rp@\"" "${${PROJECT_NAME}_BUILD_DIR}/cmake_install.cmake")
include(GNUInstallDirs)
set(${PROJECT_NAME}_INSTALL_REALTIVE_BIN_DIR        "${CMAKE_INSTALL_BINDIR}")                        # in absolute: <CMAKE_INSTALL_PREFIX>/bin
set(${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR   "${CMAKE_INSTALL_DATAROOTDIR}/${PROJECT_NAME}")   # in absolute: <CMAKE_INSTALL_PREFIX>/share/<project-name>
set(${PROJECT_NAME}_INSTALL_RELATIVE_DOC_DIR        "${CMAKE_INSTALL_DOCDIR}")                        # in absolute: <CMAKE_INSTALL_PREFIX>/share/doc/<project-name>
set(${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR    "${CMAKE_INSTALL_INCLUDEDIR}/${PROJECT_NAME}")    # in absolute: <CMAKE_INSTALL_PREFIX>/include/<project-name>
set(${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR    "${CMAKE_INSTALL_LIBDIR}/${PROJECT_NAME}")        # in absolute: <CMAKE_INSTALL_PREFIX>/lib/<project-name>

# Set the RPATH, see https://gitlab.kitware.com/cmake/community/-/wikis/doc/cmake/RPATH-handling
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES
	SKIP_BUILD_RPATH off # Include RPATHs in the build-tree.
	BUILD_WITH_INSTALL_RPATH off # Don't use the install RPATH already (but later on when installing)
	BUILD_RPATH "${${PROJECT_NAME}_LIB_DIR}" # The RPATH to use in the build-tree.
	INSTALL_RPATH_USE_LINK_PATH on # Add paths to linker search and installed rpath.
	INSTALL_RPATH "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}" # The RPATH to use in the install-tree.
)

# Create a list of header files for INSTALL_INTERFACE of `target_sources()` command.
set(${PROJECT_NAME}_INSTALL_HEADER_FILES "${${PROJECT_NAME}_HEADER_PUBLIC_FILES}")
file_manip(STRIP_PATH ${PROJECT_NAME}_INSTALL_HEADER_FILES
	BASE_DIR "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}"
)
file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_HEADER_FILES
	BASE_DIR "${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}/${PROJECT_NAME}"
)

# Create a precompiled header file for INSTALL_INTERFACE of `target_precompile_headers()`
# command.
if(${PARAM_USE_PRECOMPILED_HEADER})
	set(${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE "${${PROJECT_NAME}_PRECOMPILED_HEADER_FILE}")
	file_manip(STRIP_PATH ${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE
		BASE_DIR "${${PROJECT_NAME}_HEADER_PUBLIC_DIR}"
	)
	file_manip(ABSOLUTE_PATH ${PROJECT_NAME}_INSTALL_PRECOMPILED_HEADER_FILE
		BASE_DIR "\${_IMPORT_PREFIX}/${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}/${PROJECT_NAME}"  # Bug fix, because for some unknown reason the prefix is not added by export command.
	)
endif()

# Add usage requirements to imported internal library targets for an import from the build-tree (BUILD_INTERFACE) or the install-tree (INSTALL_INTERFACE).
message(STATUS "Add usage requirements to imported internal libraries for transitive importing")
set(${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARY_FILES "")
set(${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARY_HEADER_DIRS "")
foreach(imported_library IN ITEMS ${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES})
	get_target_property(header_dir "${imported_library}" INTERFACE_INCLUDE_DIRECTORIES)
	list(APPEND ${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARY_HEADER_DIRS "${header_dir}")
	dependency(INCLUDE_DIRECTORIES "${imported_library}" SET
		PUBLIC
			"$<BUILD_INTERFACE:${${PROJECT_NAME}_INCLUDE_DIR}>"
			"$<INSTALL_INTERFACE:${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}>"
	)
	# Usage requirements for each supported configuration type (in other words each supported build type).
	get_target_property(library_supported_config_types "${imported_library}" IMPORTED_CONFIGURATIONS)
	foreach(config_type IN ITEMS ${library_supported_config_types})
		get_target_property(library_file "${imported_library}" IMPORTED_LOCATION_${config_type})
		set(install_library_file "${library_file}")
		file_manip(STRIP_PATH install_library_file
			BASE_DIR "${${PROJECT_NAME}_LIB_DIR}"
		)
		file_manip(ABSOLUTE_PATH install_library_file
			BASE_DIR "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}"
		)
		dependency(IMPORTED_LOCATION "${imported_library}" CONFIGURATION "${config_type}"
			PUBLIC
				"$<BUILD_INTERFACE:${library_file}>"
				"$<INSTALL_INTERFACE:${install_library_file}>"
		)
		list(APPEND ${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARY_FILES "${library_file}")
	endforeach()
endforeach()

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
		"$<BUILD_INTERFACE:${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}>"
		"$<INSTALL_INTERFACE:${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES}>"
)


#---- Exporting from the Build-Tree. ----
# @see: https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets.
# @see: https://cmake.org/cmake/help/latest/command/export.html
# @see: https://cmake.org/cmake/help/latest/guide/importing-exporting/#exporting-targets-from-the-build-tree
message("")
message(STATUS "Export all targets from the build-tree")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Set output files, directories and names.
set(${PROJECT_NAME}_EXPORT_NAME                     "${PROJECT_NAME}")
string_manip(SPLIT_TRANSFORM ${PROJECT_NAME}_EXPORT_NAME START_CASE)
set(${PROJECT_NAME}_EXPORT_NAMESPACE                "${PARAM_EXPORT_NAMESPACE}")
set(${PROJECT_NAME}_EXPORT_FILE_NAME         "${${PROJECT_NAME}_EXPORT_NAME}Targets.cmake")
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES EXPORT_NAME "${${PROJECT_NAME}_EXPORT_NAME}")
set(${PROJECT_NAME}_EXPORT_INTERNAL_DEP_FILE_NAME   "DependenciesInternalTargets.cmake")

# Generate the export script `DependenciesIternalTargets.cmake` for importing of the imported internal libraries targets from the build-tree.
foreach(imported_library IN ITEMS ${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES})
	dependency(EXPORT "${imported_library}"
		BUILD_TREE
		APPEND
		OUTPUT_FILE "${${PROJECT_NAME}_EXPORT_INTERNAL_DEP_FILE_NAME}"
	)
endforeach()
print(STATUS "Export script for the imported internal libraries targets generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_INTERNAL_DEP_FILE_NAME}")

# Generate the export script `Targets.cmake` for importing of the main binary build target from the build-tree.
export(TARGETS "${${PROJECT_NAME}_MAIN_BIN_TARGET}"
	NAMESPACE "${${PROJECT_NAME}_EXPORT_NAMESPACE}::"
	FILE "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_FILE_NAME}"
)
print(STATUS "Export script for the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/${${PROJECT_NAME}_EXPORT_FILE_NAME}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "All targets are now importables from the build-tree")


#---- Exporting from the Install-Tree. ----
# @see: https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets.
# @see: https://cmake.org/cmake/help/latest/command/install.html#installing-exports
# @see: https://cmake.org/cmake/help/latest/guide/importing-exporting/#exporting-targets
message("")
message(STATUS "Export all targets from the install-tree")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Generate the install-tree and the install rules.
message(STATUS "Generate the install-tree and the install rules")

# Rule for assets in `assets/`.
install(DIRECTORY "${${PROJECT_NAME}_ASSETS_DIR}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}"
)

# Rule for all binaries in `bin/`
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

# Rule for imported internal library header files in `include/<...>`
foreach(imported_directory IN ITEMS ${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARY_HEADER_DIRS})
	install(DIRECTORY "${imported_directory}"
		DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_INCLUDE_DIR}"
		FILES_MATCHING REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$"
	)
endforeach()

# Rule for imported internal library files in `lib/`.
install(FILES ${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARY_FILES}
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_LIBRARY_DIR}"
)

# Rule for externals resources in `resources/`.
install(DIRECTORY "${${PROJECT_NAME}_RESOURCES_DIR}"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}"
)

# Generate the export script `DependenciesIternalTargets.cmake` and its install rules for importing of the imported internal libraries targets from the install-tree.
foreach(imported_library IN ITEMS ${${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES})
	dependency(EXPORT "${imported_library}"
		INSTALL_TREE
		APPEND
		OUTPUT_FILE "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake/${${PROJECT_NAME}_EXPORT_INTERNAL_DEP_FILE_NAME}"
	)
endforeach()
print(STATUS "Export script for the imported internal libraries targets generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/CMakeFiles/Export/${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake/${${PROJECT_NAME}_EXPORT_INTERNAL_DEP_FILE_NAME}")

# Generate the export script `Targets.cmake` from all `install(TARGETS)` and its install rules for importing of the main binary build target from the install-tree.
install(EXPORT "${${PROJECT_NAME}_EXPORT_NAME}"
	NAMESPACE "${${PROJECT_NAME}_EXPORT_NAMESPACE}::"
	DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake"
	FILE "${${PROJECT_NAME}_EXPORT_FILE_NAME}"
)
print(STATUS "Export script for the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" generated: @rp@" "${${PROJECT_NAME}_BUILD_DIR}/CMakeFiles/Export/${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake/${${PROJECT_NAME}_EXPORT_FILE_NAME}")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "All targets are now importable from the install-tree")


#---- Create the package configuration files for the `find_package()` command. ----
# @see https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html
# @see https://cmake.org/cmake/help/latest/guide/importing-exporting/#creating-a-package-configuration-file
# @see https://cmake.org/cmake/help/latest/command/find_package.html#full-signature-and-config-mode
# @see https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html
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
set(LOCAL_MAIN_BIN_TARGET                 "${${PROJECT_NAME}_MAIN_BIN_TARGET}")
set(LOCAL_EXPORT_FILE_NAME                "${${PROJECT_NAME}_EXPORT_FILE_NAME}")
set(LOCAL_EXPORT_INTERNAL_DEP_FILE_NAME   "${${PROJECT_NAME}_EXPORT_INTERNAL_DEP_FILE_NAME}")
configure_package_config_file(
	"${${PROJECT_NAME}_PACKAGE_TEMPLATE_CONFIG_FILE}"
	"${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}"
	INSTALL_DESTINATION "${${PROJECT_NAME}_INSTALL_RELATIVE_DATAROOT_DIR}/cmake"
	INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}"
)
unset(LOCAL_MAIN_BIN_TARGET)
unset(LOCAL_EXPORT_FILE_NAME)
unset(LOCAL_EXPORT_INTERNAL_DEP_FILE_NAME)
print(STATUS "Export config-file generated: @rp@" "${${PROJECT_NAME}_PACKAGE_CONFIG_FILE}")

# Generate a package version-file.
write_basic_package_version_file(
	"${${PROJECT_NAME}_PACKAGE_VERSION_FILE}"
	VERSION "${${PROJECT_NAME}_VERSION}"
	COMPATIBILITY AnyNewerVersion
)
print(STATUS "Export version-file generated: @rp@" "${${PROJECT_NAME}_PACKAGE_VERSION_FILE}")

# Store the current build directory in the CMake user package registry.
# @see https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html#user-package-registry
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


#---- Exporting from the Source-Tree. ----
message("")
message(STATUS "Export the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" from the source-tree")
list(APPEND CMAKE_MESSAGE_INDENT "  ")

# Alias the main binary build target to be included with `add_subdirectory()` command.
if(${${PROJECT_NAME}_MAIN_BIN_TARGET_IS_EXEC})
	add_executable("${${PROJECT_NAME}_EXPORT_NAMESPACE}::${${PROJECT_NAME}_EXPORT_NAME}" ALIAS "${${PROJECT_NAME}_MAIN_BIN_TARGET}")
elseif(${${PROJECT_NAME}_MAIN_BIN_TARGET_IS_STATIC}
	OR ${${PROJECT_NAME}_MAIN_BIN_TARGET_IS_SHARED}
	OR ${${PROJECT_NAME}_MAIN_BIN_TARGET_IS_HEADER})
	add_library("${${PROJECT_NAME}_EXPORT_NAMESPACE}::${${PROJECT_NAME}_EXPORT_NAME}" ALIAS "${${PROJECT_NAME}_MAIN_BIN_TARGET}")
else()
	message(FATAL_ERROR "A binary build target type must be \"static\" or \"shared\" or \"header\" or \"exec\"!")
endif()
message(STATUS "The target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" is now aliased as \"${${PROJECT_NAME}_EXPORT_NAMESPACE}::${${PROJECT_NAME}_EXPORT_NAME}\"")
list(POP_BACK CMAKE_MESSAGE_INDENT)
message(STATUS "The target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\" of the source-tree is now importable")


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