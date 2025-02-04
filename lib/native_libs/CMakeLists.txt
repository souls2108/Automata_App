cmake_minimum_required(VERSION 3.10)

project(native_libs)

# Define root source directory
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

# === Shared Library 2: Graphviz ===
# Link Graphviz libraries
find_library(gvc-lib gvc)
find_library(cgraph-lib cgraph)
find_library(cdt-lib cdt)

target_link_libraries(
    graphviz_lib
    ${log-lib}
    ${gvc-lib}
    ${cgraph-lib}
    ${cdt-lib}
)

add_library(
    automata_lib
    SHARED
    ${SRC_DIR}/graphviz_lib/graphviz_lib_interface.c
)

# Specify output directory for generated .so files
set_target_properties(graphviz_lib PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY
    "${CMAKE_SOURCE_DIR}/../../jniLibs/${ANDROID_ABI}"
)