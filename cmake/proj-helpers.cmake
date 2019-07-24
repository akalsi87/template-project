# proj-helpers.cmake

if (${_proj_helpers_included})
    return()
endif()

set(_proj_helpers_included 1)

set(_targets )
set(_libs )
set(_find_pkg_names )
set(_find_pkg_args )

add_custom_target(
  tests
  COMMAND ${CMAKE_COMMAND} -E echo "ALL TESTS PASSED")

# For Windows, add the required system libraries
if(WIN32)
  include(InstallRequiredSystemLibraries)
endif()

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(CMakeParseArguments)

# Fix RPATH
if (UNIX)
  if(APPLE)
    set(CMAKE_INSTALL_NAME_DIR "@executable_path/../lib")
    set(RPATH_DEF "-DCMAKE_INSTALL_NAME_DIR:STRING=${CMAKE_INSTALL_NAME_DIR}")
  else()
    set(CMAKE_INSTALL_RPATH "\$ORIGIN/../lib")
    set(RPATH_DEF "-DCMAKE_INSTALL_RPATH:STRING=${CMAKE_INSTALL_RPATH}")
  endif()
else()
  set(RPATH_DEF )
endif(UNIX)

## Macros

macro(msg m)
  message("## [${PROJECT_NAME}] ${m}")
endmacro(msg)

## Function

function(lsprn hd)
  set(_args "${ARGV}")
  set(spc "")
  foreach(f ${_args})
    set(_f "${f}")
    string(REPLACE "${PROJECT_SOURCE_DIR}/" "" "_f" "${_f}")
    msg("${spc}${_f}")
    set(spc "    ")
  endforeach()
endfunction()

## Symbol visibility
if (BUILD_SHARED_LIBS)
  set(CMAKE_C_VISIBILITY_PRESET hidden)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
endif()

