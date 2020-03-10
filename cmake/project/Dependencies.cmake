# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# Put in this file all your library dependancies to include and link in your
# library and executable. All libraries found by `directory()` function will be
# automatically link, but if you use an external library (e.g Qt), you have
# to add your special instructions like `find_package()`, `target_sources()`,
# `target_include_directories()`, `target_compile_definitions()` and
# `target_link_libraries()` here.

include(Directory)

set(${PROJECT_NAME}_LIBRARIES_FILES "")
directory(SCAN ${PROJECT_NAME}_LIBRARIES_FILES ROOT_PATH "${${PROJECT_NAME}_LIB_PATH}" INCLUDE_REGEX "(.*\\${CMAKE_SHARED_LIBRARY_SUFFIX}$)|(.*\\${CMAKE_STATIC_LIBRARY_SUFFIX}$)")

# Add your special instructions here
