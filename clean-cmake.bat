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

set "WORKSPACE_DIR=%cd%"
set "BUILD_DIR=%WORKSPACE_DIR%/build"
set "SOLUTION_DIR=%BUILD_DIR%/%PROJECT_NAME%-%PROJECT_VERSION_MAJOR%-%PROJECT_VERSION_MINOR%-%PROJECT_VERSION_PATCH%-windows"

if EXIST %SOLUTION_DIR% (
	cmake --build %SOLUTION_DIR% --target clean

	REM Remove solution in build directory
	@RD /S /Q "%SOLUTION_DIR%"
)

if %errorlevel%==0 (
	echo.The solution was successfully cleaned!
)

exit %errorlevel%
