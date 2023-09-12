cmake_minimum_required(VERSION 3.15)
cmake_policy(SET CMP0048 NEW) # project() command manages VERSION variables
project(UUtils VERSION 2.0.2 HOMEPAGE_URL "https://github.com/UPPAALModelChecker/UUtils" LANGUAGES CXX C)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)
include(FetchContent)
# set(FETCHCONTENT_QUIET FALSE) # for debugging FetchContent

if (NOT CMAKE_BUILD_TYPE)
  set(CMAKE_BUID_TYPE Release)
endif ()

option(UUtils_WITH_TESTS "Enable UUtils unit tests" ON)
option(UUtils_WITH_BENCHMARKS "Enable UUtils benchmarks (depends on tests)" OFF)
option(FIND_FATAL "Stop if find_package fails, do not attempt FetchContent" OFF)

include(cmake/stdcpp.cmake)
include(cmake/sanitizer.cmake)
if(UUtils_WITH_TESTS)
  include(cmake/doctest.cmake)
  message(STATUS "Enabled Unit Tests")
endif (UUtils_WITH_TESTS)
if (UUtils_WITH_BENCHMARKS)
  include(cmake/benchmark.cmake)
  message(STATUS "Enabled Benchmarks")
endif (UUtils_WITH_BENCHMARKS)
include(cmake/xxhash.cmake)
set(BOOST_INCLUDE_LIBRARIES headers math)
include(cmake/boost.cmake)

if(UUtils_WITH_TESTS)
  enable_testing()
endif (UUtils_WITH_TESTS)

set(MODULES base debug hash)
foreach(MODULE ${MODULES})
  add_subdirectory("src/${MODULE}")
endforeach()

if(UUtils_WITH_TESTS)
  foreach(MODULE ${MODULES})
    add_subdirectory("test/${MODULE}")
  endforeach()
endif(UUtils_WITH_TESTS)

write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/UUtilsConfigVersion.cmake VERSION ${PACKAGE_VERSION} COMPATIBILITY SameMajorVersion)

install(EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/UUtils/ NAMESPACE UUtils::)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/UUtilsConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/UUtils )
