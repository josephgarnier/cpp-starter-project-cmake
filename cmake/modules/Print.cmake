# Copyright 2019-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Print
-----

Log a message by wrapping the CMake :cmake:command:`message() <cmake:command:message>` command to extend its functionalities .It requires CMake 4.0.1 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  `Print Formated Message`_
    print([<mode>] "message with formated text" <argument>...)

  `Print Path List`_
    print([<mode>] REL_PATHS [<file-path>...] [INDENT])

  `Print String List`_
    print([<mode>] STRINGS [<string>...] [INDENT])

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

  The ``"message with formated text"`` may contain one or more custom conversion
  directives enclosed in ``@`` characters. These directives will be replaced
  using the provided arguments, in the order they are given. Text without
  directives is equivalent to a call to
  :cmake:command:`message() <cmake:command:message>` command.

  Each directive takes the form ``@specifier@``, where ``specifier`` is one of
  the following:

    ``@ap@`` (for "absolute path")
      Converts the corresponding argument into an absolute path to a file or
      directory. The argument may be a relative or absolute path, and may even
      refer to a file or directory that does not exist on disk. An error is
      raised when the argument is empty.

    ``@rp@`` (for "relative path")
      Converts the corresponding argument into a path relative to the value of
      the :variable:`PRINT_BASE_DIR` variable. The argument may be a relative
      or absolute path, and may even refer to a file or directory that does not
      exist on disk. An error is raised when the argument is empty.

    ``@apl@`` (for "absolute path list")
      Converts all the corresponding arguments into a list of absolute paths
      to files or directories. The arguments may be relative or absolute paths,
      and may even refer to files or directories that does not exist on disk.
      Each item is printed separated by a comma: ``item1, item2, ...``. When
      the provided list is empty, the directive is replaced with an empty
      string. This directive should be used last when the message includes
      several directives.

    ``@rpl@`` (for "relative path list")
      Converts all the corresponding argument into a list of path relative to
      the value of the :variable:`PRINT_BASE_DIR` variable. The arguments may
      be relative or absolute paths, and may even refer to files or
      directories that does not exist on disk. Each item is separated by a
      comma: ``item1, item2, ...``. The files or the directories must exist on
      the disk. When the provided list is empty, the directive is replaced with
      an empty string. This directive should be used last when the message
      includes several directives.

    ``@sl@`` (for "string list")
      Converts all the corresponding argument into a list of strings where each
      item is separated by a comma: ``item1, item2, ...`` like with the
      :command:`print(STRINGS)` command. When the provided list is empty, the
      directive is replaced with an empty string. This directive should be
      used last when the message includes several directives.

  For all path arguments, and because of the use of :cmake:command:`cmake_path() <cmake:command:cmake_path>`,
  only syntactic aspects of paths are handled, there is no interaction of any
  kind with any underlying file system. A path may represent a non- existing
  path or even one that is not allowed to exist on the current file system
  or platform.

  An error is raised if a directive has no associated argument, or if a message
  contains an unsupported directive.

  Example usage:

  .. code-block:: cmake

    # Message with ap and rp directives, without mode
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(my_path "src/main.cpp")
    print("Absolute: @ap@, Relative: @rp@" "${my_path}" "${my_path}")
    # Output:
    #   Absolute: /full/path/to/src/main.cpp, Relative: src/main.cpp

    # Message with ap and rp directives, with mode
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(my_path "src/main.cpp")
    print(STATUS "Absolute: @ap@, Relative: @rp@" "${my_path}" "${my_path}")
    # Output:
    #   -- Absolute: /full/path/to/src/main.cpp, Relative: src/main.cpp

    # Message with apl directive and empty argument
    print(STATUS "Absolute paths: @apl@" "")
    # Output:
    #   -- Absolute paths:

    # Message with apl directive and various paths
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(path_list
      "src/main.cpp"
      "src"
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src"
      "fake/directory/file.cpp"
      "fake/directory"
      "${CMAKE_SOURCE_DIR}/fake/directory/file.cpp"
      "${CMAKE_SOURCE_DIR}/fake/directory")
    print(STATUS "Absolute path list: @apl@." ${path_list})
    # Output:
    #   -- Absolute path list: /full/path/to/src/main.cpp, /full/path/to/src, /full/path/to/src/main.cpp, /full/path/to/src, /full/path/to/fake/directory/file.cpp, /full/path/to/fake/directory, /full/path/to/fake/directory/file.cpp, /full/path/to/fake/directory.

    # Message with rpl directive and various paths
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(path_list
      "src/main.cpp"
      "src"
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src"
      "fake/directory/file.cpp"
      "fake/directory"
      "${CMAKE_SOURCE_DIR}/fake/directory/file.cpp"
      "${CMAKE_SOURCE_DIR}/fake/directory")
    print(STATUS "Relative path list: @rpl@." ${path_list})
    # Output:
    #   -- Relative path list: src/main.cpp, src, src/main.cpp, src, fake/directory/file.cpp, fake/directory, fake/directory/file.cpp, fake/directory.

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
      "watermelon"
      "peach")
    print(STATUS "String list: @sl@." ${string_list})
    # Output:
    #   -- String list: apple, banana, orange, pineapple, carrot, strawberry, pineapple, grape, lemon, watermelon.

