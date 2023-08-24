find_package(LibXml2 2.9.13 QUIET)

if (LibXml2_FOUND)
    message(STATUS "Found LibXml2: ${LubXml2_DIR}")
else(LibXml2_FOUND)
    message(STATUS "Failed to find LibXml2, going to compile from source.")
    set(LIBXML2_WITH_ICONV OFF CACHE BOOL "disable iconv")
    set(LIBXML2_WITH_LZMA OFF CACHE BOOL "disable liblzma")
    set(LIBXML2_WITH_PYTHON OFF CACHE BOOL "disable Python")
    set(LIBXML2_WITH_ZLIB OFF CACHE BOOL "disable libz")
    FetchContent_Declare(LibXml2
        GIT_REPOSITORY https://gitlab.gnome.org/GNOME/libxml2.git
        GIT_TAG        v2.11.5
        GIT_SHALLOW TRUE # get only the last commit version
        GIT_PROGRESS TRUE # show progress of download
        FIND_PACKAGE_ARGS NAMES LibXml2
        USES_TERMINAL_DOWNLOAD TRUE # show progress in ninja generator
        USES_TERMINAL_CONFIGURE ON
        USES_TERMINAL_BUILD ON
        USES_TERMINAL_INSTALL ON
    )
    FetchContent_MakeAvailable(LibXml2)
    if (LibXml2_SOURCE_DIR)
        set(LibXml2_FOUND TRUE)
        message(STATUS "Got LibXml2: ${LibXml2_SOURCE_DIR}")
    else (LibXml2_SOURCE_DIR)
        message(FATAL_ERROR "Failed to fetch LibXml2")
    endif (LibXml2_SOURCE_DIR)
endif(LibXml2_FOUND)
