# CMakeBaseCpp

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="CrCC BY-NC-SA 4.0" src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-brightgreen.svg"/></a> <img alt="plateform-windows-linux" src="https://img.shields.io/badge/platform-windows%20%7C%20linux-lightgrey.svg"/> <img alt="languages-cmake-c++" src="https://img.shields.io/badge/languages-CMake%20%7C%20C%2B%2B-blue.svg"/> <img alt="goal-progress-80" src="https://img.shields.io/badge/goal%20progress-80%25-orange.svg"/>

CMakeBaseCpp is a template for a structured modern CMake-based C++ project that can be used as the basis for new projects on windows and linux. It includes:

- a general directory structure common to C++ projects (see [Project structure](https://github.com/josephgarnier/cmake-base-cpp#project-structure));
- a modern CMake project using the last features;
- a customizable script to run cmake (`run-cmake.sh` or `run-cmake.bat`);
- a script to clean cmake generated files (`clean-cmake.sh` or `clean-cmake.bat`);
- install script with target exporting (`make install`);
- uninstall script (`make uninstall`);
- a customizable CPack script for packaging (`cpack`);
- use [Cotire](https://github.com/sakra/cotire) to build as executable or library with precompiled headers file (pch);
- automatic API documentation with [Doxygen](http://www.doxygen.nl/) and a special command (`make docs`);
- a unit testing framework with [GTest](https://github.com/google/googletest) => **in progress**;
- separate file to manualy include external libraries (in `Dependencies.cmake` module) or recursivly and automaticaly scan `lib/` directory;
- separate file to manualy specify source project files (in `ProjectSrcFiles.cmake` module) or recursivly and automaticaly scan source file in `src/` and `include/` directories;
- a list of commands for Visual Studio Code (`tasks.json`).

## Requirements

Before using this project, please ensure that you have installed the following (install guides are provided on the respective websites):

- A C++ compiler, e.g [GCC](https://gcc.gnu.org/), [Clang C++](https://clang.llvm.org/cxx_status.html) or [Visual Studio](https://visualstudio.microsoft.com);
- [CMake](https://cmake.org/) > 3.16.

The following dependencies are optional (see [Build options](https://github.com/josephgarnier/cmake-base-cpp#build-options)):

- [Doxygen](http://www.doxygen.nl/) (necessary when `DBUILD_DOXYGEN_DOCS` build option is set to `on`);
- [GTest](https://github.com/google/googletest) (necessary when `DBUILD_TESTS` build option is set to `on`).

## Installation

1. Clone the repo.

```bash
git clone https://github.com/josephgarnier/cmake-base-cpp.git --recursive
cd cmake-base-cpp
```

2. Clean the project. CMakeBaseCpp is delivered with demo files to allow you to test different settings, therefore, before using your own source files you have to clean several directories. If you want to keep demos files for testing, go to the next section, else, remove files inside `src/` and `include/` directories.

## Configuration

### 1. Global settings

Instead of executing `cmake` command with its flags in a terminal, the two scripts `run-cmake.sh` (linux) and `run-cmake.bat` (windows) are proposed to execute them and load a CMakeCache file containing all settings described below. So, open the file `cmake/project/CMakeOptions.txt` with a text editor and edit the **variables project** listed in *customize section* (name, version, generator, etc).

These variables correspond to the CMake options used when running `cmake` command. If you don't edit them, they will be set with a default value:

- `PROJECT_NAME_VAL`: specifies a name for project
- `PROJECT_SUMMARY_VAL`: short description of the project
- `PROJECT_VENDOR_NAME_VAL`: project author
- `PROJECT_VENDOR_CONTACT_VAL`: author contact
- `PROJECT_VERSION_MAJOR_VAL`: project major version
- `PROJECT_VERSION_MINOR_VAL`: project minor version
- `PROJECT_VERSION_PATCH_VAL`: project patch version
- `TOOLCHAIN_FILE_VAL`: specifies toolchain file, see [toolchains](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html)
- `GENERATOR_VAL`: specifies CMake generator, see [cmake-generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html)
- `COMPILE_VERSION=[11|14|17 (default)|20]`: specifies compiler version "11" or "14" or "17" or "20", see [CMAKE_CXX_STANDARD](https://cmake.org/cmake/help/latest/variable/CMAKE_CXX_STANDARD.html)
- `COMPILE_DEFINITIONS`: specifies a semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty.
- `BUILD_TYPE=[(default) debug|release]`: specifies type of build "debug" or "release"
- `ASSERT_ENABLE=[ON|OFF (default)]`: specifies whether to use assert (optionally used in `cmake/project/Dependencies.cmake`)
- `BUILD_TARGET=[static|shared|exec (default)]`: specified whether build static or shared library or as an exec
- `BUILD_TESTS=[ON|OFF (default)]`: specifies whether build tests
- `BUILD_DOXYGEN_DOCS=[ON|OFF (default)]`: specifies whether build documentation
- `EXPORT_NAMESPACE`: name to prepend to the target name when it is written to the import file, see [install](https://cmake.org/cmake/help/latest/command/install.html#export)

In addition to the previous scripts, you can use the scripts `clean-cmake.sh` (linux) or `clean-cmake.bat` (windows) to clean the project from its generated files like executable, library, documentation, etc. They call the `cmake clean` command.

### 2. Setting up the toolchain and project files

To compile your project, CMake will need a [toolchains](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html) file. First, **create your own toolchains file** in `cmake/toolchains` or use one provided by default : there are one file for clang on linux and another one for visual studio on windows, feel free to clean them of their compile flags if you don't need them. Then, edit the CMakeOptions cache file and **set the path to your toolchain** file in `TOOLCHAIN_FILE_VAL` variable. We'll now configure all files in `cmake/project/`.

Add your **source files** (headers and cpp) in `src/` directory or only the private source files if you decide to separate public and private header. In this case, put the public headers in a specific directory (or not) in `include/`. Please note that there are already some files for testing, remember to erase them before putting yours. By default, the instructions in file `cmake/project/ProjectSrcFiles.cmake` will automatically scan these directories and set cmake variables accordingly. But if you don't want to use the automation script scanning, open this file and read the instructions given in comment to complete it.

In some cases, it's necessary to use a [precompiled header](https://en.wikipedia.org/wiki/Precompiled_header) file. If this concern you, rename your **precompiled header** file according to pattern `<project-name>_pch.h` or edit the two related variables in `ProjectSrcFiles.cmake` file.

Now, if you use **external libraries** (.dll or .so files), add them in `lib/` directory, and add their header files each in a specific directory in `include/` directory. Then, complete the `cmake/project/Dependencies.cmake` file by relying on the commented instructions.

The next file to configure is for **packaging and exporting** your application to be installed or included in another project. This **step is optional** if you plan to export your project only as executable. It's not an obligation either if you export as library, but strongly recommanded. For that, you have to edit `cmake/project/PackageConfig.cmake.in` and fill it from documentation of [`find_package()`](https://cmake.org/cmake/help/latest/command/find_package.html), [cmake-packages](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html) and [cmake-buildsystem](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html). But the file is already filled with a default content to be exported then imported in an other project with `target_link_libraries()`. If you are not familiar with these concepts of modern cmake, watch this [tutorial](https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets).

The two next files to configure are to generate **binary and source package installers**. This **step is optional** if you don't plan to create an installer. By default, the project is provided with a basic configuration to generate an archive installer on Linux and an NSIS installer on Windows. If despite everything you want to customize the many options, edit the files `cmake/project/CPackInstallerConfig.cmake` and `cmake/project/CPackInstallerOptions.cmake.in` in following the documentation of [CPack](https://cmake.org/cmake/help/latest/module/CPack.html).

Finally, this project allow you to generate an [Doxygen](http://www.doxygen.nl/) **documentation** and provide a default configuration in file `doc/doxyfile.in`. This **step is optional** if you set off documentation generation, else, read the manual of Doxygen to know how configure it.

## Compilation and Usage

CMakeBaseCpp provide several scripts and commands to compile, build, install, etc your project. These ones can be executed in a terminal or in a task (see `.vscode/tasks.json` file) if you use Visual Studio Code. Here is a review.

In project root directory, you will find the two scripts proposed to **clean** the `build/`, `bin/` and `doc/` directories and to **generate the build files** with `cmake` command. In a terminal, move the current working directory to your project root directory and write these commands to execute them :

```bash
./clean-cmake.sh && sleep 3s && ./run-cmake.sh
#or
start clean-cmake.bat && pause 3 && start run-cmake.bat
```

In case of success, you should see the message `The solution was successfully generated!`. All build files will be created in `build/`. Now you can **build** your project to generate an executable file or a library file in `bin/` directory.

```bash
(cd ./build && cmake --build . --clean-first)
```

That's all ! In addition to executable and library in `bin/` directory, you will find in `doc/` the **documentation** generated if you set `DPARAM_BUILD_DOXYGEN_DOCS` to on. You can generate only the documentation with the command :

```bash
(cd ./build && cmake --build . --target docs)
```

Optionnaly, you might want to [**install**](https://cmake.org/cmake/help/latest/command/install.html#command:install) your project in directory [defined by cmake](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html), or conversely you may want to **uninstall** it. In a terminal, write these commands:

```bash
(cd ./build && sudo cmake --build . --target install)
(cd ./build && sudo cmake --build . --target uninstall)
```

Also, if you want to [**pack**](https://cmake.org/cmake/help/latest/manual/cpack.1.html) your projet to generate an installer in a variety of [formats](https://cmake.org/cmake/help/latest/manual/cpack.1.html) (deb, zip, nsis, etc) in `bin/` directory, write these commands:

```bash
# pack only files install from the make install command
(cd ./build && cpack --config CPackConfig.cmake && sleep 3s && rm -rf ../../bin/_CPack_Packages)
# pack all files
(cd ./build && cpack --config CPackSourceConfig.cmake && sleep 3s && rm -rf ../../bin/_CPack_Packages)
```

Not that at any time you can clean the `build/`, `bin/` and `doc/` directories with the script:

```bash
./clean-cmake.sh
#or
start clean-cmake.bat
```

## Folder structure overview

This project has been set up with a specific file/folder structure in mind. The following describes some important features of this setup:

| **Directory and File** | **What belongs here** |
|------------------------|-----------------------|
| `.vscode/tasks.json` | specific tasks configured to compile, clean, build, etc. |
| `assets/` | contains images, musics, maps and all resources needed for a simulation or a game project. |
| `bin/` | any libs that get compiled by the project and the output executables go here, also if you pack your project, the generated files go here. |
| `build/` | contains all object files, and is removed on a `clean`. |
| `cmake/helpers/Uninstall.cmake.in` | uninstall script, necessary for the `make uninstall` target. |
| `cmake/modules/` | contains `CMake` modules. |
| `cmake/project/CMakeOptions.txt` | settings file to populate the cache. |
| `cmake/project/CPackInstallerConfig.cmake` | instructions to build package installer for binaries and sources. |
| `cmake/project/CPackInstallerOptions.cmake.in` | configuration of each cpack generator. |
| `cmake/project/Dependencies.cmake` | project external libs settings. |
| `cmake/project/PackageConfig.cmake.in` | dependency information of your project for CMake based buildsystems for `find_package()` function. |
| `cmake/project/ProjectSrcFiles.cmake` | project source files settings. |
| `cmake/toolchains/` | contains toolchain files for compilers. By default, only two are proposed for Linux Clang and Windows Visual Studio.
| `config/` | contains configuration files. |
| `doc/` | contains code documentation generated by [Doxygen](http://www.doxygen.org "Doxygen homepage"). |
| `doc/doxyfile.in` | [Doxygen](http://www.doxygen.org "Doxygen homepage") configuration file, adapted for generic use within project build (should not need to be modified). |
| `include/` | all necessary third-party header files (.h) that do not exist on your system are also placed here. |
| `lib/` | third party or any needed in your project. |
| `resources/` | contains images, musics, maps and all resources needed if for your project. |
| `src/` | project source files (*.cpp) and project header files (.h) for project build, which contains example main-function (`main.cpp`) and example precompiled files (`*_pch.h`). |
| `tests/` | project test source files (*.cpp) and project test header files (.h) that are provided to the selecting unit testing framework. |
| `clean-cmake.bat` | utility script for Windows to remove the directory generated with `run-cmake.bat` in `build/`, `bin/` and `doc/` directories. |
| `clean-cmake.sh` | utility script for Linux to remove the directory generated with `run-cmake.sh` in `build`, `bin` and `doc` directories. |
| `CMakeLists.txt` | main `CMakelists.txt` file for project (should not need to be modified for build). |
| `LICENSE.md` | license file for project (copyright statement needs to be edited). |
| `README.md` | readme file for project (copyright statement needs to be edited). |
| `run-cmake.bat` | utility script for Windows to execute `cmake` command. |
| `run-cmake.sh` | utility script for Linux to execute `cmake` command. |

## Contributing

1. Fork the repo and create your feature branch from master.

2. Create a topic branch - `git checkout -b my_branch`.

3. Push to your branch - `git push origin my_branch`.

4. Create a Pull Request from your branch.

## Credits

This project is maintained and developed by [Joseph Garnier](garnjose@gmail.com).

## License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Creative Commons License" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a><br />This work is licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/">Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License</a>.  See the [LICENSE.md](LICENSE.md) file for details.

## Acknowledgments

This project was inspired from [cppbase](https://github.com/kartikkumar/cppbase) and from advices of [Hilton Lipschitz](https://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/).
