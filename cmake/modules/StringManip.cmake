# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
StringManip
-----------

Operations on strings. It requires CMake 4.0.1 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  string_manip(`SPLIT`_ <string> <output-list-var>)
  string_manip(`SPLIT_TRANSFORM`_ <string-var> <ACTION> [OUTPUT_VARIABLE <output-var>])
  string_manip(`STRIP_INTERFACES`_ <string-var> [OUTPUT_VARIABLE <output-var>])
  string_manip(`EXTRACT_INTERFACE`_ <string-var> <BUILD|INSTALL> [OUTPUT_VARIABLE <output-var>])

Usage
^^^^^

.. signature::
  string_manip(SPLIT <string> <output-list-var>)

  Splits the input string into a list of substrings based on specific
  pattern rules. This command analyzes the given ``<string>`` and splits
  it into components using the following criteria:

  * Transitions between lowercase and uppercase letters
    (e.g., ``MyValue`` becomes ``My;Value``).
  * Non-alphanumeric characters, as defined by the :cmake:command:`string(MAKE_C_IDENTIFIER) <cmake:command:string(make_c_identifier)>`
    transformation in CMake.

  The resulting list is stored in ``<output-list-var>``. If no split point is
  detected, the original string is returned as a single-element list.

  Example usage:

  .. code-block:: cmake

    # No split point detected
    string_manip(SPLIT "mystringtosplit" output)
    # output is:
    #   "mystringtosplit"
    string_manip(SPLIT "my1string2to3split" output)
    # output is:
    #   my1string2to3split

    # Split on uppercase
    string_manip(SPLIT "myStringToSplit" output)
    # output is:
    #   my;String;To;Split

    # Split on non-alphanumeric
    string_manip(SPLIT "my-string/to*split" output)
    # output is:
    #   my;string;to;split

    # Split on multiple criteria
    string_manip(SPLIT "myString_to*Split" output)
    # output is:
    #   my;String;to;Split

.. signature::
  string_manip(SPLIT_TRANSFORM <string-var> <ACTION> [OUTPUT_VARIABLE <output-var>])

  Applies the :command:`string_manip(SPLIT)` operation to the value stored in ``<string-var>``,
  transforms each resulting element according to the specified ``<ACTION>``,
  then joins the list into a single string. The final result is either stored
  back in ``<string-var>``, or in ``<output-var>`` if the ``OUTPUT_VARIABLE``
  option is provided.

  The available values for ``<ACTION>`` are:

    ``START_CASE``
      Converts each word to Start Case (first letter uppercase, others lowercase).

    ``C_IDENTIFIER_UPPER``
      Applies a transformation inspired by :cmake:command:`string(MAKE_C_IDENTIFIER) <cmake:command:string(make_c_identifier)>`:
      each word is converted to uppercase and suffixed with an underscore.
      If the first character is a digit, an underscore is also prepended to
      the result.

  Example of transformations:

  ====================  ======================  =====================================
  Input                 Action                  Output
  ====================  ======================  =====================================
  ``myVariableName``    ``START_CASE``          ``MyVariableName``
  ``my_variable_name``  ``START_CASE``          ``MyVariableName``
  ``myVariableName``    ``C_IDENTIFIER_UPPER``  ``MY_VARIABLE_NAME_`` (joined string)
  ====================  ======================  =====================================

  If no split points are detected, the input is treated as a single-element
  list and transformed accordingly.

.. signature::
  string_manip(STRIP_INTERFACES <string-var> [OUTPUT_VARIABLE <output-var>])

  Removes CMake generator expressions of the form ``$<BUILD_INTERFACE:...>`` and
  ``$<INSTALL_INTERFACE:...>`` from the value stored in ``<string-var>``. The
  expressions are removed entirely, including any leading semicolon if
  present before the expression.

  The resulting string is either stored back in ``<string-var>``, or in
  ``<output-var>`` if the ``OUTPUT_VARIABLE`` option is provided.

  Example usage:

  .. code-block:: cmake

    set(input "libA;$<BUILD_INTERFACE:src>;libB;libC;$<INSTALL_INTERFACE:include/>libD")
    string_manip(STRIP_INTERFACES input)
    # input is:
    #   libA;libB;libClibD

