# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#[=======================================================================[.rst:
Map
---

Provides operations to manipulate key/value pairs stored as map. It requires
CMake 4.0.1 or newer.

Synopsis
^^^^^^^^

.. parsed-literal::

  `Reading`_
    map(`SIZE`_ <map-var> <output-var>)
    map(`GET`_ <map-var> <key> <output-var>)
    map(`KEYS`_ <map-var> <output-list-var>)
    map(`VALUES`_ <map-var> <output-list-var>)

  `Search`_
    map(`FIND`_ <map-var> <key> <output-var>)
    map(`SEARCH`_ <map-var> <value> <output-list-var>)
    map(`HAS_KEY`_ <map-var> <key> <output-var>)
    map(`HAS_VALUE`_ <map-var> <value> <output-var>)

  `Modification`_
    map(`SET`_ <map-var> <key> <value>)
    map(`ADD`_ <map-var> <key> <value>)
    map(`REMOVE`_ <map-var> <key>)

Introduction
^^^^^^^^^^^^

A map is represented as a :cmake:command:`list() <cmake:command:list>` of
strings, where each string must contain a single colon (``:``) separating the
key from its value (e.g. ``<key>:<value>``). Malformed entries, such as those
with no colon, empty key, or multiple colons, are ignored in most operations.
A warning is emitted when malformed entries are encountered.

Reading
^^^^^^^

.. signature::
  map(SIZE <map-var> <output-var>)

  Store in ``output-var`` the number of valid key/value pairs in the map
  ``map-var``. Entries with invalid format are ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(SIZE input_map size)
    # size is 4, the two last entries are invalid and ignored, but "four:4:4"
    # is valid

.. signature::
  map(GET <map-var> <key> <output-var>)

  Store in ``output-var`` the value associated with ``key`` in ``map-var``. An
  error is raised if the key is not found or malformed in the list.

  Compared to :command:`map(FIND)`, this command is stricter: it raises an
  error instead of setting ``<key>-NOTFOUND``.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(GET input_map "four" value)
    # value is:
    #   "4:4"
    map(GET input_map "invalid" value)
    # Uncaught exception: Cannot find the key 'invalid'!

.. signature::
  map(KEYS <map-var> <output-list-var>)

  Store in ``output-list-var`` the list of keys found in ``map-var``. Entries
  with invalid format are ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(KEYS input_map map_keys)
    # map_keys is:
    #   one;two;three;four

.. signature::
  map(VALUES <map-var> <output-list-var>)

  Store in ``output-list-var`` the list of values from ``map-var``. Entries
  with invalid format are ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(VALUES input_map map_values)
    # map_values is:
    #   1;2;;4:4

Search
^^^^^^

.. signature::
  map(FIND <map-var> <key> <output-var>)

  Store in ``output-var`` the value associated with ``key`` in ``map-var``.
  If the key is not found or malformed in the list, ``output-var`` is set to
  ``<key>-NOTFOUND``.

  Compared to :command:`map(GET)`, this command is more tolerant: it never
  raises an error, but requires checking the sentinel value.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(FIND input_map "four" value)
    # value is:
    #   "4:4"
    map(FIND input_map "invalid" value)
    # value is:
    #   "invalid-NOTFOUND"

.. signature::
  map(SEARCH <map-var> <value> <output-list-var>)

  Store in ``output-list-var`` the list of keys whose associated value matches
  ``value`` in ``map-var``. Entries with invalid format are ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(SEARCH input_map "2" map_keys)
    # map_keys is:
    #   "two"
    map(SEARCH input_map "" map_keys)
    # map_keys is:
    #   "three"

.. signature::
  map(HAS_KEY <map-var> <key> <output-var>)

  Check if the map ``map-var`` contains the given key ``key``, and store ``true``
  in ``output-var`` if found, ``false`` otherwise. Entries with invalid format
  are ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(HAS_KEY input_map "two" map_has_key)
    # map_has_key is:
    #   true
    map(HAS_KEY input_map "five" map_has_key)
    # map_has_key is:
    #   false
    map(HAS_KEY input_map "invalid" map_has_key)
    # map_has_key is:
    #   false

