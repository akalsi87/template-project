# CMakeLists.txt

cmake_minimum_required(VERSION 3.0)

project(<PKG>)

include(cmake/vcpkg-toolchain.cmake)
include(cmake/proj-helpers.cmake)

## Library version
set(ver_maj 0)
set(ver_min 1)
set(ver_patch 0)
set(ver_string ${ver_maj}.${ver_min}.${ver_patch})

## Symbol visibility
if (BUILD_SHARED_LIBS)
  set(CMAKE_C_VISIBILITY_PRESET hidden)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
endif()

## Set the CMake C++ compiler standard
# set(CMAKE_CXX_STANDARD 11)

set(PROJECT_VERSION ${ver_string})

## Setup sources

configure_file(
  ${PROJECT_SOURCE_DIR}/include/<PKG>/exports.h.in
  ${PROJECT_SOURCE_DIR}/include/<PKG>/exports.h
  @ONLY)

file(GLOB_RECURSE
     export_hdr
     ${PROJECT_SOURCE_DIR}/include/*.h
     ${PROJECT_SOURCE_DIR}/include/*.hpp)

file(GLOB_RECURSE
     src_files
     ${PROJECT_SOURCE_DIR}/src/*.c
     ${PROJECT_SOURCE_DIR}/src/*.cpp)

print_list("Project root:" "${PROJECT_SOURCE_DIR}")
print_list("Export headers:" ${export_hdr})
print_list("Source files:" ${src_files})

## Add library
add_library(<PKG> ${src_files})

## Set compiler definitions
if (BUILD_SHARED_LIBS)
  set(private_defs BUILDING_<PKGUPPER>_SHARED)
  set(public_defs )
else()
  set(private_defs )
  set(public_defs USE_<PKGUPPER>_STATIC)
endif()

if (BUILD_SHARED_LIBS)
  set_target_properties(
    <PKG>
    PROPERTIES
      VERSION ${ver_string}
      SOVERSION ${ver_maj})
endif()

target_compile_definitions(
  <PKG>
  PUBLIC
    ${public_defs}
  PRIVATE
    ${private_defs}
    <PKGUPPER>_VER_MAJ=${ver_maj}
    <PKGUPPER>_VER_MIN=${ver_min}
    <PKGUPPER>_VER_PATCH=${ver_patch}
    <PKGUPPER>_VER_STRING=\"${ver_string}\")

## Set include directories
target_include_directories(
  <PKG>
  PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
         $<INSTALL_INTERFACE:include>)

## Dependency link
target_link_libraries(<PKG> )

## Setup library config for import
configure_file(
  cmake/<PKG>-config.cmake.in
  ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/<PKG>-config.cmake @ONLY)

export(
  TARGETS <PKG>
  FILE ${PROJECT_BINARY_DIR}/<PKG>-targets.cmake)

export(PACKAGE <PKG>)

## Install configs
include(GNUInstallDirs)
install(
  TARGETS <PKG>
  EXPORT <PKG>-targets
  RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
  LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
  ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
  INCLUDES DESTINATION include)

install(
  DIRECTORY include/
  DESTINATION include
  FILES_MATCHING REGEX ".*\\.h[px]*$")

install(
  FILES ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/<PKG>-config.cmake
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/<PKG>
  COMPONENT dev)

install(
  EXPORT <PKG>-targets
  NAMESPACE <PKG>::
  DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/<PKG>
  COMPONENT dev)

install(
  FILES ${PROJECT_SOURCE_DIR}/LICENSE
  DESTINATION share/<PKG>
  RENAME LICENSE.<PKG>)

## Tests

include(tests.cmake)

## Packaging (disabled)

# set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE)
# set(CPACK_PACKAGE_VENDOR "<OWNER>")
# set(CPACK_PACKAGE_CONTACT "<EMAIL>")
# set(CPACK_STRIP_FILES 1)
# include(CPack)
