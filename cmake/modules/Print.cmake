# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

Print
---------
Log a message. It requires CMake 3.16 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    `print`_([<mode>] "message with format text" <argument_list>...)

Usage
^^^^^
.. _print:
.. code-block:: cmake

  print([<mode>] "message with format text" <argument_list>...)

Record the specified message text in the log. This command is inspired by
`message()` from CMake and `printf()` from C (see https://linux.die.net/man/3/printf).
The optional ``<mode>`` keyword determines the type of message like in CMake
(see https://cmake.org/cmake/help/latest/command/message.html#general-messages).
The format string is composed of zero or more directives: ordinary characters
(not @), which are copied unchanged to the output stream; and conversion
specifications, each of which results in fetching zero or more subsequent arguments.
Each conversion specification is boxed by the character @, and contain a conversion specifier.
Conversion specifier is one of:

::

 @ap@ = The given path will be convert into an absolute path
 @rp@ = The given path will be convert into an relative path to project

#]=======================================================================]
cmake_minimum_required (VERSION 3.16)

# Global variables
set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")

#------------------------------------------------------------------------------
# Public function of this module.
function(print)
	set(options FATAL_ERROR SEND_ERROR WARNING AUTHOR_WARNING DEPRECATION NOTICE STATUS VERBOSE DEBUG TRACE)
	set(one_value_args "")
	set(multi_value_args "")
	cmake_parse_arguments(PRT "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	set(mode "")
	set(message "")
	set(message_arg_list "")
	
	# When no arguments are given: print("").
	list(LENGTH ARGN arg_list_size)
	if(${arg_list_size} EQUAL 0)
		message("${message}")
		return()
	endif()
	
	# If the first of ARGN is a mode from "option", set the mode var and pop the first of ARGN.
	list(GET ARGN 0 first_arg)
	if("${first_arg}" IN_LIST options)
		set(mode "${first_arg}")
		list(POP_FRONT ARGN)
	endif()
	
	# Get the message and the argument list.
	list(LENGTH ARGN arg_list_size)
	if(${arg_list_size} GREATER 0)
		list(POP_FRONT ARGN message)
		set(message_arg_list "${ARGN}")
	endif()
	
	# If has got directives, they are substituted.
	list(LENGTH message_arg_list message_arg_list_size)
	if(${message_arg_list_size} GREATER 0)
		_substitute_directives()
	endif()
	
	message("${mode}" "${message}")
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(_substitute_directives)
	set(formated_message "")
	set(message_head "")
	set(message_tail "${message}")
	while(on)
		# Extract the directive "@...@ "in traveling through the message managed as a queue.
		string(FIND "${message_tail}" "@" pos_first)
		if(pos_first EQUAL -1)
			break()
		endif()
		string(SUBSTRING "${message_tail}" 0 ${pos_first} message_head)
		math(EXPR pos_first "${pos_first}+1") # +1 because the first char @ is excluded.
		string(SUBSTRING "${message_tail}" ${pos_first}+1 -1 message_tail)
		string(APPEND formated_message "${message_head}")
		
		string(FIND "${message_tail}" "@" pos_second)
		if(pos_second EQUAL -1)
			break()
		endif()
		string(SUBSTRING "${message_tail}" 0 ${pos_second} message_head)
		math(EXPR pos_second "${pos_second}+1") # +1 because the second char @ is excluded.
		string(SUBSTRING "${message_tail}" ${pos_second} -1 message_tail)
		
		
		# Substitute the directive by its value
		set(directive_to_substitute "@${message_head}@")
		list(POP_FRONT message_arg_list message_arg)
		if("${message_arg}" STREQUAL "")
			message(FATAL_ERROR "Argument missing for directive \"${directive_to_substitute}\"!")
		endif()
		
		if("${directive_to_substitute}" STREQUAL "@ap@")
			get_filename_component(message_arg "${message_arg}" ABSOLUTE BASE_DIR "${PRINT_BASE_DIR}")
			set(directive_to_substitute "${message_arg}")
		elseif("${directive_to_substitute}" STREQUAL "@rp@")
			file(RELATIVE_PATH message_arg "${PRINT_BASE_DIR}" "${message_arg}")
			set(directive_to_substitute "${message_arg}")
		else()
			message(FATAL_ERROR "Directive \"${directive_to_substitute}\" is unsupported!")
		endif()
		string(APPEND formated_message "${directive_to_substitute}")
		
		set(message "${formated_message}")
	endwhile()
endmacro()
