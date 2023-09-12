file(GLOB udebug_source "*.c" "*.cpp" "*.h")

add_library(udebug STATIC ${udebug_source} )
add_library(UUtils::udebug ALIAS udebug)

target_link_libraries(udebug PRIVATE base)

target_include_directories(udebug
                           INTERFACE
                            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                            $<INSTALL_INTERFACE:include>
                           )


install(TARGETS udebug EXPORT UUtilsConfig COMPONENT udebug)
install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/debug DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT debug)