.. signature::
  string_manip(EXTRACT_INTERFACE <string-var> <BUILD|INSTALL> [OUTPUT_VARIABLE <output-var>])

  Extracts the content of either ``$<BUILD_INTERFACE:...>`` or
  ``$<INSTALL_INTERFACE:...>`` generator expressions from the value stored
  in ``<string-var>``, depending on the specified mode.

  The value of ``<string-var>`` can be either a single string or a
  semicolon-separated list of strings. Generator expressions may be split
  across multiple list elements.

  The ``<BUILD|INSTALL>`` argument selects which generator expression to extract:

  * ``BUILD``: Extracts the content of all ``$<BUILD_INTERFACE:...>`` expressions.
  * ``INSTALL``: Extracts the content of all ``$<INSTALL_INTERFACE:...>`` expressions.

  When multiple matching generator expressions are found, their contents are
  concatenated into a single semicolon-separated string.

  The result is stored in ``<output-var>`` if the ``OUTPUT_VARIABLE`` option
  is specified. Otherwise, ``<string-var>`` is updated in place. If no
  matching expression is found, an empty string is returned.

  Example usage:

  .. code-block:: cmake

    # Case 1: Extract from a single BUILD_INTERFACE expression in place
    set(value_1 "file1.h;$<BUILD_INTERFACE:file2.h;file3.h>;file4.h")
    string_manip(EXTRACT_INTERFACE value_1 BUILD)
    # value_1 is:
    #   file2.h;file3.h

    # Case 2: Extract from a single INSTALL_INTERFACE expression in place
    set(value_2 "file5.h;$<INSTALL_INTERFACE:file6.h;file7.h>;file8.h")
    string_manip(EXTRACT_INTERFACE value_2 INSTALL)
    # value_2 is:
    #    file6.h;file7.h

    # Case 3: Multiple expressions (BUILD + INSTALL), extract only BUILD
    set(value_3 "file1.h;$<BUILD_INTERFACE:file2.h;file3.h>;file4.h;file5.h;$<INSTALL_INTERFACE:file6.h;file7.h>;file8.h")
    string_manip(EXTRACT_INTERFACE value_3 BUILD)
    # value_3 is:
    #   file2.h;file3.h
#]=======================================================================]

