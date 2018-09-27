# import vcpkg toolchain if available

find_program(vcpkg_path vcpkg)

if("vcpkg_path-NOTFOUND" STREQUAL "${vcpkg_path}")
  message("-- INFO: Could not find vcpkg")
  return()
endif()

get_filename_component(vcpkg_dir "${vcpkg_path}" PATH)

include(${vcpkg_dir}/scripts/buildsystems/vcpkg.cmake)
