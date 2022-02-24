cmake_minimum_required(VERSION 3.16)
project(UUtils VERSION 1.1.1 HOMEPAGE_URL "https://github.com/UPPAALModelChecker/UUtils" LANGUAGES CXX C)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

option(TESTING OFF)
if(TESTING)
    enable_testing()
endif(TESTING)

set(CMAKE_CXX_STANDARD 20)
cmake_policy(SET CMP0048 NEW) # project() command manages VERSION variables

set(MODULES base debug hash io)
include_directories("include")

foreach(MODULE ${MODULES})
  add_subdirectory("src/${MODULE}")
  if(TESTING)
      add_subdirectory("test/${MODULE}")
  endif(TESTING)
endforeach()

set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH};${CMAKE_CURRENT_SOURCE_DIR}/libs")
find_package(xxHash 0.8.0 REQUIRED COMPONENTS xxhash)
target_link_libraries(hash PUBLIC xxHash::xxhash)

write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/UUtilsConfigVersion.cmake VERSION ${PACKAGE_VERSION} COMPATIBILITY SameMajorVersion)

install(EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/UUtils/ NAMESPACE UUtils::)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/UUtilsConfigVersion.cmake
    DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/UUtils )
