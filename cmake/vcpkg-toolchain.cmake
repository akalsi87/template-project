# import vcpkg toolchain if available

find_program(vcpkg_path vcpkg)

if("vcpkg_path-NOTFOUND" STREQUAL "${vcpkg_path}")
  message("-- INFO: Could not find vcpkg")
  return()
endif()

get_filename_component(vcpkg_dir "${vcpkg_path}" PATH)

if("${VCPKG_TRIPLET}" STREQUAL "")
  if(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set(arch x86)
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set(arch x64)
  else()
    message(FATAL_ERROR "X Cannot determine vcpkg triplet")
  endif()

  set(os_name "${CMAKE_SYSTEM_NAME}")
  string(TOLOWER "${os_name}" os_name)
  if("${os_name}" STREQUAL "darwin")
    set(os_name "osx")
  endif()

  set(VCPKG_TRIPLET "${arch}-${os_name}")
  message("-- VCPKG triplet: ${VCPKG_TRIPLET}")
endif()

include(${vcpkg_dir}/scripts/buildsystems/vcpkg.cmake)
