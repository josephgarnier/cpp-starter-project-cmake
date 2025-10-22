# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Generate and store in ``<output-list-var>`` a printable summary of the
# ``<target-name>`` target status. The status is stored as a list of formatted
# strings.
#
# The status is generated from the variables declared when creating the target
# in a "CMakeLists.txt" file. Therefore, this function should be called at the
# end of the file.
#
# Signature:
#   generate_target_status_summary(<target-name>
#                                   <output-list-var>)
#
# Parameters:
#   target-name: The target name to generate the summary for.
#   output-list-var: The name of the variable to store the summary in.
#
# Globals read:
#   <target-name>_TYPE
#   <target-name>_COMPILE_FEATURES
#   <target-name>_COMPILE_DEFINITIONS
#   <target-name>_COMPILE_OPTIONS
#   <target-name>_LINK_OPTIONS
#   <target-name>_PRIVATE_HEADERS
#   <target-name>_PUBLIC_HEADERS
#   <target-name>_PRIVATE_SOURCES
#   <target-name>_PCH_FILE
#   <target-name>_PUBLIC_HEADER_DIR
#   <target-name>_PRIVATE_HEADER_DIR
#   <target-name>_DEPENDENCIES
#   <dep-name>_FOUND
#
# Returns:
#   output-list-var: The generated summary as a list of formatted strings.
#
# Errors:
#   If the target does not exist.
#
# Exemple:
#   generate_target_status_summary("fruit-salad" target_status_summary)
#------------------------------------------------------------------------------
function(generate_target_status_summary target_name output_list_var)
  if("${target_name}" STREQUAL "")
    message(FATAL_ERROR "target_name argument is missing!")
  endif()
  if(NOT TARGET "${target_name}")
    message(FATAL_ERROR "The target \"${target_name}\" does not exist!")
  endif()
  if("${output_list_var}" STREQUAL "")
    message(FATAL_ERROR "output_list_var argument is missing!")
  endif()

  # Print "Target type"
  list(APPEND ${output_list_var} "⚙ Target type           : ${${target_name}_TYPE}")

  # Print "Compile features"
  list(LENGTH ${target_name}_COMPILE_FEATURES nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN ${target_name}_COMPILE_FEATURES ", " printable)
    list(APPEND ${output_list_var} "⚙ Compile features      : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Compile features      : (none)")
  endif()

  # Print "Compile definitions"
  list(LENGTH ${target_name}_COMPILE_DEFINITIONS nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN ${target_name}_COMPILE_DEFINITIONS ", " printable)
    list(APPEND ${output_list_var} "⚙ Compile definitions   : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Compile definitions   : (none)")
  endif()

  # Print "Compile options"
  list(LENGTH ${target_name}_COMPILE_OPTIONS nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN ${target_name}_COMPILE_OPTIONS ", " printable)
    list(APPEND ${output_list_var} "⚙ Compile options       : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Compile options       : (none)")
  endif()

  # Print "Link options"
  list(LENGTH ${target_name}_LINK_OPTIONS nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN ${target_name}_LINK_OPTIONS ", " printable)
    list(APPEND ${output_list_var} "⚙ Link options          : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Link options          : (none)")
  endif()

  # Print "Sources"
  list(LENGTH ${target_name}_PRIVATE_HEADERS private_header_files_count)
  list(LENGTH ${target_name}_PUBLIC_HEADERS public_header_files_count)
  math(EXPR header_files_count "${private_header_files_count} + ${public_header_files_count}")
  list(LENGTH ${target_name}_PRIVATE_SOURCES source_files_count)
  list(APPEND ${output_list_var} "i Source files set (${header_files_count} headers, ${source_files_count} cpp)")

  # Print "PCH"
  if(NOT "${${target_name}_PCH_FILE}" STREQUAL "")
    list(APPEND ${output_list_var} "⚙ PCH file       : ${${target_name}_PCH_FILE}")
  else()
    list(APPEND ${output_list_var} "⚙ PCH file       : (none)")
  endif()

  # Print "Include directories"
  set(include_directories
    "${${target_name}_PUBLIC_HEADER_DIR}"
    "${${target_name}_PRIVATE_HEADER_DIR}"
  )
  list(LENGTH include_directories nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN include_directories ", " printable)
    list(APPEND ${output_list_var} "⚙ Include dirs   : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Include dirs   : (none)")
  endif()

  # Print "External dependencies"
  foreach(dep_name IN ITEMS ${${target_name}_DEPENDENCIES})
    if(${${dep_name}_FOUND})
      list(APPEND ${output_list_var} "✔ Dependency ${dep_name} linked")
    else()
      list(APPEND ${output_list_var} "⚠️ Dependency ${dep_name} not found")
      # list(APPEND ${output_list_var} "⚠ Dependency ${dep_name} (not found)")
    endif()
  endforeach()

  return(PROPAGATE "${output_list_var}")
