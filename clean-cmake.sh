# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#!/bin/bash
readonly WORKSPACE_DIR=$(pwd)
declare -r BUILD_DIR="${WORKSPACE_DIR}/build"
declare -r SOLUTION_DIR="${BUILD_DIR}"

if [[ -d "${SOLUTION_DIR}" ]]; then
	cmake --build "${SOLUTION_DIR}" --target clean

	# Remove solution in build directory, the excepted gitignore file.
	shopt -s extglob
	eval "rm -rfv \"${SOLUTION_DIR}\"/{,..?,.[!(.|gitignore)]}*"    
fi

if [[ "${?}" -eq 0 ]]; then
	echo "The solution was successfully cleaned!"
fi

exit $?
