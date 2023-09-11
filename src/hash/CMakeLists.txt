add_library(hash STATIC compute.cpp PointerTable.cpp tables.cpp)
target_link_libraries(hash PUBLIC xxHash PRIVATE base)
add_library(UUtils::hash ALIAS hash)

target_include_directories(hash
                           INTERFACE
                            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                            $<INSTALL_INTERFACE:include>
                           )


install(TARGETS hash xxHash EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT hash)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/hash DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT hash)
