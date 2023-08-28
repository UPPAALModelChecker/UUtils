# set BOOST_INCLUDE_LIBRARIES to include specific libraries before including this script, e.g.
# set(BOOST_INCLUDE_LIBRARIES program_options threads)
set(Boost_NO_SYSTEM_PATHS TRUE)
set(Boost_USE_STATIC_LIBS    ON)  # only find static libs
set(Boost_USE_DEBUG_LIBS     OFF) # ignore debug libs and
set(Boost_USE_RELEASE_LIBS   ON)  # only find release libs
set(Boost_USE_STATIC_RUNTIME ON) # Mac insists on ON for boost_program_options
#set(BOOST_USE_MULTITHREADED ON)
#set(Boost_DEBUG ON)
set(Boost_VERSION 1.83.0)

if (BOOST_INCLUDE_LIBRARIES)
  find_package(Boost ${Boost_VERSION} COMPONENTS ${BOOST_INCLUDE_LIBRARIES} QUIET PATHS /usr)
else(BOOST_INCLUDE_LIBRARIES)
  find_package(Boost ${Boost_VERSION} QUIET PATHS /usr)
endif(BOOST_INCLUDE_LIBRARIES)

if (Boost_FOUND)
  message(STATUS "Found Boost: ${Boost_DIR}")
else(Boost_FOUND)
  message(STATUS "Failed to find Boost (${BOOST_INCLUDE_LIBRARIES}), going to compile from source")
  set(BOOST_ENABLE_CMAKE ON)
  FetchContent_Declare(
    Boost
    FIND_PACKAGE_ARGS NAMES Boost COMPONENTS ${BOOST_INCLUDE_LIBRARIES}    
    DOWNLOAD_EXTRACT_TIMESTAMP ON	    
    URL https://homes.cs.aau.dk/~marius/mirrors/boost/boost-1.83.0.tar.xz
    # URL https://github.com/boostorg/boost/releases/download/boost-1.83.0/boost-1.83.0.tar.xz
    URL_HASH SHA256=c5a0688e1f0c05f354bbd0b32244d36085d9ffc9f932e8a18983a9908096f614
    USES_TERMINAL_DOWNLOAD TRUE # show progress in ninja generator
    USES_TERMINAL_CONFIGURE ON
    USES_TERMINAL_BUILD ON
    USES_TERMINAL_INSTALL ON
    )
  FetchContent_MakeAvailable(Boost) # Fetches, builds and creates boost_{SOURCE_DIR,BINARY_DIR}
  
  if (Boost_SOURCE_DIR)
    # crazy workaround for stupid CMake demand to export header-only libraries:
    set(BOOST_INCLUDE_ASSERT_DIR ${Boost_SOURCE_DIR}/libs/assert/include)
    set(BOOST_INCLUDE_CONFIG_DIR ${Boost_SOURCE_DIR}/libs/config/include)
    set(BOOST_INCLUDE_STATIC_ASSERT_DIR ${Boost_SOURCE_DIR}/libs/static_assert/include)
    set(BOOST_INCLUDE_TYPE_TRAITS_DIR ${Boost_SOURCE_DIR}/libs/type_traits/include)
    set(BOOST_INCLUDE_CORE_DIR ${Boost_SOURCE_DIR}/libs/core/include)
    set(BOOST_INCLUDE_THROW_EXCEPTION_DIR ${Boost_SOURCE_DIR}/libs/throw_exception/include)
    set(BOOST_INCLUDE_PREPROCESSOR_DIR ${Boost_SOURCE_DIR}/libs/preprocessor/include)
    set(BOOST_INCLUDE_MATH_DIR ${Boost_SOURCE_DIR}/libs/math/include)
    set(BOOST_INCLUDE_RANDOM_DIR ${Boost_SOURCE_DIR}/libs/random/include)
    set(BOOST_INCLUDE_IO_DIR ${Boost_SOURCE_DIR}/libs/io/include)
    set(BOOST_INCLUDE_RANGE_DIR ${Boost_SOURCE_DIR}/libs/range/include)
    set(BOOST_INCLUDE_UTILITY_DIR ${Boost_SOURCE_DIR}/libs/utility/include)
    set(BOOST_INCLUDE_CONCEPT_CHECK_DIR ${Boost_SOURCE_DIR}/libs/concept_check/include)  
    set(BOOST_INCLUDE_ITERATOR_DIR ${Boost_SOURCE_DIR}/libs/iterator/include)    
    set(BOOST_INCLUDE_MPL_DIR ${Boost_SOURCE_DIR}/libs/mpl/include)
    set(BOOST_INCLUDE_ARRAY_DIR ${Boost_SOURCE_DIR}/libs/array/include)
    set(BOOST_INCLUDE_INTEGER_DIR ${Boost_SOURCE_DIR}/libs/integer/include)
    set(BOOST_INCLUDE_DIRS
      ${BOOST_INCLUDE_ASSERT_DIR}
      ${BOOST_INCLUDE_CONFIG_DIR}
      ${BOOST_INCLUDE_STATIC_ASSERT_DIR}
      ${BOOST_INCLUDE_TYPE_TRAITS_DIR}
      ${BOOST_INCLUDE_CORE_DIR}
      ${BOOST_INCLUDE_THROW_EXCEPTION_DIR}
      ${BOOST_INCLUDE_PREPROCESSOR_DIR}
      ${BOOST_INCLUDE_MATH_DIR}
      ${BOOST_INCLUDE_RANDOM_DIR}
      ${BOOST_INCLUDE_IO_DIR}
      ${BOOST_INCLUDE_RANGE_DIR}
      ${BOOST_INCLUDE_UTILITY_DIR}
      ${BOOST_INCLUDE_CONCEPT_CHECK_DIR}
      ${BOOST_INCLUDE_ITERATOR_DIR}
      ${BOOST_INCLUDE_MPL_DIR}
      ${BOOST_INCLUDE_ARRAY_DIR}
      ${BOOST_INCLUDE_INTEGER_DIR}      
      )
    message(STATUS "Got Boost (${BOOST_INCLUDE_LIBRARIES}): ${Boost_SOURCE_DIR}")
    set(Boost_FOUND TRUE)
  else (Boost_SOURCE_DIR)
    message(FATAL_ERROR "Failed to fetch Boost")
  endif (Boost_SOURCE_DIR)
endif(Boost_FOUND)
