file(GLOB hash_source "*.c" "*.cpp" "*.h")

find_library(xxhash REQUIRED NAMES xxhash xxHash)

add_library(hash ${hash_source})
target_link_libraries(hash xxhash)

target_include_directories(hash
                           INTERFACE
                            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                            $<INSTALL_INTERFACE:include>
                           )


install(TARGETS hash EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT hash)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/hash DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT hash)
