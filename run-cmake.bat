set path=C:\cygwin\bin;%path%
set PROJECT_NAME="VEAbS" 		REM -DPROJECT_NAME: set string name for project_add
set GENERATOR="Unix Makefiles" 	REM -DGENERATOR: see https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html
set BUILD_TYPE="debug"			REM -DBUILD_TYPE: set type of build "debug" or "release"
set DEBUG_OPT_LVL="low"			REM -DDEBUG_OPT_LVL: set level of debug "low" or "high"
set ASSERT_ENABLE="on"			REM -DASSERT_ENABLE=[ON|OFF (default)]: enable or disable assert "off" or "on"
set BUILD_SHARED_LIBS="on"		REM -DBUILD_SHARED_LIBS=[ON|OFF (default)]: build shared libraries instead of static
set BUILD_MAIN="on"				REM -DBUILD_MAIN=[(default) ON|OFF]: build the main-function
set BUILD_TESTS="on"			REM -DBUILD_TESTS=[ON|OFF (default)]: build tests

setlocal EnableDelayedExpansion

set CMAKE_FLAGS[1]="-DPROJECT_NAME=%PROJECT_NAME%"
set CMAKE_FLAGS[2]="-DGENERATOR=%GENERATOR%"
set CMAKE_FLAGS[3]="-DBUILD_TYPE=%BUILD_TYPE%"
set CMAKE_FLAGS[4]="-DDEBUG_OPT_LVL=%DEBUG_OPT_LVL%"
set CMAKE_FLAGS[5]="-DASSERT_ENABLE=%ASSERT_ENABLE%"
set CMAKE_FLAGS[6]="-DBUILD_SHARED_LIBS=%BUILD_SHARED_LIBS%"
set CMAKE_FLAGS[7]="-DBUILD_MAIN=%BUILD_MAIN%"
set CMAKE_FLAGS[8]="-DBUILD_TESTS=%BUILD_TESTS%"

SET WORKSPACE_PATH="%cd%"
set BUILD_PATH="%WORKSPACE_PATH%/bin"
set CMAKE_PATH="%WORKSPACE_PATH%/cmake"
set SOLUTION_PATH="%BUILD_PATH%/Build-%PROJECT_NAME%-Linux"

pause



if [ ! -d ${SOLUTION_PATH} ]; then
	mkdir "${SOLUTION_PATH}"
fi

cd "${SOLUTION_PATH}"
cmake ${WORKSPACE_PATH} -G "${GENERATOR}" -DCMAKE_TOOLCHAIN_FILE="${CMAKE_PATH}/toolchains/Linux_clang.cmake" "${CMAKE_FLAGS[@]}"
if [ $? -eq 0 ]; then
	echo "Solution is successfully generated in ${SOLUTION_PATH}!"
fi

cd "${WORKSPACE_PATH}"
exit $?
