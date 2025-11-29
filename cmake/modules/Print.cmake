# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Print
-----

Log a message by wrapping the CMake :cmake:command:`message() <cmake:command:message>` command to extend its functionalities .It requires CMake 3.20 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  `Print Formated Message`_
    print([<mode>] "message with formated text" <argument>...)

  `Print Path List`_
    print([<mode>] PATHS <file-path>... [INDENT])

  `Print String List`_
    print([<mode>] STRINGS <string>... [INDENT])

Module Variables
^^^^^^^^^^^^^^^^

.. variable:: PRINT_BASE_DIR

  Specifies the base directory used to compute relative paths in the :command:`print(normal)` commands. Its default value is :cmake:variable:`CMAKE_SOURCE_DIR <cmake:variable:CMAKE_SOURCE_DIR>`.

Usage
^^^^^

.. _`Print Formated Message`:

.. signature::
  print([<mode>] "message with formated text" <argument>...)
  :target: normal

  Record the specified message text in the log, optionally specifying a message
  mode. This command is inspired by the :cmake:command:`message() <cmake:command:message>` command from CMake and
  the C `printf() <https://linux.die.net/man/3/printf>`__ function.

  If specified, the optional ``<mode>`` keyword must be one of the standard
  message modes accepted by the :cmake:command:`message() <cmake:command:message>` command, such as ``STATUS``, ``WARNING``, ``ERROR``, etc.

  The ``"text to print"`` may contain one or more custom conversion directives
  enclosed in ``@`` characters. These directives will be replaced using the
  provided arguments, in the order they are given. Text without directives
  is equivalent to a call to :cmake:command:`message() <cmake:command:message>` command.

  Each directive takes the form ``@specifier@``, where ``specifier`` is one of
  the following:

    ``@ap@`` (for "absolute path")
      Converts the corresponding argument into an absolute path to an existing
      file or directory.

    ``@rp@`` (for "relative path")
      Converts the corresponding argument into a path relative to the value of
      the :variable:`PRINT_BASE_DIR` variable. The file or the directory must
      exist on the disk.

    ``@apl@`` (for "absolute path list")
      Converts all the corresponding arguments into a list of absolute paths
      to existing files or directories. Each item is separated by a comma:
      ``item1, item2, ...``. This directive should be used last when the
      message includes several directives.

    ``@rpl@`` (for "relative path list")
      Converts all the corresponding argument into a list of path relative to
      the value of the :variable:`PRINT_BASE_DIR` variable. Each item is
      separated by a comma: ``item1, item2, ...``. The files or the directories
      must exist on the disk. This directive should be used last when the
      message includes several directives.

    ``@sl@`` (for "string list")
      Converts all the corresponding argument into a list of strings where each
      item is separated by a comma: ``item1, item2, ...`` like with the
      :command:`print(STRINGS)` command. This directive should be used last
      when the message includes several directives.

  Example usage:

  .. code-block:: cmake

    # Message with ap and rp directives, without mode
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(my_path "src/main.cpp")
    print("Absolute: @ap@, Relative: @rp@" "${my_path}" "${my_path}")
    # output is:
    #   Absolute: /full/path/to/src/main.cpp, Relative: src/main.cpp

    # Message with ap and rp directives, with mode
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(my_path "src/main.cpp")
    print(STATUS "Absolute: @ap@, Relative: @rp@" "${my_path}" "${my_path}")
    # output is:
    #   -- Absolute: /full/path/to/src/main.cpp, Relative: src/main.cpp

    # Message with apl directive
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(path_list
      "src/main.cpp"
      "src/source_1.cpp"
      "src/source_2.cpp"
      "src/source_3.cpp"
      "src/source_4.cpp"
      "src/source_5.cpp"
      "src/sub_1/source_sub_1.cpp"
      "src/sub_2/source_sub_2.cpp")
    print(STATUS "Absolute path list: @apl@." "${path_list}")
    # output is:
    #   -- Absolute path list: /full/path/to/src/main.cpp, /full/path/to/src/source_1.cpp, /full/path/to/src/source_2.cpp, /full/path/to/src/source_3.cpp, /full/path/to/src/source_4.cpp, /full/path/to/src/source_5.cpp, /full/path/to/src/sub_1/source_sub_1.cpp, /full/path/to/src/sub_2/source_sub_2.cpp.

    # Message with rpl directive
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(path_list
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_1.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_2.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_3.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_4.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_5.cpp"
      "${CMAKE_SOURCE_DIR}/src/sub_1/source_sub_1.cpp"
      "${CMAKE_SOURCE_DIR}/src/sub_2/source_sub_2.cpp")
    print(STATUS "Relative path list: @rpl@." "${path_list}")
    # output is:
    #   -- Relative path list: src/main.cpp, src/source_1.cpp, src/source_2.cpp, src/source_3.cpp, src/source_4.cpp, src/source_5.cpp, src/sub_1/source_sub_1.cpp, src/sub_2/source_sub_2.cpp.

    # Message with sl directive
    set(string_list
      "apple"
      "banana"
      "orange"
      "pineapple"
      "carrot"
      "strawberry"
      "pineapple"
      "grape"
      "lemon"
      "watermelon")
    print(STATUS "String list: @sl@." "${string_list}")
    # output is:
    #   -- String list: apple, banana, orange, pineapple, carrot, strawberry, pineapple, grape, lemon, watermelon.

