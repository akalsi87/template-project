# CMakeLists.txt

# tests

set(test_dir ${PROJECT_SOURCE_DIR}/tests)

file(GLOB_RECURSE tst_files ${test_dir}/*.c ${test_dir}/*.cpp)
list(FILTER tst_files EXCLUDE REGEX ".*/_build/.*")

print_list("Test files:" ${tst_files})

add_executable(tests.exec ${tst_files})

target_include_directories(
  tests.exec
  PRIVATE ${PROJECT_SOURCE_DIR}/include ${test_dir})

target_link_libraries(tests.exec <PKG>)

add_custom_target(
  tests
  DEPENDS tests.exec
  COMMAND $<TARGET_FILE:tests.exec>)
