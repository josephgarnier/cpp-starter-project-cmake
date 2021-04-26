<div align="center">
<figure>
  <img src="https://i.imgur.com/7moLJxE.png" alt="C++ and CMake" width="50%"/>
</figure>

# C++ Starter Project with CMake

</div>
<p align="center">
<strong>A customizable kit to quickly start your C++ projects with CMake.</strong>
</p>

<p align="center">
<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="CrCC BY-NC-SA 4.0" src="https://img.shields.io/badge/license-CC%20BY--NC--SA%204.0-brightgreen.svg"/></a> <img alt="plateform-windows-linux-mac" src="https://img.shields.io/badge/platform-windows%20%7C%20linux%20%7C%20mac-lightgrey.svg"/> <img alt="languages-cmake-c++" src="https://img.shields.io/badge/languages-CMake%20%7C%20C%2B%2B-blue.svg"/> <img alt="goal-progress-80" src="https://img.shields.io/badge/goal%20progress-80%25-orange.svg"/>
</p>

This starter ships with all you might need to get up and running blazing fast with a modern C++ project using **modern CMake**, with a particular focus on good practices. It can be used as the basis for new projects on Windows, Linux and MacOS. And, it allows you to generate commands for **all phases of the development lifecycle** of modern C++ software: clean, build, test, code analysis, doc generation and deployment.

## 💠 Table of Contents <!-- omit in toc -->

