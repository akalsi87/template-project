# CMakeLists.txt

# tests

set(test_dir ${PROJECT_SOURCE_DIR}/tests)

file(GLOB src_files ${test_dir}/*.c ${test_dir}/*.cpp)

msg("Test files:")
foreach(f ${src_files})
  string(REPLACE "${PROJECT_SOURCE_DIR}/" "" f "${f}")
  msg("  ${f}")
endforeach()

add_executable(tests.exec ${src_files})

target_include_directories(
  tests.exec
  PRIVATE ${PROJECT_SOURCE_DIR}/export)

target_link_libraries(tests.exec <PKG>)

add_custom_target(
  tests
  DEPENDS tests.exec
  COMMAND $<TARGET_FILE:tests.exec>)
