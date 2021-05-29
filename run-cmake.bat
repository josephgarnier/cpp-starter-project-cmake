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
set "BUILD_DIR=%WORKSPACE_DIR%\build"
set "CMAKE_DIR=%WORKSPACE_DIR%\cmake"
set "SOLUTION_DIR=%BUILD_DIR%"

cmake --log-level=TRACE -S "%WORKSPACE_DIR%" -B "%SOLUTION_DIR%" -C "%CMAKE_DIR%\project\StandardOptions.txt"
if %errorlevel%==0 (
	echo.The solution was successfully generated!
)

pause