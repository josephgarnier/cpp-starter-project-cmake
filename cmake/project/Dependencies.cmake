# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# Put in this file all instructions to include and link your library dependencies
# to your own library and own executable. All libraries (.dll or .so files) found by the
# `directory()` function will be automatically link, but to include their header
# file, you have to add this function. For each directory in `include/`,
# except for this containing your own headers, write the following instructions at
# the end of this file in remplacing `<library-name-directory>` by the name of
# directory where your library is:
# 
# set(${PROJECT_NAME}_LIBRARY_HEADER_DIRS "${${PROJECT_NAME}_INCLUDE_DIR}/<library-name-directory>")
#
# Warning: according to the soname policy on Linux (https://en.wikipedia.org/wiki/Soname),
# don't forget to create a link for each library in `lib\`.
#
# On the contrary, if you want to use an external library (e.g Qt) in using
# `find_package()` function, you don't need the previous code, but rather have
# to add your special instructions like `find_package()`, `target_sources()`,
# `target_include_directories()`, target_compile_definitions()` and
# `target_link_libraries()` at the end of file. You have to add these properties on
# the target : `${${PROJECT_NAME}_TARGET_NAME}`.
# To know how import a such library please read its documentation.
# Last thing, this is in this file that you will use the parameter `DPARAM_ASSERT_ENABLE`
# with a test like `if(${PARAM_ASSERT_ENABLE})`.
# An illustrated example for Qt, which you will have to delete, is proposed at the
# end of the file.
#
# Warning: if you use `find_package()` function, then don't forget to add
# your dependancies in the file cmake/project/PackageConfig.cmake.

include(Directory)
include(FileManip)

set(${PROJECT_NAME}_LIBRARY_FILES "")
directory(SCAN ${PROJECT_NAME}_LIBRARY_FILES
	LIST_DIRECTORIES off
	RELATIVE off
	ROOT_DIR "${${PROJECT_NAME}_LIB_DIR}"
	INCLUDE_REGEX ".*\\${CMAKE_SHARED_LIBRARY_SUFFIX}.*|.*\\${CMAKE_STATIC_LIBRARY_SUFFIX}.*"
)

# First use case: you want to use the internal and automatic mechanism of library integration.
# Append each include directories of your libraries in this list
# (in this way `${${PROJECT_NAME}_INCLUDE_DIR}/<library-name-directory>`) or
# let it empty. They will be added to include directories of target and copied
# by `install()` command.
#  ||
#  V
set(${PROJECT_NAME}_LIBRARY_HEADER_DIRS "")


# Second use case : you want to link a library installed in another folder than the one of your project.
# Add your special instructions here.
#  ||
#  V
