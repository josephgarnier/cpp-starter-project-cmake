# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash

export PROJECT_NAME="project-name"          # -DPROJECT_NAME: specifies a name for project
export PROJECT_SUMMARY="description"        # -DPROJECT_SUMMARY: short description of the project
export PROJECT_VENDOR_NAME="your-name"      # -DPROJECT_VENDOR_NAME: project author
export PROJECT_VENDOR_CONTACT="contact"     # -DPROJECT_VENDOR_CONTACT: author contact
export PROJECT_VERSION_MAJOR="0"            # -DPROJECT_VERSION_MAJOR: project major version
export PROJECT_VERSION_MINOR="0"            # -DPROJECT_VERSION_MINOR: project minor version
export PROJECT_VERSION_PATCH="0"            # -DPROJECT_VERSION_PATCH: project patch version
export GENERATOR="Unix Makefiles"           # -DGENERATOR: see https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
export COMPILE_VERSION="17"                 # -DCOMPILE_VERSION=[11|14|17 (default)|20]: see https://cmake.org/cmake/help/latest/variable/CMAKE_CXX_STANDARD.html
export COMPILE_DEFINITIONS=""               # -DCOMPILE_DEFINITIONS: semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty.
export BUILD_TYPE="debug"                   # -DBUILD_TYPE=[(default) debug|release]: set type of build
export ASSERT_ENABLE="off"                  # -DASSERT_ENABLE=[ON|OFF (default)]: enable or disable assert
export BUILD_SHARED_LIBS="on"               # -DBUILD_SHARED_LIBS=[(default) ON|OFF]: build shared libraries instead of static
export BUILD_EXEC="on"                      # -DBUILD_EXEC=[(default) ON|OFF]: build an executable
export BUILD_TESTS="off"                    # -DBUILD_TESTS=[ON|OFF (default)]: build tests
export BUILD_DOXYGEN_DOCS="off"             # -DBUILD_DOXYGEN_DOCS=[ON|OFF (default)]: build documentation

declare -a CMAKE_FLAGS=()
CMAKE_FLAGS+=("-DPARAM_PROJECT_NAME=${PROJECT_NAME}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_SUMMARY=${PROJECT_SUMMARY}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VENDOR_NAME=${PROJECT_VENDOR_NAME}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VENDOR_CONTACT=${PROJECT_VENDOR_CONTACT}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH}")
CMAKE_FLAGS+=("-DPARAM_GENERATOR=${GENERATOR}")
CMAKE_FLAGS+=("-DPARAM_COMPILE_VERSION=${COMPILE_VERSION}")
CMAKE_FLAGS+=("-DPARAM_COMPILE_DEFINITIONS=${COMPILE_DEFINITIONS}")
CMAKE_FLAGS+=("-DPARAM_BUILD_TYPE=${BUILD_TYPE}")
CMAKE_FLAGS+=("-DPARAM_ASSERT_ENABLE=${ASSERT_ENABLE}")
CMAKE_FLAGS+=("-DPARAM_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}")
CMAKE_FLAGS+=("-DPARAM_BUILD_EXEC=${BUILD_EXEC}")
CMAKE_FLAGS+=("-DPARAM_BUILD_TESTS=${BUILD_TESTS}")
CMAKE_FLAGS+=("-DPARAM_BUILD_DOXYGEN_DOCS=${BUILD_DOXYGEN_DOCS}")

readonly WORKSPACE_DIR=$(pwd)
declare -r BUILD_DIR="${WORKSPACE_DIR}/build"
declare -r CMAKE_DIR="${WORKSPACE_DIR}/cmake"
declare -r SOLUTION_DIR="${BUILD_DIR}/${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}-${PROJECT_VERSION_MINOR}-${PROJECT_VERSION_PATCH}-linux"

cmake -S "${WORKSPACE_DIR}" -B "${SOLUTION_DIR}" -G "${GENERATOR}" -DCMAKE_TOOLCHAIN_FILE="${CMAKE_DIR}/toolchains/Linux_clang.cmake" "${CMAKE_FLAGS[@]}"

if [[ "${?}" -eq 0 ]]; then
	echo -e "\nThe solution was successfully generated!"
fi

exit $?
