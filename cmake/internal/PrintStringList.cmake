# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Prints to the console a list of strings formatted with the pattern:
# ``<message>: <string>, ...``
#
# Signature:
#   print_string_list(<mode> <message> <string-list>)
#
# Parameters:
#   mode         : A keyword that must be one of the standard message modes
#                  accepted by the ``message()`` command, such as ``STATUS``,
#                  ``WARNING``, ``ERROR``, etc.
#   message      : The text to print.
#   string-list  : A list of strings to print.
#
# Returns:
#   None
#
# Example:
#   print_string_list(VERBOSE "Applying options" "${OPTIONS}")
#------------------------------------------------------------------------------
function(print_string_list mode message string_list)
  if(NOT ${ARGC} EQUAL 3)
    message(FATAL_ERROR "print_string_list() requires exactly 3 arguments, got ${ARGC}!")
  endif()
  if("${mode}" STREQUAL "")
    message(FATAL_ERROR "mode argument is missing!")
  endif()
  if("${message}" STREQUAL "")
    message(FATAL_ERROR "message argument is missing!")
  endif()

  list(LENGTH string_list nb_strings)
  if(${nb_strings} GREATER 0)
    print(${mode} "${message}: @sl@" "${string_list}")
  else()
    print(${mode} "${message}: (none)")
  endif()
endfunction()