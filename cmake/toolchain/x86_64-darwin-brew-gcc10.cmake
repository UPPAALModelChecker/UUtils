# the name of the target operating system
set(CMAKE_SYSTEM_NAME Darwin)

set(CMAKE_C_COMPILER gcc-10)
set(CMAKE_CXX_COMPILER g++-10)
set(CMAKE_AR gcc-ar-10)
set(CMAKE_NM gcc-nm-10)
set(CMAKE_RANLIB gcc-ranlib-10) # https://stackoverflow.com/questions/53128049/ld-archive-has-no-table-of-contents-file-error-with-homebrew
set(RANLIB gcc-ranlib-10)

# where is the target environment located
set(CMAKE_FIND_ROOT_PATH "${CMAKE_PREFIX_PATH}")

# adjust the default behavior of the FIND_XXX() commands:
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)

# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
