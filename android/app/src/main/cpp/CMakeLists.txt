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

# === Shared Library 2: Graphviz ===
# # Link Graphviz libraries
# find_package(PkgConfig REQUIRED)
# # pkg_check_modules(GRAPHVIZ REQUIRED gvc cgraph cdt)

include_directories(
    /usr/local/include
    /usr/local/include/graphviz
)


# link_directories(/usr/local/lib)

add_library(
    graphviz_lib
    SHARED
    ${SRC_DIR}/graphviz_lib/graphviz_lib.c
)

target_link_libraries(
    graphviz_lib
    ${SRC_DIR}/graphviz_lib/build/libcgraph.a
    ${SRC_DIR}/graphviz_lib/build/libgvc.a
    -lm -pthread
)

# target_link_libraries(
#     graphviz_lib 
#     PRIVATE 
#     "/lib/x86_64-linux-gnu/libgvc.so"
#     "/lib/x86_64-linux-gnu/libcgraph.so"
#     "/lib/x86_64-linux-gnu/libcdt.so"
# )

# Specify output directory for generated .so files
set_target_properties(graphviz_lib PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY
    "${CMAKE_SOURCE_DIR}/../../jniLibs/${ANDROID_ABI}"
)