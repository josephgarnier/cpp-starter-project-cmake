# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
StringManip
-----------

Operations on strings. It requires CMake 3.20 or newer.

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
    # output is "mystringtosplit"
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

  ====================  ======================  =======================================
  Input                 Action                  Output
  ====================  ======================  =======================================
  ``"myVariableName"``  ``START_CASE``          ``"MyVariableName"``
  ``"myVariableName"``  ``C_IDENTIFIER_UPPER``  ``"MY_VARIABLE_NAME_"`` (joined string)
  ====================  ======================  =======================================

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
    # output is:
    #   file2.h;file3.h

    # Case 2: Extract from a single INSTALL_INTERFACE expression in place
    set(value_1 "file5.h;$<INSTALL_INTERFACE:file6.h;file7.h>;file8.h")
    string_manip(EXTRACT_INTERFACE value_1 INSTALL)
    # output is:
    #    file6.h;file7.h

    # Case 3: Multiple expressions (BUILD + INSTALL), extract only BUILD
    set(value_3 "file1.h;$<BUILD_INTERFACE:file2.h;file3.h>;file4.h;file5.h;$<INSTALL_INTERFACE:file6.h;file7.h>;file8.h")
    string_manip(EXTRACT_INTERFACE value_3 BUILD)
    # output is:
    #   file2.h;file3.h
#]=======================================================================]

include_guard()

