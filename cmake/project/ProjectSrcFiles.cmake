# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# In this files, you will set the lists of all source files of your project.
# First, you have to set the variable `${PROJECT_NAME}_SRC_ALL_FILES` with
# source files (cpp and header) present in `${PROJECT_NAME}_SRC_DIR`
# (/src directory). Then, set the variable `${PROJECT_NAME}_SRC_HEADER_FILES`
# with header files present in ${PROJECT_NAME}_SRC_DIR` (/src directory).
# Finally, set the variable `${PROJECT_NAME}_INCLUDE_HEADER_FILES` with public
# header files present in `${PROJECT_NAME}_INCLUDE_DIR/${PROJECT_NAME}`
# (this directory is optional). In this variable, only set your own headers
# files, not headers of dependancies that will add in a specific config file.
# The last variable `${PROJECT_NAME}_PUBLIC_HEADER_FILES` is a list of public
# header files that will be copy in `/include` directory by `install()` command.
# By default, this variable is set with all header files of your project ;
# that's mean all header files are public. Feel free to replace this policy
# by yours.
#
# By default, you don't need to manually initialize these variables : this is
# done by the blob function `directory()`. But if after all you decide
# to use you own instructions, then remove the calls to `directory()`
# function, set the previously described variables, and don't forget to also set
# `${PROJECT_NAME}_PRECOMPILED_HEADER_FILE` and
# `${PROJECT_NAME}_PRECOMPILED_SOURCE_FILE`.
#
# Warning: if you don'y use precompiled header features, set to empty string
# the variables `${PROJECT_NAME}_PRECOMPILED_HEADER_FILE` and
# `${PROJECT_NAME}_PRECOMPILED_SOURCE_FILE`.

include(Directory)

set(${PROJECT_NAME}_PRECOMPILED_HEADER_FILE "${${PROJECT_NAME}_SRC_DIR}/${PROJECT_NAME}_pch.h")
set(${PROJECT_NAME}_PRECOMPILED_SOURCE_FILE "${${PROJECT_NAME}_SRC_DIR}/${PROJECT_NAME}_pch.cpp")

# All source files (.cpp and .h) of /src directory go here
set(${PROJECT_NAME}_SRC_ALL_FILES "")
directory(SCAN ${PROJECT_NAME}_SRC_ALL_FILES ROOT_DIR "${${PROJECT_NAME}_SRC_DIR}" INCLUDE_REGEX ".*[.]cpp$|.*[.]h$|.*[.]cc$")

# Only header files of /src directory go here
set(${PROJECT_NAME}_SRC_HEADER_FILES "")
directory(SCAN ${PROJECT_NAME}_SRC_HEADER_FILES ROOT_DIR "${${PROJECT_NAME}_SRC_DIR}" INCLUDE_REGEX ".*[.]h$")

# Only cpp files of /src directiry go here
set(${PROJECT_NAME}_SRC_SOURCE_FILES "")
directory(SCAN ${PROJECT_NAME}_SRC_SOURCE_FILES ROOT_DIR "${${PROJECT_NAME}_SRC_DIR}" INCLUDE_REGEX ".*[.]cpp$|.*[.]cc$")

# Only you own header files of /include/project-name directiry go here. The headers of your dependancies should not set here,
# they will be add in a specific config file.
set(${PROJECT_NAME}_INCLUDE_HEADER_FILES "")
directory(SCAN ${PROJECT_NAME}_INCLUDE_HEADER_FILES ROOT_DIR "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}" INCLUDE_REGEX ".*[.]h$")

# By default, all header files (those of /src and /include/project-name) are publics and go here
set(${PROJECT_NAME}_PUBLIC_HEADER_FILES "${${PROJECT_NAME}_SRC_HEADER_FILES}" "${${PROJECT_NAME}_INCLUDE_HEADER_FILES}")