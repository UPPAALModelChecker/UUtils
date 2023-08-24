# set BOOST_INCLUDE_LIBRARIES to include specific libraries before including this script, e.g.
# set(BOOST_INCLUDE_LIBRARIES program_options threads)
set(Boost_NO_SYSTEM_PATHS TRUE)
set(Boost_USE_STATIC_LIBS    ON)  # only find static libs
set(Boost_USE_DEBUG_LIBS     OFF) # ignore debug libs and
set(Boost_USE_RELEASE_LIBS   ON)  # only find release libs
set(Boost_USE_STATIC_RUNTIME ON) # Mac insists on ON for boost_program_options
#set(BOOST_USE_MULTITHREADED ON)
#set(Boost_DEBUG ON)
set(Boost_VERSION 1.74.0)

if (BOOST_INCLUDE_LIBRARIES)
    find_package(Boost ${Boost_VERSION} COMPONENTS ${BOOST_INCLUDE_LIBRARIES} QUIET)
else(BOOST_INCLUDE_LIBRARIES)
    find_package(Boost ${Boost_VERSION} QUIET)
endif(BOOST_INCLUDE_LIBRARIES)

if (Boost_FOUND)
    message(STATUS "Found Boost: ${Boost_DIR}")
else(Boost_FOUND)
    message(STATUS "Failed to find Boost (${BOOST_INCLUDE_LIBRARIES}), going to compile from source")
    set(BOOST_ENABLE_CMAKE ON)
    FetchContent_Declare(
            Boost
            DOWNLOAD_EXTRACT_TIMESTAMP ON
            URL https://github.com/boostorg/boost/releases/download/boost-1.83.0/boost-1.83.0.tar.xz
            URL_HASH SHA256=c5a0688e1f0c05f354bbd0b32244d36085d9ffc9f932e8a18983a9908096f614
            FIND_PACKAGE_ARGS NAMES Boost COMPONENTS ${BOOST_INCLUDE_LIBRARIES}
            USES_TERMINAL_DOWNLOAD TRUE # show progress in ninja generator
            USES_TERMINAL_CONFIGURE ON
            USES_TERMINAL_BUILD ON
            USES_TERMINAL_INSTALL ON
    )
    FetchContent_MakeAvailable(Boost) # Fetches, builds and creates boost_{SOURCE_DIR,BINARY_DIR}

    if (Boost_SOURCE_DIR)
        set(Boost_FOUND TRUE)
        message(STATUS "Got Boost (${BOOST_INCLUDE_LIBRARIES}): ${Boost_SOURCE_DIR}")
    else (Boost_SOURCE_DIR)
        message(FATAL_ERROR "Failed to fetch Boost")
    endif (Boost_SOURCE_DIR)
endif(Boost_FOUND)
