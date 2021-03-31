<div align="center">
<figure>
  <img src="https://i.imgur.com/5H55F9n.png" alt="C++ and CMake" width="50%"/>
</figure>

# C++ Starter Project with CMake

</div>

**A customizable kit to quickly start your C++ projects**.

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="CrCC BY-NC-SA 4.0" src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-brightgreen.svg"/></a> <img alt="plateform-windows-linux-mac" src="https://img.shields.io/badge/platform-windows%20%7C%20linux%20%7C%20mac-lightgrey.svg"/> <img alt="languages-cmake-c++" src="https://img.shields.io/badge/languages-CMake%20%7C%20C%2B%2B-blue.svg"/> <img alt="goal-progress-80" src="https://img.shields.io/badge/goal%20progress-80%25-orange.svg"/>

This starter ships with all you might need to get up and running blazing fast with a modern C++ project using CMake. It can be used as the basis for new projects on windows and linux.

## 💠 Table of Contents <!-- omit in toc -->

- [✨ Features](#-features)
- [✔️ Requirements](#️-requirements)
- [🚀 Getting started](#-getting-started)
- [📄 Configuration](#-configuration)
  - [1. Global settings](#1-global-settings)
  - [2. Setting up the toolchain and project files](#2-setting-up-the-toolchain-and-project-files)
  - [3. Example with Qt of a link with an external library](#3-example-with-qt-of-a-link-with-an-external-library)
- [⚙️ Compilation and Usage](#️-compilation-and-usage)
- [📂 Folder structure overview](#-folder-structure-overview)
- [🤝 Contributing](#-contributing)
- [👥 Credits](#-credits)
- [📜 License](#-license)
- [🍻 Acknowledgments](#-acknowledgments)

## ✨ Features

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
- separate file to manually include external libraries (in `Dependencies.cmake` module) or recursively and automatically scan `lib/` directory;
- separate file to manually specify source project files (in `ProjectSrcFiles.cmake` module) or recursively and automatically scan source file in `src/` and `include/` directories;
- a list of commands for Visual Studio Code (`tasks.json`).

## ✔️ Requirements

Before using this project, please ensure that you have installed the following (install guides are provided on the respective websites):

- A C++ compiler, e.g [GCC](https://gcc.gnu.org/), [Clang C++](https://clang.llvm.org/cxx_status.html) or [Visual Studio](https://visualstudio.microsoft.com);
- [CMake](https://cmake.org/) > 3.16.

The following dependencies are optional (see [Build options](https://github.com/josephgarnier/cmake-base-cpp#build-options)):

- [Doxygen](http://www.doxygen.nl/) (necessary when `DBUILD_DOXYGEN_DOCS` build option is set to `on`);
- [GTest](https://github.com/google/googletest) (necessary when `DBUILD_TESTS` build option is set to `on`).

## 🚀 Getting started

1. **Clone the repo.**

    ```bash
    git clone https://github.com/josephgarnier/cmake-base-cpp.git --recursive
    cd cmake-base-cpp
    ```

2. **Clean the project.**

    This starter ships is delivered with demo files to allow you to test different settings, therefore, before using your own source files you have to clean several directories. If you want to keep demos files for testing, go to the next section, else, remove files inside `src/` and `include/` directories.

## 📄 Configuration

### 1. Global settings

Instead of executing `cmake` command with its flags in a terminal, the two scripts `run-cmake.sh` (linux) and `run-cmake.bat` (windows) are proposed to execute them and load a CMakeCache file containing all settings described below. So, open the file `cmake/project/CMakeOptions.txt` with a text editor and edit the **variables project** listed in *customize section* (name, version, generator, etc).

These variables correspond to the CMake options used when running `cmake` command. If you don't edit them, they will be set with a default value:

- `PROJECT_NAME`: specifies a name for project
- `PROJECT_SUMMARY`: short description of the project
- `PROJECT_VENDOR_NAME`: project author
- `PROJECT_VENDOR_CONTACT`: author contact
- `PROJECT_VERSION_MAJOR`: project major version
- `PROJECT_VERSION_MINOR`: project minor version
- `PROJECT_VERSION_PATCH`: project patch version
- `TOOLCHAIN_FILE`: specifies toolchain file, see [toolchains](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html)
- `GENERATOR`: specifies CMake generator, see [cmake-generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html)
- `COMPILE_VERSION=[11|14|17 (default)|20]`: specifies compiler version "11" or "14" or "17" or "20", see [CMAKE_CXX_STANDARD](https://cmake.org/cmake/help/latest/variable/CMAKE_CXX_STANDARD.html)
- `COMPILE_DEFINITIONS`: specifies a semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty.
- `ASSERT_ENABLE=[ON|OFF (default)]`: specifies whether to use assert (optionally used in `cmake/project/Dependencies.cmake`)
- `BUILD_TYPE=[(default) debug|release]`: specifies type of build "debug" or "release"
- `BUILD_TARGET=[static|shared|exec (default)]`: specified whether build static or shared library or as an exec
- `BUILD_TESTS=[ON|OFF (default)]`: specifies whether build tests
- `BUILD_DOXYGEN_DOCS=[ON|OFF (default)]`: specifies whether build documentation
- `EXPORT_NAMESPACE`: name to prepend to the target name when it is written to the import file, see [install](https://cmake.org/cmake/help/latest/command/install.html#export)
- `INSTALL_DIRECTORY`: directory used by install command, let empty to use the default value, see [CMAKE_INSTALL_PREFIX](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html)

In addition to the previous scripts, you can use the scripts `clean-cmake.sh` (linux) or `clean-cmake.bat` (windows) to clean the project from its generated files like executable, library, documentation, etc. They call the `cmake clean` command.

### 2. Setting up the toolchain and project files

To compile your project, CMake will need a [toolchains](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html) file. First, **create your own toolchains file** in `cmake/toolchains` or use one provided by default : there are one file for clang on linux and another one for visual studio on windows, feel free to clean them of their compile flags if you don't need them. Then, edit the CMakeOptions cache file and **set the path to your toolchain** file in `TOOLCHAIN_FILE_VAL` variable. We'll now configure all files in `cmake/project/`.

Add your **source files** (headers and cpp) in `src/` directory or only the private source files if you decide to separate public and private headers. In this case, put the public headers in a specific directory (or not) in `include/`. Please note that there are already some files for testing, remember to erase them before putting yours. All customizable settings for the integral source files are located in the file `cmake/project/ProjectSrcFiles.cmake`. By default, the instructions in file will automatically scan the two directories listed and set cmake variables accordingly. But if you don't want to use the automation script scanning, open this file and read the instructions given in comment to complete it.

In some cases, it's necessary to use a [precompiled header](https://en.wikipedia.org/wiki/Precompiled_header) file. If this concern you, rename your **precompiled header** file according to pattern `<project-name>_pch.h` or edit the two related variables in `ProjectSrcFiles.cmake` file.

Now, if you use **external libraries** (.dll or .so files), either you add them in `lib/` directory and their header files each in a specific directory in `include/` directory, or you have to complete the `cmake/project/Dependencies.cmake` and `cmake/project/PackageConfig.cmake.in` files by relying on the commented instructions to import them with specifics commands as `find_package()`, `target_link_libraries()`, etc. Sometimes, some libraries (like Qt with the mocks) will generate source files in the `build/` folder that will need to be made exportable. In this case, these files will be considered internal to the project and the folder containing them will have to be be specified in the `cmake/project/ProjectSrcFiles.cmake`.

Here is an example of minimal instructions to write in the file `cmake/project/Dependencies.cmake` to link a library (only this file need to be modified). For a more consequent example, with Qt, see [here](#3-example-with-qt-of-a-link-with-an-external-library).

```bash
# First use case: you want to use the internal and automatic mechanism of library integration.
# You only need to set the variable `${PROJECT_NAME}_LIBRARY_HEADER_DIRS` with the folders containing the include headers.
set(${PROJECT_NAME}_LIBRARY_HEADER_DIRS "${${PROJECT_NAME}_INCLUDE_DIR}/myFirstLib" "${${PROJECT_NAME}_INCLUDE_DIR}//myFirstLib")

# Second use case : you want to link a library installed in another folder than the one of your project.
# You have to write these instructions after the comment "Add your special instructions here."
if(DEFINED ENV{OtherProjectName_DIR})
  set(OtherProjectName_DIR "$ENV{OtherProjectName_DIR}")
else()
  set(OtherProjectName_DIR "/usr/local/lib/other-project-name/cmake") # Path can be the build tree or the install tree
endif()
find_package(OtherProjectName REQUIRED)
target_link_libraries("${${PROJECT_NAME}_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:MyOtherProject::OtherProjectName>"
    "$<INSTALL_INTERFACE:MyOtherProject::OtherProjectName>"
)
```

The next file to configure is for **packaging and exporting** your application to be installed or included in another project. This **step is optional** if you plan to export your project only as executable. It's not an obligation either if you export as library, but strongly recommended. For that, you have to edit `cmake/project/PackageConfig.cmake.in` and fill it from documentation of [`find_package()`](https://cmake.org/cmake/help/latest/command/find_package.html), [cmake-packages](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html) and [cmake-buildsystem](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html). But the file is already filled with a default content to be exported then imported in an other project with `target_link_libraries()`. If you are not familiar with these concepts of modern cmake, watch this [tutorial](https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets).

The two next files to configure are to generate **binary and source package installers**. This **step is optional** if you don't plan to create an installer. By default, the project is provided with a basic configuration to generate an archive installer on Linux and an NSIS installer on Windows. If despite everything you want to customize the many options, edit the files `cmake/project/CPackInstallerConfig.cmake` and `cmake/project/CPackInstallerOptions.cmake.in` in following the documentation of [CPack](https://cmake.org/cmake/help/latest/module/CPack.html).

Finally, this project allow you to generate an [Doxygen](http://www.doxygen.nl/) **documentation** and provide a default configuration in file `doc/doxyfile.in`. This **step is optional** if you set off documentation generation, else, read the manual of Doxygen to know how configure it.

### 3. Example with Qt of a link with an external library

Add the instructions below in the file `cmake/project/Dependencies.cmake`.

```bash
# Second use case : you want to link a library installed in another folder than the one of your project.
# Add your special instructions here.
#  ||
#  V
message("\n** Include Qt **")
if(DEFINED ENV{Qt5_DIR})
  set(Qt5_DIR "$ENV{Qt5_DIR}")
else()
  set(Qt5_DIR "/opt/Qt/5.15.1/gcc_64/lib/cmake/Qt5")
endif()
find_package(Qt5 COMPONENTS Widgets Gui Core Svg Concurrent REQUIRED)
find_package(Qt5CoreMacrosCustom REQUIRED)
find_package(Qt5WidgetsMacrosCustom REQUIRED)

if (${Qt5Widgets_VERSION} VERSION_LESS 5.15.1
  OR ${Qt5Gui_VERSION} VERSION_LESS 5.15.1
  OR ${Qt5Core_VERSION} VERSION_LESS 5.15.1
  OR ${Qt5Svg_VERSION} VERSION_LESS 5.15.1
  OR ${Qt5Concurrent_VERSION} VERSION_LESS 5.15.1)
    message(FATAL_ERROR "Minimum supported Qt5 version is 5.15.1!")
endif()

set(QOBJECT_SOURCE_FILES "${${PROJECT_NAME}_SRC_DIR}/myQObject.cpp")
set(QOBJECT_HEADER_FILES "${${PROJECT_NAME}_SRC_DIR}/myQObject.h")
set(UI_FILES "")
set(RESSOURCE_FILES "")

# The directory where the files will be generated should be added to the
# variable `${PROJECT_NAME}_HEADER_PUBLIC_DIRS` in `ProjectSrcFiles.cmake`.
qt5_wrap_cpp(MOC_HEADER_FILES ${QOBJECT_HEADER_FILES})
qt5_wrap_ui_custom(UI_SOURCE_FILES ${UI_FILES})
qt5_add_resources_custom(RESSOURCE_SRCS ${RESSOURCE_FILES})

set(RELATIVE_QOBJECT_SOURCE_FILES "")
file_manip(RELATIVE_PATH QOBJECT_SOURCE_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_QOBJECT_SOURCE_FILES)
set(RELATIVE_QOBJECT_HEADER_FILES "")
file_manip(RELATIVE_PATH QOBJECT_HEADER_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_QOBJECT_HEADER_FILES)
set(RELATIVE_MOC_HEADER_FILES "")
file_manip(RELATIVE_PATH MOC_HEADER_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_MOC_HEADER_FILES)
set(RELATIVE_UI_FILES "")
file_manip(RELATIVE_PATH UI_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_UI_FILES)
set(RELATIVE_UI_SOURCE_FILES "")
file_manip(RELATIVE_PATH UI_SOURCE_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_UI_SOURCE_FILES)
set(RELATIVE_RESSOURCE_FILES "")
file_manip(RELATIVE_PATH RESSOURCE_FILES BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_RESSOURCE_FILES)
set(RELATIVE_RESSOURCE_SRCS "")
file_manip(RELATIVE_PATH RESSOURCE_SRCS BASE_DIR "${${PROJECT_NAME}_PROJECT_DIR}" OUTPUT_VARIABLE RELATIVE_RESSOURCE_SRCS)

message(STATUS "QObject sources found:")
foreach(file IN ITEMS ${RELATIVE_QOBJECT_SOURCE_FILES})
  message("    ${file}")
endforeach()

message(STATUS "QObject headers found:")
foreach(file IN ITEMS ${RELATIVE_QOBJECT_HEADER_FILES})
  message("    ${file}")
endforeach()

message(STATUS "QObject moc found:")
foreach(file IN ITEMS ${RELATIVE_MOC_HEADER_FILES})
  message("    ${file}")
endforeach()

message(STATUS "UI files found:")
foreach(file IN ITEMS ${RELATIVE_UI_FILES})
  message("    ${file}")
endforeach()

message(STATUS "UI sources found:")
foreach(file IN ITEMS ${RELATIVE_UI_SOURCE_FILES})
  message("    ${file}")
endforeach()

message(STATUS "Ressources files found:")
foreach(file IN ITEMS ${RELATIVE_RESSOURCE_FILES})
  message("    ${file}")
endforeach()

message(STATUS "Ressources sources found:")
foreach(file IN ITEMS ${RELATIVE_RESSOURCE_SRCS})
  message("    ${file}")
endforeach()
message("")

# Add Qt sources to target
message(STATUS "Add Qt sources to target")
target_sources("${${PROJECT_NAME}_TARGET_NAME}"
  PRIVATE
    "${RELATIVE_QOBJECT_SOURCE_FILES};${RELATIVE_MOC_HEADER_FILES};${RELATIVE_UI_SOURCE_FILES};${RELATIVE_RESSOURCE_SRCS}"
)

# Add Qt definitions to target
message(STATUS "Add Qt definitions to target")
target_compile_definitions("${${PROJECT_NAME}_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
    "$<INSTALL_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
)

# Link Qt to target
message(STATUS "Link Qt to target\n")
target_link_libraries("${${PROJECT_NAME}_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
    "$<INSTALL_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
)

# Set Qt as a position-independent target
set_target_properties("${${PROJECT_NAME}_TARGET_NAME}" PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
if(${${PROJECT_NAME}_TARGET_IS_EXEC})
  target_compile_options("${${PROJECT_NAME}_TARGET_NAME}"
    PUBLIC
      "$<BUILD_INTERFACE:-fPIE>"
      "$<INSTALL_INTERFACE:-fPIE>"
    PRIVATE
      "-fPIE"
  )
elseif(${${PROJECT_NAME}_TARGET_IS_STATIC} OR ${${PROJECT_NAME}_TARGET_IS_SHARED})
  target_compile_options("${${PROJECT_NAME}_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:-fPIC>"
    "$<INSTALL_INTERFACE:-fPIC>"
  PRIVATE
    "-fPIC"
  )
endif()

# Add Qt assert definitions to target if needed (these instructions are optional,
# they are only a way to easily enable or disable asserts from the file `cmake/project/CMakeOptions.txt`.
if(${PARAM_ASSERT_ENABLE})
  message(STATUS "QtAssert enabled\n")
else()
  message(STATUS "Add Qt assert definitions to target")
  target_compile_definitions("${${PROJECT_NAME}_TARGET_NAME}"
    PUBLIC
      "$<BUILD_INTERFACE:QT_NO_DEBUG>"
      "$<INSTALL_INTERFACE:QT_NO_DEBUG>"
  )
  message(STATUS "QtAssert disabled\n")
endif()
```

Add the instructions below in the file `cmake/project/ProjectSrcFiles.cmake`.

```bash
# The last directory specified is the one in which the mocks are generated. Here it is `/build/src`
set(${PROJECT_NAME}_HEADER_PUBLIC_DIRS "${${PROJECT_NAME}_SRC_DIR}" "${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}" "${${PROJECT_NAME}_BUILD_DIR}/src")
```

## ⚙️ Compilation and Usage

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

Optionally, you might want to [**install**](https://cmake.org/cmake/help/latest/command/install.html#command:install) your project in directory [defined by cmake](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html), or conversely you may want to **uninstall** it. In a terminal, write these commands:

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

## 📂 Folder structure overview

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
| `resources/` | contains images, musics, maps and all resources needed for your project. |
| `src/` | project source files (*.cpp) and project header files (.h) for project build, which contains example main-function (`main.cpp`) and example precompiled files (`*_pch.h`). |
| `tests/` | project test source files (*.cpp) and project test header files (.h) that are provided to the selecting unit testing framework. |
| `clean-cmake.bat` | utility script for Windows to remove the directory generated with `run-cmake.bat` in `build/`, `bin/` and `doc/` directories. |
| `clean-cmake.sh` | utility script for Linux to remove the directory generated with `run-cmake.sh` in `build`, `bin` and `doc` directories. |
| `CMakeLists.txt` | main `CMakelists.txt` file for project (should not need to be modified for build). |
| `LICENSE.md` | license file for project (copyright statement needs to be edited). |
| `README.md` | readme file for project (copyright statement needs to be edited). |
| `run-cmake.bat` | utility script for Windows to execute `cmake` command. |
| `run-cmake.sh` | utility script for Linux to execute `cmake` command. |

## 🤝 Contributing

1. Fork the repo and create your feature branch from master.
2. Create a topic branch - `git checkout -b my_branch`.
3. Push to your branch - `git push origin my_branch`.
4. Create a Pull Request from your branch.

## 👥 Credits

This project is maintained and developed by [Joseph Garnier](https://www.joseph-garnier.com/).

## 📜 License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>

This work is licensed under the terms of a <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-SA 4.0</a>.  See the [LICENSE.md](LICENSE.md) file for details.

## 🍻 Acknowledgments

This project was inspired from [cppbase](https://github.com/kartikkumar/cppbase) and from advices of [Hilton Lipschitz](https://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/).
