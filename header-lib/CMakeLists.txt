cmake_minimum_required(VERSION 3.28)

########################################################################################################################

project(header_lib LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 23)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/bin)

########################################################################################################################

include(GNUInstallDirs) # provided by CMake

########################################################################################################################

# find Threads package
find_package(Threads REQUIRED)

########################################################################################################################

# define the project path to be used in the code
get_filename_component(PROJECT_PATH "${CMAKE_CURRENT_LIST_DIR}" ABSOLUTE)

########################################################################################################################

# find Google Test package
# it enable the following variables:
#   GTest::gtest                          the gtest library
#   GTest::gtest_main                     the gtest_main library, which is used to link against the main function
#   GTest::gmock                          the gmock library
#   GTest::gmock_main                     the gmock_main library, which is used to link against the main function

# find GTest installation
# looks for GTest cmake config files installed by GTest's cmake installation.
find_package(GTest CONFIG REQUIRED HINTS "/opt/googletest")
message(STATUS "Using GTest: ${GTest_VERSION}")

include(GoogleTest) # provided by CMake

########################################################################################################################

include(./../helpers.cmake)

########################################################################################################################

add_subdirectory(test-library)
