add_library(random OBJECT random.cpp)
target_link_libraries(random PRIVATE Boost::headers Boost::math)

add_library(base STATIC bitstring.c c_allocator.c doubles.c platform.c DataAllocator.cpp Enumerator.cpp exceptions.cpp
        intutils.cpp property.cpp stats.cpp Timer.cpp)

#target_include_directories(base PRIVATE ${BOOST_INCLUDE_DIRS}) # workaround xxHash::xxhash
if (CMAKE_SYSTEM_NAME STREQUAL Windows)
#    target_link_libraries(base PUBLIC hash PRIVATE udebug iphlpapi psapi) # xxHash::xxhash Boost::headers
    target_link_libraries(base PUBLIC hash PRIVATE udebug random xxHash Boost::headers iphlpapi psapi) # breaks
else()
#    target_link_libraries(base PUBLIC hash PRIVATE udebug) # xxHash::xxhash Boost::headers
    target_link_libraries(base PUBLIC hash PRIVATE udebug random xxHash Boost::headers) # breaks
endif()

target_include_directories(base
                           INTERFACE
                            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                            $<INSTALL_INTERFACE:include>
                           )

install(TARGETS base random EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT base)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/base DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT base)
