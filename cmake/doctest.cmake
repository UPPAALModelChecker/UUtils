find_package(doctest 2.4.8 QUIET)

if (doctest_FOUND)
    message(STATUS "Found doctest: ${doctest_DIR}")
else(doctest_FOUND)
    message(STATUS "Failed to find doctest, going to compile from source.")
    set(DOCTEST_WITH_TESTS OFF CACHE BOOL "doctest tests and examples")
    set(DOCTEST_WITH_MAIN_IN_STATIC_LIB ON CACHE BOOL "static lib (cmake target) with a default main entry point")
    #set(DOCTEST_NO_INSTALL OFF CACHE BOOL "Skip the installation process")
    #set(DOCTEST_USE_STD_HEADERS OFF CACHE BOOL "Use std headers")
    FetchContent_Declare(
            doctest
            GIT_REPOSITORY https://github.com/doctest/doctest
            GIT_TAG v2.4.11
            GIT_SHALLOW TRUE # get only the last commit version
            GIT_PROGRESS TRUE # show progress of download
            FIND_PACKAGE_ARGS NAMES doctest
            USES_TERMINAL_DOWNLOAD TRUE # show progress in ninja generator
            USES_TERMINAL_CONFIGURE ON
            USES_TERMINAL_BUILD ON
            USES_TERMINAL_INSTALL ON
    )
    FetchContent_MakeAvailable(doctest)
    if (doctest_SOURCE_DIR)
        set(doctest_FOUND TRUE)
        message(STATUS "Got doctest: ${doctest_SOURCE_DIR}")
    else (doctest_SOURCE_DIR)
        message(FATAL_ERROR "Failed to fetch doctest")
    endif (doctest_SOURCE_DIR)
endif(doctest_FOUND)
