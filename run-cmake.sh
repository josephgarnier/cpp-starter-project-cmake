# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash

export PROJECT_NAME="project-name" 			# -DPROJECT_NAME: specifies a name for project
export PROJECT_SUMMARY="description" 		# -DPROJECT_SUMMARY: short description of the project
export PROJECT_VENDOR_NAME="your-name" 		# -DPROJECT_VENDOR_NAME: project author
export PROJECT_VENDOR_CONTACT="contact" 	# -DPROJECT_VENDOR_CONTACT: author contact
export PROJECT_VERSION_MAJOR="0" 			# -DPROJECT_VERSION_MAJOR: project major version
export PROJECT_VERSION_MINOR="0" 			# -DPROJECT_VERSION_MINOR: project minor version
export PROJECT_VERSION_PATCH="0" 			# -DPROJECT_VERSION_PATCH: project patch version
export GENERATOR="Unix Makefiles" 			# -DGENERATOR: see https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
export BUILD_TYPE="debug"					# -DBUILD_TYPE=[(default) debug|release]: set type of build
export DEBUG_OPT_LVL="low"					# -DDEBUG_OPT_LVL=[(default) low|high]: set level of debug
export ASSERT_ENABLE="off"					# -DASSERT_ENABLE=[ON|OFF (default)]: enable or disable assert
export BUILD_SHARED_LIBS="on"				# -DBUILD_SHARED_LIBS=[(default) ON|OFF]: build shared libraries instead of static
export BUILD_MAIN="on"						# -DBUILD_MAIN=[(default) ON|OFF]: build the main-function
export BUILD_TESTS="off"					# -DBUILD_TESTS=[ON|OFF (default)]: build tests
export BUILD_DOXYGEN_DOCS="off"				# -DBUILD_DOXYGEN_DOCS=[ON|OFF (default)]: build documentation

declare -a CMAKE_FLAGS=()
CMAKE_FLAGS+=("-DPARAM_PROJECT_NAME=${PROJECT_NAME}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_SUMMARY=${PROJECT_SUMMARY}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VENDOR_NAME=${PROJECT_VENDOR_NAME}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VENDOR_CONTACT=${PROJECT_VENDOR_CONTACT}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VERSION_MAJOR=${PROJECT_VERSION_MAJOR}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VERSION_MINOR=${PROJECT_VERSION_MINOR}")
CMAKE_FLAGS+=("-DPARAM_PROJECT_VERSION_PATCH=${PROJECT_VERSION_PATCH}")
CMAKE_FLAGS+=("-DPARAM_GENERATOR=${GENERATOR}")
CMAKE_FLAGS+=("-DPARAM_BUILD_TYPE=${BUILD_TYPE}")
CMAKE_FLAGS+=("-DPARAM_DEBUG_OPT_LVL=${DEBUG_OPT_LVL}")
CMAKE_FLAGS+=("-DPARAM_ASSERT_ENABLE=${ASSERT_ENABLE}")
CMAKE_FLAGS+=("-DPARAM_BUILD_SHARED_LIBS=${BUILD_SHARED_LIBS}")
CMAKE_FLAGS+=("-DPARAM_BUILD_MAIN=${BUILD_MAIN}")
CMAKE_FLAGS+=("-DPARAM_BUILD_TESTS=${BUILD_TESTS}")
CMAKE_FLAGS+=("-DPARAM_BUILD_DOXYGEN_DOCS=${BUILD_DOXYGEN_DOCS}")

readonly WORKSPACE_PATH=`pwd`
declare -r BUILD_PATH="${WORKSPACE_PATH}/build"
declare -r CMAKE_PATH="${WORKSPACE_PATH}/cmake"
declare -r SOLUTION_PATH="${BUILD_PATH}/${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}-${PROJECT_VERSION_MINOR}-${PROJECT_VERSION_PATCH}-linux"

if [ ! -d ${SOLUTION_PATH} ]; then
	mkdir "${SOLUTION_PATH}"
fi

cd "${SOLUTION_PATH}"
cmake ${WORKSPACE_PATH} -G "${GENERATOR}" -DCMAKE_TOOLCHAIN_FILE="${CMAKE_PATH}/toolchains/Linux_clang.cmake" "${CMAKE_FLAGS[@]}"
if [ $? -eq 0 ]; then
	echo -e "\nThe solution was successfully generated!"
fi

cd "${WORKSPACE_PATH}"
exit $?
