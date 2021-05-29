# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.
# =============================================================================
# What Is This?
# -------------
# See README file in the root directory of this source tree.

#!/bin/bash
readonly WORKSPACE_DIR=$(pwd)
declare -r BUILD_DIR="${WORKSPACE_DIR}/build"
declare -r CMAKE_DIR="${WORKSPACE_DIR}/cmake"
declare -r SOLUTION_DIR="${BUILD_DIR}"

cmake --log-level=TRACE -S "${WORKSPACE_DIR}" -B "${SOLUTION_DIR}" -C "${CMAKE_DIR}/project/StandardOptions.txt"

if [[ "${?}" -eq 0 ]]; then
	echo -e "\nThe solution was successfully generated!"
fi

exit $?
