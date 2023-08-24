find_package(UTAP 1.1.6 QUIET)

if (UTAP_FOUND)
    message(STATUS "Found UTAP: ${UTAP_DIR}")
else(UTAP_FOUND)
    message(STATUS "Failed to find UTAP, going to compile from source.")
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
    )
    FetchContent_MakeAvailable(UTAP)
    if (UTAP_SOURCE_DIR)
        set(UTAP_FOUND TRUE)
        message(STATUS "Got UTAP: ${UTAP_SOURCE_DIR}")
    else (UTAP_SOURCE_DIR)
        message(FATAL_ERROR "Failed to fetch UTAP")
    endif (UTAP_SOURCE_DIR)
endif(UTAP_FOUND)
