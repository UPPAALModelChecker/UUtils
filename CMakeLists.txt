cmake_minimum_required(VERSION 3.19)
include(CMakePackageConfigHelpers)
include(GNUInstallDirs)

option(TESTING OFF)
if(TESTING)
    enable_testing()
endif(TESTING)

set(CMAKE_CXX_STANDARD 17)
cmake_policy(SET CMP0048 NEW) # project() command manages VERSION variables

project(UUtils VERSION 1.1.0 LANGUAGES CXX C)

set(MODULES base debug hash io)
include_directories("include")

foreach(MODULE ${MODULES})
  add_subdirectory("src/${MODULE}")
  if(TESTING)
      add_subdirectory("test/${MODULE}")
  endif(TESTING)
endforeach()



write_basic_package_version_file(${CMAKE_CURRENT_BINARY_DIR}/UUtilsConfigVersion.cmake VERSION ${PACKAGE_VERSION} COMPATIBILITY SameMajorVersion)

install(EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake/UUtils/ NAMESPACE UUtils::)

install(FILES ${CMAKE_CURRENT_BINARY_DIR}/UUtilsConfigVersion.cmake
        DESTINATION lib/cmake/UUtils )
