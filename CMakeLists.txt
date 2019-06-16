# CMakeLists.txt

cmake_minimum_required(VERSION 3.0)

## Project
project(
  <PKG>
  VERSION 0.1.0
  DESCRIPTION "Project description"
  HOMEPAGE_URL "http://github.com/"
  LANGUAGES C CXX)

## Include helper CMake modules
include(cmake/vcpkg-toolchain.cmake)
include(cmake/proj-helpers.cmake)

## Set the CMake C++ compiler standard
set(CMAKE_CXX_STANDARD 11)

## Find dependencies
cm_find_pkg(Threads REQUIRED)

lsprn("Project root:" "${PROJECT_SOURCE_DIR}")

## Add library
cm_add_library(NAME <PKG> VERSION 0.1.1)
target_link_libraries(<PKG> PUBLIC Threads::Threads)

## Executable
cm_add_executable(NAME <PKG>exec VERSION 1.0.1)
target_link_libraries(<PKG>exec PRIVATE <PKG>)

## Tests
cm_add_tests(NAME <PKG>)

## Installation
cm_config_install_exports()

## License
install(
  FILES ${PROJECT_SOURCE_DIR}/LICENSE
  DESTINATION share/<PKG>
  RENAME LICENSE.<PKG>)