- [✨ Features](#-features)
- [⚓ Requirements](#-requirements)
- [🚀 Getting started](#-getting-started)
- [💫 *Build Lifecycle* overview](#-build-lifecycle-overview)
- [📄 Setting up the generator modules](#-setting-up-the-generator-modules)
  - [1. Global settings](#1-global-settings)
  - [2. *Build Generator Module* settings](#2-build-generator-module-settings)
  - [3. *Test Generator Module* settings](#3-test-generator-module-settings)
  - [4. *Code Analysis Generator Module* settings](#4-code-analysis-generator-module-settings)
  - [5. *Doc Generator Module* settings](#5-doc-generator-module-settings)
  - [6. *Export Generator Module* settings](#6-export-generator-module-settings)
  - [7. *Package Generator Module* settings](#7-package-generator-module-settings)
  - [8. *Uninstall Generator Module* settings](#8-uninstall-generator-module-settings)
- [⚙️ Usage and commands](#️-usage-and-commands)
- [📂 Folder structure overview](#-folder-structure-overview)
- [💻 Programming with CMake](#-programming-with-cmake)
- [🤝 Contributing](#-contributing)
- [👥 Credits](#-credits)
- [©️ License](#️-license)
- [🍻 Acknowledgments](#-acknowledgments)

## ✨ Features

- A template suitable for both small and complex projects.
- Start your development in C++ in a few minutes.
- A [directory structure](#-folder-structure-overview) common to all you C++ projects.
- An [easy setup](https://cmake.org/cmake/help/latest/manual/cmake.1.html#options) with an high level of customization;
- Can generate the build files for executable and for shared, static and header-only library.
- Leverages the power of [modern CMake](https://cliutils.gitlab.io/modern-cmake/) to build commands for every phase of the software development lifecycle.
- Centralized configuration files and no need to modify any CMakeList file.
- Possibility of configuring different options according to the OS (Linux, Windows and MacOS).
- Rigorous control over possible configuration errors.
- Allow to work with different [toolchains](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html) (e.g. one for VS Studio, one for QtCreator, etc).
- [Automatically download](https://cmake.org/cmake/help/latest/module/FetchContent.html) dependencies.
- Provides a way to generate a documentation, an installer, to run unit tests, to export the project and to install/uninstall it.
- A list of commands for Visual Studio Code to trigger individually each phase of the *Build Lifecycle* (see `tasks.json`).

## ⚓ Requirements

This project is only a template and you are free to use the compiler and versions of your choice. However, you will need at least the following (install guides are provided on the respective websites):

- **C++ compiler** - e.g [GCC](https://gcc.gnu.org/), [Clang C++](https://clang.llvm.org/cxx_status.html) or [Visual Studio](https://visualstudio.microsoft.com).
- **CMake v3.16+** - can be found [here](https://cmake.org/).

The following dependencies are **optional** because they will be **automatically downloaded** by CMake if they can't be found:

- [Doxygen](http://www.doxygen.nl/) (used when `ENABLE_TEST_MODULE` option is set to `on`);
- [GTest](https://github.com/google/googletest) (used when `ENABLE_DOC_MODULE` option is set to `on`).

## 🚀 Getting started

1. **Get the template** from this repository either by [downloading it](https://github.com/josephgarnier/cpp-starter-project-cmake/archive/refs/heads/master.zip), or by using it [as a template](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template) and then cloning it, or by [cloning](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) it directly with the command :

    ```bash
    git clone https://github.com/josephgarnier/cpp-starter-project-cmake.git --recursive
    cd cpp-starter-project-cmake
    ```

2. **Clean the project.** This starter ships is delivered with demo files to allow you to test different settings. If you want to keep them for now, go to the next section and come back here later. Else, if you want to delete them now to put your own files or when the time comes, empty the content of directories `src/`, `include/` and `tests/` manually (**except for** `CMakeLists.txt`) or use the following commands from the root:

    ```bash
    cd cpp-starter-project-cmake
    rm -rfvI src/* # "r" to recursively remove, "f" to force, "v" explain what is being done, "I" prompt once before removing
    rm -rfvI include/*
    shopt -s extglob && rm -rfvI tests/!(CMakeLists.txt) && shopt -u extglob
    ```

## 💫 *Build Lifecycle* overview

In the last few years, CMake has become complete and easy to use enough to handle the whole process of compilation, testing analyzing and distributing of a C ++ project. This is why the ambition of this template is to rely as much as possible on the power of CMake to propose a development base that is quick to use and covers all the steps of this process. Moreover, the objective is also to propose a structure that is generic enough to adapt to the greatest number of situations by offering a high level of customization.

No longer limited to be a [generator of project build environment](https://cmake.org/overview/) only for building libraries or executables, [CMake](https://cmake.org/cmake/help/latest/manual/cmake.1.html) has become a **complete generator of build lifecycle**, with its multiple phases (e.g. to build binary, build tests, build doc, etc), that can cover all the expected steps of a C++ project building and distribution process (just like [Maven](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html) for Java). Each phase is associated with a command. In using this template, here is an **overview of all the phases of the *Build Lifecycle*** that can be generated with their interactions:

[TODO IMAGE OVERVIEW]

Once all the files of phases of the *Build Lifecycle* have been generated, here is what they can do in using their respective command:

- `uninstall`: uninstall the installed project files from a specific location on the disk.
- `clean`: remove all files generated by a previous build and the generator.
- `build`: compile the source code of the project into a binary, link it to dependencies and optionally export it from the build tree).
- `test`: test the compiled source code using a suitable unit testing framework.
- `code analysis`: !! not implented yet !!  run any checks on results of integration tests to ensure quality criteria are met.
- `doc`: generate the project's documentation.
- `install`: install the project files into a specific location on the disk.
- `package source` and `package binary`: take the project files and package them in its distributable format, such as a ZIP or an installer.

The above is an example of a complete sequence of build phases, but it is possible to customize the order and to not generate some phases by disabling generator modules. **Generator modules** are a split of the CMake code into multiple logical units performing a particular task in the generation of the *Build Lifecycle*. Each of them generate at least one build phase, but they can be disabled as needed when a phase is not useful. However, the generator module for the `clean` and `build` phases is always enabled by default, since it is the minimum code to generate the *Build Lifecycle*.

A generator module is not an autonomous unit and it may share a dependency relationship with others, which conditions its activation. Here is the dependency graph of the modules with their configuration files:

[TODO IMAGE WORKFLOW]

The dashed lines indicate a dependency. Thus, for example, the *Uninstall Generator Module* depends on the *Export Generator Module*.

## 📄 Setting up the generator modules

Let's see now how to configure the generator modules and each build phases of the *Build Lifecycle* of your C++ project. Please remember that **only the generator module named `build` is mandatory to configure**, the others are optional and depend on your needs.

All standard options are passed to CMake thank to the [`initial-cache` feature](https://cmake.org/cmake/help/latest/manual/cmake.1.html#options) which pre-loads the script `cmake/project/StandardOptions.txt` to populate the cache. Then, it is called with the command `cmake -C <initial-cache>` (we will see later how use it easily). With this feature, it is no longer necessary to directly modify the `CMakeLists.txt` file and its is a more convenient way than using the [options](https://cmake.org/cmake/help/latest/command/option.html). Once the CMake generation command has been called, it will be possible, from the `build/` directory, to view cached variables and their descriptions with the command `cmake -LAH`.

In general, **don't worry if you make a mistake or forget an essential option** in a configuration file, each of them will be checked in `CMakeLists.txt` and you will receive an error message if necessary.

### 1. Global settings

The following options correspond to those that are global to the whole *Build Lifecycle* and not specific to a specific generator module.

Open the file `cmake/project/StandardOptions.txt` and edit them as you wish:

- `PROJECT_NAME`: specifies a name for project;
- `PROJECT_SUMMARY`: short description of the project;
- `PROJECT_VENDOR_NAME`: project author;
- `PROJECT_VENDOR_CONTACT`: author contact;
- `PROJECT_VERSION_MAJOR`: project major version;
- `PROJECT_VERSION_MINOR`: project minor version;
- `PROJECT_VERSION_PATCH`: project patch version;
- `LIFECYCLE_GENERATOR`: specifies for each platform with which generator the *Build Lifecycle* will be generated, see [cmake-generators](https://cmake.org/cmake/help/latest/manual/cmake-generators.7.html). By default, *Unix Makefiles* is used for Linux and MacOS, while *Visual Studio 16 2019* is used for Windows.

### 2. *Build Generator Module* settings

The **role of the *Build Generator Module*** is to use the optional generator given from options and the source tree files to initialize the generation of the [build tree](https://cmake.org/cmake/help/latest/manual/cmake.1.html#introduction-to-cmake-buildsystems) which will contain all the information and files of the *Build Lifecycle* of the C++ project. This basic structure will be used for all other modules. This is why this module cannot be disabled. Once the initialization is completed, the module will generate in the build tree the two build phases associated with it:

- `build`(https://cmake.org/cmake/help/latest/manual/cmake.1.html#build-a-project), to compile the source code of the project into a binary, link it to dependencies and optionally export it from the build tree (if *Export Generator Module* is enabled);
- `clean`, to remove all files generated by a previous build and the generator.

To use this module, **three options files** need to be configured. The **first file** is `cmake/project/StandardOptions.txt`, so open it and edit the options in the *Build Generator Module options* section:

- `BUILD_STANDARD_VERSION=[11|14|17 (default)|20|23]`: specifies build standard version "11" or "14" or "17" or "20" or 23, see [CMAKE_CXX_STANDARD](https://cmake.org/cmake/help/latest/variable/CMAKE_CXX_STANDARD.html);
- `BUILD_TYPE=[(default) debug|release]`: specifies type of build "debug" or "release", see [CMAKE_BUILD_TYPE](https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html);
- `BUILD_TARGET=[static|shared|header|exec (default)]`: specified whether build static or shared or header-only library or as an exec, see [TYPE](https://cmake.org/cmake/help/latest/prop_tgt/TYPE.html);
- `COMPILE_DEFINITIONS`: specifies a semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty;
- `PUBLIC_HEADERS_SEPARATED=[ON (default)|OFF]`: specifies whether public header files are separated from private header files (see below for more details);
- `TOOLCHAIN_FILE`: specifies a path to a [toolchain file](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html), (see below for more details).

The `PUBLIC_HEADERS_SEPARATED` option is there to provide **support for the two common policies in C++ projects** shown below:

[IMAGE]

The first is to put all header files in the `src/` tree files and none in `include/`. In this case `PUBLIC_HEADERS_SEPARATED` must be set to `off` and the header files will all be public. The second policy, when `PUBLIC_HEADERS_SEPARATED` is set to `on`, is to put only the private header files in `src/`, and to put the public header files in a sub-folder of `include/` in the name of your project. Therefore, if you choose the second policy you must create a `include/<project-name>` directory.

Except for personal convenience, the consequence of choosing a policy will only be visible if you enable the *Export Generator Module*. Indeed, only public header files will be exported outside the project to be made accessible for import by other projects (see the dedicated section for more details).

Finally, when you set `PUBLIC_HEADERS_SEPARATED` to `on`, header files can still be included in source files (.cpp) in two ways to allow greater flexibility: either by prefixing the paths with the project name, e.g. `#include "project-name/include1.h"`, or without prefixing, e.g. `#include "include1.h"`. This is possible because the two folders `include/` and `include/<project-name>` are added to the built binary with the command `target_include_directories()`.

The `TOOLCHAIN_FILE` option allows you to provide to the generator a path to a file that configures a [toolchain](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html) of utilities to compile, link libraries and create archives, and other tasks to drive the build. This feature offered by CMake is very useful for cross compiling. By default, the project comes with four toolchain files, located in the `cmake/toolchains` folder. If needed, you can add your own by following the [documentation provided by CMake](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html).

The **second file to configure** is the one that provides to the *Build Generator Module* the list of source and header files. Open the file `cmake/project/HeadersAndSourcesOptions.cmake` and edit each of the following variables as necessary:

- `${PROJECT_NAME}_SOURCE_SRC_FILES`: contains the list of source files (.cpp) present in the `src/` folder;
- `${PROJECT_NAME}_HEADER_SRC_FILES`: contains the list of header files (.h) in the `src/` directory;
- `${PROJECT_NAME}_HEADER_INCLUDE_FILES`: contains the list of header files present in the `include/<project-name>` folder (can be empty depending on the chosen policy).
- `${PROJECT_NAME}_PRECOMPILED_HEADER_FILE`: path to the **[precompiled header](https://en.wikipedia.org/wiki/Precompiled_header) file**. Initiated by default with a path pointing to the `include/` folder and more precisely `${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}/${PROJECT_NAME}_pch.h`, set the value to empty if you don't use this feature.

In order to minimize configuration time and to make CMake accessible, **the first three variables are automatically initialized** using a [glob function](https://cmake.org/cmake/help/latest/command/file.html#glob). So by default you don't have to configure them. However, using a glob function is [not a recommended practice](https://cmake.org/cmake/help/latest/command/file.html#glob) by CMake, so you are free to replace it with a manual initialization.

The **third and last file to configure** concerns the libraries to be linked to the binary. Open the file `cmake/project/DependenciesOptions.cmake` and edit each of the following variables as necessary:

- `${PROJECT_NAME}_LIBRARY_FILES`: contains the list of libraries in the `lib/` folder.
- `${PROJECT_NAME}_LIBRARY_HEADER_DIRS`: contains the list of subdirectories of `include/` that have header files for the libraries. The directory `include/<project-name>` is not in the list.

By default, and to simplify the use of CMake, all the internal libraries that are in the `lib/` folder will be automatically linked to the binary, with their header files that are in the subdirectories of `include/` (for linux workers, don't forget to create a link to each library in `lib\` for the [soname policy](https://en.wikipedia.org/wiki/Soname)). If you don't want to use this feature, just initialize both variables to empty.

Moreover, it is in this file, after the message *Import and link external libraries from here* that you have to put the **instructions necessary to import and link the external libaries** to the binary. Here are two examples of library import.

<details>
<summary>Link Qt</summary>

```cmake
#------------------------------------------------------
# Import and link external libraries from here.
#------------------------------------------------------
message("** Include Qt **")
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
target_sources("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
  PRIVATE
    "${RELATIVE_QOBJECT_SOURCE_FILES};${RELATIVE_MOC_HEADER_FILES};${RELATIVE_UI_SOURCE_FILES};${RELATIVE_RESSOURCE_SRCS}"
)

# Add Qt definitions to target
message(STATUS "Add Qt definitions to target")
target_compile_definitions("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
    "$<INSTALL_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
)

# Link Qt to target
message(STATUS "Link Qt to target")
target_link_libraries("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
    "$<INSTALL_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
)

# Set Qt as a position-independent target
set_target_properties("${${PROJECT_NAME}_BUILD_TARGET_NAME}" PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
if(${${PROJECT_NAME}_BUILD_TARGET_IS_EXEC})
  target_compile_options("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
    PUBLIC
      "$<BUILD_INTERFACE:-fPIE>"
      "$<INSTALL_INTERFACE:-fPIE>"
    PRIVATE
      "-fPIE"
  )
elseif(${${PROJECT_NAME}_BUILD_TARGET_IS_STATIC} OR ${${PROJECT_NAME}_BUILD_TARGET_IS_SHARED})
  target_compile_options("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:-fPIC>"
    "$<INSTALL_INTERFACE:-fPIC>"
  PRIVATE
    "-fPIC"
  )
endif()

# Add Qt assert definitions to target if needed (these instructions are optional,
# they are only a way to easily enable or disable asserts from the file `cmake/project/StandardOptions.txt`.
if("${CMAKE_BUILD_TYPE}" STREQUAL "debug")
  message(STATUS "QtAssert enabled")
else()
  message(STATUS "Add Qt assert definitions to target")
  target_compile_definitions("${${PROJECT_NAME}_BUILD_TARGET_NAME}"
    PUBLIC
      "$<BUILD_INTERFACE:QT_NO_DEBUG>"
      "$<INSTALL_INTERFACE:QT_NO_DEBUG>"
  )
  message(STATUS "QtAssert disabled")
endif()
```

</details>

<details>
<summary>Link Eigen3</summary>

```cmake
#------------------------------------------------------
# Link external libraries from here.
#------------------------------------------------------
message("** Include Eigen3 **")
if(DEFINED ENV{Eigen3_DIR}) 
  set(Eigen3_DIR "$ENV{Eigen3_DIR}")
else()
  set(Eigen3_DIR "D:/library/eigen-3.3.7/bin/share/eigen3/cmake")
endif()
find_package(Eigen3 REQUIRED NO_MODULE)

target_link_libraries("${${PROJECT_NAME}_TARGET_NAME}"
  PUBLIC
    "$<BUILD_INTERFACE:Eigen3::Eigen>"
    "$<INSTALL_INTERFACE:Eigen3::Eigen>"
)
```

</details>

If after configuring this module you do not wish to activate any others, go directly to the next section.

### 3. *Test Generator Module* settings

TODO `test`.


### 4. *Code Analysis Generator Module* settings

!! NOT IMPLEMENTED YET !!

### 5. *Doc Generator Module* settings

The **role of the *Doc Generator Module*** is to generate the `doc` phase which will allow to build the documentation [Doxygen](http://www.doxygen.nl/) of the project:

- `doc`: generate the project's documentation.

The **module depends on Doxygen**, so either you install it following the [site instructions](https://www.doxygen.nl/manual/install.html), or you let the module use the [auto-download feature](https://cmake.org/cmake/help/latest/module/FetchContent.html) which will detect the absence of the dependency and download it directly from its GitHub repository during generation. However, due to the size of the library, it is **strongly discouraged to use auto-download** and recommended to install it, because CMake re-downloads and then rebuilds the whole library each time the project is cleaned up, which takes several minutes.

To use this module, **two option files** need to be configured. The **first file** is `cmake/project/StandardOptions.txt`, so open it and edit the options in the *Doc Generator Module options* section:

- `ENABLE_DOC_MODULE=[ON|OFF (default)]`: specifies whether enable the doc generator module.

The **second file to configure** is the configuration template file `cmake/project/DoxygenConfig.in` which the module will autocomplete, in part, and use to generate the configuration file used by Doxygen. If you don't want to use the default values, open it and complete it following the instructions available on the [Doxygen documentation](https://www.doxygen.nl/manual/config.html). Values of the form `@var-name@` are autocomplete by CMake according to some project variables, so it is not recommended to modify them.

If after configuring this module you do not wish to activate any others, go directly to the next section.

### 6. *Export Generator Module* settings

The **role of the *Export Generator Module*** is to [export](https://cmake.org/cmake/help/latest/command/export.html) (if you are not familiar with this concept of modern CMake, two good tutorials are available [here](https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets), [here](https://cmake.org/cmake/help/latest/guide/importing-exporting/) and [here](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html)) the project from the [build tree](https://cmake.org/cmake/help/latest/manual/cmake.1.html#introduction-to-cmake-buildsystems) and the [install tree](https://cmake.org/cmake/help/latest/command/install.html), after generating it, to make it accessible to the [import](https://cmake.org/cmake/help/latest/guide/importing-exporting/#importing-targets) by other projects with the `find-package()` command. Thus, will be exported all source files compiled in `bin/`, the libraries in `lib/`, the header files from `include/`, the public header files of the project located in `src/` or in `include/<project-name>`, according to the option value `PUBLIC_HEADERS_SEPARATED` specified in the *Build Generator Module*, the documentation in `doc/`, the assets in `assets/`, the configuration files in `config/` and the resources in `resources/`.

To make the project importable by others, **the module will work in three steps**. During the first step, it will initialize all the properties of the project binaries that define its [usage requirements](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#target-usage-requirements) (include directories, compile definitions, etc) for import from the build or install tree. Then during the second step, it will use these properties to perform the actual export by generating a first [target file](https://cmake.org/cmake/help/latest/command/export.html) called `build/<project-name>Targets.cmake` which will contain all the code to be executed to import the project and its files located in the build tree (take a look at it, it's very instructive) generated by the *Build Generator Module*, as well as a second [target file](https://cmake.org/cmake/help/latest/command/install.html#installing-exports) that, this time, will allow an import of the binary from the install tree. Moreover, it will create install rules to build the install tree, which will be executed during the only build phase associated with the module:

- `install`, to install the project files into a specific location on the disk.

Finally in the third and last step, the module will create files that will allow the `find_package()` command of another project to locate on the disk the `<project-name>Targets.cmake` import files of the build tree and the install tree. Details are given below.

To use this module, **two options files** need to be configured. The **first file** is `cmake/project/StandardOptions.txt`, so open it and edit the options in the *Export Generator Module options* section:

- `ENABLE_EXPORT_MODULE=[ON (default)|OFF]`: specifies whether enable the export generator module;
- `EXPORT_NAMESPACE`: name to prepend to the build target name when it [will be imported](https://cmake.org/cmake/help/latest/command/install.html#export). Usually, the namespace of the C++ project;
- `INSTALL_DIRECTORY`: location on the disk where the compiled source will be installed. Let empty to use the [default value](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html);

The **second file to configure** is the configuration template file `cmake/project/ExportConfig.cmake.in` that the *Export Generator Module* will use to [generate two files](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html) intended to allow import with the [`find_package()` command](https://cmake.org/cmake/help/latest/command/find_package.html#full-signature-and-config-mode): `build/<project-name>Config.cmake` and `build/<project-name>ConfigVersion.cmake`. These two files provide to a downstream consumer project the information to locate on disk the import file `<project-name>Targets.cmake` which informs about the project and about include-directories, libraries and their dependencies, required compile-flags or locations of executables. The format of their name is imposed by the [`find_package(<project-name>)` command](https://cmake.org/cmake/help/latest/command/find_package.html#full-signature-and-config-mode), which will use the environment variable `<project-name>_DIR`, the project name as a parameter and possibly a [version number](https://cmake.org/cmake/help/latest/command/find_package.html#version-selection) to find them.

The configuration of this export mechanism has been greatly [simplified by CMake](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html), and now, thanks to the configuration template file and the [CMakePackageConfigHelpers](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html) module, which uses it to generate the two files mentioned above, there is almost nothing to edit in the `cmake/project/ExportConfig.cmake.in` file. The only thing you need to do there is to **import your project's external dependencies** into the dedicated section, those declared in `cmake/project/DependenciesOptions.cmake`. So open it and use the `find_dependency()` command as explained [here](https://cmake.org/cmake/help/latest/guide/importing-exporting/#creating-a-package-configuration-file). Here are two examples of library imports into the file.

<details>
<summary>Import Qt</summary>

```cmake
#------------------------------------------------------
# Declare here all requirements upstream dependencies.
#------------------------------------------------------
if(DEFINED ENV{Qt5_DIR}) 
  set(Qt5_DIR "$ENV{Qt5_DIR}")
else()
  set(Qt5_DIR "/opt/Qt/5.12.6/gcc_64/lib/cmake/Qt5")
endif()
find_dependency(Qt5 COMPONENTS Widgets Gui Core Svg Concurrent REQUIRED)
#------------------------------------------------------
# End of the declaration section.
#------------------------------------------------------
```

</details>

<details>
<summary>Link Qt</summary>

```cmake
#------------------------------------------------------
# Declare here all requirements upstream dependencies.
#------------------------------------------------------
if(DEFINED ENV{Eigen3_DIR}) 
  set(Eigen3_DIR "$ENV{Eigen3_DIR}")
else()
  set(Eigen3_DIR "D:/library/eigen-3.3.7/bin/share/eigen3/cmake")
endif()
find_dependency(Eigen3 REQUIRED NO_MODULE)
#------------------------------------------------------
# End of the declaration section.
#------------------------------------------------------
```

</details>

If after configuring this module you do not wish to activate any others, go directly to the next section.

### 7. *Package Generator Module* settings

TODO With `package source` and `package binary`: https://gitlab.kitware.com/cmake/community/-/wikis/doc/cpack/PackageGenerators

### 8. *Uninstall Generator Module* settings

The **role of the *Uninstall Generator Module*** is to generate a script and a command that will remove all installed files during the execution of the `install` build phase. The command is activated only during the associated build phase:

- `uninstall`, to uninstall the installed project files from a specific location on the disk.

This module is the most succinct of all and has only **one option in a single file**. Open the file `cmake/project/StandardOptions.txt` and edit the options in the section *Uninstall Generator Module options*:

- `ENABLE_UNINSTALL_MODULE=[ON (default)|OFF]`: specifies whether enable the uninstall generator module.

If after configuring this module you do not wish to activate any others, go directly to the next section.

## ⚙️ Usage and commands

This project provide several scripts and commands to generate the *Build Lifecycle* and execute each build phase. If you are using VS Code, they have all been written in `.vscode/tasks.json` and can be launched from the [command palette](https://code.visualstudio.com/docs/editor/tasks), otherwise you can use a command prompt. All the following instructions have to be executed from the root of the project. They are listed in the order of execution of a complete and classic sequence of build phases.

Use the following commands to **clean the *Build Lifecycle*** (these scripts clean the `build/`, `doc/` and `bin/` directories):

```bash
# clean the Build Lifecycle (on Linux/MacOS)
./clean-cmake.sh

# clean the Build Lifecycle (on Windows)
clean-cmake.bat
```

Use the following commands to **generate the *Build Lifecycle*** (these scripts call the `cmake` command):

```bash
# generate the Build Lifecycle (on Linux/MacOS)
./run-cmake.sh

# generate the Build Lifecycle (on Windows)
run-cmake.bat
```

Use the following commands to **clean and generate the *Build Lifecycle***:

```bash
# clean and generate the Build Lifecycle (on Linux/MacOS)
./clean-cmake.sh && sleep 3s && echo \"\" && ./run-cmake.sh

# clean and generate the Build Lifecycle (on Windows)
clean-cmake.bat && timeout /t 3 > NUL && echo. && run-cmake.bat
```

Use the following commands to **execute the `uninstall` phase** of the *Build Lifecycle* (only available if the *Uninstall Generator Module* has been activated):

```bash
# `execute the `uninstall` phase (on Linux/MacOS)
sudo cmake --build build/ --target uninstall

# execute the `uninstall` phase (on Windows)
cmake --build build/ --target uninstall
```

Use the following commands to **execute the `clean` phase** of the *Build Lifecycle* (clean the `build/`, `doc/` and `bin/` directories):

```bash
# execute the `clean` phase
cmake --build build/ --target clean
```

Use the following commands to **execute the `build` phase** of the *Build Lifecycle*:

```bash
# execute the `build` phase
cmake --build build/

# execute the `build` phase in verbose mode
cmake --build build/ --verbose

# execute the `build` phase after the `clean` phase
cmake --build build/ --clean-first

# execute the `build` phase after the `clean` phase in verbose
cmake --build build/ --clean-first --verbose
```

Use the following commands to **execute the `test` phase** of the *Build Lifecycle* (only available if the *Test Generator Module* has been activated):

```bash
# execute the `test` phase (on Linux/MacOS)
./bin/project-name_test

# execute the `test` phase (on Windows)
bin/project-name_test
```

Use the following commands to **execute the `doc` phase** of the *Build Lifecycle* (only available if the *Doc Generator Module* has been activated):

```bash
# execute the `doc` phase 
cmake --build build/ --target doc
```

Use the following commands to **execute the `install` phase** of the *Build Lifecycle* (only available if the *Export Generator Module* has been activated):

```bash
# execute the `install` phase (on Linux/MacOS)
sudo cmake --build build/ --target install

# execute the `install` phase (on Windows)
cmake --build build/ --target install
```

Use the following commands to **execute the `package binary` phase** of the *Build Lifecycle* (only available if the *Package Generator Module* has been activated):

```bash
# execute the `package binary` phase (on Linux/MacOS)
cpack --config CPackConfig.cmake && sleep 3s && rm -rfvI bin/_CPack_Packages

# execute the `package binary` phase (on Windows)
cpack --config CPackConfig.cmake && timeout /t 3 > NUL && del /a /f /s /q bin/_CPack_Packages
```

Use the following commands to **execute the `package source` phase** of the *Build Lifecycle* (only available if the *Package Generator Module* has been activated):

```bash
# execute the `package source` phase (on Linux/MacOS)
cpack --config CPackSourceConfig.cmake && sleep 3s && rm -rfvI bin/_CPack_Packages

# execute the `package source` phase (on Windows)
cpack --config CPackSourceConfig.cmake && timeout /t 3 > NUL && del /a /f /s /q bin/_CPack_Packages
```

Use the following commands to **execute the binary built** as executable:

```bash
# execute the binary built as executable (on Linux/MacOS)
./bin/project-name

# execute the binary built as executable (on Windows)
bin/project-name
```

## 📂 Folder structure overview

This project has been set up with a specific file/folder structure in mind. The following describes some important features of this setup:

| **Directory and File** | **What belongs here** |
|------------------------|-----------------------|
| `.vscode/tasks.json` | Specific VS Code tasks configured to compile, clean, build, etc. |
| `assets/` | Contains images, musics, maps and all resources needed for a game or a simulation project. |
| `bin/` | Any libs that get compiled by the project and the output executables go here, also if you pack your project, the generated files go here. |
| `build/` | Contains the CMake build tree. |
| `cmake/helpers/` | Contains some scripts and all generator modules used to generate the *Build Lifecycle*. |
| `cmake/modules/` | Contains custom CMake modules. |
| `cmake/project/` | Setting files for configuring the generator modules. |
| `cmake/toolchains/` | Contains toolchain files for compilers.
| `config/` | Contains configuration files used by the C++ project. |
| `doc/` | Contains code documentation generated by [Doxygen](http://www.doxygen.org). |
| `include/` | All necessary third-party header files (.h) and public header files (.h) of the project. |
| `lib/` | Any libaries needed in the project. |
| `resources/` | Contains images, musics, maps and all resources needed for the project (e.g for graphical user interfaces). |
| `src/` | Source files (.cpp) and private/public header files (.h) of the project. |
| `tests/` | Source files (.cpp) and header files (.h) for the unit testing framework [GTest](https://github.com/google/googletest). |
| `clean-cmake.bat` | Utility script for Windows to remove all generated files in `build/`, `bin/` and `doc/` directories. |
| `clean-cmake.sh` | Utility script for Linux/MacOS to remove all generated files in `build/`, `bin/` and `doc/` directories. |
| `CMakeLists.txt` | Main `CMakelists.txt` file of the project. |
| `LICENSE.md` | License file for project (needs to be edited). |
| `README.md` | Readme file for project (needs to be edited). |
| `run-cmake.bat` | Utility script for Windows to generate the *Build Lifecycle*. |
| `run-cmake.sh` | Utility script for Linux/MacOS to generate the *Build Lifecycle*. |

## 💻 Programming with CMake

For this project, several CMake modules had to be developed to complete the commands of the CMake library. They are in the directory `cmake/modules`, feel free to use them for your own CMake project or to customize this one. They have been written according to [CMake recommendations](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html), in an identical style and each command is documented in reStructuredText format. They are all independent and autonomous.

To use a module, follow these instructions:

- copy the module to a directory in your project (e.g. `myproject/cmake/`);
- in `CMakeLists.txt`, add this directory to search path for CMake modules with `set(CMAKE_MODULE_PATH "${CMAKE_MODULE_PATH}"	"myproject/cmake)"`;
- in `CMakeLists.txt`, after the previous instruction, include the module with the [`include()` command](https://cmake.org/cmake/help/latest/command/include.html) (e.g. `include(Debug)`).

## 🤝 Contributing

1. Fork the repo and create your feature branch from master.
2. Create a topic branch - `git checkout -b my_branch`.
3. Push to your branch - `git push origin my_branch`.
4. Create a Pull Request from your branch.

## 👥 Credits

This project is maintained and developed by [Joseph Garnier](https://www.joseph-garnier.com/).

## ©️ License

<a rel="license" href="http://creativecommons.org/licenses/by-nc-sa/4.0/"><img alt="Licence Creative Commons" style="border-width:0" src="https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png" /></a>

This work is licensed under the terms of a <a href="http://creativecommons.org/licenses/by-nc-sa/4.0/?ref=chooser-v1" target="_blank" rel="license noopener noreferrer" style="display:inline-block;">CC BY-NC-SA 4.0</a>.  See the [LICENSE.md](LICENSE.md) file for details.

## 🍻 Acknowledgments

This project was inspired by [cppbase](https://github.com/kartikkumar/cppbase) and by advices of [Hilton Lipschitz](https://hiltmon.com/blog/2013/07/03/a-simple-c-plus-plus-project-structure/).
