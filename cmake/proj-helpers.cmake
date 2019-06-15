# proj-helpers.cmake

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

include(CMakeParseArguments)
include(GNUInstallDirs)

macro(msg m)
  message("## [${PROJECT_NAME}] ${m}")
endmacro(msg)

function(print_list hd)
  set(_args "${ARGV}")
  set(spc "")
  foreach(f ${_args})
    set(_f "${f}")
    string(REPLACE "${PROJECT_SOURCE_DIR}/" "" "_f" "${_f}")
    msg("${spc}${_f}")
    set(spc "  ")
  endforeach()
endfunction()

## Symbol visibility
if (BUILD_SHARED_LIBS)
  set(CMAKE_C_VISIBILITY_PRESET hidden)
  set(CMAKE_CXX_VISIBILITY_PRESET hidden)
endif()

# cm_add_library(NAME <name>
#                FILES source1 [source2 ...]
#                VERSION version)
function(cm_add_library)
  set(options )
  set(one_value NAME VERSION)
  set(multi_value FILES)
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

  ## Add export header
  set(xprt_hdr ${CMAKE_BINARY_DIR}/include/${_NAME}/exports.h)
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

${_UNAME}_C_API const char* ${_UNAME}_VERSION;

#endif/*${_UNAME}_EXPORTS_H*/
")

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
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
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
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/${PROJECT_NAME}
    COMPONENT dev)
endfunction(cm_add_library)

# cm_add_tests(NAME <name>
#              FILES source1 [source2 ...])
function(cm_add_tests)
  set(options )
  set(one_value NAME)
  set(multi_value FILES)
  cmake_parse_arguments(
    ""
    "${options}"
    "${one_value}"
    "${multi_value}"
    ${ARGN})
  add_executable(${_NAME}-lib-tests ${_FILES})

  target_include_directories(
    ${_NAME}-lib-tests
    PRIVATE
      ${PROJECT_SOURCE_DIR}/include
      ${CMAKE_BINARY_DIR}/include
      ${PROJECT_SOURCE_DIR}/tests)

  target_link_libraries(${_NAME}-lib-tests ${_NAME})

  add_custom_target(
    ${_NAME}-lib-tests-run
    DEPENDS ${_NAME}-lib-tests
    COMMAND $<TARGET_FILE:${_NAME}-lib-tests>)

  add_dependencies(tests ${_NAME}-lib-tests-run)
endfunction(cm_add_tests)