# cm_add_library(NAME <name>
#                VERSION version
#                [DISABLE_WARNINGS])
function(cm_add_library)
  set(options DISABLE_WARNINGS)
  set(one_value NAME VERSION)
  set(multi_value )
  cmake_parse_arguments(
    ""
    "${options}"
    "${one_value}"
    "${multi_value}"
    ${ARGN})

  string(TOUPPER "${_NAME}" _UNAME)
  string(REPLACE "." ";" ver_list "${_VERSION}")

  file(GLOB_RECURSE
       export_hdr
       ${PROJECT_SOURCE_DIR}/include/${_NAME}/*.h
       ${PROJECT_SOURCE_DIR}/include/${_NAME}/*.hpp
       ${PROJECT_SOURCE_DIR}/include/${_NAME}/*.hxx)

  file(GLOB_RECURSE
       src_files
       ${PROJECT_SOURCE_DIR}/src/${_NAME}/*.c
       ${PROJECT_SOURCE_DIR}/src/${_NAME}/*.cpp
       ${PROJECT_SOURCE_DIR}/src/${_NAME}/*.cxx)

  msg("${_NAME} (library)")
  lsprn("  Export headers:" ${export_hdr})
  lsprn("  Source files:" ${src_files})
  set(_FILES ${src_files} ${export_hdr})

  list(GET ver_list 0 ver_maj)
  list(GET ver_list 1 ver_min)
  list(GET ver_list 2 ver_patch)

  ## Add export header
  set(xprt_hdr ${CMAKE_BINARY_DIR}/include/${_NAME}/exports.h)
  if (NOT EXISTS ${xprt_hdr})
    file(WRITE ${xprt_hdr} "/*! exports.h */

#ifndef ${_UNAME}_EXPORTS_H
#define ${_UNAME}_EXPORTS_H

#if defined(USE_${_UNAME}_STATIC)
#  define ${_UNAME}_API
#elif defined(_WIN32) && !defined(__GCC__)
#  ifdef BUILDING_${_UNAME}_SHARED
#    define ${_UNAME}_API __declspec(dllexport)
#  else
#    define ${_UNAME}_API __declspec(dllimport)
#  endif
#else
#  ifdef BUILDING_${_UNAME}_SHARED
#    define ${_UNAME}_API __attribute__((visibility(\"default\")))
#  else
#    define ${_UNAME}_API
#  endif
#endif

#if defined(__cplusplus)
#  define ${_UNAME}_EXTERN_C extern \"C\"
#else
#  define ${_UNAME}_EXTERN_C extern
#endif

#define ${_UNAME}_C_API ${_UNAME}_EXTERN_C ${_UNAME}_API

#define ${_UNAME}_MAJOR_VER ${ver_maj}
#define ${_UNAME}_MINOR_VER ${ver_min}
#define ${_UNAME}_PATCH_VER ${ver_patch}

#define ${_UNAME}_VERSION_NUMBER \
  (${ver_maj} * 10000 + ${ver_min} * 100 + ${ver_patch})

#endif/*${_UNAME}_EXPORTS_H*/
")
  endif()

  ## Add the library
  add_library(${_NAME} ${_FILES} ${xprt_hdr})

  ## Set compiler definitions
  if (BUILD_SHARED_LIBS)
    set(private_defs BUILDING_${_UNAME}_SHARED)
    set(public_defs )
  else()
    set(private_defs )
    set(public_defs USE_${_UNAME}_STATIC)
  endif()

  if (BUILD_SHARED_LIBS)
    set_target_properties(
      ${_NAME}
      PROPERTIES
        VERSION ${_VERSION}
        SOVERSION ${ver_maj})
  endif()

  target_compile_definitions(
    ${_NAME}
    PUBLIC
      ${public_defs}
    PRIVATE
      ${private_defs}
      ${_UNAME}_VER_MAJ=${ver_maj}
      ${_UNAME}_VER_MIN=${ver_min}
      ${_UNAME}_VER_PATCH=${ver_patch}
      ${_UNAME}_VER_STRING=\"${_VERSION}\")

  if (NOT _DISABLE_WARNINGS)
    if (MSVC)
      target_compile_options(${_NAME} PRIVATE /W3 /WX)
    else()
      target_compile_options(
        ${_NAME} PRIVATE -Wall -Werror -Wno-unused-function)
    endif()
  endif()

  ## Set include directories
  target_include_directories(
    ${_NAME}
    PUBLIC
      $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:include>
    PRIVATE
      $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
      $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/include>)

  ## Install configs
  export(
    TARGETS ${_NAME}
    FILE ${PROJECT_BINARY_DIR}/${_NAME}-targets.cmake)

  install(
    TARGETS ${_NAME}
    EXPORT ${_NAME}-targets
    RUNTIME DESTINATION bin
    LIBRARY DESTINATION lib
    ARCHIVE DESTINATION lib
    INCLUDES DESTINATION include)

  ## Install headers
  install(
    DIRECTORY include/
    DESTINATION include
    FILES_MATCHING REGEX ".*[/\\]${_NAME}[/\\].*\\.h[px]*$")

  install(
    FILES ${xprt_hdr}
    DESTINATION include/${_NAME})

  ## Install targets export
  install(
    EXPORT ${_NAME}-targets
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION lib/cmake/${PROJECT_NAME}
    COMPONENT dev)

  list (FIND _targets ${_NAME} _index)
  if (${_index} EQUAL -1)
    set(_targets "${_targets};${_NAME}" CACHE STRING "Targets" FORCE)
    set(_libs "${_libs};${_NAME}" CACHE STRING "Libs" FORCE)
  endif()
endfunction(cm_add_library)

# cm_add_executable(NAME <name>
#                   VERSION version
#                   [DISABLE_WARNINGS])
function(cm_add_executable)
  set(options DISABLE_WARNINGS)
  set(one_value NAME VERSION)
  set(multi_value )
  cmake_parse_arguments(
    ""
    "${options}"
    "${one_value}"
    "${multi_value}"
    ${ARGN})

  string(TOUPPER "${_NAME}" _UNAME)
  string(REPLACE "." ";" ver_list "${_VERSION}")

  list(GET ver_list 0 ver_maj)
  list(GET ver_list 1 ver_min)
  list(GET ver_list 2 ver_patch)

  file(GLOB_RECURSE
       src_files
       ${PROJECT_SOURCE_DIR}/src/${_NAME}/*.c
       ${PROJECT_SOURCE_DIR}/src/${_NAME}/*.cpp
       ${PROJECT_SOURCE_DIR}/src/${_NAME}/*.cxx)

  msg("${_NAME} (executable)")
  lsprn("  Source files:" ${src_files})
  set(_FILES ${src_files})

  ## Add the executable
  add_executable(${_NAME} ${_FILES})

  target_compile_definitions(
    ${_NAME}
    PRIVATE
      ${_UNAME}_VER_MAJ=${ver_maj}
      ${_UNAME}_VER_MIN=${ver_min}
      ${_UNAME}_VER_PATCH=${ver_patch}
      ${_UNAME}_VER_STRING=\"${_VERSION}\")

  if (NOT _DISABLE_WARNINGS)
    if (MSVC)
      target_compile_options(${_NAME} PRIVATE /W3 /WX)
    else()
      target_compile_options(
        ${_NAME} PRIVATE -Wall -Werror -Wno-unused-function)
    endif()
  endif()

  ## Set include directories
  target_include_directories(
    ${_NAME}
    PUBLIC
      $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
      $<INSTALL_INTERFACE:include>
    PRIVATE
      $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/src>
      $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/include>)

  ## Install configs
  export(
    TARGETS ${_NAME}
    FILE ${PROJECT_BINARY_DIR}/${_NAME}-targets.cmake)

  install(
    TARGETS ${_NAME}
    EXPORT ${_NAME}-targets
    RUNTIME DESTINATION bin)

  ## Install targets export
  install(
    EXPORT ${_NAME}-targets
    NAMESPACE ${PROJECT_NAME}::
    DESTINATION lib/cmake/${PROJECT_NAME}
    COMPONENT dev)

  list (FIND _targets ${_NAME} _index)
  if (${_index} EQUAL -1)
    set(_targets "${_targets};${_NAME}" CACHE STRING "Targets" FORCE)
  endif()
  # force build when building tests
  add_dependencies(tests ${_NAME})
endfunction(cm_add_executable)

# cm_add_tests(NAME <name> [DISABLE_WARNINGS])
function(cm_add_tests)
  set(options DISABLE_WARNINGS)
  set(one_value NAME)
  set(multi_value )
  cmake_parse_arguments(
    ""
    "${options}"
    "${one_value}"
    "${multi_value}"
    ${ARGN})

  set(test_dir ${PROJECT_SOURCE_DIR}/tests)
  file(GLOB_RECURSE
       tst_files
       ${test_dir}/${_NAME}/*.c
       ${test_dir}/${_NAME}/*.cpp
       ${test_dir}/${_NAME}/*.cxx)

  msg("${_NAME} (test)")
  lsprn("  Source files:" ${tst_files})
  set(_FILES ${tst_files})

  add_executable(${_NAME}-lib-tests ${_FILES} ${test_dir}/tmain.cxx)

  target_include_directories(
    ${_NAME}-lib-tests
    PRIVATE
      ${PROJECT_SOURCE_DIR}/include
      ${CMAKE_BINARY_DIR}/include
      ${PROJECT_SOURCE_DIR}/tests)

  if (NOT _DISABLE_WARNINGS)
    if (MSVC)
      target_compile_options(${_NAME}-lib-tests PRIVATE /W3 /WX)
    else()
      target_compile_options(
        ${_NAME}-lib-tests PRIVATE -Wall -Werror -Wno-unused-function)
    endif()
  endif()

  target_link_libraries(${_NAME}-lib-tests ${_NAME})

  if (WIN32)
    add_custom_target(
      ${_NAME}-lib-tests-run
      DEPENDS ${_NAME}-lib-tests
      COMMAND set "PATH=${CMAKE_INSTALL_PREFIX}/bin;%PATH%"
      COMMAND $<TARGET_FILE:${_NAME}-lib-tests>)
  elseif(APPLE)
    add_custom_target(
      ${_NAME}-lib-tests-run
      DEPENDS ${_NAME}-lib-tests
      COMMAND ${CMAKE_COMMAND} -E env DYLD_LIBRARY_PATH=${CMAKE_INSTALL_PREFIX}/lib
              $<TARGET_FILE:${_NAME}-lib-tests>)
  else()
    add_custom_target(
      ${_NAME}-lib-tests-run
      DEPENDS ${_NAME}-lib-tests
      COMMAND $<TARGET_FILE:${_NAME}-lib-tests>)
  endif()

  add_dependencies(tests ${_NAME}-lib-tests-run)
endfunction(cm_add_tests)

# cm_find_pkg(<package> [version] [EXACT] [QUIET] [MODULE]
#             [REQUIRED] [[COMPONENTS] [components...]]
#             [OPTIONAL_COMPONENTS components...]
#             [NO_POLICY_SCOPE])
macro(cm_find_pkg)
  find_package(${ARGN})
  list(APPEND _find_pkg_names ${ARGV0})
  set(_find_pkg_args_${ARGV0} "${ARGN}")
endmacro(cm_find_pkg)

# cm_config_install_exports()
function(cm_config_install_exports)
  set(pkg_cfg ${CMAKE_BINARY_DIR}/pkgcfg.cmake.in)
  set(PROJ ${PROJECT_NAME})
  string(TOUPPER "${PROJ}" PROJUPPER)

  file(WRITE ${pkg_cfg} "# ${PROJ}-config.cmake

# Config file for the ${PROJ} package.
# It defines the following variables:
#  ${PROJUPPER}_INCLUDE_DIRS - include directories for ${PROJ}
#  ${PROJUPPER}_LIBRARIES    - libraries to link against

# Find dependent packages here
")

  foreach(dep ${_find_pkg_names})
    set(fp_args ${_find_pkg_args_${dep}})
    string(REPLACE ";" " " fp_args "${fp_args}")
    file(APPEND ${pkg_cfg} "find_package(${fp_args})\n")
  endforeach()

  file(APPEND ${pkg_cfg} "
if (${PROJUPPER}_CMAKE_DIR)
  # already imported
  return()
endif()

# Compute paths
get_filename_component(${PROJUPPER}_CMAKE_DIR \"\${CMAKE_CURRENT_LIST_FILE}\" PATH)

# Set include dir
set(${PROJUPPER}_INCLUDE_DIRS include)

# Our library dependencies (contains definitions for IMPORTED targets)
")

  foreach(tgt ${_targets})
    file(APPEND ${pkg_cfg}
         "include(\${${PROJUPPER}_CMAKE_DIR}/${tgt}-targets.cmake)\n")
    file(APPEND ${pkg_cfg}
         "message(\"-- Imported target ${PROJ}::${tgt}\")\n")
  endforeach()

  string(REPLACE ";" " " all_libs "${_libs}")
  file(APPEND ${pkg_cfg} "
# These are IMPORTED targets created by ${PROJ}-targets.cmake
set(${PROJUPPER}_LIBRARIES ${all_libs})
")

  configure_file(
    ${pkg_cfg}
    ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${PROJ}-config.cmake @ONLY)

  export(PACKAGE ${PROJ})

  install(
    FILES ${PROJECT_BINARY_DIR}${CMAKE_FILES_DIRECTORY}/${PROJ}-config.cmake
    DESTINATION lib/cmake/${PROJ}
    COMPONENT dev)
endfunction(cm_config_install_exports)
