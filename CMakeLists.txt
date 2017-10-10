# CMakeLists.txt

cmake_minimum_required(VERSION 3.0)

## set up hunter for deps

set(ENV{HUNTER_ROOT} ${CMAKE_CURRENT_SOURCE_DIR}/.hunter)
string(COMPARE EQUAL ${CMAKE_BUILD_TYPE} "Debug" _is_dbg)
if (_is_dbg)
  set(HUNTER_CONFIGURATION_TYPES Debug)
else()
  set(HUNTER_CONFIGURATION_TYPES Release)
endif()
set(HUNTER_BUILD_SHARED_LIBS ${BUILD_SHARED_LIBS})
include(cmake/HunterGate.cmake)
HunterGate(
  URL "https://github.com/ruslo/hunter/archive/v0.19.121.tar.gz"
  SHA1 "4cf307799ec543084dd5bada002feea066e8c203")

## info

macro(msg m)
  message("  == [<PKG>] ==  ${m}")
endmacro(msg)

## set up project

project(<PKG> LANGUAGES C CXX VERSION 0.1.1)

## set up dependencies

include(cmake/deps.cmake)

# eg.
# set(deps libuv::uv)
set(deps )
build_deps("${deps}")

## set to export explicit exports only

set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

## set up RPATHs

if (UNIX)
  if(APPLE)
    set(CMAKE_INSTALL_NAME_DIR "@rpath/")
  else()
    set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib")
  endif()
endif(UNIX)

## set up sources

msg("Got project source dir: ${PROJECT_SOURCE_DIR}")

file(GLOB_RECURSE export_hdr ${PROJECT_SOURCE_DIR}/export/*.h ${PROJECT_SOURCE_DIR}/*.hpp)

file(GLOB_RECURSE src_files ${PROJECT_SOURCE_DIR}/src/*.c ${PROJECT_SOURCE_DIR}/src/*.cpp)

msg("Got export hdrs: ${export_hdr}")
msg("Got src files: ${src_files}")

## set up library

add_library(<PKG> ${src_files} ${export_hdr})

## setup build flags (public and private)

if (BUILD_SHARED_LIBS)
  set(build_flag BUILDING_<PKGUPPER>_SHARED)
  set(pub_build_flag )
else()
  set(build_flag )
  set(pub_build_flag USE_<PKGUPPER>_STATIC)
endif()

if (BUILD_SHARED_LIBS)
  set_target_properties(<PKG> PROPERTIES VERSION ${PROJECT_VERSION} SOVERSION ${PROJECT_VERSION_MAJOR})
endif()

target_compile_definitions(
  <PKG>
  PUBLIC
    ${pub_build_flag}
  PRIVATE
    ${build_flag}
    <PKGUPPER>_VER_MAJ=${PROJECT_VERSION_MAJOR}
    <PKGUPPER>_VER_MIN=${PROJECT_VERSION_MINOR}
    <PKGUPPER>_VER_PATCH=${PROJECT_VERSION_PATCH}
    <PKGUPPER>_VER_STRING=${PROJECT_VERSION})

target_include_directories(
  <PKG>
  PRIVATE include
  PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/export>
         $<INSTALL_INTERFACE:include>)

## link

target_link_libraries(<PKG> PRIVATE ${deps})

#target_compile_features(
#  <PKG>
#  PUBLIC
#  cxx_nullptr
#  cxx_lambdas
#  cxx_auto_type
#  cxx_static_assert)

## configure exports

configure_file(
  cmake/<PKG>Config.cmake.in
  ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/<PKG>Config.cmake @ONLY)

## set up install

export(
  TARGETS <PKG>
  FILE ${PROJECT_BINARY_DIR}/<PKG>Targets.cmake)

export(PACKAGE <PKG>)

## install configs

install(
  TARGETS <PKG>
  EXPORT <PKG>Targets
  ARCHIVE DESTINATION lib
  LIBRARY DESTINATION lib
  RUNTIME DESTINATION bin
  INCLUDES DESTINATION include)

install(
  DIRECTORY export/
  DESTINATION include)

set(cmake_config_dir lib/cmake/<PKG>)

install(
  FILES ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/<PKG>Config.cmake
  DESTINATION ${cmake_config_dir}
  COMPONENT dev)

install(
  EXPORT <PKG>Targets
  DESTINATION ${cmake_config_dir}
  COMPONENT dev)

install(
  FILES ${PROJECT_SOURCE_DIR}/LICENSE
  DESTINATION share/<PKG>
  RENAME LICENSE.<PKG>)

install_deps("${deps}" INCLUDE_HEADERS) # or EXCLUDE_HEADERS

## tests

include(tests.cmake)

## packaging

set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE)
set(CPACK_PACKAGE_VENDOR "Aaditya Kalsi")
set(CPACK_PACKAGE_CONTACT "akalsi.dev@gmail.com")
set(CPACK_STRIP_FILES 1)
include(CPack)
