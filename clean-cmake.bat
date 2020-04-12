@echo off
rem Copyright 2019-present, Joseph Garnier
rem All rights reserved.
rem
rem This source code is licensed under the license found in the
rem LICENSE file in the root directory of this source tree.

setlocal EnableDelayedExpansion

set "WORKSPACE_DIR=%cd%"
set "BUILD_DIR=%WORKSPACE_DIR%/build"
set "SOLUTION_DIR=%BUILD_DIR%"

if EXIST %SOLUTION_DIR% (
	cmake --build %SOLUTION_DIR% --target clean

	rem Remove solution in build directory
	del /A /F /S /Q "%SOLUTION_DIR%"
	for /D %%p IN ("%SOLUTION_DIR%\*") DO rmdir "%%p" /s /q
)

if %errorlevel%==0 (
	echo.The solution was successfully cleaned!
)

pause
exit %errorlevel%