.. signature::
  map(HAS_VALUE <map-var> <value> <output-var>)

  Check if the map ``map-var`` contains at least one entry with value ``value``
  , and store ``true`` in ``output-var`` if found, ``false`` otherwise. Entries
  with invalid format are ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(HAS_VALUE input_map "2" map_has_value)
    # map_has_value is:
    #   true
    map(HAS_VALUE input_map "5" map_has_value)
    # map_has_value is:
    #   false
    map(HAS_VALUE input_map "missing key" map_has_value)
    # map_has_value is:
    #   false

Modification
^^^^^^^^^^^^

.. signature::
  map(SET <map-var> <key> <value>)

  Set the value associated with ``key`` in ``map-var`` to ``value``. If the key
  exists, it is updated. Otherwise, a new entry is appended. Entries already
  stored in ``map-var`` with invalid format are ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "invalid" ":missing key")
    map(SET input_map "three" "3")
    map(SET input_map "four" "4:4")
    # input_map is:
    #   one:1;two:2;three:3;invalid;:missing key;four:4:4

.. signature::
  map(ADD <map-var> <key> <value>)

  Append a key/value pair to the map ``map-var``, only if ``key`` does not
  already exist. Entries already stored in ``map-var`` with invalid format are
  ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "invalid" ":missing key")
    map(ADD input_map "three" "3")
    # No change, "three" already exists
    map(ADD input_map "four" "4:4")
    # input_map is:
    #   one:1;two:2;three:;invalid;:missing key;four:4:4

.. signature::
  map(REMOVE <map-var> <key>)

  Remove a key/value pair that matches ``key`` in the map ``map-var``. If the
  key does not exist, ``map-var`` is unchanged. Entries already stored in
  ``map-var`` with invalid format are ignored.

  Example usage:

  .. code-block:: cmake

    set(input_map "one:1" "two:2" "three:" "four:4:4" "invalid" ":missing key")
    map(REMOVE input_map "two")
    # input_map is:
    #   one:1;three:;four:4:4;invalid;:missing key
#]=======================================================================]

include_guard()

cmake_minimum_required(VERSION 4.0.1 FATAL_ERROR)

#------------------------------------------------------------------------------
# Public function of this module
function(map)
  set(options "")
  set(one_value_args "")
  set(multi_value_args SIZE GET KEYS VALUES FIND SEARCH HAS_KEY HAS_VALUE SET ADD REMOVE)
  cmake_parse_arguments(PARSE_ARGV 0 arg
    "${options}" "${one_value_args}" "${multi_value_args}"
  )

  set(map_ARGV "${ARGV}") # `cmake_parse_arguments` removing empty arguments, we will work directly with ARGN to retrieve empty values when they are allowed.
  list(POP_FRONT map_ARGV) # Remove the operation name
  if(DEFINED arg_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() called with unrecognized arguments: \"${arg_UNPARSED_ARGUMENTS}\"!")
  endif()
  if(DEFINED arg_SIZE)
    set(current_command "map(SIZE)")
    _map_size()
  elseif(DEFINED arg_GET)
    set(current_command "map(GET)")
    _map_get()
  elseif(DEFINED arg_KEYS)
    set(current_command "map(KEYS)")
    _map_keys()
  elseif(DEFINED arg_VALUES)
    set(current_command "map(VALUES)")
    _map_values()
  elseif(DEFINED arg_FIND)
    set(current_command "map(FIND)")
    _map_find()
  elseif(DEFINED arg_SEARCH)
    set(current_command "map(SEARCH)")
    _map_search()
  elseif(DEFINED arg_HAS_KEY)
    set(current_command "map(HAS_KEY)")
    _map_has_key()
  elseif(DEFINED arg_HAS_VALUE)
    set(current_command "map(HAS_VALUE)")
    _map_has_value()
  elseif(DEFINED arg_SET)
    set(current_command "map(SET)")
    _map_set()
  elseif(DEFINED arg_ADD)
    set(current_command "map(ADD)")
    _map_add()
  elseif(DEFINED arg_REMOVE)
    set(current_command "map(REMOVE)")
    _map_remove()
  else()
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}(<OP> <value> ...) requires an operation and a value to be specified!")
  endif()
