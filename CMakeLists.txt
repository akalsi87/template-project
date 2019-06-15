# CMakeLists.txt

cmake_minimum_required(VERSION 3.0)

## Project
project(
  <PKG>
  VERSION 0.1.0
  DESCRIPTION "Project description"
  HOMEPAGE_URL "http://github.com/"
  LANGUAGES C CXX)

include(cmake/vcpkg-toolchain.cmake)
include(cmake/proj-helpers.cmake)

## Set the CMake C++ compiler standard
# set(CMAKE_CXX_STANDARD 11)

add_custom_target(
  tests
  COMMAND ${CMAKE_COMMAND} -E echo "ALL TESTS PASSED")

## Setup sources
file(GLOB_RECURSE
     export_hdr
     ${PROJECT_SOURCE_DIR}/include/*.h
     ${PROJECT_SOURCE_DIR}/include/*.hpp
     ${PROJECT_SOURCE_DIR}/include/*.hxx)

file(GLOB_RECURSE
     src_files
     ${PROJECT_SOURCE_DIR}/src/*.c
     ${PROJECT_SOURCE_DIR}/src/*.cpp
     ${PROJECT_SOURCE_DIR}/src/*.cxx)

print_list("Project root:" "${PROJECT_SOURCE_DIR}")
print_list("Export headers:" ${export_hdr})
print_list("Source files:" ${src_files})

## Add library
cm_add_library(
  NAME <PKG>
  FILES ${src_files} ${export_hdr}
  VERSION 0.1.1)

## Dependency link
target_link_libraries(<PKG> )

## Tests
set(test_dir ${PROJECT_SOURCE_DIR}/tests)

file(GLOB_RECURSE
     tst_files
     ${test_dir}/*.c
     ${test_dir}/*.cpp
     ${test_dir}/*.cxx)

list(FILTER tst_files EXCLUDE REGEX ".*/_build/.*")

print_list("Test files:" ${tst_files})
cm_add_tests(
  NAME <PKG>
  FILES ${tst_files})

## Configure and install library config for import
configure_file(
  cmake/<PKG>-config.cmake.in
  ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/<PKG>-config.cmake @ONLY)

export(PACKAGE <PKG>)

install(
  FILES ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/<PKG>-config.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/<PKG>
  COMPONENT dev)

install(
  FILES ${PROJECT_SOURCE_DIR}/LICENSE
  DESTINATION share/<PKG>
  RENAME LICENSE.<PKG>)