endfunction()

#------------------------------------------------------------------------------
# Print in console the status summary of all targets in the project.
#
# To be printed, the summary of a target's status must be previously generated
# with the ``generate_target_status_summary()`` command and stored in a variable
# of the form `<target-name>_STATUS_SUMMARY`.
#
# Signature:
#   print_target_status_summaries()
#
# Exemple:
#   print_target_status_summaries()
#------------------------------------------------------------------------------
function(print_target_status_summaries)
  _collect_all_targets(list_of_targets "${CMAKE_SOURCE_DIR}")
  foreach(target IN ITEMS ${list_of_targets})
    if(DEFINED ${target}_STATUS_SUMMARY)
      message(STATUS "🎯 Target '${target}' Status Checks:")
      list(APPEND CMAKE_MESSAGE_INDENT "  ")
      foreach(line IN ITEMS ${${target}_STATUS_SUMMARY})
        message(STATUS "${line}")
      endforeach()
      list(POP_BACK CMAKE_MESSAGE_INDENT)
    endif()
  endforeach()
endfunction()

#------------------------------------------------------------------------------
# [Internal usage]
# Collect all buildsystem targets defined in the given directory ``<root-dir>``
# and its subdirectories into ``<output-list-var>``.
#
# Signature:
#   _collect_all_targets(<output-list-var>
#                        <root-dir>)
#
# Parameters:
#   output-list-var: Variable to store the collected targets.
#   root-dir: The root directory to scan.
#
# Returns:
#   output-list-var: The list of collected targets.
#
# Errors:
#   If the root dir does not exist or is not a directory.
#
# Exemple:
#   _collect_all_targets(list_of_targets "${CMAKE_SOURCE_DIR}")
#------------------------------------------------------------------------------
function(_collect_all_targets output_list_var root_dir)
  if("${output_list_var}" STREQUAL "")
    message(FATAL_ERROR "output_list_var argument is missing!")
  endif()
  if("${root_dir}" STREQUAL "")
    message(FATAL_ERROR "root_dir argument is missing!")
  endif()
  if((NOT EXISTS "${root_dir}")
    OR (NOT IS_DIRECTORY "${root_dir}"))
      message(FATAL_ERROR "Given path: ${root_dir} does not refer to an existing path or directory on disk!")
  endif()

  set(collected "")
  get_directory_property(targets DIRECTORY "${root_dir}" BUILDSYSTEM_TARGETS)
  foreach(target IN ITEMS ${targets})
    list(APPEND collected "${target}")
  endforeach()

  get_directory_property(subdirs DIRECTORY "${root_dir}" SUBDIRECTORIES)
  foreach(subdir IN ITEMS ${subdirs})
    _collect_all_targets(sub_collected "${subdir}")
    list(APPEND collected "${sub_collected}")
  endforeach()

  list(REMOVE_DUPLICATES collected)

  set(${output_list_var} "${collected}")
  return(PROPAGATE "${output_list_var}")
endfunction()

