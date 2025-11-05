# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Validates a project name. A valid project name must:
#   - Not be empty
#   - Not contain spaces
#
# Signature:
#   validate_project_name(<output-result-var>
#                         <out-err-msg-var>
#                         <error-on-fail>
#                         <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                        ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error
#                        when validation fails. Use "on" to trigger a fatal
#                        error, or "off" to continue execution.
#   input-value        : The project name to validate.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided project name is invalid and ``<error-on-fail>`` is set to
#   "on".
#
# Example:
#   validate_project_name(is_valid err_msg on "MyProject")
#------------------------------------------------------------------------------
function(validate_project_name output_result_var out_err_msg_var error_on_fail input_value)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "validate_project_name() requires exactly 4 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  if("${input_value}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Project name cannot be empty!")
  elseif("${input_value}" MATCHES " ")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Project name '${input_value}' cannot contain spaces!")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    message(FATAL_ERROR "${${out_err_msg_var}}")
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()

#------------------------------------------------------------------------------
# Validates cxx standard version. A valid cxx standard version must:
#   - Not be empty
#   - Be 11, 14, 17, 20, 23 or 26
#
# Signature:
#   validate_cxx_standard_version(<output-result-var>
#                                 <out-err-msg-var>
#                                 <error-on-fail>
#                                 <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                        ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error
#                        when validation fails. Use "on" to trigger a fatal
#                        error, or "off" to continue execution.
#   input-value        : The cxx standard version to validate.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided cxx standard version is invalid and ``<error-on-fail>`` is
#   set to "on".
#
# Example:
#   validate_cxx_standard_version(is_valid err_msg on "${CMAKE_CXX_STANDARD}")
#------------------------------------------------------------------------------
function(validate_cxx_standard_version output_result_var out_err_msg_var error_on_fail input_value)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "validate_cxx_standard_version() requires exactly 4 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  if("${input_value}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "C++ standard version cannot be empty!")
  elseif(NOT "${input_value}" MATCHES "^(11|14|17|20|23|26)$")
    set(${output_result_var} off)
    set(${out_err_msg_var} "C++ standard version '${input_value}' is invalid: it must be 11, 14, 17, 20, 23 or 26!")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    message(FATAL_ERROR "${${out_err_msg_var}}")
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()

#------------------------------------------------------------------------------
# Validates a build type. A valid build type must:
#   - Not be empty
#   - Be "Debug" or "Release"
#
# Signature:
#   validate_build_type(<output-result-var>
#                       <out-err-msg-var>
#                       <error-on-fail>
#                       <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                        ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error
#                        when validation fails. Use "on" to trigger a fatal
#                        error, or "off" to continue execution.
#   input-value        : The build type to validate.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided build type is invalid and ``<error-on-fail>`` is set to
#   "on".
#
# Example:
#   validate_build_type(is_valid err_msg on "${CMAKE_BUILD_TYPE}")
#------------------------------------------------------------------------------
function(validate_build_type output_result_var out_err_msg_var error_on_fail input_value)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "validate_build_type() requires exactly 4 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  if("${input_value}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Build type cannot be empty!")
  elseif(NOT "${input_value}" MATCHES "^(Debug|Release)$")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Build type '${input_value}' is invalid: it must be 'Debug' or 'Release'!")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    message(FATAL_ERROR "${${out_err_msg_var}}")
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()

#------------------------------------------------------------------------------
# Validates a target name. A valid target name must:
#   - Not be empty
#   - Not contain spaces
#
# Signature:
#   validate_target_name(<output-result-var>
#                        <out-err-msg-var>
#                        <error-on-fail>
#                        <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                        ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error
#                        when validation fails. Use "on" to trigger a fatal
#                        error, or "off" to continue execution.
#   input-value        : The target name to validate.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided target name is invalid and ``<error-on-fail>`` is set to
#   "on".
#
# Example:
#   validate_target_name(is_valid err_msg on "MyTarget")
#------------------------------------------------------------------------------
function(validate_target_name output_result_var out_err_msg_var error_on_fail input_value)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "validate_target_name() requires exactly 4 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  if("${input_value}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Target name cannot be empty!")
  elseif("${input_value}" MATCHES " ")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Target name '${input_value}' cannot contain spaces!")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    message(FATAL_ERROR "${${out_err_msg_var}}")
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()