.. _`Print Path List`:

.. signature::
  print([<mode>] REL_PATHS [<file-path>...] [INDENT])
  :target: REL_PATHS

  Record in the log each file from the specified ``<file-path>`` list after
  converting them to paths relative to the value of the :variable:`PRINT_BASE_DIR`
  variable. Each item is printed separated by a comma: ``item1, item2, ...``.
  This command is inspired by the :cmake:command:`message() <cmake:command:message>`
  command from CMake.

  The ``REL_PATHS`` values may be relative or absolute paths, and may even
  refer to files or directories that does not exist on disk. Because of the use
  of :cmake:command:`cmake_path() <cmake:command:cmake_path>`,
  only syntactic aspects of paths are handled, there is no interaction of any
  kind with any underlying file system. A path may represent a non- existing
  path or even one that is not allowed to exist on the current file system
  or platform.

  The optional ``<mode>`` argument determines the message type and may be any
  of the standard message modes supported by the :cmake:command:`message() <cmake:command:message>` command,
  such as ``STATUS``, ``WARNING``, ``ERROR``, etc.

  If the ``INDENT`` option is specified, the output message is indented by
  two spaces. This affects the indentation level of the printed message using
  the internal :cmake:variable:`CMAKE_MESSAGE_INDENT <cmake:variable:CMAKE_MESSAGE_INDENT>` stack.

  Example usage:

  .. code-block:: cmake

    # Print empty list
    print(STATUS REL_PATHS)
    # Output:
    #   --

    # Print empty list with indentation
    print(STATUS REL_PATHS INDENT)
    # Output:
    #   --

    # Print empty list with quote
    print(STATUS REL_PATHS "")
    # Output:
    #   --

    # Print list with indentation
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
    print(STATUS REL_PATHS ${path_list} INDENT)
    # Output:
    #   --   src/main.cpp, src/source_2.cpp, src/source_3.cpp, src/source_4.cpp, src/source_5.cpp, src/sub_1/source_sub_1.cpp, src/sub_2/source_sub_2.cpp

    # Print list with various paths
    set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")
    set(path_list
      "src/main.cpp"
      "src"
      "${CMAKE_SOURCE_DIR}/src/main.cpp"
      "${CMAKE_SOURCE_DIR}/src"
      "fake/directory/file.cpp"
      "fake/directory"
      "${CMAKE_SOURCE_DIR}/fake/directory/file.cpp"
      "${CMAKE_SOURCE_DIR}/fake/directory")
    print(STATUS REL_PATHS ${path_list})
    # Output:
    #   -- src/main.cpp, src, src/main.cpp, src, fake/directory/file.cpp, fake/directory, fake/directory/file.cpp, fake/directory.

.. _`Print String List`:

.. signature::
  print([<mode>] STRINGS [<string>...] [INDENT])
  :target: STRINGS

  Record in the log each string from the given ``<string>`` list. Each item is
  printed separated by a comma: ``item1, item2, ...``. This command is inspired by the
  :cmake:command:`message() <cmake:command:message>` command from CMake.

  If specified, the optional ``<mode>`` keyword must be one of the standard
  message modes accepted by the :cmake:command:`message() <cmake:command:message>` command, such as ``STATUS``, ``WARNING``, ``ERROR``, etc.

  If the ``INDENT`` option is specified, the output message is indented by
  two spaces. This affects the indentation level of the printed message using
  the internal :cmake:variable:`CMAKE_MESSAGE_INDENT <cmake:variable:CMAKE_MESSAGE_INDENT>` stack.

  Example usage:

  .. code-block:: cmake

    # Print empty list
    print(STATUS STRINGS)
    # Output:
    #   --

    # Print empty list with indentation
    print(STATUS STRINGS INDENT)
    # Output:
    #   --

    # Print empty list with quote
    print(STATUS STRINGS "")
    # Output:
    #   --

    # Print list of strings with indentation
    set(string_list
      "apple" "banana" "orange" "pineapple" "carrot"
      "strawberry" "pineapple" "grape" "lemon" "watermelon" "peach")
    print(STATUS STRINGS ${string_list} INDENT)
    # Output:
    #   --   apple, banana, orange, pineapple, carrot, strawberry, pineapple, grape, lemon, watermelon, peach
#]=======================================================================]

