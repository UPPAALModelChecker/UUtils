file(GLOB udebug_source "*.c" "*.cpp" "*.h")

add_library(udebug ${udebug_source} )

install(TARGETS udebug EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT debug)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/debug DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT debug)
