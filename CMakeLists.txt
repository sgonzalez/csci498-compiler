cmake_minimum_required(VERSION 2.8)

project(HellmanCompiler CXX)

find_package(FLEX REQUIRED)
find_package(BISON REQUIRED)

if(NOT FLEX_FOUND)
    message(FATAL_ERROR "Unable to find flex.")
endif()

if(NOT BISON_FOUND)
    message(FATAL_ERROR "Unable to find Bison.")
endif()

if(WIN32)
    # Flex uses the unistd.h header file, which doesn't exist on Windows.
    # Passing this flag, on a specific port at least, tells Flex to use io.h instead.
    # We need this flag to build on Windows, as far as I can tell.
    # Download Flex and Bison here: http://sourceforge.net/projects/winflexbison/
    set(FLEX_FLAGS "--wincompat")
else()
    set(FLEX_FLAGS "")
endif()

# For convience.
set(BIN ${CMAKE_CURRENT_BINARY_DIR})

# Store the auto-generated files in their own directory.
file(MAKE_DIRECTORY ${BIN}/flex-bison-autogen)
FLEX_TARGET(
    SCANNER flex-bison/language_0.l
    ${BIN}/flex-bison-autogen/language_0_scanner.cpp COMPILE_FLAGS "${FLEX_FLAGS}")
BISON_TARGET(
    PARSER flex-bison/language_0.y
    ${BIN}/flex-bison-autogen/language_0_parser.cpp)
ADD_FLEX_BISON_DEPENDENCY(SCANNER PARSER)

if(MSVC)
    # Why /SAFESEH?
    #     If the version used to build a library (like fl) doesn't match the one you're
    #     using, this setting will error during linking. Turning it off here lets
    #     us use VS2013 with whichever version of Flex we got.

    set(CMAKE_EXE_LINKER_FLAGS
        "${CMAKE_EXE_LINKER_FLAGS} /SAFESEH:NO"
        )
    add_definitions(
        # Anything higher will start checking the standard headers. Yes, really.
        /W4
        )
    # Disable warnings in auto-generated files. We don't have control over them.
    set_source_files_properties(
        ${BIN}/flex-bison-autogen/language_0_scanner.cpp
        ${BIN}/flex-bison-autogen/language_0_parser.cpp
        PROPERTIES COMPILE_FLAGS /W0
        )
    # Technically, this only works for GCC/Clang. If someone tries using
    #     another compiler, maybe Intel?, CMake will get confused.
else()
    # Difference versions of GCC/Clang use different flags for C++11.
    #   So we need to check which one is available.
    #   (Alamode uses c++0x, but anything from the past 2.5 years uses c++11)
    include(CheckCXXCompilerFlag)
    CHECK_CXX_COMPILER_FLAG("-std=c++11" CXX11)
    SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wall -Wextra -pedantic")
    if (CXX11)
        add_definitions("-std=c++11")
    else()
        # Assume it has the older flag. If it doesn't have even that,
        #   we're going to have trouble building anyway.
        add_definitions("-std=c++0x")
    endif()

    # Disable warnings in auto-generated files. We don't have control over them.
    set_source_files_properties(
        ${BIN}/flex-bison-autogen/language_0_scanner.cpp
        ${BIN}/flex-bison-autogen/language_0_parser.cpp
        PROPERTIES COMPILE_FLAGS -w
        )
endif()

include_directories(
    include
    ${BIN}/flex-bison-autogen
    )

# The main driver for the compiler.
add_executable(frontend
    # Source files.
    source/frontend.cpp

    source/ast.cpp
    source/datablock.cpp
    source/symboltable.cpp

    # Header files.
    include/ast.h
    include/datablock.h
    include/symboltable.h

    # Flex/Bison files.
    flex-bison/language_0.l
    flex-bison/language_0.y

    ${BIN}/flex-bison-autogen/language_0_scanner.cpp
    ${BIN}/flex-bison-autogen/language_0_parser.cpp

    ${BIN}/flex-bison-autogen/language_0_parser.hpp

    )

# Testing files.
# TODO: We need more of these.
add_executable(test_datablock
    tests/datablock_test.cpp

    include/datablock.h
    source/datablock.cpp
    )

add_executable(test_symboltable
    tests/symboltable_test.cpp

    include/symboltable.h
    source/symboltable.cpp
    )

target_link_libraries(frontend fl)