include_guard()

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)

# Global variables
set(PRINT_BASE_DIR "${CMAKE_SOURCE_DIR}")

#------------------------------------------------------------------------------
# Public function of this module
function(print)
  set(options FATAL_ERROR SEND_ERROR WARNING AUTHOR_WARNING DEPRECATION NOTICE STATUS VERBOSE DEBUG TRACE INDENT)
  set(one_value_args "")
  set(multi_value_args REL_PATHS STRINGS)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${one_value_args}" "${multi_value_args}"
  )

  # Parse arguments. The macro `_print_formated_message()` can't use the result
  # of cmake_parse_arguments() because it has to parse each argument.
  set(print_ARGV "")
  set(print_ARGC ${ARGC})
  set(print_ARGC_MAX_INDEX "")
  math(EXPR print_ARGC_MAX_INDEX "${ARGC}-1") # Need this variable because the max index is included in range of foreach.
  foreach(arg_index RANGE ${print_ARGC_MAX_INDEX})
    set(print_ARGV${arg_index} "${ARGV${arg_index}}")
    list(APPEND print_ARGV "${ARGV${arg_index}}")
  endforeach()

  if((DEFINED arg_REL_PATHS) OR ("REL_PATHS" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    set(current_command "print(REL_PATHS)")
    _print_paths_list()
  elseif((DEFINED arg_STRINGS) OR ("STRINGS" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    set(current_command "print(STRINGS)")
    _print_strings_list()
  else()
    set(current_command "print()")
    _print_formated_message()
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_print_formated_message)
  if(${print_ARGC} EQUAL 0)
    message(FATAL_ERROR "${current_command} called with wrong number of arguments!")
  endif()

  # Warning: this macro doesn't have to loop on ARGV or ARGN because the message
  # to print can contain a semi column character ";", which will be interpreted as
  # a new argument, as an item separator. So, it is necessary to use print_ARGV#,
  # print_ARGC_MAX and print_ARGC.
  set(mode "")
  set(message "")
  set(message_arg_list "") # Will be UNDEFINED if no message arg is found
  set(current_argv_index 0)

  # If the first of print_ARGV (index 0) is a mode from "options", set the
  # mode var and increment the current index of print_ARGV
  if("${print_ARGV${current_argv_index}}" IN_LIST options)
    set(mode "${print_ARGV${current_argv_index}}")
    math(EXPR current_argv_index "${current_argv_index}+1")
  endif()

  # Get the message
  if(${current_argv_index} LESS ${print_ARGC})
    set(message "${print_ARGV${current_argv_index}}")
    math(EXPR current_argv_index "${current_argv_index}+1")
  endif()

  # Get the message arg list
  if(${current_argv_index} LESS ${print_ARGC})
    foreach(argv_index RANGE ${current_argv_index} ${print_ARGC_MAX_INDEX})
      list(APPEND message_arg_list "${print_ARGV${current_argv_index}}")
      math(EXPR current_argv_index "${current_argv_index}+1")
    endforeach()
  else()
    unset(message_arg_list)
  endif()

  # If arguments to the message are given, the directives are substituted
  _substitute_directives()

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
  while(true)
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
    if(NOT DEFINED message_arg_list)
      message(FATAL_ERROR
        "${current_command} requires the directive ${directive_to_substitute} to have an associated argument!"
      )
    endif()

    if("${directive_to_substitute}" STREQUAL "@ap@")
      list(POP_FRONT message_arg_list message_arg)
      if(NOT "${message_arg}" STREQUAL "")
        cmake_path(ABSOLUTE_PATH message_arg
          BASE_DIRECTORY "${PRINT_BASE_DIR}"
          NORMALIZE
          OUTPUT_VARIABLE absolute_path
        )
        set(directive_to_substitute "${absolute_path}")
      else()
        message(FATAL_ERROR
          "${current_command} requires the directive ${directive_to_substitute} to have a non-empty string argument!"
        )
      endif()
    elseif("${directive_to_substitute}" STREQUAL "@rp@")
      list(POP_FRONT message_arg_list message_arg)
      if(NOT "${message_arg}" STREQUAL "")
        cmake_path(IS_ABSOLUTE message_arg is_absolute)
        set(relative_path "${message_arg}")
        if(${is_absolute})
          cmake_path(RELATIVE_PATH message_arg
            BASE_DIRECTORY "${PRINT_BASE_DIR}"
            OUTPUT_VARIABLE relative_path
          )
        endif()
        set(directive_to_substitute "${relative_path}")
      else()
        message(FATAL_ERROR
          "${current_command} requires the directive ${directive_to_substitute} to have a non-empty string argument!"
        )
      endif()
    elseif("${directive_to_substitute}" STREQUAL "@apl@")
      list(LENGTH message_arg_list nb_message_args)
      if(${nb_message_args} GREATER 0)
        foreach(file IN ITEMS ${message_arg_list})
          cmake_path(ABSOLUTE_PATH file
            BASE_DIRECTORY "${PRINT_BASE_DIR}"
            NORMALIZE
            OUTPUT_VARIABLE absolute_path
          )
          list(APPEND absolute_path_list "${absolute_path}")
        endforeach()
        list(JOIN absolute_path_list ", " formated_path_list)
        set(directive_to_substitute "${formated_path_list}")
      else()
        set(directive_to_substitute "")
      endif()
      unset(message_arg_list) # This directive consumes all the arguments
    elseif("${directive_to_substitute}" STREQUAL "@rpl@")
      list(LENGTH message_arg_list nb_message_args)
      if(${nb_message_args} GREATER 0)
        foreach(file IN ITEMS ${message_arg_list})
          cmake_path(IS_ABSOLUTE file is_absolute)
          set(relative_path "${file}")
          if(${is_absolute})
            cmake_path(RELATIVE_PATH file
              BASE_DIRECTORY "${PRINT_BASE_DIR}"
              OUTPUT_VARIABLE relative_path
            )
          endif()
          list(APPEND relative_path_list "${relative_path}")
        endforeach()
        list(JOIN relative_path_list ", " formated_path_list)
        set(directive_to_substitute "${formated_path_list}")
      else()
        set(directive_to_substitute "")
      endif()
      unset(message_arg_list) # This directive consumes all the arguments
    elseif("${directive_to_substitute}" STREQUAL "@sl@")
      list(LENGTH message_arg_list nb_message_args)
      if(${nb_message_args} GREATER 0)
        list(JOIN message_arg_list ", " formated_string_list)
        set(directive_to_substitute "${formated_string_list}")
      else()
        set(directive_to_substitute "")
      endif()
      unset(message_arg_list) # This directive consumes all the arguments
    else()
      message(FATAL_ERROR
        "${current_command} does not support the directive ${directive_to_substitute}!"
      )
    endif()
    set(message_cursor "${directive_to_substitute}")

    string(APPEND message_head "${message_cursor}")
    set(message "${message_head}${message_tail}")
  endwhile()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_print_paths_list)
  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${current_command} called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"!")
  endif()
  if((NOT DEFINED arg_REL_PATHS)
      AND (NOT "REL_PATHS" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword REL_PATHS to be provided!")
  endif()

  set(mode "")
  set(message "")

  # If the first of print_ARGV (index 0) is a mode from "options", set the
  # mode var
  if("${print_ARGV0}" IN_LIST options)
    set(mode "${print_ARGV0}")
  endif()

  # Format the paths
  set(relative_path_list "")
  foreach(file IN ITEMS ${arg_REL_PATHS})
    cmake_path(IS_ABSOLUTE file is_absolute)
    set(relative_path "${file}")
    if(${is_absolute})
      cmake_path(RELATIVE_PATH file
        BASE_DIRECTORY "${PRINT_BASE_DIR}"
        OUTPUT_VARIABLE relative_path
      )
    endif()
    list(APPEND relative_path_list "${relative_path}")
  endforeach()
  list(JOIN relative_path_list ", " formated_message)
  set(message "${formated_message}")

  if(${arg_INDENT})
    list(APPEND CMAKE_MESSAGE_INDENT "  ")
  endif()
  if(NOT mode STREQUAL "")
    message(${mode} "${message}")
  else()
    message("${message}")
  endif()
  if(${arg_INDENT})
    list(POP_BACK CMAKE_MESSAGE_INDENT)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_print_strings_list)
  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${current_command} called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"!")
  endif()
  if((NOT DEFINED arg_STRINGS)
      AND (NOT "STRINGS" IN_LIST arg_KEYWORDS_MISSING_VALUES))
    message(FATAL_ERROR "${current_command} requires the keyword STRINGS to be provided!")
  endif()

  set(mode "")
  set(message "")

  # If the first of print_ARGV (index 0) is a mode from "options", set the
  # mode var
  if("${print_ARGV0}" IN_LIST options)
    set(mode "${print_ARGV0}")
  endif()

  # Format the strings
  set(formated_message "")
  foreach(string IN ITEMS ${arg_STRINGS})
    list(APPEND formated_message "${string}")
  endforeach()
  list(JOIN formated_message ", " formated_message)
  set(message "${formated_message}")

  if(${arg_INDENT})
    list(APPEND CMAKE_MESSAGE_INDENT "  ")
  endif()
  if(NOT mode STREQUAL "")
    message(${mode} "${message}")
  else()
    message("${message}")
  endif()
  if(${arg_INDENT})
    list(POP_BACK CMAKE_MESSAGE_INDENT)
  endif()
endmacro()