#------------------------------------------------------------------------------
# Print in console a summary of the properties of ``<target-name>`` target.
#
# Signature:
#   print_target_properties_summary(<target-name>)
#
# Parameters:
#   target-name: The target name to generate the summary for.
#
# Errors:
#   If the target does not exist.
#
# Exemple:
#   print_target_properties_summary("fruit-salad")
#------------------------------------------------------------------------------
function(print_target_properties_summary target_name)
  if("${target_name}" STREQUAL "")
    message(FATAL_ERROR "target_name argument is missing!")
  endif()
  if(NOT TARGET "${target_name}")
    message(FATAL_ERROR "The target \"${target_name}\" does not exist!")
  endif()

  # Print "Target type"
  get_target_property(type "${target_name}" TYPE)
  message(STATUS "• Bin type: ${type}")

  # Print "Compile features"
  get_target_property(compile_features "${target_name}" COMPILE_FEATURES)
  get_target_property(compile_features_interface "${target_name}" 
    INTERFACE_COMPILE_FEATURES)
  if(NOT "${compile_features_interface}" MATCHES "-NOTFOUND$")
    list(APPEND compile_features "${compile_features_interface}")
  endif()
  list(LENGTH compile_features nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN compile_features ", " printable)
    message(STATUS "• Compile features: ${printable}")
  else()
    message(STATUS "• Compile features: (none)")
  endif()

  # Print "Compile definitions"
  get_target_property(compile_definitions "${target_name}" COMPILE_DEFINITIONS)
  get_target_property(compile_definitions_interface "${target_name}" 
    INTERFACE_COMPILE_DEFINITIONS)
  if(NOT "${compile_definitions_interface}" MATCHES "-NOTFOUND$")
    list(APPEND compile_definitions "${compile_definitions_interface}")
  endif()
  list(LENGTH compile_definitions nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN compile_definitions ", " printable)
    message(STATUS "• Compile definitions: ${printable}")
  else()
    message(STATUS "• Compile definitions: (none)")
  endif()

  # Print "Compile options"
  get_target_property(compile_options "${target_name}" COMPILE_OPTIONS)
  get_target_property(compile_options_interface "${target_name}" 
    INTERFACE_COMPILE_OPTIONS)
  if(NOT "${compile_options_interface}" MATCHES "-NOTFOUND$")
    list(APPEND compile_options "${compile_options_interface}")
  endif()
  list(LENGTH compile_options nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN compile_options ", " printable)
    message(STATUS "• Compile options: ${printable}")
  else()
    message(STATUS "• Compile options: (none)")
  endif()

  # Print "Link options"
  get_target_property(link_options "${target_name}" LINK_OPTIONS)
  get_target_property(link_options_interface "${target_name}" 
    INTERFACE_LINK_OPTIONS)
  if(NOT "${link_options_interface}" MATCHES "-NOTFOUND$")
    list(APPEND link_options "${link_options_interface}")
  endif()
  list(LENGTH link_options nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN link_options ", " printable)
    message(STATUS "• Link options: ${printable}")
  else()
    message(STATUS "• Link options: (none)")
  endif()

  # Print "Sources"
  get_target_property(sources "${target_name}" SOURCES)
  get_target_property(sources_interface "${target_name}" INTERFACE_SOURCES)
  if(NOT "${sources_interface}" MATCHES "-NOTFOUND$")
    list(APPEND sources "${sources_interface}")
  endif()
  list(LENGTH sources nb_vals)
  message(STATUS "• Sources: ${nb_vals} files set (cpp and h)")

  # Print "PCH"
  get_target_property(precompiled_headers "${target_name}" PRECOMPILE_HEADERS)
  get_target_property(precompiled_headers_interface "${target_name}" 
    INTERFACE_PRECOMPILE_HEADERS)
  set(printable_pch_prop "")
  if(NOT "${precompiled_headers}" MATCHES "-NOTFOUND$")
    list(APPEND printable_pch_prop "${precompiled_headers}")
  endif()
  if(NOT "${precompiled_headers_interface}" MATCHES "-NOTFOUND$")
    list(APPEND printable_pch_prop "${precompiled_headers_interface}")
  endif()
  list(LENGTH printable_pch_prop nb_printable_vals)
  if(${nb_printable_vals} GREATER 0)
    list(JOIN printable_pch_prop ", " printable_pch_prop)
    message(STATUS "• PCH file: ${printable_pch_prop}")
  else()
    message(STATUS "• PCH file: (none)")
  endif()

  # Print "Include directories"
  get_target_property(include_directories "${target_name}" INCLUDE_DIRECTORIES)
  get_target_property(include_directories_interface "${target_name}" 
    INTERFACE_INCLUDE_DIRECTORIES)
  if(NOT "${include_directories_interface}" MATCHES "-NOTFOUND$")
    list(APPEND include_directories "${include_directories_interface}")
  endif()
  list(LENGTH include_directories nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN include_directories ", " printable)
    message(STATUS "• Include dirs: ${printable}")
  else()
    message(STATUS "• Include dirs: (none)")
  endif()
endfunction()