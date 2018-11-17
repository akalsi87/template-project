# proj-helpers.cmake

set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

macro(msg m)
  message("## [${PROJECT_NAME}] ${m}")
endmacro(msg)

macro(print_list hd rest)
  set(_args "${ARGV}")
  msg("${hd}")
  list(REMOVE_AT _args 0)
  foreach(f ${_args})
    set(_f "${f}")
    string(REPLACE "${PROJECT_SOURCE_DIR}/" "" "_f" "${_f}")
    msg("  ${_f}")
  endforeach()
endmacro()