.. _`Print Path List`:

.. signature::
  print([<mode>] PATHS <file-path>... [INDENT])
  :target: PATHS

  Record in the log each file from the specified ``<file-path>`` list after
  converting them to paths relative to the value of the :variable:`PRINT_BASE_DIR`
  variable. Each item is separated by a comma: ``item1, item2, ...``. This
  command is inspired by the :cmake:command:`message() <cmake:command:message>`
  command from CMake.

  The optional ``<mode>`` argument determines the message type and may be any
  of the standard message modes supported by the :cmake:command:`message() <cmake:command:message>` command,
  such as ``STATUS``, ``WARNING``, ``ERROR``, etc.

  If the ``INDENT`` option is specified, the output message is indented by
  two spaces. This affects the indentation level of the printed message using
  the internal :cmake:variable:`CMAKE_MESSAGE_INDENT <cmake:variable:CMAKE_MESSAGE_INDENT>` stack.

  Example usage:

  .. code-block:: cmake

    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(path_list
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_1.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_2.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_3.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_4.cpp"
      "${CMAKE_SOURCE_DIR}/src/source_5.cpp"
      "${CMAKE_SOURCE_DIR}/src/sub_1/source_sub_1.cpp"
      "${CMAKE_SOURCE_DIR}/src/sub_2/source_sub_2.cpp")
    print(STATUS PATHS ${path_list} INDENT)
    # output is:
    #   -- src/main.cpp, src/source_2.cpp, src/source_3.cpp, src/source_4.cpp, src/source_5.cpp, src/sub_1/source_sub_1.cpp, src/sub_2/source_sub_2.cpp

.. _`Print String List`:

.. signature::
  print([<mode>] STRINGS <string>... [INDENT])
  :target: STRINGS

  Record in the log each string from the given ``<string>`` list. Each item is
  separated by a comma: ``item1, item2, ...``. This command is inspired by the
  :cmake:command:`message() <cmake:command:message>` command from CMake.

  If specified, the optional ``<mode>`` keyword must be one of the standard
  message modes accepted by the :cmake:command:`message() <cmake:command:message>` command, such as ``STATUS``, ``WARNING``, ``ERROR``, etc.

  If the ``INDENT`` option is specified, the output message is indented by
  two spaces. This affects the indentation level of the printed message using
  the internal :cmake:variable:`CMAKE_MESSAGE_INDENT <cmake:variable:CMAKE_MESSAGE_INDENT>` stack.

  Example usage:

  .. code-block:: cmake

    set(string_list
        "apple" "banana" "orange"
        "carrot" "strawberry" "pineapple"
        "grape" "lemon" "watermelon")
    print(STATUS STRINGS ${string_list} INDENT)
    # output is:
    #   -- apple, banana, orange, carrot, strawberry, pineapple, grape, lemon, watermelon
#]=======================================================================]

include_guard()

cmake_minimum_required (VERSION 3.20 FATAL_ERROR)

# Global variables
set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")

