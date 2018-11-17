# CMakeLists.txt

# tests

set(test_dir ${PROJECT_SOURCE_DIR}/tests)

file(GLOB tst_files ${test_dir}/*.c ${test_dir}/*.cpp)

print_list("Test files:" ${tst_files})

add_executable(tests.exec ${tst_files})

target_include_directories(
  tests.exec
  PRIVATE ${PROJECT_SOURCE_DIR}/include)

target_link_libraries(tests.exec <PKG>)

add_custom_target(
  tests
  DEPENDS tests.exec
  COMMAND $<TARGET_FILE:tests.exec>)
