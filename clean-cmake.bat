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
set "SOLUTION_DIR=%BUILD_DIR%"

if EXIST %SOLUTION_DIR% (
	cmake --build %SOLUTION_DIR% --target clean

	rem Remove solution in build directory.
	for /f "usebackq tokens=*" %%f in (`dir "%SOLUTION_DIR%\*" /a /b`) do (
		if exist "%SOLUTION_DIR%\%%f\" (
			rmdir "%SOLUTION_DIR%\%%f" /s /q
			echo Directory deleted - %SOLUTION_DIR%\%%~f
		) else if not "%%f" == ".gitignore" (
			del "%SOLUTION_DIR%\%%~f" /a /f /q
			echo File deleted - %SOLUTION_DIR%\%%~f
		)
	)
)

if %errorlevel%==0 (
	echo.The solution was successfully cleaned!
)

pause