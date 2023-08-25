find_package(xxHash 0.8.2 CONFIG QUIET)

if (xxHash_FOUND)
    message(STATUS "Found xxHash: ${xxHash_DIR}")
else(xxHash_FOUND)
    message(STATUS "Failed to find xxHash, going to compile from source.")
    set(XXHASH_BUILD_ENABLE_INLINE_API ON CACHE BOOL "adds xxhash.c for the -DXXH_INLINE_ALL api. Default ON")
    set(XXHASH_BUILD_XXHSUM OFF CACHE BOOL "build the command line binary. Default ON")
    set(BUILD_SHARED_LIBS OFF CACHE BOOL "build dynamic library. Default ON")
    # set(DISPATCH OFF CACHE BOOL "enable dispatch mode. Default OFF")
    FetchContent_Declare(
            xxHash
            GIT_REPOSITORY https://github.com/Cyan4973/xxHash
            GIT_TAG v0.8.2
            GIT_SHALLOW TRUE # get only the last commit version
            GIT_PROGRESS TRUE # show progress of download
            SOURCE_SUBDIR cmake_unofficial # CMakeLists.txt is not in the main folder
            FIND_PACKAGE_ARGS NAMES xxHash COMPONENTS xxhash
            USES_TERMINAL_DOWNLOAD TRUE # show progress in ninja generator
            USES_TERMINAL_CONFIGURE ON
            USES_TERMINAL_BUILD ON
            USES_TERMINAL_INSTALL ON
    )
    FetchContent_MakeAvailable(xxHash)
    if (xxHash_SOURCE_DIR)
        set(xxHash_FOUND TRUE)
        message(STATUS "Got xxHash: ${xxHash_SOURCE_DIR}")
    else(xxHash_SOURCE_DIR)
        message(FATAL_ERROR "Failed to fetch xxHash")
    endif (xxHash_SOURCE_DIR)
    # Custom config: https://github.com/untrioctium/refrakt/blob/main/CMakeLists.txt
endif(xxHash_FOUND)
