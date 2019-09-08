# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash

export PROJECT_NAME="ProjectName" 			# -DPROJECT_NAME: specifies a name for project
export PROJECT_SUMMARY="Description" 		# -DPROJECT_SUMMARY: short description of the project
export PROJECT_VENDOR_NAME="YourName" 		# -DPROJECT_VENDOR_NAME: project author
export PROJECT_VERSION_MAJOR="0" 			# -DPROJECT_VERSION_MAJOR: project major version
export PROJECT_VERSION_MINOR="0" 			# -DPROJECT_VERSION_MINOR: project minor version
export PROJECT_VERSION_PATCH="0" 			# -DPROJECT_VERSION_PATCH: project patch version

readonly WORKSPACE_PATH=`pwd`
declare -r BUILD_PATH="${WORKSPACE_PATH}/build"
declare -r SOLUTION_PATH="${BUILD_PATH}/${PROJECT_NAME}-${PROJECT_VERSION_MAJOR}-${PROJECT_VERSION_MINOR}-${PROJECT_VERSION_PATCH}-linux"

if [ -d ${SOLUTION_PATH} ]; then
	rm -r "${SOLUTION_PATH}"
fi

if [ $? -eq 0 ]; then
	echo "The solution was successfully cleaned!"
fi

exit $?
