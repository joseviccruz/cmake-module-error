########################################################################################################################

# Concatenate two paths using '/' as separator
function(concatenate_paths lhs rhs result)
  if(NOT ${lhs} STREQUAL "" AND NOT ${rhs} STREQUAL "")
    set(${result} "${lhs}/${rhs}" PARENT_SCOPE)
  elseif(NOT ${lhs} STREQUAL "")
    set(${result} "${lhs}" PARENT_SCOPE)
  elseif(NOT ${rhs} STREQUAL "")
    set(${result} "${rhs}" PARENT_SCOPE)
  else()
    set(${result} "" PARENT_SCOPE)
  endif()
endfunction()

########################################################################################################################

enable_testing()
include(GNUInstallDirs) # provided by CMake

# add cpp library
# named parameters:
#  NAME: name of the library
#  HDRS: header files
#  SRCS: source files
#  MODS: module files
#  DEPS: dependencies
#  MACROS: macros
#  CONFIGS: CMake configurable header files
#  COMPILE_OPTIONS: compile options
#  COMPILE_FEATURES: compile features
function(robocin_cpp_library)
  cmake_parse_arguments(
    ARG # prefix of output variables
    "" # list of names of the boolean arguments
    "NAME" # list of names of mono-valued arguments
    "HDRS;SRCS;MODS;DEPS;MACROS;CONFIGS;COMPILE_OPTIONS;COMPILE_FEATURES" # list of names of multi-valued arguments
    ${ARGN} # arguments of the function to parse (ARGN contains all the arguments after the function name)
  )

  # if there isn't at least one module file, then should be at least one header file and one source file
  if(NOT ARG_MODS)
    # if there isn't at least one header file, then the library is not created
    if(NOT ARG_HDRS)
      message(FATAL_ERROR "robocin_cpp_library: no header files given.")
    endif()

    # if there isn't at least one source file, then the library is not created
    if(NOT ARG_SRCS)
      message(FATAL_ERROR "robocin_cpp_library: no source files given.")
    endif()
  endif()

  # if there are CMake configurable files, then they are configured and added to the library
  if(ARG_CONFIGS)
    foreach(CONFIG_FILE ${ARG_CONFIGS})
      get_filename_component(config_last_extension ${CONFIG_FILE} LAST_EXT)

      if(NOT ${config_last_extension} STREQUAL ".in")
        message(FATAL_ERROR
                  "robocin_cpp_library: invalid extension '${config_last_extension}' for configurable file '${CONFIG_FILE}'."
        )
      endif()

      get_filename_component(config_absolute_file ${CONFIG_FILE} ABSOLUTE)
      get_filename_component(config_absolute_path ${config_absolute_file} DIRECTORY)
      file(RELATIVE_PATH config_relative_subdirectory ${CMAKE_CURRENT_SOURCE_DIR} ${config_absolute_path})

      get_filename_component(config_filename ${CONFIG_FILE} NAME_WLE)
      concatenate_paths("${config_relative_subdirectory}" "${config_filename}" config_filename)

      configure_file(${CONFIG_FILE} ${config_filename})
      concatenate_paths("${CMAKE_CURRENT_BINARY_DIR}" "${config_filename}" config_filename_real_path)
      list(APPEND CONFIG_HDRS "${config_filename_real_path}")
    endforeach()
  endif()

  add_library(${ARG_NAME} ${ARG_HDRS} ${ARG_SRCS} ${ARG_MODS} ${CONFIG_HDRS}
  )# add library with given name, headers, sources and modules
  target_link_libraries(${ARG_NAME} PUBLIC ${ARG_DEPS}) # link library with given dependencies

  if(ARG_MODS)
    if(CMAKE_CXX_STANDARD)
      if(CMAKE_CXX_STANDARD GREATER_EQUAL 20)
        target_compile_features(${ARG_NAME} PUBLIC cxx_std_${CMAKE_CXX_STANDARD})
      else()
        message(FATAL_ERROR "robocin_cpp_library: modules are only supported with C++20 or newer.")
      endif()
    else()
      message(WARNING "robocin_cpp_library: CMAKE_CXX_STANDARD is not defined when adding modules to library '${ARG_NAME}'. Using C++20 as default."
      )
      target_compile_features(${ARG_NAME} PUBLIC cxx_std_20)
    endif()

    target_sources(${ARG_NAME} PUBLIC FILE_SET CXX_MODULES FILES ${ARG_MODS})
  endif()

  target_include_directories(${ARG_NAME} PRIVATE ${PROJECT_PATH})
  target_include_directories(${ARG_NAME} PRIVATE ${CMAKE_BINARY_DIR})

  option(TEST_FORCING_MODULE_ERROR "" OFF)
  if(NOT TEST_FORCING_MODULE_ERROR)
    # add include directories of dependencies to the library (required for modules installation)
    foreach(DEP ${ARG_DEPS})
      get_target_property(dep_include_dirs ${DEP} INTERFACE_INCLUDE_DIRECTORIES)
      target_include_directories(${ARG_NAME} PRIVATE ${dep_include_dirs})
    endforeach()
  else()
    message(WARNING "TEST_FORCING_MODULE_ERROR")
  endif()

  target_compile_definitions(${ARG_NAME} PRIVATE PROJECT_PATH="${PROJECT_PATH}")

  if(ARG_MACROS)
    target_compile_definitions(${ARG_NAME} ${ARG_MACROS})
  endif()

  if(ARG_COMPILE_OPTIONS)
    target_compile_options(${ARG_NAME} ${ARG_COMPILE_OPTIONS})
  endif()

  if(ARG_COMPILE_FEATURES)
    target_compile_features(${ARG_NAME} ${ARG_COMPILE_FEATURES})
  endif()

  # installing steps:
  #  - include directories to be used by other projects
  target_include_directories(
    ${ARG_NAME} INTERFACE $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}> $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCLUDEDIR}>
  )
  #  - install header files preserving the directory structure
  foreach(HDR_FILE ${ARG_HDRS})
    get_filename_component(header_absolute_file ${HDR_FILE} ABSOLUTE)
    get_filename_component(header_absolute_path ${header_absolute_file} DIRECTORY)
    file(RELATIVE_PATH header_relative_path ${PROJECT_PATH} ${header_absolute_path})

    concatenate_paths("${CMAKE_INSTALL_INCLUDEDIR}" "${header_relative_path}" header_install_path)
    install(FILES ${HDR_FILE} DESTINATION "${header_install_path}")
  endforeach()
  #  - install module files preserving the directory structure
  foreach(MOD_FILE ${ARG_MODS})
    get_filename_component(module_absolute_file ${MOD_FILE} ABSOLUTE)
    get_filename_component(module_absolute_path ${module_absolute_file} DIRECTORY)
    file(RELATIVE_PATH module_relative_path ${PROJECT_PATH} ${module_absolute_path})

    concatenate_paths("${CMAKE_INSTALL_INCLUDEDIR}" "${module_relative_path}" module_install_path)
    install(FILES ${MOD_FILE} DESTINATION "${module_install_path}")
  endforeach()
  #  - install config files preserving the directory structure
  foreach(CONFIG_HDR ${CONFIG_HDRS})
    file(RELATIVE_PATH config_relative_path ${PROJECT_PATH} ${CMAKE_CURRENT_SOURCE_DIR})

    get_filename_component(config_relative_subdirectory ${CONFIG_HDR} DIRECTORY)
    file(RELATIVE_PATH config_relative_subdirectory ${CMAKE_CURRENT_BINARY_DIR} ${config_relative_subdirectory})

    concatenate_paths("${config_relative_path}" "${config_relative_subdirectory}" config_relative_path)
    concatenate_paths("${CMAKE_INSTALL_INCLUDEDIR}" "${config_relative_path}" config_install_path)

    install(FILES ${CONFIG_HDR} DESTINATION "${config_install_path}")
  endforeach()

  configure_file(${PROJECT_SOURCE_DIR}/../Config.cmake.in ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake @ONLY)
  install(FILES ${PROJECT_BINARY_DIR}/${PROJECT_NAME}Config.cmake
          DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
  )
  #  - install library
  install(TARGETS ${ARG_NAME}
          EXPORT "${PROJECT_NAME}Targets"
          CXX_MODULES_BMI
          DESTINATION modules
          FILE_SET HEADERS
          DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
          FILE_SET CXX_MODULES
          DESTINATION modules
  )
  #  - install CMake configuration files
  install(EXPORT "${PROJECT_NAME}Targets"
          NAMESPACE "${PROJECT_NAME}::"
          FILE "${PROJECT_NAME}Targets.cmake"
          DESTINATION "${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}"
          CXX_MODULES_DIRECTORY cxx_modules
  )

