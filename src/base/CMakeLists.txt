add_library(base STATIC bitstring.c c_allocator.c doubles.c platform.c DataAllocator.cpp Enumerator.cpp exceptions.cpp
        intutils.cpp property.cpp stats.cpp Timer.cpp random.cpp)
add_library(UUtils::base ALIAS base)

if (CMAKE_SYSTEM_NAME STREQUAL Windows)
    target_link_libraries(base PUBLIC hash PRIVATE udebug xxHash Boost::headers Boost::math iphlpapi psapi)
else()
    target_link_libraries(base PUBLIC hash PRIVATE udebug xxHash Boost::headers Boost::math)
endif()

target_include_directories(base
                           INTERFACE
                            $<BUILD_INTERFACE:${PROJECT_SOURCE_DIR}/include>
                            $<INSTALL_INTERFACE:include>
                           )

install(TARGETS base EXPORT UUtilsConfig COMPONENT base)
install(DIRECTORY ${PROJECT_SOURCE_DIR}/include/base DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT base)