cmake_minimum_required (VERSION 3.20 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(string_manip)
  set(options START_CASE C_IDENTIFIER_UPPER BUILD INSTALL)
  set(one_value_args SPLIT_TRANSFORM STRIP_INTERFACES OUTPUT_VARIABLE EXTRACT_INTERFACE)
  set(multi_value_args SPLIT)
  cmake_parse_arguments(SM "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  
  if(DEFINED SM_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"!")
  endif()
  if(DEFINED SM_SPLIT)
    _string_manip_split()
  elseif(DEFINED SM_SPLIT_TRANSFORM)
    if(${SM_C_IDENTIFIER_UPPER})
      _string_manip_split_transform_identifier_upper()
    elseif(${SM_START_CASE})
      _string_manip_split_transform_start_case()
    else()
      message(FATAL_ERROR "ACTION argument is missing!")
    endif()
  elseif(DEFINED SM_STRIP_INTERFACES)
    _string_manip_strip_interfaces()
  elseif(DEFINED SM_EXTRACT_INTERFACE)
    _string_manip_extract_interface()
  else()
    message(FATAL_ERROR "The operation name or arguments are missing!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage
macro(_string_manip_split)
  list(LENGTH SM_SPLIT nb_args)
  if(NOT ${nb_args} EQUAL 2)
    message(FATAL_ERROR "SPLIT argument is missing or wrong!")
  endif()

  list(GET SM_SPLIT 0 string_to_split)
  string(MAKE_C_IDENTIFIER "${string_to_split}" string_to_split)
  string(REGEX MATCHALL "[^_][^|A-Z|_]*" strings_list "${string_to_split}")
  list(GET SM_SPLIT 1 output_list_var)
  set(${output_list_var} "${strings_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_string_manip_split_transform_identifier_upper)
  if(NOT DEFINED SM_SPLIT_TRANSFORM)
    message(FATAL_ERROR "TRANSFORM arguments is missing or need a value!")
  endif()
  if(NOT ${SM_C_IDENTIFIER_UPPER})
    message(FATAL_ERROR "C_IDENTIFIER_UPPER argument is missing!")
  endif()
  
  set(output_formated_word "")
    # Check if the input string is empty to avoid fatal error in ``string_manip(SPLIT ...)``
  if(NOT "${${SM_SPLIT_TRANSFORM}}" STREQUAL "")
    string_manip(SPLIT "${${SM_SPLIT_TRANSFORM}}" words_list)
    foreach(word IN ITEMS ${words_list})
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

  if(NOT DEFINED SM_OUTPUT_VARIABLE)
    set(${SM_SPLIT_TRANSFORM} "${output_formated_word}" PARENT_SCOPE)
  else()
    set(${SM_OUTPUT_VARIABLE} "${output_formated_word}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_string_manip_split_transform_start_case)
  if(NOT DEFINED SM_SPLIT_TRANSFORM)
    message(FATAL_ERROR "TRANSFORM arguments is missing or need a value!")
  endif()
  if(NOT ${SM_START_CASE})
    message(FATAL_ERROR "START_CASE argument is missing!")
  endif()
  
  set(output_formated_word "")
  # Check if the input string is empty to avoid fatal error in ``string_manip(SPLIT ...)``
  if(NOT "${${SM_SPLIT_TRANSFORM}}" STREQUAL "")
    string_manip(SPLIT "${${SM_SPLIT_TRANSFORM}}" words_list)
    foreach(word IN ITEMS ${words_list})
      string(TOLOWER "${word}" formated_word)
      string(SUBSTRING ${formated_word} 0 1 first_letter)
      string(TOUPPER "${first_letter}" first_letter)
      string(REGEX REPLACE "^.(.*)" "${first_letter}\\1" formated_word "${formated_word}")
      string(APPEND output_formated_word "${formated_word}")
      unset(formated_word)
    endforeach()
  endif()

  if(NOT DEFINED SM_OUTPUT_VARIABLE)
    set(${SM_SPLIT_TRANSFORM} "${output_formated_word}" PARENT_SCOPE)
  else()
    set(${SM_OUTPUT_VARIABLE} "${output_formated_word}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_string_manip_strip_interfaces)
  if(NOT DEFINED SM_STRIP_INTERFACES)
    message(FATAL_ERROR "STRIP_INTERFACES argument is missing or need a value!")
  endif()

  set(regex ";?\\$<BUILD_INTERFACE:[^>]+>|;?\\$<INSTALL_INTERFACE:[^>]+>")
  string(REGEX REPLACE "${regex}" "" string_striped "${${SM_STRIP_INTERFACES}}")

  if(NOT DEFINED SM_OUTPUT_VARIABLE)
    set(${SM_STRIP_INTERFACES} "${string_striped}" PARENT_SCOPE)
  else()
    set(${SM_OUTPUT_VARIABLE} "${string_striped}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage
macro(_string_manip_extract_interface)
  if(NOT DEFINED SM_EXTRACT_INTERFACE)
    message(FATAL_ERROR "EXTRACT_INTERFACE arguments is missing or need a value!")
  endif()
  if((NOT ${SM_BUILD})
    AND (NOT ${SM_INSTALL}))
    message(FATAL_ERROR "BUILD|INSTALL arguments is missing!")
  endif()
  if(${SM_BUILD} AND ${SM_INSTALL})
    message(FATAL_ERROR "BUILD|INSTALL cannot be used together!")
  endif()

  set(results_list "")
  if(${SM_BUILD})
    set(opening_marker "$<BUILD_INTERFACE:")
  elseif(${SM_INSTALL})
    set(opening_marker "$<INSTALL_INTERFACE:")
  else()
    message(FATAL_ERROR "Wrong interface type!")
  endif()
  set(closing_marker ">")
  set(accumulator "")
  set(inside_expr off)
  foreach(item IN ITEMS ${${SM_EXTRACT_INTERFACE}})
    # Accumulate until the closing generator expression is found
    if(NOT ${inside_expr} AND ("${item}" MATCHES "^\\${opening_marker}.*"))
      set(accumulator "${item}")
      set(inside_expr on)
    elseif(${inside_expr})
      list(APPEND accumulator "${item}")
    endif()

    if(${inside_expr} AND ("${item}" MATCHES ".*${closing_marker}$"))
      list(LENGTH accumulator len)
      list(JOIN accumulator ";" expr_str)
      # Remove prefix "$<...:" and suffix ">"
      string(REPLACE "${opening_marker}" "" expr_str "${expr_str}")
      string(REPLACE "${closing_marker}" "" expr_str "${expr_str}")
      list(APPEND results_list "${expr_str}")
      unset(accumulator)
      set(inside_expr off)
    endif()
  endforeach()

  list(JOIN results_list ";" string_extracted)
  if(NOT DEFINED SM_OUTPUT_VARIABLE)
    set(${SM_EXTRACT_INTERFACE} "${string_extracted}" PARENT_SCOPE)
  else()
    set(${SM_OUTPUT_VARIABLE} "${string_extracted}" PARENT_SCOPE)
  endif()
endmacro()
