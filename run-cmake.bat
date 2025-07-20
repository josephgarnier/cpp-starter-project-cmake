@echo off
rem Copyright 2019-present, Joseph Garnier
rem All rights reserved.
rem
rem This source code is licensed under the license found in the
rem LICENSE file in the root directory of this source tree.
rem =============================================================================
rem What Is This?
rem -------------
rem See README file in the root directory of this source tree.

setlocal EnableDelayedExpansion

set "WORKSPACE_DIR=%cd%"

cmake --log-level=TRACE -S "%WORKSPACE_DIR%" --preset "x64-Release-Win-GCC"

rem To debug your CMakeLists.txt, use the command below and comment the previous one
rem cmake --debug-output --trace-expand --log-level=TRACE -S "%WORKSPACE_DIR%" --preset "x64-Release-Win-GCC" --trace-redirect=output.log

if %errorlevel%==0 (
	echo.The solution was successfully generated!
)

pause