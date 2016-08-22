cmake_minimum_required(VERSION 3.5)
project(cl_nupic)



find_package(OpenCL REQUIRED)
include_directories(${OpenCL_INCLUDE_DIRS})
link_directories(${OpenCL_LIBRARY})

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -std=c++11")

set(SOURCE_FILES main.cpp)
add_executable(cl_nupic ${SOURCE_FILES})
target_link_libraries (cl_nupic ${OpenCL_LIBRARY})

#via http://stackoverflow.com/a/13429998/782170
add_custom_command(TARGET cl_nupic POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_directory
        ${CMAKE_SOURCE_DIR}/CLCTL $<TARGET_FILE_DIR:cl_nupic>/CLCTL)

add_custom_command(TARGET cl_nupic POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy
        ${CMAKE_SOURCE_DIR}/library_tester.cl $<TARGET_FILE_DIR:cl_nupic>/library_tester.cl)

file(COPY library_tester.cl DESTINATION .)