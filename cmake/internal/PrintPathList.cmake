# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Prints to the console a list of paths formatted with the pattern:
# ``<message> (<nb-path>): <file-path>, ...``
#
# Signature:
#   print_path_list(<mode> <message> <path-list>)
#
# Parameters:
#   mode       : A keyword that must be one of the standard message modes
#                accepted by the ``message()`` command, such as ``STATUS``,
#                ``WARNING``, ``ERROR``, etc.
#   message    : The text to print.
#   path-list  : A list of file paths to print.
#
# Returns:
#   None
#
# Example:
#   print_path_list(VERBOSE "Source collected" "${SOURCE_FILES}")
#------------------------------------------------------------------------------
function(print_path_list mode message path_list)
  if(NOT ${ARGC} EQUAL 3)
    message(FATAL_ERROR "print_path_list() requires exactly 3 arguments, got ${ARGC}!")
  endif()
  if("${mode}" STREQUAL "")
    message(FATAL_ERROR "mode argument is missing!")
  endif()
  if("${message}" STREQUAL "")
    message(FATAL_ERROR "message argument is missing!")
  endif()

  list(LENGTH path_list nb_paths)
  if(${nb_paths} GREATER 0)
    print(${mode} "${message} (${nb_paths}): @rpl@" "${path_list}")
  else()
    print(${mode} "${message}: (none)")
  endif()
endfunction()
