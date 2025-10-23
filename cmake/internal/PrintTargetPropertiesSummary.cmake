# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Prints to the console a summary of the properties of the specified target
# ``<target-name>``.
#
# Signature:
#   print_target_properties_summary(<target-name>)
#
# Parameters:
#   target-name: The name of the target whose properties summary is to be printed.
#
# Errors:
#   If the specified target does not exist.
#
# Example:
#   print_target_properties_summary("fruit-salad")
#------------------------------------------------------------------------------
function(print_target_properties_summary target_name)
  if("${target_name}" STREQUAL "")
    message(FATAL_ERROR "target_name argument is missing!")
  endif()
  if(NOT TARGET "${target_name}")
    message(FATAL_ERROR "The target \"${target_name}\" does not exist!")
  endif()

  # Print "Target type"
  get_target_property(type "${target_name}" TYPE)
  message(STATUS "• Bin type: ${type}")

  # Print "Compile features"
  get_target_property(compile_features "${target_name}" COMPILE_FEATURES)
  get_target_property(compile_features_interface "${target_name}" 
    INTERFACE_COMPILE_FEATURES)
  if(NOT "${compile_features_interface}" MATCHES "-NOTFOUND$")
    list(APPEND compile_features "${compile_features_interface}")
  endif()
  list(LENGTH compile_features nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN compile_features ", " printable)
    message(STATUS "• Compile features: ${printable}")
  else()
    message(STATUS "• Compile features: (none)")
  endif()

  # Print "Compile definitions"
  get_target_property(compile_definitions "${target_name}" COMPILE_DEFINITIONS)
  get_target_property(compile_definitions_interface "${target_name}" 
    INTERFACE_COMPILE_DEFINITIONS)
  if(NOT "${compile_definitions_interface}" MATCHES "-NOTFOUND$")
    list(APPEND compile_definitions "${compile_definitions_interface}")
  endif()
  list(LENGTH compile_definitions nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN compile_definitions ", " printable)
    message(STATUS "• Compile definitions: ${printable}")
  else()
    message(STATUS "• Compile definitions: (none)")
  endif()

  # Print "Compile options"
  get_target_property(compile_options "${target_name}" COMPILE_OPTIONS)
  get_target_property(compile_options_interface "${target_name}" 
    INTERFACE_COMPILE_OPTIONS)
  if(NOT "${compile_options_interface}" MATCHES "-NOTFOUND$")
    list(APPEND compile_options "${compile_options_interface}")
  endif()
  list(LENGTH compile_options nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN compile_options ", " printable)
    message(STATUS "• Compile options: ${printable}")
  else()
    message(STATUS "• Compile options: (none)")
  endif()

  # Print "Link options"
  get_target_property(link_options "${target_name}" LINK_OPTIONS)
  get_target_property(link_options_interface "${target_name}" 
    INTERFACE_LINK_OPTIONS)
  if(NOT "${link_options_interface}" MATCHES "-NOTFOUND$")
    list(APPEND link_options "${link_options_interface}")
  endif()
  list(LENGTH link_options nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN link_options ", " printable)
    message(STATUS "• Link options: ${printable}")
  else()
    message(STATUS "• Link options: (none)")
  endif()

  # Print "Sources"
  get_target_property(sources "${target_name}" SOURCES)
  get_target_property(sources_interface "${target_name}" INTERFACE_SOURCES)
  if(NOT "${sources_interface}" MATCHES "-NOTFOUND$")
    list(APPEND sources "${sources_interface}")
  endif()
  list(LENGTH sources nb_vals)
  message(STATUS "• Sources: ${nb_vals} files set (cpp and h)")

  # Print "PCH"
  get_target_property(precompiled_headers "${target_name}" PRECOMPILE_HEADERS)
  get_target_property(precompiled_headers_interface "${target_name}" 
    INTERFACE_PRECOMPILE_HEADERS)
  set(printable_pch_prop "")
  if(NOT "${precompiled_headers}" MATCHES "-NOTFOUND$")
    list(APPEND printable_pch_prop "${precompiled_headers}")
  endif()
  if(NOT "${precompiled_headers_interface}" MATCHES "-NOTFOUND$")
    list(APPEND printable_pch_prop "${precompiled_headers_interface}")
  endif()
  list(LENGTH printable_pch_prop nb_printable_vals)
  if(${nb_printable_vals} GREATER 0)
    list(JOIN printable_pch_prop ", " printable_pch_prop)
    message(STATUS "• PCH file: ${printable_pch_prop}")
  else()
    message(STATUS "• PCH file: (none)")
  endif()

  # Print "Include directories"
  get_target_property(include_directories "${target_name}" INCLUDE_DIRECTORIES)
  get_target_property(include_directories_interface "${target_name}" 
    INTERFACE_INCLUDE_DIRECTORIES)
  if(NOT "${include_directories_interface}" MATCHES "-NOTFOUND$")
    list(APPEND include_directories "${include_directories_interface}")
  endif()
  list(LENGTH include_directories nb_vals)
  if(${nb_vals} GREATER 0)
    list(JOIN include_directories ", " printable)
    message(STATUS "• Include dirs: ${printable}")
  else()
    message(STATUS "• Include dirs: (none)")
  endif()
endfunction()