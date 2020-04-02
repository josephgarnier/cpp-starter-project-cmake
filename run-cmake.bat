@echo off
REM Copyright 2019-present, Joseph Garnier
REM All rights reserved.
REM
REM This source code is licensed under the license found in the
REM LICENSE file in the root directory of this source tree.

setlocal EnableDelayedExpansion

set "WORKSPACE_DIR=%cd%"
set "BUILD_DIR=%WORKSPACE_DIR%/build"
set "CMAKE_DIR=%WORKSPACE_DIR%/cmake"
set "SOLUTION_DIR=%BUILD_DIR%/project-name-0-0-0-windows"

cmake -S %WORKSPACE_DIR% -B %SOLUTION_DIR% -A x64 -C %CMAKE_DIR%/project/CMakeOptions.txt
if %errorlevel%==0 (
	echo.The solution was successfully generated!
)

exit %errorlevel%