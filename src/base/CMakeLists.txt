file(GLOB base_source "*.c" "*.cpp")
add_library(base STATIC ${base_source})
#target_include_directories(base PRIVATE "${Boost_INCLUDE_DIRS}")
if (CMAKE_SYSTEM_NAME STREQUAL Windows)
    target_link_libraries(base PUBLIC hash PRIVATE udebug xxHash::xxhash Boost::math iphlpapi psapi)
else()
    target_link_libraries(base PUBLIC hash PRIVATE udebug xxHash::xxhash Boost::math)
endif()

target_include_directories(base
                           INTERFACE
                            $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}>
                            $<INSTALL_INTERFACE:include>
                           )


install(TARGETS base xxhash
        boost_math boost_assert boost_concept_check boost_preprocessor boost_type_traits boost_array boost_container
        boost_intrusive boost_move boost_numeric_conversion boost_mpl boost_range boost_optional boost_regex
        boost_tuple boost_utility boost_io boost_container_hash boost_describe boost_mp11 boost_conversion
        boost_smart_ptr boost_typeof boost_detail boost_iterator boost_function_types boost_fusion boost_functional
        boost_function boost_bind boost_config boost_core boost_integer boost_lexical_cast boost_predef boost_random
        boost_dynamic_bitset boost_system boost_variant2 boost_winapi boost_static_assert boost_throw_exception
        EXPORT UUtilsConfig DESTINATION ${CMAKE_INSTALL_LIBDIR} COMPONENT base)
install(DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/../../include/base DESTINATION ${CMAKE_INSTALL_INCLUDEDIR} COMPONENT base)
