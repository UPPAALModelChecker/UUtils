file(GLOB udebug_source "*.c" "*.cpp" "*.h")

add_library(udebug ${udebug_source} )

target_include_directories(udebug
                           INTERFACE
                            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                            $<INSTALL_INTERFACE:include>
                           )


install(TARGETS udebug EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT debug)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/debug DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT debug)
