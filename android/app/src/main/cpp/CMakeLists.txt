cmake_minimum_required(VERSION 3.10)

project(automata_lib)

add_library(
    automata_lib  # Name of the compiled library
    SHARED
    automata_lib_interface.cpp  # Your C++ source file
)

find_library(
    log-lib
    log
)

target_link_libraries(
    automata_lib
    ${log-lib}
)

# Specify output directory for generated .so files
set_target_properties(automata_lib PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY
    "${CMAKE_SOURCE_DIR}/../../jniLibs/${ANDROID_ABI}"
)