file(GLOB base_source "*.c" "*.cpp")
add_library(base ${base_source})
target_include_directories(base PRIVATE "${Boost_INCLUDE_DIRS}")

if (CMAKE_SYSTEM_NAME STREQUAL Windows)
    target_link_libraries(base PRIVATE udebug iphlpapi psapi PUBLIC hash)
else()
    target_link_libraries(base PRIVATE udebug PUBLIC hash)
endif()

target_include_directories(base
                           INTERFACE
                            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                            $<INSTALL_INTERFACE:include>
                           )


install(TARGETS base EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT base)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/base DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT base)
