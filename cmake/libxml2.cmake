find_package(LibXml2 2.9.14 QUIET)

if (LibXml2_FOUND)
    message(STATUS "Found LibXml2")
else(LibXml2_FOUND)
    # Download libxml2 source code using FetchContent
    include(FetchContent)
    FetchContent_Declare(LibXml2
        GIT_REPOSITORY https://gitlab.gnome.org/GNOME/libxml2.git
        GIT_TAG        v2.10.3)
    FetchContent_MakeAvailable(LibXml2)
endif(LibXml2_FOUND)
