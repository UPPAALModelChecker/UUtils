file(GLOB io_source "*.c" "*.cpp" "*.h")

add_library(io INTERFACE)

target_include_directories(io
                           INTERFACE
                            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                            $<INSTALL_INTERFACE:include>
                           )

install(TARGETS io EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT io)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/io DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT io)
