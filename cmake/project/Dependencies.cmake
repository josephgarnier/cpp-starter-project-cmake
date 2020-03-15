# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# Put in this file all instructions to include and link your library dependancies
# to your own library and own executable. All libraries (.dll or .so files) found by the
# `directory()` function will be automatically link, but to include their header
# file, you have to add this function.  For each directory in `/include`,
# except for this containing your own headers, write the following instructions at
# the end of file in remplacing `<library-name>` by the name of library:
# 
# set(<library-name>_include_header_files "")
# directory(SCAN <library-name>_include_header_files ROOT_PATH "${${PROJECT_NAME}_INCLUDE_PATH}/${<library-name>}" INCLUDE_REGEX ".*[.]h$")
# set(${PROJECT_NAME}_PUBLIC_HEADER_FILES "${${PROJECT_NAME}_PUBLIC_HEADER_FILES}" "${<library-name>_include_header_files}")
#
# On the contrary, if you want to use an external library (e.g Qt) in using
# `find_package()` function, you don't need the previous code, but rather have
# to add your special instructions like `find_package()`, `target_sources()`,
# `target_include_directories()`, target_compile_definitions()` and
# `target_link_libraries()` at the end of file.

include(Directory)

set(${PROJECT_NAME}_LIBRARIES_FILES "")
directory(SCAN ${PROJECT_NAME}_LIBRARIES_FILES ROOT_PATH "${${PROJECT_NAME}_LIB_PATH}" INCLUDE_REGEX "(.*\\${CMAKE_SHARED_LIBRARY_SUFFIX}$)|(.*\\${CMAKE_STATIC_LIBRARY_SUFFIX}$)")

# Add your special instructions here
