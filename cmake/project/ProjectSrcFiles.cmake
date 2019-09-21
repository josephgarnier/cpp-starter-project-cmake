# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
#
# What Is This?
# -------------
# Put in this file all your source files. The scan_sub_folders function will
# list all files in src directory.
# Warning : if you decide to use you own instructions as add_subdirectory,
# remove the calls to scan_sub_folders function, but don't forget to set
# ${PROJECT_NAME}_PRECOMPILED_HEADER_PATH, ${PROJECT_NAME}_PRECOMPILED_SOURCE_PATH,
# ${PROJECT_NAME}_SRC_FILES and ${PROJECT_NAME}_HEADER_FILES

include(Directory)

set(${PROJECT_NAME}_PRECOMPILED_HEADER_PATH "${${PROJECT_NAME}_SRC_PATH}/${PROJECT_NAME}_pch.h")
set(${PROJECT_NAME}_PRECOMPILED_SOURCE_PATH "${${PROJECT_NAME}_SRC_PATH}/${PROJECT_NAME}_pch.cpp")

set(${PROJECT_NAME}_SRC_FILES "")
scan_sub_folders(${PROJECT_NAME}_SRC_FILES ROOT_PATH "${${PROJECT_NAME}_SRC_PATH}" INCLUDE_REGEX ".*[.]cpp$|.*[.]h$|.*[.]ui$|.*[.]qrc$|.*[.].*")

set(${PROJECT_NAME}_HEADER_FILES "")
scan_sub_folders(${PROJECT_NAME}_HEADER_FILES ROOT_PATH "${${PROJECT_NAME}_SRC_PATH}" INCLUDE_REGEX ".*[.]h$")
