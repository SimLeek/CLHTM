cmake_minimum_required(VERSION 3.5)
project(cl_nupic)

find_package(OpenCL REQUIRED)
include_directories(${OpenCL_INCLUDE_DIRS})
link_directories(${OpenCL_LIBRARY})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES main.cpp)
add_executable(cl_nupic ${SOURCE_FILES})
target_link_libraries (cl_nupic ${OpenCL_LIBRARY})