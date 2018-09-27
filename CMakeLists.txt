# CMakeLists.txt

cmake_minimum_required(VERSION 3.0)

project(<PKG>)

include(cmake/vcpkg-toolchain.cmake)

## Library version
set(ver_maj 0)
set(ver_min 1)
set(ver_patch 0)
set(ver_string ${ver_maj}.${ver_min}.${ver_patch})

## Symbol visibility
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_CXX_VISIBILITY_PRESET hidden)

set(PROJECT_VERSION ${ver_string})

## Project specific messages
macro(msg m)
  message("## [<PKG>] ${m}")
endmacro(msg)

## Setup sources

msg("Source dir: ${PROJECT_SOURCE_DIR}")

file(GLOB_RECURSE export_hdr ${PROJECT_SOURCE_DIR}/export/*.h ${PROJECT_SOURCE_DIR}/*.hpp)

file(GLOB_RECURSE src_files ${PROJECT_SOURCE_DIR}/src/*.c ${PROJECT_SOURCE_DIR}/src/*.cpp)

msg("Export headers:")
foreach(f ${export_hdr})
  string(REPLACE "${PROJECT_SOURCE_DIR}/" "" f "${f}")
  msg("  ${f}")
endforeach()

msg("Source files:")
foreach(f ${src_files})
  string(REPLACE "${PROJECT_SOURCE_DIR}/" "" f "${f}")
  msg("  ${f}")
endforeach()

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
  set_target_properties(<PKG> PROPERTIES VERSION ${ver_string} SOVERSION ${ver_maj})
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
    <PKGUPPER>_VER_STRING=${ver_string})

## Set include directories
target_include_directories(
  <PKG>
  PRIVATE include
  PUBLIC $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/export>
         $<INSTALL_INTERFACE:include>)

## Dependency link
target_link_libraries(<PKG> )

## Setup library config for import
configure_file(
  cmake/<PKG>Config.cmake.in
  ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/<PKG>Config.cmake @ONLY)

export(
  TARGETS <PKG>
  FILE ${PROJECT_BINARY_DIR}/<PKG>Targets.cmake)

export(PACKAGE <PKG>)

## Install configs
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

install(
  FILES ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/<PKG>Config.cmake
  DESTINATION lib/cmake/<PKG>
  COMPONENT dev)

install(
  EXPORT <PKG>Targets
  DESTINATION lib/cmake/<PKG>
  COMPONENT dev)

install(
  FILES ${PROJECT_SOURCE_DIR}/LICENSE
  DESTINATION share/<PKG>
  RENAME LICENSE.<PKG>)

## Tests

include(tests.cmake)

## Packaging (disabled)

# set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_CURRENT_SOURCE_DIR}/LICENSE)
# set(CPACK_PACKAGE_VENDOR "Aaditya Kalsi")
# set(CPACK_PACKAGE_CONTACT "akalsi.dev@gmail.com")
# set(CPACK_STRIP_FILES 1)
# include(CPack)