include_guard()

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(string_manip)
  set(options START_CASE C_IDENTIFIER_UPPER BUILD INSTALL)
  set(one_value_args SPLIT_TRANSFORM STRIP_INTERFACES OUTPUT_VARIABLE EXTRACT_INTERFACE)
  set(multi_value_args SPLIT)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${one_value_args}" "${multi_value_args}"
  )

  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"!")
  endif()
  if(DEFINED arg_SPLIT)
    set(current_command "string_manip(SPLIT)")
    _string_manip_split()
  elseif(DEFINED arg_SPLIT_TRANSFORM)
    set(current_command "string_manip(SPLIT_TRANSFORM)")
    if(${arg_C_IDENTIFIER_UPPER})
      _string_manip_split_transform_identifier_upper()
    elseif(${arg_START_CASE})
      _string_manip_split_transform_start_case()
    else()
      message(FATAL_ERROR "${current_command} requires the keyword ACTION to be provided with a supported value!")
    endif()
  elseif(DEFINED arg_STRIP_INTERFACES)
    set(current_command "string_manip(STRIP_INTERFACES)")
    _string_manip_strip_interfaces()
  elseif(DEFINED arg_EXTRACT_INTERFACE)
    set(current_command "string_manip(EXTRACT_INTERFACE)")
    _string_manip_extract_interface()
  else()
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}(<OP> <value> ...) requires an operation and a value to be specified!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_string_manip_split)
  list(LENGTH arg_SPLIT nb_args)
  if(NOT ${nb_args} EQUAL 2)
    message(FATAL_ERROR "${current_command} called with wrong number of arguments!")
  endif()

  list(GET arg_SPLIT 0 string_to_split)
  list(GET arg_SPLIT 1 output_list_var)
  string(MAKE_C_IDENTIFIER "${string_to_split}" string_to_split)
  string(REGEX MATCHALL "[^_][^|A-Z|_]*" ${output_list_var} "${string_to_split}")
  return(PROPAGATE "${output_list_var}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_string_manip_split_transform_identifier_upper)
  if((NOT DEFINED arg_SPLIT_TRANSFORM)
      OR ("${arg_SPLIT_TRANSFORM}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword SPLIT_TRANSFORM to be provided with a non-empty string value!")
  endif()
  if(NOT ${arg_C_IDENTIFIER_UPPER})
    message(FATAL_ERROR "${current_command} requires the keyword C_IDENTIFIER_UPPER to be provided!")
  endif()
  if((DEFINED arg_OUTPUT_VARIABLE)
      AND ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(output_formated_word "")
    # Check if the input string is empty to avoid fatal error in ``string_manip(SPLIT ...)``
  if(NOT "${${arg_SPLIT_TRANSFORM}}" STREQUAL "")
    string_manip(SPLIT "${${arg_SPLIT_TRANSFORM}}" word_list)
    foreach(word IN ITEMS ${word_list})
      string(TOUPPER "${word}" formated_word)
      string(APPEND output_formated_word "_${formated_word}")
      unset(formated_word)
    endforeach()
  endif()

  # The underscore is removed if the second letter is not a digit
  string(LENGTH "${output_formated_word}" output_formated_word_size)
  if(${output_formated_word_size} GREATER_EQUAL 2)
    string(SUBSTRING ${output_formated_word} 1 1 second_letter)
    if(NOT "${second_letter}" MATCHES "[0-9]")
      string(SUBSTRING "${output_formated_word}" 1 -1 output_formated_word)
    endif()
  endif()

  if(NOT DEFINED arg_OUTPUT_VARIABLE)
    set(${arg_SPLIT_TRANSFORM} "${output_formated_word}" PARENT_SCOPE)
  else()
    set(${arg_OUTPUT_VARIABLE} "${output_formated_word}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_string_manip_split_transform_start_case)
  if((NOT DEFINED arg_SPLIT_TRANSFORM)
      OR ("${arg_SPLIT_TRANSFORM}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword SPLIT_TRANSFORM to be provided with a non-empty string value!")
  endif()
  if(NOT ${arg_START_CASE})
    message(FATAL_ERROR "${current_command} requires the keyword START_CASE to be provided!")
  endif()
  if((DEFINED arg_OUTPUT_VARIABLE)
      AND ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(output_formated_word "")
  # Check if the input string is empty to avoid fatal error in ``string_manip(SPLIT ...)``
  if(NOT "${${arg_SPLIT_TRANSFORM}}" STREQUAL "")
    string_manip(SPLIT "${${arg_SPLIT_TRANSFORM}}" word_list)
    foreach(word IN ITEMS ${word_list})
      string(TOLOWER "${word}" formated_word)
      string(SUBSTRING ${formated_word} 0 1 first_letter)
      string(TOUPPER "${first_letter}" first_letter)
      string(REGEX REPLACE "^.(.*)" "${first_letter}\\1" formated_word "${formated_word}")
      string(APPEND output_formated_word "${formated_word}")
      unset(formated_word)
    endforeach()
  endif()

  if(NOT DEFINED arg_OUTPUT_VARIABLE)
    set(${arg_SPLIT_TRANSFORM} "${output_formated_word}" PARENT_SCOPE)
  else()
    set(${arg_OUTPUT_VARIABLE} "${output_formated_word}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_string_manip_strip_interfaces)
  if((NOT DEFINED arg_STRIP_INTERFACES)
      OR ("${arg_STRIP_INTERFACES}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword STRIP_INTERFACES to be provided with a non-empty string value!")
  endif()
  if((DEFINED arg_OUTPUT_VARIABLE)
      AND ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(regex ";?\\$<BUILD_INTERFACE:[^>]+>|;?\\$<INSTALL_INTERFACE:[^>]+>")
  string(REGEX REPLACE "${regex}" "" string_striped "${${arg_STRIP_INTERFACES}}")

  if(NOT DEFINED arg_OUTPUT_VARIABLE)
    set(${arg_STRIP_INTERFACES} "${string_striped}" PARENT_SCOPE)
  else()
    set(${arg_OUTPUT_VARIABLE} "${string_striped}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_string_manip_extract_interface)
  if((NOT DEFINED arg_EXTRACT_INTERFACE)
      OR ("${arg_EXTRACT_INTERFACE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword EXTRACT_INTERFACE to be provided with a non-empty string value!")
  endif()
  if((NOT ${arg_BUILD})
      AND (NOT ${arg_INSTALL}))
    message(FATAL_ERROR "${current_command} requires the keyword BUILD or INSTALL to be provided!")
  endif()
  if(${arg_BUILD} AND ${arg_INSTALL})
    message(FATAL_ERROR "${current_command} requires BUILD and INSTALL not to be used together, they are mutually exclusive!")
  endif()
  if((DEFINED arg_OUTPUT_VARIABLE)
      AND ("${arg_OUTPUT_VARIABLE}" STREQUAL ""))
    message(FATAL_ERROR "${current_command} requires the keyword OUTPUT_VARIABLE to be provided with a non-empty string value!")
  endif()

  set(result_list "")
  if(${arg_BUILD})
    set(opening_marker "$<BUILD_INTERFACE:")
  elseif(${arg_INSTALL})
    set(opening_marker "$<INSTALL_INTERFACE:")
  else()
    message(FATAL_ERROR "${current_command} called with a wrong interface type!")
  endif()
  set(closing_marker ">")
  set(accumulator "")
  set(inside_expr false)
  foreach(item IN ITEMS ${${arg_EXTRACT_INTERFACE}})
    # Accumulate until the closing generator expression is found
    if(NOT ${inside_expr} AND ("${item}" MATCHES "^\\${opening_marker}.*"))
      set(accumulator "${item}")
      set(inside_expr true)
    elseif(${inside_expr})
      list(APPEND accumulator "${item}")
    endif()

    if(${inside_expr} AND ("${item}" MATCHES ".*${closing_marker}$"))
      list(LENGTH accumulator len)
      list(JOIN accumulator ";" expr_str)
      # Remove prefix "$<...:" and suffix ">"
      string(REPLACE "${opening_marker}" "" expr_str "${expr_str}")
      string(REPLACE "${closing_marker}" "" expr_str "${expr_str}")
      list(APPEND result_list "${expr_str}")
      unset(accumulator)
      set(inside_expr false)
    endif()
  endforeach()

  list(JOIN result_list ";" extracted_strings)
  if(NOT DEFINED arg_OUTPUT_VARIABLE)
    set(${arg_EXTRACT_INTERFACE} "${extracted_strings}" PARENT_SCOPE)
  else()
    set(${arg_OUTPUT_VARIABLE} "${extracted_strings}" PARENT_SCOPE)
  endif()
endmacro()
