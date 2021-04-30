# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

include(Directory)


# Note: set the list of absolute paths to source files (.cpp) that are
# inside `src/` directory. By default, the function use a glob function.
set(${PROJECT_NAME}_SOURCE_SRC_FILES "")
directory(SCAN ${PROJECT_NAME}_SOURCE_SRC_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_SRC_DIR}"
	INCLUDE_REGEX ".*[.]cpp$|.*[.]cc|.*[.]cxx$"
)


# Note: set the list of absolute path to header files (.h) that are
# inside `src/` directory. By default, the function use a glob function.
set(${PROJECT_NAME}_HEADER_SRC_FILES "")
directory(SCAN ${PROJECT_NAME}_HEADER_SRC_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_SRC_DIR}"
	INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$"
)


# Note: set the list of absolute path to header files (.h) that are
# inside `include/<project-name>` directory. By default, the function use a glob function.
set(${PROJECT_NAME}_HEADER_INCLUDE_FILES "")
directory(SCAN ${PROJECT_NAME}_HEADER_INCLUDE_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}"
	INCLUDE_REGEX ".*[.]h$|.*[.]hpp$|.*[.]hxx$|.*[.]inl$"
)


# Note: set the absolute path to the precompiled header file. Ignore it or let it empty if you don't use it.
set(${PROJECT_NAME}_PRECOMPILED_HEADER_FILE "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}/${PROJECT_NAME}_pch.h")


# Note: set the absolute path to the main source file.
set(${PROJECT_NAME}_MAIN_SOURCE_FILE "${${PROJECT_NAME}_SRC_DIR}/main.cpp")
