cmake_minimum_required(VERSION 4.00)

include(FetchContent)

FetchContent_Declare(
  catch
  GIT_REPOSITORY https://github.com/catchorg/Catch2.git
  GIT_TAG v3.5.1
)
FetchContent_MakeAvailable(catch)

file(GLOB_RECURSE TEST_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/*.cpp")
add_executable(algorithms_tests ${TEST_SOURCES})
target_link_libraries(algorithms_tests PRIVATE Catch2::Catch2WithMain algorithm_samples_headers)
target_compile_features(algorithms_tests PUBLIC cxx_std_23)

if(MSVC)
  # Ensure MSVC interprets source files as UTF-8 so Japanese test names compile correctly
  target_compile_options(algorithms_tests PRIVATE "/source-charset:utf-8" "/execution-charset:utf-8")
endif()

enable_testing()
add_test(NAME algorithms_tests COMMAND algorithms_tests)
