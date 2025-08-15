cmake_minimum_required(VERSION 4.00)

project(algorithm_samples)

# Windows での UTF-8 対応
if(MSVC)
    add_compile_options(/source-charset:utf-8)
endif()

add_library(algorithm_samples_headers INTERFACE)
target_include_directories(algorithm_samples_headers INTERFACE ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(algorithms_runner main.cpp)
target_link_libraries(algorithms_runner PRIVATE algorithm_samples_headers)
target_compile_features(algorithms_runner PUBLIC cxx_std_23)

file(GLOB_RECURSE DEMO_SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/demos/*.cpp")
if(DEMO_SOURCES)
	target_sources(algorithms_runner PRIVATE ${DEMO_SOURCES})
endif()

option(BUILD_TESTS "Build unit tests" ON)
if(BUILD_TESTS)
	enable_testing()
	add_subdirectory(tests)
endif()
