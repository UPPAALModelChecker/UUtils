add_library(hash STATIC compute.cpp PointerTable.cpp tables.cpp)
#target_link_libraries(hash PRIVATE xxHash)
target_compile_definitions(hash PRIVATE XXHASH_INLINE_ALL)
target_include_directories(hash PRIVATE ${XXHASH_INCLUDE_DIR}) # workaround for xxHash::xxhash

target_include_directories(hash
                           INTERFACE
                            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                            $<INSTALL_INTERFACE:include>
                           )


install(TARGETS hash EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT hash)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/hash DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT hash)
