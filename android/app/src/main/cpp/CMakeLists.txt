cmake_minimum_required(VERSION 3.10)

project(native_libs)

# XXX: remove this line
set(SRC_DIR ${CMAKE_SOURCE_DIR}/../cpp)

# Find necessary system libraries
find_library(log-lib log)

# === Shared Library 1: Automata ===
add_library(
    automata_lib
    SHARED
    ${SRC_DIR}/automata_lib/automata_lib_interface.cpp
)

target_link_libraries(
    automata_lib
    ${log-lib}
)

set_target_properties(automata_lib PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY
    "${CMAKE_SOURCE_DIR}/../../jniLibs/${ANDROID_ABI}"
)