#------------------------------------------------------------------------------
# Validates a main file path. To be valid, a main file path must:
#   - Not be empty
#   - Exist on disk
#
# Signature:
#   validate_main_file_path(<output-result-var>
#                           <out-err-msg-var>
#                           <error-on-fail>
#                           <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                        ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error
#                        when validation fails. Use "on" to trigger a fatal
#                        error, or "off" to continue execution.
#   input-value        : The main file path to validate.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided main file path is invalid and ``<error-on-fail>`` is set to
#   "on".
#
# Example:
#   validate_main_file_path(is_valid err_msg on "${CMAKE_CURRENT_SOURCE_DIR}/main.cpp")
#------------------------------------------------------------------------------
function(validate_main_file_path output_result_var out_err_msg_var error_on_fail input_value)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "validate_main_file_path() requires exactly 4 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  if("${input_value}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Main file path cannot be empty!")
  elseif(NOT EXISTS "${input_value}")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Main file path '${input_value}' does not exist on disk!")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    message(FATAL_ERROR "${${out_err_msg_var}}")
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()

#------------------------------------------------------------------------------
# Validates a PCH file path. A valid PCH file path must:
#   - Not be empty
#   - Exist on disk
#   - Be located in the public headers directory
#
# Signature:
#   validate_pch_file_path(<output-result-var>
#                          <out-err-msg-var>
#                          <error-on-fail>
#                          <public-header-dir>
#                          <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                      ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error
#                        when validation fails. Use "on" to trigger a fatal
#                        error, or "off" to continue execution.
#   public-header-dir  : The public headers directory root path.
#   input-value        : The PCH file path to validate.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided PCH file path is invalid and ``<error-on-fail>`` is set to
#   "on".
#
# Example:
#   validate_pch_file_path(is_valid err_msg on
#                          "${CMAKE_CURRENT_SOURCE_DIR}"
#                          "${CMAKE_CURRENT_SOURCE_DIR}/pch.h")
#------------------------------------------------------------------------------
function(validate_pch_file_path output_result_var out_err_msg_var error_on_fail public_header_dir input_value)
  if(NOT ${ARGC} EQUAL 5)
    message(FATAL_ERROR "validate_pch_file_path() requires exactly 5 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()
  if("${public_header_dir}" STREQUAL "")
    message(FATAL_ERROR "public_header_dir argument is missing!")
  endif()
  if((NOT EXISTS "${public_header_dir}")
    OR (NOT IS_DIRECTORY "${public_header_dir}"))
      message(FATAL_ERROR "Given path: ${public_header_dir} does not refer to an existing path or directory on disk!")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  if("${input_value}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "PCH file path cannot be empty!")
  elseif(NOT EXISTS "${input_value}")
    set(${output_result_var} off)
    set(${out_err_msg_var} "PCH file path '${input_value}' does not exist on disk!")
  elseif(NOT "${input_value}" MATCHES "^${public_header_dir}")
    set(${output_result_var} off)
    set(${out_err_msg_var} "PCH file '@rp@' is not located in the public header directory!" "${input_value}")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    print(FATAL_ERROR ${${out_err_msg_var}}) # don't add quote or Print() will fail
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()

#------------------------------------------------------------------------------
# Validates a dependency name. A valid dependency name must:
#   - Not be empty
#   - Not contain spaces
#
# Signature:
#   validate_dep_name(<output-result-var>
#                     <out-err-msg-var>
#                     <error-on-fail>
#                     <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                        ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error
#                        when validation fails. Use "on" to trigger a fatal
#                        error, or "off" to continue execution.
#   input-value        : The depedency name to validate.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided dependency name is invalid and ``<error-on-fail>`` is set to
#   "on".
#
# Example:
#   validate_dep_name(is_valid err_msg on "DependencyName")
#------------------------------------------------------------------------------
function(validate_dep_name output_result_var out_err_msg_var error_on_fail input_value)
  if(NOT ${ARGC} EQUAL 4)
    message(FATAL_ERROR "validate_dep_name() requires exactly 4 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  if("${input_value}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Dependency name cannot be empty!")
  elseif("${input_value}" MATCHES " ")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Dependency name '${input_value}' cannot contain spaces!")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    message(FATAL_ERROR "${${out_err_msg_var}}")
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()

#------------------------------------------------------------------------------
# Validates the dependency rules file path. A valid dependency rules file
# path must:
#   - Not be empty
#   - Exist on disk
#
# Signature:
#   validate_dep_rules_file_path(<output-result-var>
#                                <out-err-msg-var>
#                                <error-on-fail>
#                                <project-dir>
#                                <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                        ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error
#                        when validation fails. Use "on" to trigger a fatal
#                        error, or "off" to continue execution.
#   project-dir        : The project directory path.
#   input-value        : The dependency rules relative file path to validate.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided dependency rules file path is invalid and ``<error-on-fail>``
#   is set to "on".
#
# Example:
#   validate_dep_rules_file_path(is_valid err_msg on
#                                "${CMAKE_SOURCE_DIR}"
#                                "rules.cmake")
#------------------------------------------------------------------------------
function(validate_dep_rules_file_path output_result_var out_err_msg_var error_on_fail project_dir input_value)
  if(NOT ${ARGC} EQUAL 5)
    message(FATAL_ERROR "validate_dep_rules_file_path() requires exactly 5 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()
  if("${project_dir}" STREQUAL "")
    message(FATAL_ERROR "project_dir argument is missing!")
  endif()
  if((NOT EXISTS "${project_dir}")
    OR (NOT IS_DIRECTORY "${project_dir}"))
      message(FATAL_ERROR "Given path: ${project_dir} does not refer to an existing path or directory on disk!")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  set(absolute_rules_file_path "${project_dir}/${input_value}")
  if("${input_value}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Dependency rules file path cannot be empty!")
  elseif(NOT EXISTS "${absolute_rules_file_path}")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Dependency rules file path '${input_value}' does not exist on disk!")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    print(FATAL_ERROR ${${out_err_msg_var}}) # don't add quote or Print() will fail
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()

#------------------------------------------------------------------------------
# Validates a dependency import status variable. A valid dependency import
# status variable must:
#   - Be defined
#   - Not be empty
#   - Be a boolean with value of '1' (found) or '0' (not found)
#
# Signature:
#   validate_dep_import_status(<output-result-var>
#                              <out-err-msg-var>
#                              <error-on-fail>
#                              <input-value>)
#
# Parameters:
#   output-result-var  : The variable in which to store the validation result
#                        ("on" or "off").
#   out-err-msg-var    : The variable in which to store the error message, if
#                        any.
#   error-on-fail      : Controls whether the function raises a fatal error when
#                        validation fails. Use "on" to trigger a fatal error, or
#                        "off" to continue execution.
#   input-var          : The dependency import status variable to validate.
#   context            : The file path where the dependency import status
#                        variable is defined.
#
# Returns:
#   output-result-var  : The validation result ("on" or "off").
#   out-err-msg-var    : The associated error message, if validation failed.
#
# Errors:
#   If the provided dependency import status variable is invalid and
#   ``<error-on-fail>`` is set to "on".
#
# Example:
#   validate_dep_import_status(is_valid err_msg on "${spdlog_FOUND}")
#------------------------------------------------------------------------------
function(validate_dep_import_status output_result_var out_err_msg_var error_on_fail input_var context)
  if(NOT ${ARGC} EQUAL 5)
    message(FATAL_ERROR "validate_dep_import_status() requires exactly 5 arguments, got ${ARGC}!")
  endif()
  if("${output_result_var}" STREQUAL "")
    message(FATAL_ERROR "output_result_var argument is missing!")
  endif()
  if("${out_err_msg_var}" STREQUAL "")
    message(FATAL_ERROR "out_err_msg_var argument is missing!")
  endif()
  if(NOT "${error_on_fail}" MATCHES "^(on|off)$")
    message(FATAL_ERROR "error_on_fail must be 'on' or 'off'")
  endif()

  set(${output_result_var} on)
  set(${out_err_msg_var} "")

  # Check validity
  if(NOT DEFINED "${input_var}")
    set(${output_result_var} off)
    set(${out_err_msg_var} "The dependency import status variable '${input_var}' is undefined in ${context}. It must be '1' (found) or '0' (not found)!")
  elseif("${${input_var}}" STREQUAL "")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Dependency import status variable '${input_var}' in ${context} is not a boolean value!")
  elseif(NOT "${${input_var}}" MATCHES "^(1|0)$")
    set(${output_result_var} off)
    set(${out_err_msg_var} "Dependency import status variable '${input_var}' with value '${${input_var}}' in ${context} is not a boolean with value '1' (found) or '0' (not found)!")
  endif()

  if(NOT ${output_result_var} AND ${error_on_fail})
    print(FATAL_ERROR ${${out_err_msg_var}}) # don't add quote or Print() will fail
  endif()

  return(PROPAGATE "${output_result_var}" "${out_err_msg_var}")
endfunction()