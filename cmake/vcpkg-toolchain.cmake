# import vcpkg toolchain if available

find_program(vcpkg_path vcpkg)

if("vcpkg_path-NOTFOUND" STREQUAL "${vcpkg_path}")
  message("-- INFO: Could not find vcpkg")
  return()
endif()

get_filename_component(VCPKG_DIR "${vcpkg_path}" PATH)

include(${vcpkg_path}/scripts/buildsystems/vcpkg.cmake)
