# CMakeLists.txt for install

cmake_minimum_required(VERSION 3.0)

list(APPEND CMAKE_PREFIX_PATH ${CMAKE_INSTALL_PREFIX})
message("-- Build type: ${CMAKE_BUILD_TYPE}")
message("-- Build dir : ${CMAKE_BINARY_DIR}")

find_package(<PKG> CONFIG REQUIRED)

file(GLOB src_files ${TESTS_DIR}/*.c ${TESTS_DIR}/*.cpp)

add_executable(tests_install ${src_files})

target_include_directories(
  tests_install
  PRIVATE ${TESTS_DIR})

target_link_libraries(tests_install <PKG>::<PKG>)

add_custom_target(
  tests_run
  COMMAND env PATH="${CMAKE_INSTALL_PREFIX}/bin" $<TARGET_FILE:tests_install>
  DEPENDS tests_install)