endfunction()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_size)
  list(LENGTH arg_SIZE nb_args)
  if(NOT ${nb_args} EQUAL 2)
    message(FATAL_ERROR "${current_command} requires exactly 2 arguments, got ${nb_args}!")
  endif()

  list(GET arg_SIZE 0 map_var)
  list(GET arg_SIZE 1 output_var)

  set(map_content "${${map_var}}")
  set(${output_var} 0)

  foreach(entry IN ITEMS ${map_content})
    _validate_map_key("${entry}" entry_key key_is_valid)
    if(NOT ${key_is_valid})
      continue()
    endif()
    math(EXPR ${output_var} "${${output_var}} + 1")
  endforeach()

  return(PROPAGATE "${output_var}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_get)
  list(LENGTH arg_GET nb_args)
  if(NOT ${nb_args} EQUAL 3)
    message(FATAL_ERROR "${current_command} requires exactly 3 arguments, got ${nb_args}!")
  endif()

  set(arg_FIND "${arg_GET}")
  _map_find()

  if(NOT ${key_is_found})
    message(FATAL_ERROR "${current_command} cannot find the key '${key}'!")
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_keys)
  list(LENGTH arg_KEYS nb_args)
  if(NOT ${nb_args} EQUAL 2)
    message(FATAL_ERROR "${current_command} requires exactly 2 arguments, got ${nb_args}!")
  endif()

  list(GET arg_KEYS 0 map_var)
  list(GET arg_KEYS 1 output_var)

  set(map_content "${${map_var}}")
  set(${output_var} "")

  foreach(entry IN ITEMS ${map_content})
    _validate_map_key("${entry}" entry_key key_is_valid)
    if(NOT ${key_is_valid})
      continue()
    endif()
    list(APPEND ${output_var} "${entry_key}")
  endforeach()

  return(PROPAGATE "${output_var}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_values)
  list(LENGTH arg_VALUES nb_args)
  if(NOT ${nb_args} EQUAL 2)
    message(FATAL_ERROR "${current_command} requires exactly 2 arguments, got ${nb_args}!")
  endif()

  list(GET arg_VALUES 0 map_var)
  list(GET arg_VALUES 1 output_var)

  set(map_content "${${map_var}}")
  set(${output_var} "")

  foreach(entry IN ITEMS ${map_content})
    _validate_map_key("${entry}" entry_key key_is_valid)
    if(NOT ${key_is_valid})
      continue()
    endif()

    string(LENGTH "${entry_key}" key_len)
    math(EXPR value_start "${key_len} + 1") # Skip the colon separator
    string(SUBSTRING "${entry}" ${value_start} -1 entry_value)
    list(APPEND ${output_var} "${entry_value}")
  endforeach()

  return(PROPAGATE "${output_var}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_find)
  list(LENGTH arg_FIND nb_args)
  if(NOT ${nb_args} EQUAL 3)
    message(FATAL_ERROR "${current_command} requires exactly 3 arguments, got ${nb_args}!")
  endif()

  list(GET arg_FIND 0 map_var)
  list(GET arg_FIND 1 key)
  list(GET arg_FIND 2 output_var)
  if("${key}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot get empty key!")
  endif()

  set(map_content "${${map_var}}")
  set(${output_var} "${key}-NOTFOUND")
  set(key_is_found false)

  foreach(entry IN ITEMS ${map_content})
    _validate_map_key("${entry}" entry_key key_is_valid)
    if(NOT ${key_is_valid})
      continue()
    endif()

    string(LENGTH "${entry_key}" key_len)
    math(EXPR value_start "${key_len} + 1") # Skip the colon separator
    string(SUBSTRING "${entry}" ${value_start} -1 entry_value)
    if("${entry_key}" STREQUAL "${key}")
      set(${output_var} "${entry_value}")
      set(key_is_found true)
      break()
    endif()
  endforeach()

  return(PROPAGATE "${output_var}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_search)
  list(LENGTH map_ARGV nb_args) # arg_SEARCH must not be used here, because it can't contain empty arguments due to `cmake_parse_arguments` working
  if(NOT ${nb_args} EQUAL 3)
    message(FATAL_ERROR "${current_command} requires exactly 3 arguments, got ${nb_args}!")
  endif()

  list(GET map_ARGV 0 map_var)
  list(GET map_ARGV 1 value)
  list(GET map_ARGV 2 output_var)
  if("${map_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot search in empty map!")
  endif()
  if("${output_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot store result in empty variable!")
  endif()

  set(map_content "${${map_var}}")
  set(${output_var} "")

  foreach(entry IN ITEMS ${map_content})
    _validate_map_key("${entry}" entry_key key_is_valid)
    if(NOT ${key_is_valid})
      continue()
    endif()

    string(LENGTH "${entry_key}" key_len)
    math(EXPR value_start "${key_len} + 1") # Skip the colon separator
    string(SUBSTRING "${entry}" ${value_start} -1 entry_value)

    list(APPEND result_values "${entry_value}")
    if("${entry_value}" STREQUAL "${value}")
      list(APPEND ${output_var} "${entry_key}")
    endif()
  endforeach()

  return(PROPAGATE "${output_var}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_has_key)
  list(LENGTH map_ARGV nb_args) # arg_HAS_KEY must not be used here, because it can't contain empty arguments due to `cmake_parse_arguments` working
  if(NOT ${nb_args} EQUAL 3)
    message(FATAL_ERROR "${current_command} requires exactly 3 arguments, got ${nb_args}!")
  endif()

  list(GET map_ARGV 0 map_var)
  list(GET map_ARGV 1 key)
  list(GET map_ARGV 2 output_var)
  if("${map_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot search in empty map!")
  endif()
  if("${output_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot store result in empty variable!")
  endif()

  set(map_content "${${map_var}}")
  set(${output_var} false)

  foreach(entry IN ITEMS ${map_content})
    _validate_map_key("${entry}" entry_key key_is_valid)
    if(NOT ${key_is_valid})
      continue()
    endif()

    if("${entry_key}" STREQUAL "${key}")
      set(${output_var} true)
      break()
    endif()
  endforeach()

  return(PROPAGATE "${output_var}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_has_value)
  list(LENGTH map_ARGV nb_args) # arg_HAS_VALUE must not be used here, because it can't contain empty arguments due to `cmake_parse_arguments` working
  if(NOT ${nb_args} EQUAL 3)
    message(FATAL_ERROR "${current_command} requires exactly 3 arguments, got ${nb_args}!")
  endif()

  list(GET map_ARGV 0 map_var)
  list(GET map_ARGV 1 value)
  list(GET map_ARGV 2 output_var)
  if("${map_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot search in empty map!")
  endif()
  if("${output_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot store result in empty variable!")
  endif()

  set(map_content "${${map_var}}")
  set(${output_var} false)

  foreach(entry IN ITEMS ${map_content})
    _validate_map_key("${entry}" entry_key key_is_valid)
    if(NOT ${key_is_valid})
      continue()
    endif()

    string(LENGTH "${entry_key}" key_len)
    math(EXPR value_start "${key_len} + 1") # Skip the colon separator
    string(SUBSTRING "${entry}" ${value_start} -1 entry_value)
    if("${entry_value}" STREQUAL "${value}")
      set(${output_var} true)
      break()
    endif()
  endforeach()

  return(PROPAGATE "${output_var}")
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_set)
  list(LENGTH map_ARGV nb_args) # arg_SET must not be used here, because it can't contain empty arguments due to `cmake_parse_arguments` working
  if(NOT ${nb_args} EQUAL 3)
    message(FATAL_ERROR "${current_command} requires exactly 3 arguments, got ${nb_args}!")
  endif()

  list(GET map_ARGV 0 map_var)
  list(GET map_ARGV 1 new_key)
  list(GET map_ARGV 2 new_value)
  if("${map_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot set in empty map!")
  endif()
  if("${new_key}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot set empty key!")
  endif()

  set(map_content "${${map_var}}")
  set(new_entry "${new_key}:${new_value}")
  set(key_is_found false)

  list(LENGTH map_content map_len)
  if(map_len GREATER 0)
    math(EXPR last_index "${map_len} - 1") # With RANGE, the last index is included
    foreach(i RANGE 0 ${last_index})
      list(GET map_content ${i} entry)
      _validate_map_key("${entry}" entry_key key_is_valid)
      if(NOT ${key_is_valid})
        continue()
      endif()

      if("${entry_key}" STREQUAL "${new_key}")
        list(REMOVE_AT map_content ${i}) # CMake has no SET operator
        list(INSERT map_content ${i} "${new_entry}")
        set(key_is_found true)
        break()
      endif()
    endforeach()
  endif()

  if(NOT ${key_is_found})
    list(APPEND map_content "${new_entry}")
  endif()
  set(${map_var} "${map_content}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_add)
  list(LENGTH map_ARGV nb_args) # arg_ADD must not be used here, because it can't contain empty arguments due to `cmake_parse_arguments` working
  if(NOT ${nb_args} EQUAL 3)
    message(FATAL_ERROR "${current_command} requires exactly 3 arguments, got ${nb_args}!")
  endif()

  list(GET map_ARGV 0 map_var)
  list(GET map_ARGV 1 new_key)
  list(GET map_ARGV 2 new_value)
  if("${map_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot add in empty map!")
  endif()
  if("${new_key}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot add empty key!")
  endif()

  set(map_content "${${map_var}}")
  set(new_entry "${new_key}:${new_value}")
  set(key_is_found false)

  foreach(entry IN ITEMS ${map_content})
    _validate_map_key("${entry}" entry_key key_is_valid)
    if(NOT ${key_is_valid})
      continue()
    endif()

    if("${entry_key}" STREQUAL "${new_key}")
      set(key_is_found true)
      break()
    endif()
  endforeach()

  if(NOT ${key_is_found})
    list(APPEND map_content "${new_entry}")
    set(${map_var} "${map_content}" PARENT_SCOPE)
  endif()
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
macro(_map_remove)
  list(LENGTH map_ARGV nb_args) # arg_REMOVE must not be used here, because it can't contain empty arguments due to `cmake_parse_arguments` working
  if(NOT ${nb_args} EQUAL 2)
    message(FATAL_ERROR "${current_command} requires exactly 2 arguments, got ${nb_args}!")
  endif()

  list(GET map_ARGV 0 map_var)
  list(GET map_ARGV 1 key_to_remove)
  if("${map_var}" STREQUAL "")
    message(FATAL_ERROR "${current_command} cannot remove in empty map!")
  endif()

  set(map_content "${${map_var}}")
  set(entry_to_remove_index -1)

  list(LENGTH map_content map_len)
  if(map_len GREATER 0)
    math(EXPR last_index "${map_len} - 1") # The last index is included in RANGE loop
    foreach(i RANGE 0 ${last_index})
      list(GET map_content ${i} entry)
      _validate_map_key("${entry}" entry_key key_is_valid)
      if(NOT ${key_is_valid})
        continue()
      endif()

      if("${entry_key}" STREQUAL "${key_to_remove}")
        set(entry_to_remove_index ${i})
        break()
      endif()
    endforeach()
  endif()

  if(NOT ${entry_to_remove_index} EQUAL -1)
    list(REMOVE_AT map_content ${entry_to_remove_index})
  endif()
  set(${map_var} "${map_content}" PARENT_SCOPE)
endmacro()

#------------------------------------------------------------------------------
# [Internal use only]
function(_validate_map_key entry output_key_var output_is_valid_var)
  if(NOT ${ARGC} EQUAL 3)
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() requires exactly 3 arguments, got ${ARGC}!")
  endif()
  if("${output_key_var}" STREQUAL "")
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() requires 'output_key_var' argument to be a non-empty string value!")
  endif()
  if("${output_is_valid_var}" STREQUAL "")
    message(FATAL_ERROR "${CMAKE_CURRENT_FUNCTION}() requires 'output_is_valid_var' argument to be a non-empty string value!")
  endif()

  set(entry_key "")
  string(FIND "${entry}" ":" colon_pos)
  if(${colon_pos} EQUAL -1)
    message(WARNING "Skipping malformed map entry '${entry}' (no colon found)")
    set(${output_key_var} "${output_key_var}-NOTFOUND")
    set(${output_is_valid_var} false)
    return(PROPAGATE "${output_key_var}" "${output_is_valid_var}")
  endif()

  string(SUBSTRING "${entry}" 0 ${colon_pos} entry_key)
  if("${entry_key}" STREQUAL "")
    message(WARNING "Skipping malformed map entry '${entry}' (empty key)")
    set(${output_key_var} "${output_key_var}-NOTFOUND")
    set(${output_is_valid_var} false)
    return(PROPAGATE "${output_key_var}" "${output_is_valid_var}")
  endif()

  set(${output_key_var} "${entry_key}")
  set(${output_is_valid_var} true)
  return(PROPAGATE "${output_key_var}" "${output_is_valid_var}")
endfunction()