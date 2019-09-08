# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
#
# What Is This?
# -------------
# Put in this file all your dependancies. The scan_sub_folders function will
# list all libraries in lib directory. But, you have to add your special
# instructions like include_directories or add_definitions.
#
# Example of special instructions with Qwt library
# -------------
# message("\n== Make Qwt ==")
# find_package(Qwt REQUIRED)
# include_directories(${QWT_INCLUDE_DIRS})
# add_definitions(${QWT_DEFINITIONS})

include(Directory)

set(${PROJECT_NAME}_LIBRARIES_FILES "")
scan_sub_folders(${PROJECT_NAME}_LIBRARIES_FILES ROOT_PATH "${${PROJECT_NAME}_LIB_PATH}" INCLUDE_REGEX "(.*\\${CMAKE_SHARED_LIBRARY_SUFFIX}$)|(.*\\${CMAKE_STATIC_LIBRARY_SUFFIX}$)")

# Add your special instructions here #
