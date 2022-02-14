file(GLOB hash_source "*.c" "*.cpp" "*.h")

add_library(hash ${hash_source})
target_link_libraries(hash xxhash)

install(TARGETS hash EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT hash)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/hash DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT hash)
