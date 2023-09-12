# the name of the target operating system
set(CMAKE_SYSTEM_NAME Darwin)

set(CMAKE_C_COMPILER cc)
set(CMAKE_CXX_COMPILER c++)

# where is the target environment located
set(CMAKE_FIND_ROOT_PATH "${CMAKE_PREFIX_PATH}")

# adjust the default behavior of the FIND_XXX() commands:
# search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)

# search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
