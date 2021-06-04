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
  - [The build phases](#the-build-phases)
  - [The generator modules](#the-generator-modules)
- [📄 Setting up the generator modules](#-setting-up-the-generator-modules)
  - [1. Global settings](#1-global-settings)
  - [2. *Base Generator Module* settings](#2-base-generator-module-settings)
  - [3. *Test Generator Module* settings](#3-test-generator-module-settings)
  - [4. *Code Analysis Generator Module* settings](#4-code-analysis-generator-module-settings)
  - [5. *Doc Generator Module* settings](#5-doc-generator-module-settings)
  - [6. *Export Generator Module* settings](#6-export-generator-module-settings)
  - [7. *Package Generator Module* settings](#7-package-generator-module-settings)
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
- Generation of export macros for libraries.
- A list of commands for Visual Studio Code to trigger individually each phase of the *Build Lifecycle* (see `tasks.json`).

## ⚓ Requirements

This project is only a template and you are free to use the compiler and versions of your choice. However, you will need at least the following (install guides are provided on the respective websites):

- **C++ compiler** - e.g [GCC](https://gcc.gnu.org/), [Clang C++](https://clang.llvm.org/cxx_status.html) or [Visual Studio](https://visualstudio.microsoft.com).
- **CMake v3.20+** - can be found [here](https://cmake.org/).

The following dependencies are **optional** because they will be **automatically downloaded** by CMake if they can't be found:

- [Doxygen](http://www.doxygen.nl/) (used when `ENABLE_TEST_MODULE` option is set to `on`);
- [GTest](https://github.com/google/googletest) (used when `ENABLE_DOC_MODULE` option is set to `on`).

## 🚀 Getting started

1. **Get the template** from this repository either by [downloading it](https://github.com/josephgarnier/cpp-starter-project-cmake/archive/refs/heads/master.zip), or by using it [as a template](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/creating-a-repository-from-a-template) and then cloning it, or by [cloning](https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository) it directly with the command :

    ```bash
    git clone https://github.com/josephgarnier/cpp-starter-project-cmake.git --recursive
    cd cpp-starter-project-cmake
    ```

2. **Clean the project.** This starter ships is delivered with demo files to allow you to test different settings. If you want to keep them for now, go to the next section and come back here later. Else, if you want to delete them now to put your own files or when the time comes, empty the content of directories `src/`, `include/` and `tests/` manually or use the following commands from the root:

    ```bash
    cd cpp-starter-project-cmake
    rm -rfvI src/* # "r" to recursively remove, "f" to force, "v" explain what is being done, "I" prompt once before removing
    rm -rfvI include/*
    rm -rfvI tests/*
    ```

3. **Edit the basic settings.** Open the file `cmake/project/StandardOptions.txt` and edit the name of your project in the variable `PROJECT_NAME` and the type of the main binary build target in `MAIN_BINARY_TARGET_TYPE` ("static", "shared", "header", for header-only library, or "exec). Then set `PUBLIC_HEADERS_SEPARATED` to off and `USE_PRECOMPILED_HEADER` to off.

4. **Add the dependencies**. If the project requires dependencies, add the instructions to link external libaries at the end of the `cmake/project/DependenciesExternalOptions.cmake` file.

5. **Let's go to dev your amazing project.** The project structure is now ready to receive your C++ files. Put the header and source files in the `src/` directory, and name the file containing the main function `main.cpp`. Then, generate the build environment with the command `./clean-cmake.sh && sleep 3s && echo \"\" && ./run-cmake.sh` and finally compile with the command `cmake --build build/ --clean-first`. The generated binary will be in the `bin/` directory. The default configuration uses the compilers Visual Studio for Windows and GCC for Linux/MacOS.

For more advanced use and with more functionality, please refer to the following sections.

## 💫 *Build Lifecycle* overview

In the last few years, CMake has become complete and easy to use enough to handle the whole process of compilation, testing analyzing and distributing of a C ++ project. This is why the ambition of this template is to rely as much as possible on the power of CMake to propose a development base that is quick to use and covers all the steps of this process. Moreover, the objective is also to propose a structure that is generic enough to adapt to the greatest number of situations by offering a high level of customization.

### The build phases

Although designed and traditionally used to be a [generator of project build environment](https://cmake.org/overview/) and more specifically of [build target](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html) for building libraries or executables from build target, we can now consider that [CMake](https://cmake.org/cmake/help/latest/manual/cmake.1.html) has become a **generator of complete *Build Lifecycle***.

In this template project, we define a ***Build Lifecycle*** as a sequence of build phases that can be invoked to cover all the expected steps of a C++ project building and distribution process (just like [Maven](https://maven.apache.org/guides/introduction/introduction-to-the-lifecycle.html) for Java). A **build phase** is a virtual set of [cmake targets](https://cmake.org/cmake/help/latest/command/add_custom_target.html) or [cmake commands](https://cmake.org/cmake/help/latest/command/add_custom_command.html) that can be executed to build a binary, build tests, generate the doc, build package, install or uninstall a project, etc.

This **concept of build phase does not exist in CMake**, it is a convenient way introduced in this project to virtually group several targets or commands contributing to a major step in the *Build Lifecycle*. This means that you can completely customize your lifecycle. Thus, the objective of this project is only to generate with CMake all targets and commands you might need to run each of the proposed build phases or to compose yours.

In the image below, you can see an **overview of the *Build Lifecycle* proposed by default** with its sequence of the build phases, their composition and their interactions:

[TODO IMAGE OVERVIEW]

Here is a description of what each build phase achieves (their associated targets and commands are described in the next section):

- `uninstall`: uninstall the installed project files from a specific location on the disk.
- `clean`: remove all files generated by other phases and the generator.
- `compile`: compile the source code of the C++ project into an executable or a library. Can optionally export it from the build-tree.
- `test`: compile the unit tests of the project into an executable for testing and execute the test executable built.
- `code analysis`: !! not implented yet !!  run any checks on results of integration tests to ensure quality criteria are met. Also run many tools for code sanitizers.
- `doc`: generate the project's documentation.
- `install`: install the project files into a specific location on the disk.
- `package`: take the project files and packs them into two packages in a distributable format, such as a ZIP or an installer.

### The generator modules

It is possible to completely customize this sequence of build phases, their composition and their behavior by setting up the so-called *Generator Module*. A ***Generator Module*** is a logical unit containing CMake instructions to generate or modify one or more [cmake targets](https://cmake.org/cmake/help/latest/command/add_custom_target.html) or [cmake commands](https://cmake.org/cmake/help/latest/command/add_custom_command.html) that contribute to the same step in the *Build Lifecycle*.

Each *Generator Module* has its own configuration parameters and can be disabled to prevent the generation of its targets and commands that you may consider not useful. However, it is not possible to deactivate a particular target, just like the *Base Generator Module* responsible for compiling the project and cleaning it. This one generate the minimum code for a *Build Lifecycle*. Furthermore, a *Generator Module* is not an autonomous unit and it may share a dependency relationship with others, which conditions its activation.

Here is **the dependency graph of the modules**, their configuration files and the cmake targets or command they generate:

[TODO IMAGE WORKFLOW]

The dashed lines indicate a dependency. Thus, for example, the *Package Generator Module* depends on the *Export Generator Module*.

## 📄 Setting up the generator modules

All **the configuration files you will need** to set up the generator modules are in the `cmake/project/` directory. Please remember that **only the *Base Generator Module* is mandatory to configure**, the others are optional and depend on your needs. All generator modules are in the directory `cmake/helpers/` but your don't need to edit them. Finally, if for some reason you want to know what targets has been generated by a module, you can use this command `cmake --build build/ --target help` from the project root.

All standard options are passed to CMake thank to the [`initial-cache` feature](https://cmake.org/cmake/help/latest/manual/cmake.1.html#options) which pre-loads the script `cmake/project/StandardOptions.txt` to populate the cache. Then, it is called with the command `cmake -C <initial-cache>` (we will see later how use it easily). With this feature, it is no longer necessary to directly modify the `CMakeLists.txt` file and its is a more convenient way than using the [options](https://cmake.org/cmake/help/latest/command/option.html). Once the CMake generation command has been called, it will be possible to view cached variables and their descriptions with the command `cmake -LAH build/`.

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

### 2. *Base Generator Module* settings

#### Description <!-- omit in toc -->

The **role of the *Base Generator Module*** is to use the generator given from options and the source-tree files to initialize the generation of the [build-tree](https://cmake.org/cmake/help/latest/manual/cmake.1.html#introduction-to-cmake-buildsystems) which will contain all files of the *Build Lifecycle* of the C++ project. This basic structure will be used for all other modules. This is why this module cannot be disabled. Once the initialization is completed, the other role of this module is to generate at least one [binary build target](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#binary-targets), for building the project binary, and five additional targets:

- `all`: the default build target that build all binary build targets and compile all source code in the source-tree into one or more binaries (executable or library);
- `<project-name>`: the main binary build target that build an [executable](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#binary-executables) or a [library](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#binary-library-types) from source code of the project in the source-tree;
- `clean`: remove all files generated by other targets and the generator;
- `edit_cache`: edit the project configuration with [ccmake](https://cmake.org/cmake/help/latest/manual/ccmake.1.html) instead of [cmake-gui](https://cmake.org/cmake/help/latest/manual/cmake-gui.1.html);
- `rebuild_cache`: run cmake command on the source-tree and picks up additional cache entries if they exist;
- `depend`: run cmake to generate dependencies for the source files.

By default there is only one binary build target, so the build targets `all` and `<project-name>` do the same thing.

#### Configuration <!-- omit in toc -->

To use this module, **four options files** need to be configured. The **first file** is `cmake/project/StandardOptions.txt`, so open it and edit the options in the *Base Generator Module options* section:

- `BUILD_STANDARD_VERSION=[11|14|17 (default)|20|23]`: specifies the standard version for building binaries, "11" or "14" or "17" or "20" or 23, see [CMAKE_CXX_STANDARD](https://cmake.org/cmake/help/latest/variable/CMAKE_CXX_STANDARD.html);
- `BUILD_TYPE=[(default) debug|release]`: specifies the type of configuration for the build-tree, "debug" or "release", see [CMAKE_BUILD_TYPE](https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html);
- `MAIN_BINARY_TARGET_TYPE=[static|shared|header|exec (default)]`: specifies the type of the main binary build target, "static" or "shared" or "header" (for header-only library) or as an "exec", see [TYPE](https://cmake.org/cmake/help/latest/prop_tgt/TYPE.html);
- `COMPILE_DEFINITIONS`: specifies a semicolon-separated list of preprocessor definitions (e.g -DFOO;-DBAR or FOO;BAR). Can be empty;
- `PUBLIC_HEADERS_SEPARATED=[ON|OFF (default)]`: specifies whether public header files are separated from private header files (see below for more details);
- `USE_PRECOMPILED_HEADER=[ON|OFF (default)]`: specifies whether a precompiled header file will be used or not;
- `TOOLCHAIN_FILE`: specifies a path to a [toolchain file](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html), (see below for more details).

The `PUBLIC_HEADERS_SEPARATED` option is there to provide **support for the two common policies in C++ projects** shown below:

[IMAGE]

The first is to put all header files in `src/` and none in `include/`. In this case, `PUBLIC_HEADERS_SEPARATED` must be set to `off` and the header files will all be public. The second policy, when `PUBLIC_HEADERS_SEPARATED` is set to `on`, is to put only the private header files in `src/` and the public header files in a sub-folder of `include/` named like your project. Therefore, if you choose the second policy you must create a `include/<project-name>` directory.

Except for personal convenience, the consequence of choosing a policy will only be visible if you enable the *Export Generator Module*. Indeed, only public header files will be exported outside the project to be made accessible for import by other projects (see the dedicated section for more details).

Finally, when you set `PUBLIC_HEADERS_SEPARATED` to `on`, the header files can still included in the source files (.cpp) in two different ways to allow a greater flexibility: either by prefixing the paths with the project name, e.g. `#include "project-name/include1.h"`, or without prefixing, e.g. `#include "include1.h"`. This is possible because the three directories, `src/`, `include/` and `include/<project-name>`, are added to the main binary build target with the command `target_include_directories()`.

The `TOOLCHAIN_FILE` option allows you to provide to the generator a path to a file that configures a [toolchain](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html). For CMake, a toolchain is a set of all the necessary tools required to drive the binaries building: the working environment, the CMake executable, the make tool and compilers, and the debugger. This feature offered by CMake is very useful for cross compiling. By default, the project comes with four toolchain files, located in the `cmake/toolchains` folder. If needed, you can add your own by following the [documentation provided by CMake](https://cmake.org/cmake/help/latest/manual/cmake-toolchains.7.html).

In addition, each toolchain includes options for the compilers set by default in the project (most of them are based on those proposed by [Jason Turner](https://github.com/lefticus/cppbestpractices/blob/master/02-Use_the_Tools_Available.md) in his best practices). Feel free to modify them by referring to their respective compiler documentations:

- `cmake/toolchains/ClangOptions.cmake` for the [Clang options](https://clang.llvm.org/docs/ClangCommandLineReference.html);
- `cmake/toolchains/GccOptions.cmake` for the [GCC options](https://gcc.gnu.org/onlinedocs/gcc/Option-Summary.html);
- `cmake/toolchains/VsOptions.cmake` for the [Visual Studio options](https://docs.microsoft.com/en-us/cpp/build/reference/compiler-options-listed-by-category);

The **second file to configure** is the one that provides to the *Base Generator Module* the list of source and header files. Open the file `cmake/project/HeadersAndSourcesOptions.cmake` and edit each of the following variables as necessary:

- `${PROJECT_NAME}_SOURCE_SRC_FILES`: contains the list of source files (.cpp) present in `src/`;
- `${PROJECT_NAME}_HEADER_SRC_FILES`: contains the list of header files (.h) in `src/`;
- `${PROJECT_NAME}_HEADER_INCLUDE_FILES`: contains the list of header files present in the `include/<project-name>` folder (can be empty depending on the chosen policy).
- `${PROJECT_NAME}_PRECOMPILED_HEADER_FILE`: path to the **[precompiled header](https://en.wikipedia.org/wiki/Precompiled_header) file**. Initiated by default with a path pointing to `include/` and more precisely to `${${PROJECT_NAME}_INCLUDE_DIR}/${PROJECT_NAME}/${PROJECT_NAME}_pch.h`, set the value to your own filename if you don't want to use this format. The file will be ignored if you previously set the associated option to off.
- `${PROJECT_NAME}_MAIN_SOURCE_FILE`: path to the file containing the main function.

In order to minimize configuration time and to make CMake accessible, **the first three variables are automatically initialized** using a [glob function](https://cmake.org/cmake/help/latest/command/file.html#glob). So by default you don't have to configure them. However, using a glob function is [not a recommended practice](https://cmake.org/cmake/help/latest/command/file.html#glob) by CMake, so you are free to replace it with a manual initialization.

The **third file to configure** concerns the **internal dependencies** to be imported and linked to the main binary build target. This step **is optional**, so if you don't want to use this feature, just go to the next paragraph. Indeed, the good practice is to [import a library](https://cmake.org/cmake/help/git-stage/guide/importing-exporting/index.html#importing-targets) from an export script generated by the vendor as described in the next paragraph. But in some cases this file does not exist. That's why this template proposes an import mechanism based on the CMake one (the code is available in `cmake/modules/Dependency.cmake`). To take advantage of it, put your library files in `lib/` and their header files in a subdirectory in `include/<my-library-name>`. To cover all cases, there are normally eight files per library: static/shared x unix/windows x debug/release. But, you don't have to cover them all. To configure this feature, open the file `cmake/project/DependenciesInternalOptions.cmake` and use the command `dependency()`, who works as the [`find_library()`](https://cmake.org/cmake/help/latest/command/find_library.html) CMake command, for each internal library to import as follow:

```cmake
#------------------------------------------------------
# Import internal libraries from here.
#------------------------------------------------------

#---- Import mylibname. ----
dependency(IMPORT "<my-library-name>"
  SHARED
  RELEASE_NAME "<release-raw-filename>" # Must be a filename wihtout its prefix, version numbers and suffix. Can be deleted.
  DEBUG_NAME "<debug-raw-filename>" # Must be a filename wihtout its prefix, version numbers and suffix. Can be deleted.
  ROOT_DIR "${${PROJECT_NAME}_LIB_DIR}"
  INCLUDE_DIR "${${PROJECT_NAME}_INCLUDE_DIR}/<my-library-name>"
)
list(APPEND ${PROJECT_NAME}_IMPORTED_INTERNAL_LIBRARIES "<my-library-name>")
```

The `<raw-filename>` must be a library filename without any version numbers, any special character, any prefixes (e.g. lib) and any suffixes (e.g. .so) that are platform dependent. The command use a fuzzy regular expression in this format to find a library: `<`[CMAKE_STATIC_LIBRARY_PREFIX](https://cmake.org/cmake/help/latest/variable/CMAKE_STATIC_LIBRARY_PREFIX.html)`|`[CMAKE_SHARED_LIBRARY_PREFIX](https://cmake.org/cmake/help/latest/variable/CMAKE_SHARED_LIBRARY_PREFIX.html)`><raw_filename><version-numbers><`[CMAKE_STATIC_LIBRARY_SUFFIX](https://cmake.org/cmake/help/latest/variable/CMAKE_STATIC_LIBRARY_SUFFIX.html)`|`[CMAKE_SHARED_LIBRARY_SUFFIX](https://cmake.org/cmake/help/latest/variable/CMAKE_SHARED_LIBRARY_SUFFIX.html)`>`. **Prefix and version numbers are optional** in the library filename, but if they are actually present, the format must be: `<prefix><library-name><.|_|-|><version-numbers><suffix>`. Furthermore, the options `RELEASE_NAME` and `DEBUG_NAME` are optional but at least one of them must be specified. Finally,you have to choose what type of library build you want to use with the option `SHARED` or `STATIC`.

**Setting these variables is optional**. Indeed, by default, and to simplify the use of CMake, all the internal libraries that are in `lib/` will be automatically linked to the main binary build target, with their header files that are in the subdirectories of `include/` (for linux workers, don't forget to create a link to each library in `lib/` for the [soname policy](https://en.wikipedia.org/wiki/Soname)). If you don't want to use this feature, just initialize both variables to empty or let the lib directory empty.

The **fourth and last file to configure** concerns the **external dependencies** to be imported and linked to the main binary build target. Open the file `cmake/project/DependenciesExternalOptions.cmake` and put the **instructions necessary to import and link the external libaries** to the main binary build target after the message *Import and link external libraries from here*. Here are three examples of library import.

<details>
<summary>Link Qt (with auto-moc method)</summary>

```cmake
#------------------------------------------------------
# Import and link external libraries from here.
#------------------------------------------------------

#---- Import and link Qt. ----
message(STATUS "Import and link Qt")
if(DEFINED ENV{Qt5_DIR}) 
  set(Qt5_DIR "$ENV{Qt5_DIR}")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
  set(Qt5_DIR "C:/Qt/5.15.2/mingw81_64/lib/cmake")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
  set(Qt5_DIR "/opt/Qt/5.15.2/gcc_64/lib/cmake")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
  set(Qt5_DIR "/opt/Qt/5.15.2/gcc_64/lib/cmake")
endif()
if(DEFINED ENV{CMAKE_PREFIX_PATH}) 
  set(CMAKE_PREFIX_PATH "$ENV{CMAKE_PREFIX_PATH}")
else()
  set(CMAKE_PREFIX_PATH "${Qt5_DIR}")
endif()

# See https://cmake.org/cmake/help/latest/manual/cmake-properties.7.html for their documentations.
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES
  AUTOGEN_ORIGIN_DEPENDS on
  AUTOMOC on
  AUTOMOC_COMPILER_PREDEFINES on
  AUTOMOC_MACRO_NAMES "${CMAKE_AUTOMOC_MACRO_NAMES}"
  AUTOMOC_PATH_PREFIX on
  AUTORCC on
  AUTOUIC on
  AUTOUIC_SEARCH_PATHS "${${PROJECT_NAME}_SRC_DIR}/gui"
)

find_package(Qt5 COMPONENTS Widgets Gui Core Svg Concurrent REQUIRED)

if (${Qt5Widgets_VERSION} VERSION_LESS 5.15.2
  OR ${Qt5Gui_VERSION} VERSION_LESS 5.15.2
  OR ${Qt5Core_VERSION} VERSION_LESS 5.15.2
  OR ${Qt5Svg_VERSION} VERSION_LESS 5.15.2
  OR ${Qt5Concurrent_VERSION} VERSION_LESS 5.15.2)
    message(FATAL_ERROR "Minimum supported Qt5 version is 5.15.2!")
endif()

# Add Qt definitions to the main binary build target.
message(STATUS "Add Qt definitions to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
    "$<INSTALL_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
)
# Add Qt assert definitions to the main binary build target only for debug.
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:$<$<NOT:$<STREQUAL:${CMAKE_BUILD_TYPE},DEBUG>>:QT_NO_DEBUG>>"
    "$<INSTALL_INTERFACE:$<$<NOT:$<STREQUAL:${CMAKE_BUILD_TYPE},DEBUG>>:QT_NO_DEBUG>>"
)

# Link Qt to the main binary build target.
message(STATUS "Link Qt to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
    "$<INSTALL_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
)

# Set Qt as a position-independent target.
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
target_compile_options("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>>"
    "$<INSTALL_INTERFACE:$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>>"
  PRIVATE
    "$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>"
)

message(STATUS "Import and link Qt - done")
```

</details>

<details>
<summary>Link Qt (with macro method)</summary>

```cmake
#------------------------------------------------------
# Import and link external libraries from here.
#------------------------------------------------------

#---- Import and link Qt. ----
message(STATUS "Import and link Qt")
if(DEFINED ENV{Qt5_DIR}) 
  set(Qt5_DIR "$ENV{Qt5_DIR}")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows")
  set(Qt5_DIR "C:/Qt/5.15.2/mingw81_64/lib/cmake")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux")
  set(Qt5_DIR "/opt/Qt/5.15.2/gcc_64/lib/cmake")
elseif("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin")
  set(Qt5_DIR "/opt/Qt/5.15.2/gcc_64/lib/cmake")
endif()
if(DEFINED ENV{CMAKE_PREFIX_PATH}) 
  set(CMAKE_PREFIX_PATH "$ENV{CMAKE_PREFIX_PATH}")
else()
  set(CMAKE_PREFIX_PATH "${Qt5_DIR}")
endif()

find_package(Qt5 COMPONENTS Widgets Gui Core Svg Concurrent REQUIRED)

if (${Qt5Widgets_VERSION} VERSION_LESS 5.15.2
  OR ${Qt5Gui_VERSION} VERSION_LESS 5.15.2
  OR ${Qt5Core_VERSION} VERSION_LESS 5.15.2
  OR ${Qt5Svg_VERSION} VERSION_LESS 5.15.2
  OR ${Qt5Concurrent_VERSION} VERSION_LESS 5.15.2)
    message(FATAL_ERROR "Minimum supported Qt5 version is 5.15.2!")
endif()

set(QOBJECT_SOURCE_FILES
  "${${PROJECT_NAME}_SRC_DIR}/myQObject.cpp"
)
set(QOBJECT_HEADER_FILES
  "${${PROJECT_NAME}_SRC_DIR}/myQObject.h"
)
set(UI_FILES
  "${${PROJECT_NAME}_SRC_DIR}/myGUI.ui"
)
set(RESSOURCE_FILES
  "${${PROJECT_NAME}_RESOURCES_DIR}/myResources.qrc"
)

qt5_wrap_cpp(MOC_HEADER_FILES ${QOBJECT_HEADER_FILES} TARGET "${${PROJECT_NAME}_MAIN_BIN_TARGET}")
qt5_wrap_ui(UI_SOURCE_FILES ${UI_FILES})
qt5_add_resources(RESSOURCE_SOURCE_FILES ${RESSOURCE_FILES})

message(STATUS "Found the following QObject source files:")
print(STATUS PATHS "${QOBJECT_SOURCE_FILES}" INDENT)

message(STATUS "Found the following QObject header files:")
print(STATUS PATHS "${QOBJECT_HEADER_FILES}" INDENT)

message(STATUS "Found the following moc header files:")
print(STATUS PATHS "${MOC_HEADER_FILES}" INDENT)

message(STATUS "Found the following UI files:")
print(STATUS PATHS "${UI_FILES}" INDENT)

message(STATUS "Found the following UI source files:")
print(STATUS PATHS "${UI_SOURCE_FILES}" INDENT)

message(STATUS "Found the following resources files:")
print(STATUS PATHS "${RESSOURCE_FILES}" INDENT)

message(STATUS "Found the following resources source files:")
print(STATUS PATHS "${RESSOURCE_SOURCE_FILES}" INDENT)

# Add Qt source and header files to the main binary build target.
message(STATUS "Add the found Qt source and header files to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_sources("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PRIVATE
    "${QOBJECT_SOURCE_FILES}"
    "${MOC_HEADER_FILES}"
    "${UI_SOURCE_FILES}"
    "${RESSOURCE_SOURCE_FILES}"
)
source_group(TREE "${${PROJECT_NAME}_PROJECT_DIR}"
  FILES
    "${QOBJECT_SOURCE_FILES}"
    "${MOC_HEADER_FILES}"
    "${UI_SOURCE_FILES}"
    "${RESSOURCE_SOURCE_FILES}"
)

# Add Qt definitions to the main binary build target.
message(STATUS "Add Qt definitions to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
    "$<INSTALL_INTERFACE:QT_USE_QSTRINGBUILDER;QT_SHAREDPOINTER_TRACK_POINTERS;QT_MESSAGELOGCONTEXT>"
)
# Add Qt assert definitions to the main binary build target only for debug.
target_compile_definitions("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:$<$<NOT:$<STREQUAL:${CMAKE_BUILD_TYPE},DEBUG>>:QT_NO_DEBUG>>"
    "$<INSTALL_INTERFACE:$<$<NOT:$<STREQUAL:${CMAKE_BUILD_TYPE},DEBUG>>:QT_NO_DEBUG>>"
)

# Link Qt to the main binary build target.
message(STATUS "Link Qt to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
    "$<INSTALL_INTERFACE:Qt5::Widgets;Qt5::Gui;Qt5::Core;Qt5::Svg;Qt5::Concurrent>"
)

# Set Qt as a position-independent target.
set_target_properties("${${PROJECT_NAME}_MAIN_BIN_TARGET}" PROPERTIES INTERFACE_POSITION_INDEPENDENT_CODE ON)
target_compile_options("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>>"
    "$<INSTALL_INTERFACE:$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>>"
  PRIVATE
    "$<IF:$<STREQUAL:$<TARGET_PROPERTY:TYPE>,EXECUTABLE>,-fPIE,-fPIC>"
)
message(STATUS "Import and link Qt - done")
```

</details>

<details>
<summary>Link Eigen3</summary>

```cmake
#------------------------------------------------------
# Import and link external libraries from here.
#------------------------------------------------------

#---- Import and link Eigen3. ----
message(STATUS "Import and link Eigen3")
if(DEFINED ENV{Eigen3_DIR}) 
  set(Eigen3_DIR "$ENV{Eigen3_DIR}")
else()
  set(Eigen3_DIR "D:/library/eigen-3.3.7/bin/share/eigen3/cmake")
endif()

# Find Eigen3 or auto-download it.
message(STATUS "Find Eigen3 package")
include(FetchContent)
find_package(Eigen3 NO_MODULE)
if(NOT ${Eigen3_FOUND})
  message(STATUS "Eigen3 not found, it will be auto-downloaded in the build-tree")
  set(FETCHCONTENT_QUIET off)
  FetchContent_Declare(eigen3
    GIT_REPOSITORY https://gitlab.com/libeigen/eigen.git
    GIT_TAG master
    GIT_PROGRESS on
    STAMP_DIR "${${PROJECT_NAME}_BUILD_DIR}"
    DOWNLOAD_NO_PROGRESS off
    LOG_DOWNLOAD on
    LOG_UPDATE on
    LOG_PATCH on
    LOG_CONFIGURE on
    LOG_BUILD on
    LOG_INSTALL on
    LOG_TEST on
    LOG_MERGED_STDOUTERR on
    LOG_OUTPUT_ON_FAILURE on
    USES_TERMINAL_DOWNLOAD on
  )
  FetchContent_MakeAvailable(eigen3)
else()
  message(STATUS "Eigen3 found")
endif()

# Link Eigen3 to the main binary build target.
message(STATUS "Link Eigen3 library to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PRIVATE
    "Eigen3::Eigen"
)
message(STATUS "Import and link Eigen3 - done")
```

</details>

If after configuring this module you do not wish to activate any others, go directly to the next section.

### 3. *Test Generator Module* settings

#### Description <!-- omit in toc -->

The **role of the *Test Generator Module*** is to generate the test binary build target, which will allow to compile and execute the unit tests with [GoogleTest](https://github.com/google/googletest):

- `<project-name>_test`: the test binary build target that build an executable from the test code in using a suitable unit testing framework. This target is not added to the `all` target.
- `gtest`: the binary build target of Google Test that build the gtest library from source code in the build-tree;
- `gtest_main`: the binary build target of Google Test that build the gtest_main library from source code in the build-tree;
- `gmock`: the binary build target of Google Test that build the gmock library from source code in the build-tree;
- `gmock_main`: the binary build target of Google Test that build the gmock_main library from source code in the build-tree;
- `clean`: remove all files generated by the previous targets and the generator.

The **module depends on GoogleTest**, so either you install it following the [site instructions](https://github.com/google/googletest/blob/master/googletest/README.md), or you let the module use the auto-download feature which will detect the absence of the dependency and download it in the build-tree directly from its GitHub repository during generation. Since the test library is small, **auto-download is the preferred option**.

#### Configuration <!-- omit in toc -->

To use this module, only **one option in a single file** has to be set. Open the file `cmake/project/StandardOptions.txt` and edit the option in the section *Test Generator Module options*:

- `ENABLE_TEST_MODULE=[ON|OFF (default)]`: specifies whether enable the Test Generator Module.

Then, write all your tests (source and header files) in `tests/`. The module will automatically detect these files and add them to the test binary build target. There are several strategies for linking test files to the files to be tested, each with their advantages and disadvantages. Here, the one that has been chosen is to add all the source and header files of the main binary build target to the test binary build target. The disadvantage is that the project has to be built twice, but on one hand this reduces the dependencies between the main binary build target and the test binary build target, and on the other hand, the test configuration is much less complex to write.

If after configuring this module you do not wish to activate any others, go directly to the next section.

### 4. *Code Analysis Generator Module* settings

!! NOT IMPLEMENTED YET !!

### 5. *Doc Generator Module* settings

#### Description <!-- omit in toc -->

The **role of the *Doc Generator Module*** is to generate the target which will allow to generate the documentation [Doxygen](http://www.doxygen.nl/) of the project:

- `doc`: the target to generate the project's documentation;
- `clean`: remove all files generated by the previous target and the generator.

The **module depends on Doxygen**, so either you install it following the [site instructions](https://www.doxygen.nl/manual/install.html), or you let the module use the [auto-download feature](https://cmake.org/cmake/help/latest/module/FetchContent.html) which will detect the absence of the dependency and download it in the build-tree directly from its GitHub repository during generation. However, due to the size of the library, it is **strongly discouraged to use auto-download** and recommended to install it, because CMake re-downloads and then rebuilds the whole library each time the project is cleaned up, which takes several minutes.

#### Configuration <!-- omit in toc -->

To use this module, **two option files** need to be configured. The **first file** is `cmake/project/StandardOptions.txt`, so open it and edit the options in the *Doc Generator Module options* section:

- `ENABLE_DOC_MODULE=[ON|OFF (default)]`: specifies whether enable the doc generator module.

The **second file to configure** is the options file `cmake/project/DocOptions.cmake` which the module will use, with the CMake FindDoxygen module, to generate the configuration file used by Doxygen. If you don't want to use the default values, open it and edit it, with the help of the CMake initialization functions, in using the [FindDoxygen](https://cmake.org/cmake/help/latest/module/FindDoxygen.html) module and [Doxygen](https://www.doxygen.nl/manual/config.html) documentation. Please note, the variables `DOXYGEN_OUTPUT_DIRECTORY` and `DOXYGEN_INPUT` should not be changed as indicated in the FindDoxygen module documentation.

If after configuring this module you do not wish to activate any others, go directly to the next section.

### 6. *Export Generator Module* settings

#### Description <!-- omit in toc -->

The **first role of the *Export Generator Module*** is to [export](https://cmake.org/cmake/help/latest/command/export.html) the project from the [build-tree](https://cmake.org/cmake/help/latest/manual/cmake.1.html#introduction-to-cmake-buildsystems) and the [install-tree](https://cmake.org/cmake/help/latest/command/install.html), after generating it, to make it accessible to the [import](https://cmake.org/cmake/help/latest/guide/importing-exporting/#importing-targets) by other projects with the `find-package()` command (if you are not familiar with these concepts of modern CMake, three good tutorials are available [here](https://gitlab.kitware.com/cmake/community/-/wikis/doc/tutorials/Exporting-and-Importing-Targets), [here](https://cmake.org/cmake/help/latest/guide/importing-exporting/) and [here](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html)). In addition, the module exports the source-tree of the project so that it can be added as a subdirectory of another project with the `add_subdirectory()` command. Thus, will be exported all source files compiled in `bin/`, the libraries in `lib/`, the header files from `include/`, the public header files of the project located in `src/` or in `include/<project-name>`, according to the option value `PUBLIC_HEADERS_SEPARATED` specified in the *Base Generator Module*, the documentation in `doc/`, the assets in `assets/`, the configuration files in `config/` and the resources in `resources/`.

To make the project importable by others, **the module will work in six steps**. 1) It will use the [GenerateExportHeader CMake module](https://cmake.org/cmake/help/latest/module/GenerateExportHeader.html) to **generate a header file with all macros** you might need to declare the C++ symbol to export. This header file will be generate in the directory containing the public header files: either `src/<project-name>_export.h` or `include/<project-name>/<project-name>_export.h`. 2) The module will initialize the properties of the main binary build target with its [usage requirements](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#transitive-usage-requirements) (include directories, compile definitions, etc) for importing from the build or install-tree. 3) These properties will be used to perform the actual export by generating a first [target file](https://cmake.org/cmake/help/latest/command/export.html) called `build/<formated-project-name>Targets.cmake` which will contain all the code to be executed to import the project and its files located in the build-tree (take a look at it, it's very instructive) generated by the *Base Generator Module*. An export name prefixed with a namespace is also generated. 4) The same kind of work will do with a second [target file](https://cmake.org/cmake/help/latest/command/install.html#installing-exports) that, this time, will allow an import of the binary from the install-tree. 5) The module will create the files that will allow to the [`find_package()` command](https://cmake.org/cmake/help/latest/command/find_package.html) of another project to locate on the disk the `<formated-project-name>Targets.cmake` import files of the build-tree and the install-tree. Details are given in configuration section below. 6) The main binary build target is aliased for exporting the project from the source-tree and allow an import with `add_subdirectory()` command.

During this process, the module will also create all install rules needed to build the install-tree and copy it to a specific location with its associated target:

- `install`: target to install the project files into a specific location on the disk.

The **second role of the *Export Generator Module*** is to generate a script and a command that will remove all installed files during the execution of the `install` target. The command is activated with the following target:

- `uninstall`: target to uninstall the installed project files from a specific location on the disk.

#### Configuration <!-- omit in toc -->

To use this module, **two options files** need to be configured. The **first file** is `cmake/project/StandardOptions.txt`, so open it and edit the options in the *Export Generator Module options* section:

- `ENABLE_EXPORT_MODULE=[ON (default)|OFF]`: specifies whether enable the export generator module;
- `EXPORT_NAMESPACE`: namespace, or alias, to prepend to name of the main binary build target when it [will be imported](https://cmake.org/cmake/help/latest/command/install.html#export). Should be the namespace of the C++ project;
- `INSTALL_DIRECTORY`: location on the disk where the compiled source will be installed. Let empty to use the [default value](https://cmake.org/cmake/help/latest/variable/CMAKE_INSTALL_PREFIX.html);

The **second file to configure** is the configuration of the template file `cmake/project/ExportConfig.cmake.in` that the *Export Generator Module* will use to [generate two files](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html) intended to allow import with the [`find_package()` command](https://cmake.org/cmake/help/latest/command/find_package.html#full-signature-and-config-mode): `build/<formated-project-name>Config.cmake` and `build/<formated-project-name>ConfigVersion.cmake`. These two files provide to a downstream consumer project the information to locate on disk the import file `<project-name>Targets.cmake` which informs about the project and about its usage requirement: include-directories, libraries and their dependencies, required compile-flags or locations of executables. The format of their names is imposed by the [`find_package(<formated-project-name>)` command](https://cmake.org/cmake/help/latest/command/find_package.html#full-signature-and-config-mode), which will use the environment variable `<formated-project-name>_DIR`, the project name as a parameter and possibly a [version number](https://cmake.org/cmake/help/latest/command/find_package.html#version-selection) to find them.

Fortunately, the configuration of this export mechanism has been greatly [simplified by CMake](https://cmake.org/cmake/help/latest/manual/cmake-packages.7.html), and now, thanks to the configuration of the template file and the [CMakePackageConfigHelpers](https://cmake.org/cmake/help/latest/module/CMakePackageConfigHelpers.html) module, which uses it to generate the two files mentioned above, there is almost nothing to edit in the `cmake/project/ExportConfig.cmake.in` file. The only thing you need to do there is to **import your project's external dependencies** into the dedicated section, those declared in `cmake/project/DependenciesOptions.cmake`. So open it and use the `find_dependency()` command as explained [here](https://cmake.org/cmake/help/latest/guide/importing-exporting/#creating-a-package-configuration-file). Here are two examples of upstream dependencies declaration into the file.

<details>
<summary>Declare Qt as upstream requirement</summary>

```cmake
#------------------------------------------------------
# Declare here all requirements upstream external dependencies.
#------------------------------------------------------
if(DEFINED ENV{Qt5_DIR}) 
  set(Qt5_DIR "$ENV{Qt5_DIR}")
else()
  set(Qt5_DIR "/opt/Qt/5.15.2/gcc_64/lib/cmake")
endif()
find_dependency(Qt5 COMPONENTS Widgets Gui Core Svg Concurrent REQUIRED)
#------------------------------------------------------
# End of the declaration section.
#------------------------------------------------------
```

</details>

<details>
<summary>Declare Eigen3 as upstream requirement</summary>

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

Once the project is exported, **it can be imported into another project** as below. You will notice that there are several variables to complete:

- `<project-name>` is the name of the project set in the variable `PROJECT_NAME` of the imported project;
- `<Namespace>` is the namespace value set in the variable `EXPORT_NAMESPACE` of the imported project;
- `<ProjectName>` is the name of the imported project in a start case format. A such name is generated by this module.

<details>
<summary>For importing from install-tree</summary>

```cmake
#------------------------------------------------------
# Import and link external libraries from here.
#------------------------------------------------------

#---- Import and link <ProjectName>. ----
message(STATUS "Import and link <ProjectName>")
if(DEFINED ENV{<ProjectName>_DIR}) 
  set(<ProjectName>_DIR "$ENV{<ProjectName>_DIR}")
else()
  set(<ProjectName>_DIR "/usr/local/share/<project-name>/cmake")
endif()

# Find <ProjectName>.
message(STATUS "Find <ProjectName> package")
find_package(<ProjectName> REQUIRED)

# Link <ProjectName> to the main binary build target.
message(STATUS "Link <ProjectName> library to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:<Namespace>::<ProjectName>>"
    "$<INSTALL_INTERFACE:<Namespace>::<ProjectName>>"
  PRIVATE
    "<Namespace>::<ProjectName>"
)
message(STATUS "Import and link <ProjectName> - done")
```

</details>
<details>
<summary>For importing from build-tree</summary>

```cmake
#------------------------------------------------------
# Import and link external libraries from here.
#------------------------------------------------------

#---- Import and link <ProjectName>. ----
message(STATUS "Import and link <ProjectName>")
if(DEFINED ENV{<ProjectName>_DIR}) 
  set(<ProjectName>_DIR "$ENV{<ProjectName>_DIR}")
else()
  set(<ProjectName>_DIR "/link/to/<project-name>/build")
endif()

# Find <ProjectName>.
message(STATUS "Find <ProjectName> package")
find_package(<ProjectName> REQUIRED)

# Link <ProjectName> to the main binary build target.
message(STATUS "Link <ProjectName> library to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:<Namespace>::<ProjectName>>"
    "$<INSTALL_INTERFACE:<Namespace>::<ProjectName>>"
  PRIVATE
    "<Namespace>::<ProjectName>"
)
message(STATUS "Import and link <ProjectName> - done")
```

</details>
<details>
<summary>For importing from source-tree</summary>

```cmake
#------------------------------------------------------
# Import and link external libraries from here.
#------------------------------------------------------

#---- Import and link <ProjectName>. ----
message(STATUS "Import and link <ProjectName>")
if(DEFINED ENV{<ProjectName>_DIR}) 
  set(<ProjectName>_DIR "$ENV{<ProjectName>_DIR}")
else()
  set(<ProjectName>_DIR "/link/to/<project-name>")
endif()

# Auto-download <ProjectName>.
message(STATUS "<ProjectName> will be auto-downloaded in the build-tree")
include(FetchContent)
set(FETCHCONTENT_QUIET off)
FetchContent_Declare(<project-name>
  URL "${<ProjectName>_DIR}"
  STAMP_DIR "${${PROJECT_NAME}_BUILD_DIR}"
  DOWNLOAD_NO_PROGRESS off
  LOG_DOWNLOAD on
  LOG_UPDATE on
  LOG_PATCH on
  LOG_CONFIGURE on
  LOG_BUILD on
  LOG_INSTALL on
  LOG_TEST on
  LOG_MERGED_STDOUTERR on
  LOG_OUTPUT_ON_FAILURE on
  USES_TERMINAL_DOWNLOAD on
)
FetchContent_GetProperties(<project-name>)
if(NOT ${<project-name>_POPULATED})
  FetchContent_Populate(<project-name>)
  include("${<project-name>_SOURCE_DIR}/cmake/project/StandardOptions.txt")
  add_subdirectory("${<project-name>_SOURCE_DIR}" "${<project-name>_SOURCE_DIR}/build")
  include("${${PROJECT_NAME}_CMAKE_PROJECT_DIR}/StandardOptions.txt")
endif()

# Link <ProjectName> to the main binary build target.
message(STATUS "Link <ProjectName> library to the target \"${${PROJECT_NAME}_MAIN_BIN_TARGET}\"")
target_link_libraries("${${PROJECT_NAME}_MAIN_BIN_TARGET}"
  PUBLIC
    "$<BUILD_INTERFACE:<Namespace>::<ProjectName>>"
    "$<INSTALL_INTERFACE:<Namespace>::<ProjectName>>"
  PRIVATE
    "<Namespace>::<ProjectName>"
)
message(STATUS "Import and link <ProjectName> - done")
```

</details>

If after configuring this module you do not wish to activate any others, go directly to the next section.

### 7. *Package Generator Module* settings

#### Description <!-- omit in toc -->

The **role of the *Package Generator Module*** is to generate the files that will allow the `cpack` program to pack the project files in a distributable format, such as a ZIP or an installer. Three targets are associated to it:

- `package`: take the binary files and packs them into a packages in a distributable format, such as a ZIP or an installer.
- `package_source`: take all project files and packs them into a packages in a distributable format, such as a ZIP or an installer.
- `clean`: remove all files generated by the previous targets and the generator.

The [`cpack` program](https://cmake.org/cmake/help/latest/manual/cpack.1.html) is a tool of CMake for packaging programs. It generates installers and source packages in a variety of formats. However by default, [this program is independent](https://gitlab.kitware.com/cmake/community/-/wikis/doc/cpack/Packaging-With-CPack) of the main `cmake` command and is not accessible as a CMake target. Therefore, when we want to integrate it into a build system generator like here, there is an intermediate step to do which is to generate the configuration files that `cpack` will need to generate a binary installers and a source packages, as well as a CMake target to run the program. Fortunately, CMake provides the [CPack module](https://gitlab.kitware.com/cmake/community/-/wikis/doc/cpack/PackageGenerators) which allows to perform all these actions and to generate the configuration files needed by the `cpack` program.

#### Configuration <!-- omit in toc -->

To use this module and customize the packaging, **three options files** need to be configured. The **first file** is `cmake/project/StandardOptions.txt`, so open it and edit the options in the *Package Generator Module options* section:

- `ENABLE_PACKAGE_MODULE=[ON|OFF (default)]`: specifies whether enable the Package Generator Module;

The **two other files to configure** are linked and allow to customize the generation for binary installers and source packages as well as the different generators used (zip, NSIS, DEB, etc). They will be read by CPack which will provide them to the `cpack` program.

The **first file** is `cmake/project/PackageOptions.cmake`. Open it and edit it in using the [CPack](https://cmake.org/cmake/help/latest/module/CPack.html#variables-common-to-all-cpack-generators) and [CPackComponent](https://cmake.org/cmake/help/latest/module/CPackComponent.html) documentation. Only the options common to all generators should be written in this file, as the specific options will go in the second file. Normally there are few values to change and the default one already covers the classical use cases. However, the variables `CPACK_GENERATOR` and `CPACK_SOURCE_GENERATOR` should attract your attention, because it is with them that the list of generators of packaging to be used is specified (the two default one are WIX and ZIP). The complete list of available generators is available [here](https://cmake.org/cmake/help/latest/manual/cpack-generators.7.html).

Then, the **second file** to configure is the one that allows to customize the generators listed individually. Open the file `cmake/project/PackageGeneratorConfig.cmake.in` and write for each of the generators listed in the previous file their individual options. Each of them has its own options, which can be found [here](https://cmake.org/cmake/help/latest/manual/cpack-generators.7.html). To help, an [example configuration](https://github.com/Kitware/CMake/blob/master/CMakeCPackOptions.cmake.in) is provided by CMake.

If after configuring this module you do not wish to activate any others, go directly to the next section.

## ⚙️ Usage and commands

This project provide several scripts and commands to generate the *Build Lifecycle* and execute each build phase with their targets. If you are a VS Code user, they have all been written in `.vscode/tasks.json` and can be launched from the [command palette](https://code.visualstudio.com/docs/editor/tasks), otherwise you can use a command prompt. All the following instructions have to be executed from the root of the project. They are listed in the order of execution of a complete and classic sequence of build phases.

Commands to **clean the *Build Lifecycle*** (these scripts clean `build/`, `doc/` and `bin/`):

```bash
# clean the Build Lifecycle (on Linux/MacOS)
./clean-cmake.sh

# clean the Build Lifecycle (on Windows)
clean-cmake.bat
```

Commands to **generate the *Build Lifecycle*** (these scripts call the `cmake` command):

```bash
# generate the Build Lifecycle (on Linux/MacOS)
./run-cmake.sh

# generate the Build Lifecycle (on Windows)
run-cmake.bat

# a useful command for listing what targets has been generated
cmake --build build/ --target help

# a useful command for listing variables in the cache and their descriptions
cmake -LAH build/
```

Commands to **clean and generate the *Build Lifecycle***:

```bash
# clean and generate the Build Lifecycle (on Linux/MacOS)
./clean-cmake.sh && sleep 3s && echo \"\" && ./run-cmake.sh

# clean and generate the Build Lifecycle (on Windows)
clean-cmake.bat && timeout /t 3 > NUL && echo. && run-cmake.bat
```

Commands to **execute the `uninstall` build phase** of the *Build Lifecycle* (only available if the *Export Generator Module* has been activated):

```bash
# run the uninstall target (on Linux/MacOS)
sudo cmake --build build/ --target uninstall

# run the uninstall target (on Windows)
cmake --build build/ --target uninstall
```

Commands to **execute the `clean` build phase** of the *Build Lifecycle*:

```bash
# run the clean target
cmake --build build/ --target clean
```

Commands to **execute the `compile` build phase** of the *Build Lifecycle*:

```bash
# build all binary targets (except for tests)
cmake --build build/ --target all

# build all binary targets in verbose mode (except for tests)
cmake --build build/ --target all --verbose

# execute the `compile` phase after the `clean` phase
cmake --build build/ --target all --clean-first

# execute the `compile` phase after the `clean` phase in verbose
cmake --build build/ --target all --clean-first --verbose
```

Commands to **execute the `test` build phase** of the *Build Lifecycle* (only available if the *Test Generator Module* has been activated):

```bash
# build the test binary target and execute the tests binary executable
cmake --build build/ --target project-name_test && ../bin/project-name_test
```

Commands to **execute the `doc` build phase** of the *Build Lifecycle* (only available if the *Doc Generator Module* has been activated):

```bash
# run the doc target
cmake --build build/ --target doc
```

Commands to **execute the `install` build phase** of the *Build Lifecycle* (only available if the *Export Generator Module* has been activated):

```bash
# run the install target (on Linux/MacOS)
sudo cmake --build build/ --target install

# run the install target (on Windows)
cmake --build build/ --target install
```

Commands to **execute the `package` build phase** of the *Build Lifecycle* (only available if the *Package Generator Module* has been activated):

```bash
# run the package and package_source targets (on Linux/MacOS)
cmake --build build/ --target package package_source && sleep 3s && rm -rfv bin/_CPack_Packages

# run the package and package_source targets (on Windows)
cmake --build build/ --target package package_source && timeout /t 3 > NUL && del /a /f /s /q bin/_CPack_Packages

# run the package target (on Linux/MacOS)
cmake --build build/ --target package && sleep 3s && rm -rfv bin/_CPack_Packages

# run the package target (on Windows)
cmake --build build/ --target package && timeout /t 3 > NUL && del /a /f /s /q bin/_CPack_Packages

# run the package_source target (on Linux/MacOS)
cmake --build build/ --target package_source && sleep 3s && rm -rfv bin/_CPack_Packages

# run the package_source target (on Windows)
cmake --build build/ --target package_source && timeout /t 3 > NUL && del /a /f /s /q bin/_CPack_Packages

# a useful command for debugging during the package configuration step (on Linux/MacOS)
cpack --debug --verbose --config build/CPackConfig.cmake && sleep 3s && rm -rfv bin/_CPack_Packages

# a useful command for debugging during the package configuration step (on Windows)
cpack --debug --verbose --config build/CPackConfig.cmake && timeout /t 3 > NUL && del /a /f /s /q bin/_CPack_Packages
```

Use the following commands to **execute the binaries built** as executable:

```bash
# execute the main binary executable (on Linux/MacOS)
./bin/project-name

# execute the main binary executable (on Windows)
bin/project-name
```

## 📂 Folder structure overview

This project has been set up with a specific file/folder structure in mind. The following describes some important features of this setup:

| **Directory and File** | **What belongs here** |
|------------------------|-----------------------|
| `.vscode/tasks.json` | Specific VS Code tasks configured to compile, clean, build, etc. |
| `assets/` | Contains images, musics, maps and all resources needed for a game or a simulation project. |
| `bin/` | Any libs that get compiled by the project and the output executables go here, also if you pack your project, the generated files go here. |
| `build/` | Contains the CMake build-tree. |
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
| `clean-cmake.bat` | Utility script for Windows to remove all generated files in `build/`, `bin/` and `doc/`. |
| `clean-cmake.sh` | Utility script for Linux/MacOS to remove all generated files in `build/`, `bin/` and `doc/` directories. |
| `CMakeLists.txt` | Main `CMakelists.txt` file of the project. |
| `LICENSE.md` | License file for project (needs to be edited). |
| `README.md` | Readme file for project (needs to be edited). |
| `run-cmake.bat` | Utility script for Windows to generate the *Build Lifecycle*. |
| `run-cmake.sh` | Utility script for Linux/MacOS to generate the *Build Lifecycle*. |

## 💻 Programming with CMake

For this project, several CMake modules had to be developed to complete the commands of the CMake library. They are in the directory `cmake/modules`, feel free to use them for your own CMake project or to customize this one. They have been written according to [CMake recommendations](https://cmake.org/cmake/help/latest/manual/cmake-developer.7.html), in an identical style, and each command is documented in reStructuredText format, according to the [recommendations](https://github.com/Kitware/CMake/blob/master/Help/dev/documentation.rst). They are all independent and autonomous. Also, to avoid conflicts with [reserved words](https://cmake.org/cmake/help/latest/manual/cmake-variables.7.html), macros and private functions are all prefixed with `_` and global variables with `${PROJECT_NAME}_`.

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
