find_package(UTAP 1.1.6 QUIET)

if (utap_FOUND)
    message(STATUS "Found UTAP.")
else(utap_FOUND)
    message(STATUS "Failed to find UTAP, will try fetching and compiling from source.")
    include(FetchContent)
    FetchContent_Declare(
            UTAP
            GIT_REPOSITORY https://github.com/UPPAALModelChecker/utap.git
            GIT_TAG main
            GIT_SHALLOW TRUE # get only the last commit version
            GIT_PROGRESS TRUE # show progress of download
            FIND_PACKAGE_ARGS NAMES UTAP
            USES_TERMINAL_DOWNLOAD TRUE # show progress in ninja generator
            USES_TERMINAL_CONFIGURE ON
            USES_TERMINAL_BUILD ON
            USES_TERMINAL_INSTALL ON
            LOG_DOWNLOAD ON
            LOG_CONFIGURE ON
            LOG_BUILD ON
            LOG_INSTALL ON
            LOG_OUTPUT_ON_FAILURE ON
    )
    FetchContent_MakeAvailable(UTAP)
endif(utap_FOUND)
