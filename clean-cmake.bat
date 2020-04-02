@echo off
REM Copyright 2019-present, Joseph Garnier
REM All rights reserved.
REM
REM This source code is licensed under the license found in the
REM LICENSE file in the root directory of this source tree.

setlocal EnableDelayedExpansion

set "WORKSPACE_DIR=%cd%"
set "BUILD_DIR=%WORKSPACE_DIR%/build"
set "SOLUTION_DIR=%BUILD_DIR%"

if EXIST %SOLUTION_DIR% (
	cmake --build %SOLUTION_DIR% --target clean

	REM Remove solution in build directory
	del /S "%SOLUTION_DIR%/*"
)

if %errorlevel%==0 (
	echo.The solution was successfully cleaned!
)

exit %errorlevel%