endfunction(robocin_cpp_library)

########################################################################################################################

# Add cpp executable
# Named parameters:
#  NAME: name of the executable
#  HDRS: header files
#  SRCS: source files
#  DEPS: dependencies
function(robocin_cpp_executable)
  cmake_parse_arguments(
    ARG # prefix of output variables
    "" # list of names of the boolean arguments
    "NAME" # list of names of mono-valued arguments
    "HDRS;SRCS;DEPS" # list of names of multi-valued arguments
    ${ARGN} # arguments of the function to parse (ARGN contains all the arguments after the function name)
  )

  # check if at least one source file is given with suffix '_main.cpp'
  if(NOT ARG_SRCS)
    message(FATAL_ERROR "robocin_cpp_executable: no source files given.")
  else()
    set(FILTERED_SRCS ${ARG_SRCS})
    list(FILTER
         FILTERED_SRCS
         INCLUDE
         REGEX
         "_main\\.cpp$"
    )

    if(NOT FILTERED_SRCS)
      message(FATAL_ERROR "robocin_cpp_executable: no source files given with suffix '_main.cpp'.")
    endif()
  endif()

  add_executable(${ARG_NAME} ${ARG_HDRS} ${ARG_SRCS} ${ARG_MODS}
  )# add executable with given name, headers, sources and modules
  target_link_libraries(${ARG_NAME} PRIVATE ${ARG_DEPS}) # link library with given dependencies

  target_include_directories(${ARG_NAME} PRIVATE ${PROJECT_PATH})
  target_include_directories(${ARG_NAME} PRIVATE ${CMAKE_BINARY_DIR})

  target_compile_definitions(${ARG_NAME} PRIVATE PROJECT_PATH="${PROJECT_PATH}")

  target_sources(${ARG_NAME} PUBLIC FILE_SET CXX_MODULES FILES ${ARG_MODS})

endfunction(robocin_cpp_executable)
