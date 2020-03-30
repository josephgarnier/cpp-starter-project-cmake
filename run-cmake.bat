@echo off
REM Copyright 2019-present, Joseph Garnier
REM All rights reserved.
REM
REM This source code is licensed under the license found in the
REM LICENSE file in the root directory of this source tree.

REM -DPROJECT_NAME: specifies a name for project
set "PROJECT_NAME=project-name"
REM -DPROJECT_SUMMARY: short description of the project
set "PROJECT_SUMMARY=description"
REM -DPROJECT_VENDOR_NAME: project author
set "PROJECT_VENDOR_NAME=your-name"
REM -DPROJECT_VENDOR_CONTACT: author contact
set "PROJECT_VENDOR_CONTACT=contact"
REM -DPROJECT_VERSION_MAJOR: project major version
set "PROJECT_VERSION_MAJOR=0"
REM -DPROJECT_VERSION_MINOR: project minor version
set "PROJECT_VERSION_MINOR=0"
REM -DPROJECT_VERSION_PATCH: project patch version
set "PROJECT_VERSION_PATCH=0"
REM -DGENERATOR: see https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
set "GENERATOR=Visual Studio 16 2019"
REM -DCOMPILE_VERSION=[11|14|17 (default)|20]: see https://cmake.org/cmake/help/latest/variable/CMAKE_CXX_STANDARD.html
set "COMPILE_VERSION=17"
REM -DCOMPILE_DEFINITIONS: semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty.
set "COMPILE_DEFINITIONS="
REM -DBUILD_TYPE=[(default) debug|release]: set type of build
set "BUILD_TYPE=debug"
REM -DASSERT_ENABLE=[ON|OFF (default)]: enable or disable assert
set "ASSERT_ENABLE=off"
REM -DBUILD_SHARED_LIBS=[(default) ON|OFF]: build shared libraries instead of static
set "BUILD_SHARED_LIBS=on"
REM -DBUILD_EXEC=[(default) ON|OFF]: build an executable
set "BUILD_EXEC=on"
REM -DBUILD_TESTS=[ON|OFF (default)]: build tests
set "BUILD_TESTS=off"
REM -DBUILD_DOXYGEN_DOCS=[ON|OFF (default)]: build documentation
set "BUILD_DOXYGEN_DOCS=off"

setlocal EnableDelayedExpansion

set CMAKE_FLAGS="-DPARAM_PROJECT_NAME=%PROJECT_NAME%"^
 "-DPARAM_PROJECT_SUMMARY=%PROJECT_SUMMARY%"^
 "-DPARAM_PROJECT_VENDOR_NAME=%PROJECT_VENDOR_NAME%"^
 "-DPARAM_PROJECT_VENDOR_CONTACT=%PROJECT_VENDOR_CONTACT%"^
 "-DPARAM_PROJECT_VERSION_MAJOR=%PROJECT_VERSION_MAJOR%"^
 "-DPARAM_PROJECT_VERSION_MINOR=%PROJECT_VERSION_MINOR%"^
 "-DPARAM_PROJECT_VERSION_PATCH=%PROJECT_VERSION_PATCH%"^
 "-DPARAM_GENERATOR=%GENERATOR%"^
 "-DPARAM_COMPILE_VERSION=%COMPILE_VERSION%"^
 "-DPARAM_COMPILE_DEFINITIONS=%COMPILE_DEFINITIONS%"^
 "-DPARAM_BUILD_TYPE=%BUILD_TYPE%"^
 "-DPARAM_ASSERT_ENABLE=%ASSERT_ENABLE%"^
 "-DPARAM_BUILD_SHARED_LIBS=%BUILD_SHARED_LIBS%"^
 "-DPARAM_BUILD_EXEC=%BUILD_EXEC%"^
 "-DPARAM_BUILD_TESTS=%BUILD_TESTS%"^
 "-DPARAM_BUILD_DOXYGEN_DOCS=%BUILD_DOXYGEN_DOCS%"

set "WORKSPACE_DIR=%cd%"
set "BUILD_DIR=%WORKSPACE_DIR%/build"
set "CMAKE_DIR=%WORKSPACE_DIR%/cmake"
set "SOLUTION_DIR=%BUILD_DIR%/%PROJECT_NAME%-%PROJECT_VERSION_MAJOR%-%PROJECT_VERSION_MINOR%-%PROJECT_VERSION_PATCH%-windows"

cmake -S %WORKSPACE_DIR% -B %SOLUTION_DIR% -G "%GENERATOR%" -A x64 -DCMAKE_TOOLCHAIN_FILE=%CMAKE_DIR%/toolchains/Windows_vs.cmake %CMAKE_FLAGS[%

if %errorlevel%==0 (
	echo.The solution was successfully generated!
)

exit %errorlevel%