# CMakeBaseCpp

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="CrCC BY-NC-SA 4.0" src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-brightgreen.svg"/></a> <img alt="plateform-windows-linux" src="https://img.shields.io/badge/platform-windows%20%7C%20linux-lightgrey.svg"/> <img alt="languages-cmake-c++" src="https://img.shields.io/badge/languages-CMake%20%7C%20C%2B%2B-blue.svg"/> <img alt="goal-progress-60" src="https://img.shields.io/badge/goal%20progress-60%25-orange.svg"/>

CMakeBaseCpp is a template for a structured CMake-based C++ project that can be used as the basis for new projects on windows and linux. It includes:

- A general directory structure common to C++ projects (see [Project structure](https://github.com/josephgarnier/cmake-base-cpp#project-structure))
- A customizable script to run cmake (`run-cmake.sh` or `run-cmake.bat`)
- A script to clean cmake generated files (`clean-cmake.sh` or `clean-cmake.bat`)
- Install script (`make install`)
- Uninstall script (`make uninstall`)
- CPack script for packaging (`cpack`)
- Use [Cotire](https://github.com/sakra/cotire) to build as executable or library with precompiled headers file (pch)
- Automatic API documentation with [Doxygen](http://www.doxygen.nl/) => **in progress**
- A unit testing framework with [GTest](https://github.com/google/googletest) => **in progress**
- Separate file to manualy include external libraries (in `Dependencies.cmake` module) or recursivly and automaticaly scan `/lib` directory
- Separate file to manualy specify source project files (in `ProjectSrcFiles.cmake` module) or recursivly and automaticaly scan source file in `/src` directory

## Requirements

Before using this project, please ensure that you have installed the following (install guides are provided on the respective websites):

- A C++ compiler, e.g [GCC](https://gcc.gnu.org/), [Clang C++](https://clang.llvm.org/cxx_status.html) or [Visual Studio](https://visualstudio.microsoft.com)
- [CMake](https://cmake.org/) > 3.12

The following dependencies are optional (see [Build options](https://github.com/josephgarnier/cmake-base-cpp#build-options)):

- [Doxygen](http://www.doxygen.nl/) (necessary when `DBUILD_DOXYGEN_DOCS` build option is set to `on`)
- [GTest](https://github.com/google/googletest) (necessary when `DBUILD_TESTS` build option is set to `on`)

## Installation

1. Clone the repo.
```bash
git clone https://github.com/josephgarnier/cmake-base-cpp.git --recursive
cd cmake-base-cpp
```
2. Customize all settings *variables project* prefixed with "export" (name, version, generator, etc) in `run-cmake.sh` (linux) or `run-cmake.bat` (windows) and in `clean-cmake.sh` (linux) or `clean-cmake.bat` (windows). See [Build options](https://github.com/josephgarnier/cmake-base-cpp#build-options) for more details about their use.
3. Set your *compiler* in [toolchains](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html) file in `cmake/toolchains` or use one provided by default to configure your cmake generator (see [cmake-generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html))
4. Add your *source files* (headers and sources) in `/src` directory. Please note that there are already some files for testing, remember to erase them before putting yours. Then, complete the `/cmake/project/ProjectSrcFiles.cmake` file by relying on the commented example or let them empty if you don't want to use the automation script scanning. If you use a *precompiled header* file, rename it according to pattern `<ProjectName_pch.h>` or edit the related variable in `ProjectSrcFiles.cmake` file.
5. If you use *external libraries*, add them in `/lib` directory, and add their header files in `/include` directory. Then, complete the `/cmake/project/Dependencies.cmake` file by relying on the commented example or do nothing and let the automation script scanning the directory.

## Compilation and Usage

In project root directory, use the proposed scripts to clean the `/build` directory and to *generate the new build files* with `cmake` command. These scripts are optionnals, you can clean the `/build` directory and call the `cmake` command yourself.

```bash
./clean-cmake.sh && sleep 3s && ./run-cmake.sh
#or
./clean-cmake.bat && pause 3 && ./run-cmake.bat
```

In case of success, you should see the message `The solution was successfully generated!`. A new directory containing all build files was created in `\build` and named according to pattern `<ProjectName-MajorVersion-MinorVersion-PatchVersion-OsSystem>`.

Now, you can *build* your solution to generate an executable file and/or a library file in `/bin` directory.

```bash
(cd ./build/project-name-0-0-0-linux; cmake --build .)
```

Optionnaly, you might want to *install* your projet in directory [defined by cmake](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html). Conversely, you may want to uninstall it.

```bash
(cd ./build/project-name-0-0-0-linux; sudo make install)
(cd ./build/project-name-0-0-0-linux; sudo make uninstall)
```

Also, if you want to [*pack*](https://cmake.org/cmake/help/latest/manual/cpack.1.html) your projet to generate an installer in a variety of [formats](https://cmake.org/cmake/help/latest/manual/cpack.1.html) (deb, zip, rpm, etc) in `/bin` directory.

```bash
# pack only files install from the make install command
(cd ./build/project-name-0-0-0-linux; cpack --config CPackConfig.cmake && sleep 2s && rm -r ../../bin/_CPack_Packages)
# pack all files
(cd ./build/project-name-0-0-0-linux; cpack --config CPackSourceConfig.cmake && sleep 2s && rm -r ../../bin/_CPack_Packages)
```

At any time you can clean the `/build` and `/bin` directories.

```bash
./clean-cmake.sh
#or
./clean-cmake.bat

(cd ./build/project-name-0-0-0-linux; make clean)
```

## Build options

You can pass the following command-line options when running CMake, otherwise they will be set with a default value:

- `DPARAM_PROJECT_NAME`: specifies a name for project
- `DPARAM_PROJECT_SUMMARY`: short description of the project
- `DPARAM_PROJECT_VENDOR_NAME`: project author
- `DPARAM_PROJECT_VENDOR_CONTACT`: author contact
- `DPARAM_PROJECT_VERSION_MAJOR`: project major version
- `DPARAM_PROJECT_VERSION_MINOR`: project minor version
- `DPARAM_PROJECT_VERSION_PATCH`: project patch version
- `DPARAM_GENERATOR`: see [cmake-generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html)
- `DPARAM_COMPILE_VERSION=[11|14|17 (default)|20]`: see [CMAKE_CXX_STANDARD](https://cmake.org/cmake/help/v3.1/variable/CMAKE_CXX_STANDARD.html)
- `DPARAM_BUILD_TYPE=[(default) debug|release]`: set type of build
- `DPARAM_DEBUG_OPT_LVL=[(default) low|high]`: set level of debug
- `DPARAM_ASSERT_ENABLE=[ON|OFF (default)]`: enable or disable assert
- `DPARAM_BUILD_SHARED_LIBS=[(default) ON|OFF]`: build shared libraries instead of static
- `DPARAM_BUILD_MAIN=[(default) ON|OFF]`: build the main-function
- `DPARAM_BUILD_TESTS=[ON|OFF (default)]`: build tests
- `DPARAM_BUILD_DOXYGEN_DOCS=[ON|OFF (default)]`: build documentation

## Project structure

This project has been set up with a specific file/folder structure in mind. The following describes some important features of this setup:

- `assets/`: contains images, musics, maps and all resources needed for a simulation or a game project.
- `bin/`: any libs that get compiled by the project and the output executables go here, also if you pack your project, the generated files go here.
- `build/`: contains all object files, and is removed on a `clean`.
- `cmake/modules/`: contains `CMake` modules.
- `cmake/project/Dependencies.cmake`: scan external libs.
- `cmake/project/ProjectFiles.cmake`: scan project source files to build.
- `cmake/toolchains/`: contains toolchain file for your compiler. Call it in using CMake option `-DCMAKE_TOOLCHAIN_FILE`. By default, only one is proposed for Linux Clang.
- `config/`: contains configuration files.
- `doc/`: contains code documentation generated by [Doxygen](http://www.doxygen.org "Doxygen homepage")
- `include/`: all necessary third-party header files (.h) that do not exist under `/usr/local/include` are also placed here.
- `lib/`: third party or any needed in development. Prior to deployment, third party libraries get moved to `/usr/local/lib` where they belong, leaving the project clean enough to compile on our Linux deployment servers.
- `resources/`: contains images, musics, maps and all resources needed if for your project.
- `src/`: project source files (*.cpp) and project header files (.h), including `main.cpp`, which contains example main-function for project build.
- `tests/`: project test source files (*.cpp) and project test header files (.h) that are provided to the selecting unit testing framework.
- `clean-cmake.bat`: utility script for Windows to remove the directory generated with `run-cmake.bat` in `build`.
- `clean-cmake.sh`: utility script for Linux to remove the directory generated with `run-cmake.sh` in `build`.
- `CMakeLists.txt`: main `CMakelists.txt` file for project (should not need to be modified for build).
- `Doxyfile.in`: [Doxygen](http://www.doxygen.org "Doxygen homepage") configuration file, adapted for generic use within project build (should not need to be modified).
- `LICENSE.md`: license file for project (copyright statement needs to be edited).
- `README.md`: readme file for project (copyright statement needs to be edited).
- `Uninstall.cmake.in`: Uninstall configuration scrip, necessary for the `make uninstall` target.
- `run-cmake.bat`: utility script for Windows to execute `cmake` command. It is strongly recommanded to use it, otherwise take note what you must to do by refering to [Build options](https://github.com/josephgarnier/cmake-base-cpp#build-options).
- `run-cmake.sh`: utility script for Linux to execute `cmake` command. It is strongly recommanded to use it, otherwise take note what you must to do by refering to [Build options](https://github.com/josephgarnier/cmake-base-cpp#build-options).

## Acknowledgments

This project was inspired from [cppbase](https://github.com/kartikkumar/cppbase) and from advices of [Hilton Lipschitz](https://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/).

## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.
