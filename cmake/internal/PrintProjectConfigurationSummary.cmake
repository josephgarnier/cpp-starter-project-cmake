# Copyright 2025-present, Joseph Garnier
# All rights reserved.
#
# This source code is licensed under the license found in the
# LICENSE file in the root directory of this source tree.

#------------------------------------------------------------------------------
# Prints to the console a summary of the current project configuration.
#
# Signature:
#   print_project_configuration_summary()
#
# Parameters:
#   None
#
# Globals read:
#   PROJECT_NAME
#   CMAKE_CXX_STANDARD
#   CMAKE_BUILD_TYPE
#   CMAKE_GENERATOR
#   <project-name>_PROJECT_DIR
#   <project-name>_BUILD_DIR
#   <project-name>_BIN_DIR
#
# Returns:
#   None
#
# Example:
#   print_project_configuration_summary()
#------------------------------------------------------------------------------
function(print_project_configuration_summary)
  if(NOT ${ARGC} EQUAL 0)
    message(FATAL_ERROR "print_project_configuration_summary() requires exactly 0 arguments, got ${ARGC}!")
  endif()
  message(STATUS "📄 Project '${PROJECT_NAME}' Configuration Summary:")
  list(APPEND CMAKE_MESSAGE_INDENT "   ")
  message(STATUS "• C++ standard        : C++${CMAKE_CXX_STANDARD}")
  message(STATUS "• Build configuration : ${CMAKE_BUILD_TYPE} (${CMAKE_GENERATOR})")
  message(STATUS "• Source-tree         : ${${PROJECT_NAME}_PROJECT_DIR}")
  message(STATUS "• Build-tree          : ${${PROJECT_NAME}_BUILD_DIR}")
  message(STATUS "• Output directory    : ${${PROJECT_NAME}_BIN_DIR}")
  list(POP_BACK CMAKE_MESSAGE_INDENT)
endfunction()