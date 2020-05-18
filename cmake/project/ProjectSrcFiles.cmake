# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# By default, you don't need to manually initialize these variables: this is
# done by the glob functions `directory()`. But if after all you decide
# to use you own instructions, then remove all functions with the exception of 
# all `set()`. Follow the instructions of each variable to know how initialize them.
#
# Warning: in all case if you don't use precompiled header features, set to
# empty string the variables `${PROJECT_NAME}_PRECOMPILED_HEADER_FILE` and
# `${PROJECT_NAME}_PRECOMPILED_SOURCE_FILE`.

include(Directory)

# The precompiled files are set here. If you don't need them, set the variables to empty string
set(${PROJECT_NAME}_PRECOMPILED_HEADER_FILE "${${PROJECT_NAME}_SRC_DIR}/${PROJECT_NAME}_pch.h")
set(${PROJECT_NAME}_PRECOMPILED_SOURCE_FILE "${${PROJECT_NAME}_SRC_DIR}/${PROJECT_NAME}_pch.cpp")

# Only private source files (.cpp) go here, they will not be exported or installed.
set(${PROJECT_NAME}_SOURCE_PRIVATE_FILES "")
directory(SCAN ${PROJECT_NAME}_SOURCE_PRIVATE_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_SRC_DIR}"
	INCLUDE_REGEX ".*[.]cpp$|.*[.]cc$"
)

# By default, all header files of `src/` and `include/project-name/` (this
# last directory is optional) are publics, then these directories are set here.
# They will be added to the public include_directories property of target.
# You can remove `src/` from this variable to make it private, but `include/`
# will always be public.
#
# Warning: the header directories of your dependencies should not be set here,
# but in a specific config file.
set(${PROJECT_NAME}_HEADER_PUBLIC_DIRS "${${PROJECT_NAME}_SRC_DIR}" "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}")

# Set here all header files (.h) present in `${PROJECT_NAME}_HEADER_PUBLIC_DIRS` directories.
set(${PROJECT_NAME}_HEADER_PUBLIC_FILES "")
foreach(directory IN ITEMS ${${PROJECT_NAME}_HEADER_PUBLIC_DIRS})
	set(header_files "")
	directory(SCAN header_files
		LIST_DIRECTORIES off
		RELATIVE off
		ROOT_DIR "${directory}"
		INCLUDE_REGEX ".*[.]h$"
	)
	list(APPEND ${PROJECT_NAME}_HEADER_PUBLIC_FILES ${header_files})
endforeach()

# In this variable, you tell where are the directories of your private header files.
# Warning: the header directories of your dependencies should not be set here, they will
# be added in a specific config file.
set(${PROJECT_NAME}_HEADER_PRIVATE_DIRS "")

# Set here all header files (.h) present in `${PROJECT_NAME}_HEADER_PRIVATE_DIRS` directories.
set(${PROJECT_NAME}_HEADER_PRIVATE_FILES "")
foreach(directory IN ITEMS ${${PROJECT_NAME}_HEADER_PRIVATE_DIRS})
	set(header_files "")
	directory(SCAN header_files
		LIST_DIRECTORIES off
		RELATIVE off
		ROOT_DIR "${directory}"
		INCLUDE_REGEX ".*[.]h$"
	)
	list(APPEND ${PROJECT_NAME}_HEADER_PRIVATE_FILES ${header_files})
endforeach()
