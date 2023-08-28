file(GLOB base_source "*.c" "*.cpp")
add_library(base STATIC ${base_source})
target_include_directories(base PRIVATE ${XXHASH_INCLUDE_DIR} ${BOOST_INCLUDE_DIRS}) # workaround exports
if (CMAKE_SYSTEM_NAME STREQUAL Windows)
#    target_link_libraries(base PUBLIC hash PRIVATE udebug iphlpapi psapi) # xxHash::xxhash Boost::headers
    target_link_libraries(base PUBLIC hash PRIVATE udebug xxHash::xxhash Boost::headers iphlpapi psapi) # breaks
else()
    target_link_libraries(base PUBLIC hash PRIVATE udebug) # xxHash::xxhash Boost::headers
#    target_link_libraries(base PUBLIC hash PRIVATE udebug xxHash::xxhash Boost::headers) # breaks
endif()

target_include_directories(base
                           INTERFACE
                            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                            $<INSTALL_INTERFACE:include>
                           )

install(TARGETS base EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT base)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/base DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT base)
