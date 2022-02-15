cmake_minimum_required(VERSION 3.16)
project(UUtils VERSION 1.1.0 LANGUAGES CXX C)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

option(TESTING OFF)
if(TESTING)
    enable_testing()
endif(TESTING)

set(CMAKE_CXX_STANDARD 17)
cmake_policy(SET CMP0048 NEW) # project() command manages VERSION variables


set(MODULES base debug hash io)
include_directories("include")

find_library(xxhash NAMES xxhash xxHash)
if(NOT xxhash)
    message("XXHash not found. Downloading wia fetchContent")
    include(FetchContent)
    FetchContent_Declare(xxhashc
        GIT_REPOSITORY https://github.com/Cyan4973/xxHash.git
        GIT_TAG 35b0373c697b5f160d3db26b1cbb45a0d5ba788c
        )
    FetchContent_MakeAvailable(xxhashc)
    include_directories("${xxhashc_SOURCE_DIR}")
endif()

foreach(MODULE ${MODULES})
  add_subdirectory("src/${MODULE}")
  if(TESTING)
      add_subdirectory("test/${MODULE}")
  endif(TESTING)
endforeach()

if(xxhash)
target_link_libraries(hash xxhash)
endif(xxhash)

write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/UUtilsConfigVersion.cmake VERSION ${PACKAGE_VERSION} COMPATIBILITY SameMajorVersion)

install(EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/UUtils/ NAMESPACE UUtils::)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/UUtilsConfigVersion.cmake
        DESTINATION lib/cmake/UUtils )