#------------------------------------------------------------------------------
# Public function of this module
function(print)
  set(options FATAL_ERROR SEND_ERROR WARNING AUTHOR_WARNING DEPRECATION NOTICE STATUS VERBOSE DEBUG TRACE INDENT)
  set(one_value_args "")
  set(multi_value_args PATHS STRINGS)
  cmake_parse_arguments(PRT "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
  
  # Parse arguments. The macro `_print_formated_message()` can't use the result of
  # cmake_parse_arguments() because it has to parse each argument.
  set(PRT_ARGV "")
  set(PRT_ARGC ${ARGC})
  set(PRT_ARGC_MAX_INDEX "")
  math(EXPR PRT_ARGC_MAX_INDEX "${ARGC}-1") # Need this variable because the max index is included in range of foreach.
  foreach(arg_index RANGE ${PRT_ARGC_MAX_INDEX})
    set(PRT_ARGV${arg_index} "${ARGV${arg_index}}")
    list(APPEND PRT_ARGV "${ARGV${arg_index}}")
  endforeach()

  if((DEFINED PRT_PATHS) OR ("PATHS" IN_LIST PRT_KEYWORDS_MISSING_VALUES))
    _print_paths_list()
  elseif((DEFINED PRT_STRINGS) OR ("STRINGS" IN_LIST PRT_KEYWORDS_MISSING_VALUES))
    _print_strings_list()
  else()
    _print_formated_message()
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_print_formated_message)
  # Error when no arguments are given.
  if(${PRT_ARGC} EQUAL 0)
    message(FATAL_ERROR "Incorrect number of arguments!")
  endif()
  
  # Warning: this macro doesn't have to loop on ARGV or ARGN because the message
  # to print can contain a semi column character ";", which will be interpreted as
  # a new argument, as an item separator. So, it is necessary to use PRT_ARGV#, PRT_ARGC_MAX and PRT_ARGC.
  set(mode "")
  set(message "")
  set(message_args_list "")
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
      list(APPEND message_args_list "${PRT_ARGV${current_argv_index}}")
      math(EXPR current_argv_index "${current_argv_index}+1")
    endforeach()
  endif()

  # If arguments to the message are given, the directives are substituted
  list(LENGTH message_args_list message_args_list_size)
  if(${message_args_list_size} GREATER 0)
    _substitute_directives()
  else()
    _remove_directives()
  endif()

  if(NOT mode STREQUAL "")
    message(${mode} "${message}")
  else()
    message("${message}")
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_substitute_directives)
  set(message_head "")
  set(message_tail "${message}")
  set(message_cursor "")
  while(on)
    # Extract the directive "@...@" in traveling through the message parsed like
    # a cursor moving on a ribbon (like on a Turing machine).
    # `message_head` is what has already been parsed, `message_cursor` is what is
    # currently parsed and `message_tail` is what will be parsed.
    string(FIND "${message_tail}" "@" pos_first)
    if(${pos_first} EQUAL -1)
      break()
    endif()
    string(SUBSTRING "${message_tail}" 0 ${pos_first} message_cursor)
    math(EXPR pos_first "${pos_first}+1") # Skip the first @ char
    string(SUBSTRING "${message_tail}" ${pos_first}+1 -1 message_tail)
    string(APPEND message_head "${message_cursor}")

    string(FIND "${message_tail}" "@" pos_second)
    if(${pos_second} EQUAL -1)
      break()
    endif()
    string(SUBSTRING "${message_tail}" 0 ${pos_second} message_cursor)
    math(EXPR pos_second "${pos_second}+1") # Skip the second @ char
    string(SUBSTRING "${message_tail}" ${pos_second} -1 message_tail)

    # Substitute the directive by its value
    set(directive_to_substitute "@${message_cursor}@")
    list(POP_FRONT message_args_list message_arg)
    if("${message_arg}" STREQUAL "")
      message(FATAL_ERROR "Argument missing for directive ${directive_to_substitute}!")
    endif()

    if("${directive_to_substitute}" STREQUAL "@ap@")
      file(REAL_PATH "${message_arg}" absolute_path BASE_DIRECTORY "${PRINT_BASE_DIR}")
      set(directive_to_substitute "${absolute_path}")
    elseif("${directive_to_substitute}" STREQUAL "@rp@")
      file(RELATIVE_PATH relative_path "${PRINT_BASE_DIR}" "${message_arg}")
      set(directive_to_substitute "${relative_path}")
    elseif("${directive_to_substitute}" STREQUAL "@apl@")
      foreach(file IN ITEMS ${message_arg} ${message_args_list})
        file(REAL_PATH "${file}" absolute_path BASE_DIRECTORY "${PRINT_BASE_DIR}")
        list(APPEND absolute_path_list "${absolute_path}")
      endforeach()
      list(JOIN absolute_path_list ", " formated_path_list)
      set(directive_to_substitute "${formated_path_list}")
      set(message_args_list "")
    elseif("${directive_to_substitute}" STREQUAL "@rpl@")
      foreach(file IN ITEMS ${message_arg} ${message_args_list})
        file(RELATIVE_PATH relative_path "${PRINT_BASE_DIR}" "${file}")
        list(APPEND relative_path_list "${relative_path}")
      endforeach()
      list(JOIN relative_path_list ", " formated_path_list)
      set(directive_to_substitute "${formated_path_list}")
      set(message_args_list "")
    elseif("${directive_to_substitute}" STREQUAL "@sl@")
      list(PREPEND message_args_list "${message_arg}")
      list(JOIN message_args_list ", " formated_string_list)
      set(directive_to_substitute "${formated_string_list}")
      set(message_args_list "")
    else()
      message(FATAL_ERROR "Directive ${directive_to_substitute} is unsupported!")
    endif()
    set(message_cursor "${directive_to_substitute}")

    string(APPEND message_head "${message_cursor}")
    set(message "${message_head}${message_tail}")
  endwhile()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_remove_directives)
  string(REGEX REPLACE "@(ap|rp|apl|rpl|sl)@" "" message "${message}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_print_paths_list)
  if(DEFINED PRT_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${PRT_UNPARSED_ARGUMENTS}\"!")
  endif()
  if((NOT DEFINED PRT_PATHS)
      AND (NOT "PATHS" IN_LIST PRT_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "PATHS arguments is missing!")
  endif()
  
  set(mode "")
  set(message "")
  
  # If the first of PRT_ARGV (index 0) is a mode from "options", set the
  # mode var
  if("${PRT_ARGV0}" IN_LIST options)
    set(mode "${PRT_ARGV0}")
  endif()

  # Format the paths
  set(relative_path_list "")
  foreach(file IN ITEMS ${PRT_PATHS})
    file(RELATIVE_PATH relative_path "${PRINT_BASE_DIR}" "${file}")
    list(APPEND relative_path_list "${relative_path}")
  endforeach()
  list(JOIN relative_path_list ", " formated_message)
  set(message "${formated_message}")

  if(${PRT_INDENT})
    list(APPEND CMAKE_MESSAGE_INDENT "  ")
  endif()
  if(NOT mode STREQUAL "")
    message(${mode} "${message}")
  else()
    message("${message}")
  endif()
  if(${PRT_INDENT})
    list(POP_BACK CMAKE_MESSAGE_INDENT)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_print_strings_list)
  if(DEFINED PRT_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "Unrecognized arguments: \"${PRT_UNPARSED_ARGUMENTS}\"!")
  endif()
  if((NOT DEFINED PRT_STRINGS)
      AND (NOT "STRINGS" IN_LIST PRT_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "STRINGS arguments is missing!")
  endif()
  
  set(mode "")
  set(message "")
  
  # If the first of PRT_ARGV (index 0) is a mode from "options", set the
  # mode var
  if("${PRT_ARGV0}" IN_LIST options)
    set(mode "${PRT_ARGV0}")
  endif()
  
  # Format the strings
  set(formated_message "")
  foreach(string IN ITEMS ${PRT_STRINGS})
    list(APPEND formated_message "${string}")
  endforeach()
  list(JOIN formated_message ", " formated_message)
  set(message "${formated_message}")

  if(${PRT_INDENT})
    list(APPEND CMAKE_MESSAGE_INDENT "  ")
  endif()
  if(NOT mode STREQUAL "")
    message(${mode} "${message}")
  else()
    message("${message}")
  endif()
  if(${PRT_INDENT})
    list(POP_BACK CMAKE_MESSAGE_INDENT)
  endif()
endmacro()