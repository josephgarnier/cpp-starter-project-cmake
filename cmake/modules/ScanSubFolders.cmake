# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
ScanSubFolders
---------

Function for scanning a system of directories.

 Usage
 ^^^^^
	scan_sub_folders(
		<return_files>
		ROOT_PATH <rootpath>
		INCLUDE_REGEX [ext1 [ext2 [ext3 ...]]])


 Arguments
 ^^^^^^^^^
	``\return:return_files``
	the name of the variable that should hold the returned file list.

	``\param:ROOT_PATH``
	specify the root folder to search for files.

	``\group:INCLUDE_REGEX``
	specify a regular expression that the file names (without path)
	must match to be listed.


 Requires these CMake modules
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
	None

 Requires CMake 3.12 or newer
 ^^^^^^^^^^^^^^^^^^^^^^^^^^^^
#]=======================================================================]
cmake_minimum_required (VERSION 3.12)

function(scan_sub_folders return_files)
	set(options "")
	set(one_value_args ROOT_PATH INCLUDE_REGEX)
	set(multi_value_args "")
	cmake_parse_arguments(SSF "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	if(SSF_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SSF_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED SSF_ROOT_PATH)
		set(SSF_ROOT_PATH "")
	endif()
	if(NOT DEFINED SSF_INCLUDE_REGEX)
		message(FATAL_ERROR "Regex arguments missing")
	endif()

	file(GLOB relativePath RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} "${SSF_ROOT_PATH}")
	file(GLOB children RELATIVE ${SSF_ROOT_PATH} "${SSF_ROOT_PATH}/*")
	set(list_dirs "")
	set(list_files "")

	foreach(child ${children})
		if(IS_DIRECTORY "${SSF_ROOT_PATH}/${child}")
			list(APPEND list_dirs ${child})
		elseif("${child}" MATCHES "${SSF_INCLUDE_REGEX}")
			list(APPEND list_files "${SSF_ROOT_PATH}/${child}")
		endif()
	endforeach()

	string(REPLACE "/" "\\" relative_path "${relative_path}")
	if ("${relative_path}" STREQUAL "")
		set(source_group "")
	else()
		set(source_group "${relative_path}")
	endif()
	source_group("${source_group}" FILES "${list_files}")

	foreach(subdirectory ${list_dirs})
		scan_sub_folders(${return_files} ROOT_PATH "${SSF_ROOT_PATH}/${subdirectory}" INCLUDE_REGEX "${SSF_INCLUDE_REGEX}")
	endforeach()
	
	if(NOT ${return_files})
		set(${return_files} "${list_files}" PARENT_SCOPE)
	else()
		set(${return_files} "${${return_files}}" "${list_files}" PARENT_SCOPE)
	endif()
endfunction()
