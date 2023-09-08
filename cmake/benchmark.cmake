find_package(benchmark QUIET) # benchmarkConfigVersion may have garbage version numbers

if (benchmark_FOUND)
  message(STATUS "Found benchmark: ${benchmark_DIR}")
else(benchmark_FOUND)
  message(STATUS "Failed to find benchmark, going to compile from source.")
  if (FIND_FATAL)
    message(FATAL_ERROR "Failed to find with CMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH}")
  endif(FIND_FATAL)
  set(BENCHMARK_ENABLE_TESTING OFF CACHE BOOL "Enable tests")
  set(BENCHMARK_ENABLE_EXCEPTIONS ON CACHE BOOL "Enable the use of exceptions in the benchmark library. Default ON")
  set(BENCHMARK_ENABLE_LTO OFF CACHE BOOL "Enable link time optimisation of the benchmark library. Default OFF")
  set(BENCHMARK_USE_LIBCXX OFF CACHE BOOL "Build and test using libc++ as the standard library. Default OFF")
  set(BENCHMARK_ENABLE_WERROR ON CACHE BOOL "Build Release candidates with -Werror. Default ON")
  set(BENCHMARK_FORCE_WERROR OFF CACHE BOOL "Build Release candidates with -Werror regardless of compiler issues. Default OFF")
  FetchContent_Declare(
    benchmark
    GIT_REPOSITORY https://github.com/google/benchmark
    GIT_TAG v1.8.3
    GIT_SHALLOW TRUE # get only the last commit version
    GIT_PROGRESS TRUE # show progress of download
    # FIND_PACKAGE_ARGS NAMES benchmark
    USES_TERMINAL_DOWNLOAD TRUE # show progress in ninja generator
    USES_TERMINAL_CONFIGURE ON
    USES_TERMINAL_BUILD ON
    USES_TERMINAL_INSTALL ON
    )
  FetchContent_MakeAvailable(benchmark)
  if (benchmark_SOURCE_DIR)
    set(benchmark_FOUND TRUE)
    message(STATUS "Got benchmark: ${benchmark_SOURCE_DIR}")
  else (benchmark_SOURCE_DIR)
    message(FATAL_ERROR "Failed to fetch benchmark")
  endif (benchmark_SOURCE_DIR)
endif(benchmark_FOUND)
