# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

StringManip
-----------
Operations on strings. It requires CMake 3.16 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    string_manip(`SPLIT`_ <string> <output_var>)
    string_manip(`TRANSFORM`_ <string_list_var> START_CASE [OUTPUT_VARIABLE <output_var>])
    string_manip(`TRANSFORM`_ <string_var> START_CASE [OUTPUT_VARIABLE <output_var>])

Usage
^^^^^

.. _SPLIT:
.. code-block:: cmake

  string_manip(SPLIT <string> <output_var>)

Split the string ``<string>`` into a list of strings wherever special char
occurs or a uppercase char follow a lowercase char. This list is returned in 
``<output_var>``. In case where no special char is found, the input string is
returned.

.. _TRANSFORM:
.. code-block:: cmake

  string_manip(TRANSFORM <string_list_var> START_CASE [OUTPUT_VARIABLE <output_var>])

Transform each element of the list of strings ``<string_list_var>`` into start
case, storing the result in-place or in the specified ``<output_var>``.

.. code-block:: cmake

  string_manip(TRANSFORM <string_var> START_CASE [OUTPUT_VARIABLE <output_var>])

Transform the string ``<string_var>`` into start case then store de result in
place or in the specified ``<output_var>``.

#]=======================================================================]
cmake_minimum_required (VERSION 3.16)

#------------------------------------------------------------------------------
# Public function of this module.
function(string_manip)
	set(options START_CASE)
	set(one_value_args TRANSFORM OUTPUT_VARIABLE)
	set(multi_value_args SPLIT)
	cmake_parse_arguments(SM "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	if(DEFINED SM_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SM_UNPARSED_ARGUMENTS}\"")
	endif()

	if(DEFINED SM_SPLIT)
		string_manip_split(SPLIT "${SM_SPLIT}")
	elseif(DEFINED SM_TRANSFORM)
		if(NOT ${SM_START_CASE})
			message(FATAL_ERROR "START_CASE argument is missing")
		endif()

		list(LENGTH ${SM_TRANSFORM} nb_args)
		if(${nb_args} EQUAL 1)
			string_manip_transform_string_var(TRANSFORM ${SM_TRANSFORM} START_CASE OUTPUT_VARIABLE ${SM_OUTPUT_VARIABLE})
		else()
			string_manip_transform_string_list(TRANSFORM ${SM_TRANSFORM} START_CASE OUTPUT_VARIABLE ${SM_OUTPUT_VARIABLE})
		endif()
	else()
		message(FATAL_ERROR "Operation argument is missing")
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(string_manip_split)
	set(options "")
	set(one_value_args "")
	set(multi_value_args SPLIT)
	cmake_parse_arguments(SMS "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED SMS_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SMS_UNPARSED_ARGUMENTS}\"")
	endif()
	list(LENGTH SMS_SPLIT nb_args)
	if(NOT ${nb_args} EQUAL 2)
		message(FATAL_ERROR "SPLIT argument is missing or wrong")
	endif()

	list(GET SMS_SPLIT 0 string_to_split)
	string(REGEX MATCHALL "([A-Za-z][a-z]*)" string_list "${string_to_split}")
	list(GET SMS_SPLIT 1 output_var)
	set(${output_var} "${string_list}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(string_manip_transform_string_list)
	set(options START_CASE)
	set(one_value_args TRANSFORM OUTPUT_VARIABLE)
	set(multi_value_args "")
	cmake_parse_arguments(SMTSL "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED SMTSL_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SMTSL_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED SMTSL_TRANSFORM)
		message(FATAL_ERROR "TRANSFORM argument is missing")
	endif()
	if(NOT ${SMTSL_START_CASE})
		message(FATAL_ERROR "START_CASE argument is missing")
	endif()

	set(formated_word_list "")
	foreach(word IN ITEMS ${${SMTSL_TRANSFORM}})
		string_manip(TRANSFORM word START_CASE OUTPUT_VARIABLE formated_word)
		list(APPEND formated_word_list "${formated_word}")
	endforeach()
	
	if(NOT DEFINED SMTSL_OUTPUT_VARIABLE)
		set(${SMTSL_TRANSFORM} "${formated_word_list}" PARENT_SCOPE)
	else()
		set(${SMTSL_OUTPUT_VARIABLE} "${formated_word_list}" PARENT_SCOPE)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(string_manip_transform_string_var)
	set(options START_CASE)
	set(one_value_args TRANSFORM OUTPUT_VARIABLE)
	set(multi_value_args "")
	cmake_parse_arguments(SMTSV "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})

	if(DEFINED SMTSV_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${SMTSV_UNPARSED_ARGUMENTS}\"")
	endif()
	if(NOT DEFINED SMTSV_TRANSFORM)
		message(FATAL_ERROR "TRANSFORM arguments is missing")
	endif()
	if(NOT ${SMTSV_START_CASE})
		message(FATAL_ERROR "START_CASE argument is missing")
	endif()
	
	set(word_list "")
	set(formated_word "")
	string_manip(SPLIT "${${SMTSV_TRANSFORM}}" word_list)
	list(LENGTH word_list nb_args)
	if(${nb_args} GREATER_EQUAL 2)
		# The split function returned a list of words
		string_manip(TRANSFORM word_list START_CASE)
		list(JOIN word_list "" formated_word)
	else()
		# The split function returned a single word
		string(TOLOWER "${word_list}" formated_word)
		string(SUBSTRING ${formated_word} 0 1 first_letter)
		string(TOUPPER "${first_letter}" first_letter)
		string(REGEX REPLACE "^.(.*)" "${first_letter}\\1" formated_word "${formated_word}")
	endif()

	if(NOT DEFINED SMTSV_OUTPUT_VARIABLE)
		set(${SMTSV_TRANSFORM} "${formated_word}" PARENT_SCOPE)
	else()
		set(${SMTSV_OUTPUT_VARIABLE} "${formated_word}" PARENT_SCOPE)
	endif()
endmacro()