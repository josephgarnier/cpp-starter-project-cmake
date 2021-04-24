# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

set(${PROJECT_NAME}_UNINSTALL_TEMPLATE_SCRIPT_FILE  "${${PROJECT_NAME}_CMAKE_HELPERS_DIR}/cmake_uninstall.cmake.in")
set(${PROJECT_NAME}_UNINSTALL_SCRIPT_FILE           "${${PROJECT_NAME}_BUILD_DIR}/cmake_uninstall.cmake")

# Add the target (or command) onyl if it doesn't exist.
if(NOT TARGET uninstall)
	# Add uninstall rules.
	message(STATUS "Generate the uninstall rules")
	set(LOCAL_BUILD_DIR "${${PROJECT_NAME}_BUILD_DIR}")
	set(LOCAL_INSTALL_INCLUDE_DIR "${${PROJECT_NAME}_INSTALL_INCLUDE_DIR}")
	set(LOCAL_INSTALL_LIBRARY_DIR "${${PROJECT_NAME}_INSTALL_LIBRARY_DIR}")
	configure_file(
		"${${PROJECT_NAME}_UNINSTALL_TEMPLATE_SCRIPT_FILE}"
		"${${PROJECT_NAME}_UNINSTALL_SCRIPT_FILE}"
		@ONLY
	)
	unset(LOCAL_BUILD_DIR)
	unset(LOCAL_INSTALL_INCLUDE_DIR)
	unset(LOCAL_INSTALL_LIBRARY_DIR)
	file(RELATIVE_PATH relative_path "${${PROJECT_NAME}_PROJECT_DIR}" "${${PROJECT_NAME}_UNINSTALL_SCRIPT_FILE}")
	message(STATUS "Uninstall script generated: ${relative_path}")
	
	# Add `make uninstall` command.
	message(STATUS "Add the uninstall command")
	add_custom_target(uninstall
		COMMAND ${CMAKE_COMMAND} -P "${${PROJECT_NAME}_UNINSTALL_SCRIPT_FILE}"
	)

	# Add uninstall target in a folder for IDE project generation.
	get_cmake_property(target_folder PREDEFINED_TARGETS_FOLDER)
	set_target_properties(uninstall PROPERTIES FOLDER "${target_folder}")
else()
	message(STATUS "Uninstall command already exists, don't need to generate it again")
endif()