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
include(FileManip)


# Note: set the list of absolute paths to libraries (.so and .dll) that are
# inside `lib/` directory. By default, the function use a glob function.
set(${PROJECT_NAME}_LIBRARY_FILES "")
directory(SCAN ${PROJECT_NAME}_LIBRARY_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_LIB_DIR}"
	INCLUDE_REGEX ".*\\${CMAKE_SHARED_LIBRARY_SUFFIX}.*|.*\\${CMAKE_STATIC_LIBRARY_SUFFIX}.*"
)

# Note: set the list of absolute paths to libary header files (.h) that are
# inside `include/` directory. By default, the function use a glob function.
# Warning: the `include/<project-name>` directory must be excluded.
set(${PROJECT_NAME}_LIBRARY_HEADER_DIRS "")
directory(SCAN_DIRS ${PROJECT_NAME}_LIBRARY_HEADER_DIRS
	RECURSE off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_INCLUDE_DIR}"
	EXCLUDE_REGEX "${PROJECT_NAME}"
)
