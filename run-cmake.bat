REM Copyright 2019-present, Joseph Garnier
REM All rights reserved.
REM
REM This source code is licensed under the license found in the
REM LICENSE file in the root directory of this source tree.

set PROJECT_NAME="project-name"          REM -DPROJECT_NAME: specifies a name for project
set PROJECT_SUMMARY="description"        REM -DPROJECT_SUMMARY: short description of the project
set PROJECT_VENDOR_NAME="your-name"      REM -DPROJECT_VENDOR_NAME: project author
set PROJECT_VENDOR_CONTACT="contact"     REM -DPROJECT_VENDOR_CONTACT: author contact
set PROJECT_VERSION_MAJOR="0"            REM -DPROJECT_VERSION_MAJOR: project major version
set PROJECT_VERSION_MINOR="0"            REM -DPROJECT_VERSION_MINOR: project minor version
set PROJECT_VERSION_PATCH="0"            REM -DPROJECT_VERSION_PATCH: project patch version
set GENERATOR="Unix Makefiles"           REM -DGENERATOR: see https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
set COMPILE_VERSION="17"                 REM -DCOMPILE_VERSION=[11|14|17 (default)|20]: see https://cmake.org/cmake/help/latest/variable/CMAKE_CXX_STANDARD.html
set COMPILE_DEFINITIONS=""               REM -DCOMPILE_DEFINITIONS: semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty.
set BUILD_TYPE="debug"                   REM -DBUILD_TYPE=[(default) debug|release]: set type of build
set ASSERT_ENABLE="off"                  REM -DASSERT_ENABLE=[ON|OFF (default)]: enable or disable assert
set BUILD_SHARED_LIBS="on"               REM -DBUILD_SHARED_LIBS=[(default) ON|OFF]: build shared libraries instead of static
set BUILD_EXEC="on"                      REM -DBUILD_EXEC=[(default) ON|OFF]: build an executable
set BUILD_TESTS="off"                    REM -DBUILD_TESTS=[ON|OFF (default)]: build tests
set BUILD_DOXYGEN_DOCS="off"             REM -DBUILD_DOXYGEN_DOCS=[ON|OFF (default)]: build documentation

setlocal EnableDelayedExpansion

set CMAKE_FLAGS[0]="-DPARAM_PROJECT_NAME=%PROJECT_NAME%"
set CMAKE_FLAGS[1]="-DPARAM_PROJECT_SUMMARY=%PROJECT_SUMMARY%"
set CMAKE_FLAGS[2]="-DPARAM_PROJECT_VENDOR_NAME=%PROJECT_VENDOR_NAME%"
set CMAKE_FLAGS[3]="-DPARAM_PROJECT_VENDOR_CONTACT=%PROJECT_VENDOR_CONTACT%"
set CMAKE_FLAGS[4]="-DPARAM_PROJECT_VERSION_MAJOR=%PROJECT_VERSION_MAJOR%"
set CMAKE_FLAGS[5]="-DPARAM_PROJECT_VERSION_MINOR=%PROJECT_VERSION_MINOR%"
set CMAKE_FLAGS[6]="-DPARAM_PROJECT_VERSION_PATCH=%PROJECT_VERSION_PATCH%"
set CMAKE_FLAGS[7]="-DPARAM_GENERATOR=%GENERATOR%"
set CMAKE_FLAGS[8]="-DPARAM_COMPILE_VERSION=%COMPILE_VERSION%"
set CMAKE_FLAGS[9]="-DPARAM_COMPILE_DEFINITIONS=%COMPILE_DEFINITIONS%"
set CMAKE_FLAGS[10]="-DPARAM_BUILD_TYPE=%BUILD_TYPE%"
set CMAKE_FLAGS[11]="-DPARAM_ASSERT_ENABLE=%ASSERT_ENABLE%"
set CMAKE_FLAGS[12]="-DPARAM_BUILD_SHARED_LIBS=%BUILD_SHARED_LIBS%"
set CMAKE_FLAGS[13]="-DPARAM_BUILD_EXEC=%BUILD_EXEC%"
set CMAKE_FLAGS[14]="-DPARAM_BUILD_TESTS=%BUILD_TESTS%"
set CMAKE_FLAGS[15]="-DPARAM_BUILD_DOXYGEN_DOCS=%BUILD_DOXYGEN_DOCS%"

set WORKSPACE_PATH="%cd%"
set BUILD_PATH="%WORKSPACE_PATH%/build"
set CMAKE_PATH="%WORKSPACE_PATH}/cmake"
set SOLUTION_PATH="%BUILD_PATH}/%PROJECT_NAME}-%PROJECT_VERSION_MAJOR}-%PROJECT_VERSION_MINOR}-%PROJECT_VERSION_PATCH}-linux"

cmake -S "%WORKSPACE_PATH%" -B "%SOLUTION_PATH%" -G "%GENERATOR%" -DCMAKE_TOOLCHAIN_FILE="%CMAKE_PATH%/toolchains/Linux_clang.cmake" "%CMAKE_FLAGS[@]%"

if %errorlevel%==0 (
	echo "\nThe solution was successfully generated!"
)

exit %errorlevel%