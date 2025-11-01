# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Prints to the console the status summaries stored in
# ``<target-name><target-summary-var-suffix>`` for all targets in the project.
# Each target's status summary is expected to be a list of formatted strings.
# Targets without a summary are ignored.
#
# Each target's summary must be generated beforehand using the
# ``generate_target_status_summary()`` command, and stored in a variable named
# according to the pattern ``<target-name><target-summary-var-suffix>``.
#
# Signature:
#   print_target_status_summaries(<target-summary-var-suffix>)
#
# Parameters:
#   target-summary-var-suffix: The variable name suffix used to locate each
#                              target's status summary. Each summary must be
#                              stored in a variable following the pattern
#                              ``<target-name><target-summary-var-suffix>``.
#
# Globals read:
#   <target-name><target-summary-var-suffix>
#
# Returns:
#   None
#
# Example:
#   print_target_status_summaries("_STATUS_SUMMARY")
#------------------------------------------------------------------------------
function(print_target_status_summaries target_summary_var_suffix)
  if(NOT ${ARGC} EQUAL 1)
    message(FATAL_ERROR "print_target_status_summaries() requires exactly 1 arguments, got ${ARGC}!")
  endif()
  if("${target_summary_var_suffix}" STREQUAL "")
    message(FATAL_ERROR "target_summary_var_suffix argument is missing!")
  endif()

  _collect_all_targets(list_of_targets "${CMAKE_SOURCE_DIR}")
  foreach(target IN ITEMS ${list_of_targets})
    if(DEFINED ${target}${target_summary_var_suffix})
      message(STATUS "🎯 Target '${target}' Status Checks:")
      list(APPEND CMAKE_MESSAGE_INDENT "   ")
      foreach(line IN ITEMS ${${target}${target_summary_var_suffix}})
        message(STATUS "${line}")
      endforeach()
      list(POP_BACK CMAKE_MESSAGE_INDENT)
    endif()
  endforeach()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
# Collects all build system targets defined in the specified ``<root-dir>``
# and its subdirectories, and stores them in ``<output-list-var>``.
#
# Signature:
#   _collect_all_targets(<output-list-var>
#                        <root-dir>)
#
# Parameters:
#   output-list-var  : The variable in which to store the collected targets.
#   root-dir         : The root directory to scan for targets.
#
# Returns:
#   output-list-var: The list of collected targets.
#
# Errors:
#   If the specified root directory does not exist or is not a directory.
#
# Example:
#   _collect_all_targets(list_of_targets "${CMAKE_SOURCE_DIR}")
#------------------------------------------------------------------------------
function(_collect_all_targets output_list_var root_dir)
  if(NOT ${ARGC} EQUAL 2)
    message(FATAL_ERROR "_collect_all_targets() requires exactly 2 arguments, got ${ARGC}!")
  endif()
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

  unset(${output_list_var})
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