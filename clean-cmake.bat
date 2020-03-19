@echo off
REM Copyright 2019-present, Joseph Garnier
REM All rights reserved.
REM
REM This source code is licensed under the license found in the
REM LICENSE file in the root directory of this source tree.

REM -DPROJECT_NAME: specifies a name for project
set "PROJECT_NAME=project-name"
REM -DPROJECT_VERSION_MAJOR: project major version
set "PROJECT_VERSION_MAJOR=0"
REM -DPROJECT_VERSION_MINOR: project minor version
set "PROJECT_VERSION_MINOR=0"
REM -DPROJECT_VERSION_PATCH: project patch version
set "PROJECT_VERSION_PATCH=0"

setlocal EnableDelayedExpansion

set "WORKSPACE_PATH=%cd%"
set "BUILD_PATH=%WORKSPACE_PATH%/build"
set "SOLUTION_PATH=%BUILD_PATH%/%PROJECT_NAME%-%PROJECT_VERSION_MAJOR%-%PROJECT_VERSION_MINOR%-%PROJECT_VERSION_PATCH%-windows"

if EXIST %SOLUTION_PATH% (
	cmake --build %SOLUTION_PATH% --target clean

	REM Remove solution in build directory
	Del %SOLUTION_PATH%
)

if %errorlevel%==0 (
	echo.The solution was successfully cleaned!
)

exit %errorlevel%
