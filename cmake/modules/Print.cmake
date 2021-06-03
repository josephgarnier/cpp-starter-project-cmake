# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:

Print
---------
Log a message. It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^
.. parsed-literal::

    `print`_([<mode>] "message with format text" <argument>...)
    `print`_([<mode>] PATHS <file_list>... [INDENT])
    `print`_([<mode>] LISTS <string_list>... [INDENT])

Usage
^^^^^
.. _print:
.. code-block:: cmake

  print([<mode>] "message with format text" <argument>...)

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
 @rp@ = The given path will be convert into an relative path to `PRINT_BASE_DIR`

.. _print:
.. code-block:: cmake

  print([<mode>] PATHS <file_list>... [INDENT])

Record each file of the list of ``<file_list>`` in the log after having computed
their relative path to ``PRINT_BASE_DIR``. The message is indented if ``INDENT``
is set. This command is inspired by `message()` from CMake.
The optional ``<mode>`` keyword determines the type of message like in CMake
(see https://cmake.org/cmake/help/latest/command/message.html#general-messages).

.. _print:
.. code-block:: cmake

  print([<mode>] LISTS <string_list>... [INDENT])

Record each string of the list of ``<file_list>`` in the log. The message is indented
if ``INDENT`` is set. This command is inspired by `message()` from CMake.
The optional ``<mode>`` keyword determines the type of message like in CMake
(see https://cmake.org/cmake/help/latest/command/message.html#general-messages).

#]=======================================================================]
include_guard()

cmake_minimum_required (VERSION 3.20)

# Global variables
set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")

#------------------------------------------------------------------------------
# Public function of this module.
function(print)
	set(options FATAL_ERROR SEND_ERROR WARNING AUTHOR_WARNING DEPRECATION NOTICE STATUS VERBOSE DEBUG TRACE INDENT)
	set(one_value_args "")
	set(multi_value_args PATHS LISTS)
	cmake_parse_arguments(PRT "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
	
	# Parse arguments. The macro `_print_message()` can't use the result of
	# cmake_parse_arguments() because it has to parse each argument.
	set(PRT_ARGV "")
	set(PRT_ARGC ${ARGC})
	set(PRT_ARGC_MAX_INDEX "")
	math(EXPR PRT_ARGC_MAX_INDEX "${ARGC}-1") # need this variable because the max index is included in range of foreach.
	foreach(arg_index RANGE ${PRT_ARGC_MAX_INDEX})
		set(PRT_ARGV${arg_index} "${ARGV${arg_index}}")
		list(APPEND PRT_ARGV "${ARGV${arg_index}}")
	endforeach()

	if((DEFINED PRT_PATHS) OR ("PATHS" IN_LIST PRT_KEYWORDS_MISSING_VALUES))
		_print_paths()
	elseif((DEFINED PRT_LISTS) OR ("LISTS" IN_LIST PRT_KEYWORDS_MISSING_VALUES))
		_print_lists()
	else()
		_print_message()
	endif()
endfunction()

#------------------------------------------------------------------------------
# Internal usage.
macro(_print_message)
	# Error when no arguments are given.
	if(${PRT_ARGC} EQUAL 0)
		message(FATAL_ERROR "Incorrect number of arguments!")
	endif()
	
	# Warning: this macro doesn't have to loop on ARGV or ARGN because the message
	# to print can contain a semi column character ";", which will be interpreted as
	# a new argument, as an item separator. So, it is necessary to use PRT_ARGV#, PRT_ARGC_MAX and PRT_ARGC.
	set(mode "")
	set(message "")
	set(message_arg_list "")
	set(current_argv_index 0)

	# If the first of PRT_ARGV (index 0) is a mode from "options", set the
	# mode var and increment the current index of PRT_ARGV.
	if("${PRT_ARGV${current_argv_index}}" IN_LIST options)
		set(mode "${PRT_ARGV${current_argv_index}}")
		math(EXPR current_argv_index "${current_argv_index}+1")
	endif()

	# Get the message.
	if(${current_argv_index} LESS ${PRT_ARGC})
		set(message "${PRT_ARGV${current_argv_index}}")
		math(EXPR current_argv_index "${current_argv_index}+1")
	endif()

	# Get the message arg list.
	if(${current_argv_index} LESS ${PRT_ARGC})
		foreach(argv_index RANGE ${current_argv_index} ${PRT_ARGC_MAX_INDEX})
			list(APPEND message_arg_list "${PRT_ARGV${current_argv_index}}")
			math(EXPR current_argv_index "${current_argv_index}+1")
		endforeach()
	endif()

	# If arguments to the message are given, the directives are substituted.
	list(LENGTH message_arg_list message_arg_list_size)
	if(${message_arg_list_size} GREATER 0)
		_substitute_directives()
	endif()

	message("${mode}" "${message}")
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_substitute_directives)
	set(message_head "")
	set(message_tail "${message}")
	set(message_cursor "")
	while(on)
		# Extract the directive "@...@ "in traveling through the message parsed like
		# a cursor moving on a ribbon (like on a Turing machine).
		# `message_head` is what has already been parsed, `message_cursor` is what is
		# currently parsed () and `message_tail` is what will be parsed.
		string(FIND "${message_tail}" "@" pos_first)
		if(${pos_first} EQUAL -1)
			break()
		endif()
		string(SUBSTRING "${message_tail}" 0 ${pos_first} message_cursor)
		math(EXPR pos_first "${pos_first}+1") # +1 because the first char @ is excluded.
		string(SUBSTRING "${message_tail}" ${pos_first}+1 -1 message_tail)
		string(APPEND message_head "${message_cursor}")
		
		string(FIND "${message_tail}" "@" pos_second)
		if(${pos_second} EQUAL -1)
			break()
		endif()
		string(SUBSTRING "${message_tail}" 0 ${pos_second} message_cursor)
		math(EXPR pos_second "${pos_second}+1") # +1 because the second char @ is excluded.
		string(SUBSTRING "${message_tail}" ${pos_second} -1 message_tail)
		
		
		# Substitute the directive by its value
		set(directive_to_substitute "@${message_cursor}@")
		list(POP_FRONT message_arg_list message_arg)
		if("${message_arg}" STREQUAL "")
			message(FATAL_ERROR "Argument missing for directive \"${directive_to_substitute}\"!")
		endif()
		
		if("${directive_to_substitute}" STREQUAL "@ap@")
			file(REAL_PATH "${message_arg}" message_arg BASE_DIRECTORY "${PRINT_BASE_DIR}")
			set(directive_to_substitute "${message_arg}")
		elseif("${directive_to_substitute}" STREQUAL "@rp@")
			file(RELATIVE_PATH message_arg "${PRINT_BASE_DIR}" "${message_arg}")
			set(directive_to_substitute "${message_arg}")
		else()
			message(FATAL_ERROR "Directive \"${directive_to_substitute}\" is unsupported!")
		endif()
		set(message_cursor "${directive_to_substitute}")
		
		string(APPEND message_head "${message_cursor}")
		set(message "${message_head}${message_tail}")
	endwhile()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_print_paths)
	if(DEFINED PRT_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${PRT_UNPARSED_ARGUMENTS}\"")
	endif()
	if((NOT DEFINED PRT_PATHS)
		AND (NOT "PATHS" IN_LIST PRT_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "PATHS arguments is missing")
	endif()
	
	set(mode "")
	set(message "")
	
	# If the first of PRT_ARGV (index 0) is a mode from "options", set the
	# mode var.
	if("${PRT_ARGV0}" IN_LIST options)
		set(mode "${PRT_ARGV0}")
	endif()
	
	# Format the paths
	set(relative_path_list "")
	foreach(file IN ITEMS ${PRT_PATHS})
		file(RELATIVE_PATH relative_path "${PRINT_BASE_DIR}" "${file}")
		list(APPEND relative_path_list "${relative_path}")
	endforeach()
	list(JOIN relative_path_list " ; " formated_message)
	set(message "${formated_message}")

	if(${PRT_INDENT})
		list(APPEND CMAKE_MESSAGE_INDENT "  ")
	endif()
	message("${mode}" "${message}")
	if(${PRT_INDENT})
		list(POP_BACK CMAKE_MESSAGE_INDENT)
	endif()
endmacro()

#------------------------------------------------------------------------------
# Internal usage.
macro(_print_lists)
	if(DEFINED PRT_UNPARSED_ARGUMENTS)
		message(FATAL_ERROR "Unrecognized arguments: \"${PRT_UNPARSED_ARGUMENTS}\"")
	endif()
	if((NOT DEFINED PRT_LISTS)
		AND (NOT "LISTS" IN_LIST PRT_KEYWORDS_MISSING_VALUES))
		message(FATAL_ERROR "LISTS arguments is missing")
	endif()
	
	set(mode "")
	set(message "")
	
	# If the first of PRT_ARGV (index 0) is a mode from "options", set the
	# mode var.
	if("${PRT_ARGV0}" IN_LIST options)
		set(mode "${PRT_ARGV0}")
	endif()
	
	# Format the lists
	set(formated_message "")
	foreach(string IN ITEMS ${PRT_LISTS})
		list(APPEND formated_message "${string}")
	endforeach()
	list(JOIN formated_message " ; " formated_message)
	set(message "${formated_message}")

	if(${PRT_INDENT})
		list(APPEND CMAKE_MESSAGE_INDENT "  ")
	endif()
	message("${mode}" "${message}")
	if(${PRT_INDENT})
		list(POP_BACK CMAKE_MESSAGE_INDENT)
	endif()
endmacro()