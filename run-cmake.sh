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

cmake -S "${WORKSPACE_DIR}" --preset "x64-Release-Linux-GCC"

# To debug your CMakeLists.txt, use the command below and comment the previous one
# cmake --debug-output --trace-expand --log-level=TRACE -S "${WORKSPACE_DIR}" --preset "x64-Release-Linux-GCC" --trace-redirect=output.log

if [[ "${?}" -eq 0 ]]; then
	echo -e "\nThe solution was successfully generated!"
fi

exit $?
