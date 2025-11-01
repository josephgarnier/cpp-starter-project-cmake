# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Generates and stores in ``<output-list-var>`` a printable summary of the
# ``<target-name>`` target's generation status. The summary is stored as
# a list of human-readable strings.
#
# The status is derived from the variables declared during the target's
# creation in the corresponding "CMakeLists.txt" file. Therefore, this function
# should be called at the end of that file.
#
# Signature:
#   generate_target_status_summary(<target-name>
#                                  <output-list-var>)
#
# Parameters:
#   target-name      : The name of the target to generate the summary for.
#   output-list-var  : The name of the variable in which to store the summary.
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
#   If the specified target does not exist.
#
# Example:
#   generate_target_status_summary("fruit-salad" target_status_summary)
#------------------------------------------------------------------------------
function(generate_target_status_summary target_name output_list_var)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "generate_target_status_summary() requires exactly 2 arguments, got ${ARGC}!")
  endif()
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
  set(${output_list_var} "")
  list(APPEND ${output_list_var} "⚙ Target type         : ${${target_name}_TYPE}")

  # Print "Compile features"
  list(LENGTH ${target_name}_COMPILE_FEATURES nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN ${target_name}_COMPILE_FEATURES ", " printable)
    list(APPEND ${output_list_var} "⚙ Compile features    : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Compile features    : (none)")
  endif()

  # Print "Compile definitions"
  list(LENGTH ${target_name}_COMPILE_DEFINITIONS nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN ${target_name}_COMPILE_DEFINITIONS ", " printable)
    list(APPEND ${output_list_var} "⚙ Compile definitions : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Compile definitions : (none)")
  endif()

  # Print "Compile options"
  list(LENGTH ${target_name}_COMPILE_OPTIONS nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN ${target_name}_COMPILE_OPTIONS ", " printable)
    list(APPEND ${output_list_var} "⚙ Compile options     : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Compile options     : (none)")
  endif()

  # Print "Link options"
  list(LENGTH ${target_name}_LINK_OPTIONS nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN ${target_name}_LINK_OPTIONS ", " printable)
    list(APPEND ${output_list_var} "⚙ Link options        : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Link options        : (none)")
  endif()

  # Print "Sources"
  list(LENGTH ${target_name}_PRIVATE_HEADERS private_header_files_count)
  list(LENGTH ${target_name}_PUBLIC_HEADERS public_header_files_count)
  math(EXPR header_files_count "${private_header_files_count} + ${public_header_files_count}")
  list(LENGTH ${target_name}_PRIVATE_SOURCES source_files_count)
  list(APPEND ${output_list_var} "i Source files set (${header_files_count} headers, ${source_files_count} cpp)")

  # Print "PCH"
  if(NOT "${${target_name}_PCH_FILE}" STREQUAL "")
    list(APPEND ${output_list_var} "⚙ PCH file     : ${${target_name}_PCH_FILE}")
  else()
    list(APPEND ${output_list_var} "⚙ PCH file     : (none)")
  endif()

  # Print "Include directories"
  set(include_directories
    "${${target_name}_PUBLIC_HEADER_DIR}"
    "${${target_name}_PRIVATE_HEADER_DIR}"
  )
  list(LENGTH include_directories nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN include_directories ", " printable)
    list(APPEND ${output_list_var} "⚙ Include dirs : ${printable}")
  else()
    list(APPEND ${output_list_var} "⚙ Include dirs : (none)")
  endif()

  # Print "External dependencies"
  foreach(dep_name IN ITEMS ${${target_name}_DEPENDENCIES})
    if(${${dep_name}_FOUND})
      list(APPEND ${output_list_var} "✔ Dependency ${dep_name} found")
    else()
      list(APPEND ${output_list_var} "⚠ Dependency ${dep_name} not found")
    endif()
  endforeach()

  return(PROPAGATE "${output_list_var}")
endfunction()
