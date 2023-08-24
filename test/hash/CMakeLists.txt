if (UUtils_WITH_BENCHMARKS)
  find_package(benchmark REQUIRED)
  add_executable(bm_compute bm_compute.cpp)
  target_link_libraries(bm_compute PRIVATE hash xxHash::xxhash benchmark::benchmark_main)
endif (UUtils_WITH_BENCHMARKS)

add_executable(test_compute test_compute.cpp)
target_link_libraries(test_compute PRIVATE xxHash::xxhash doctest::doctest) # hash base udebug
add_test(NAME hash_compute COMMAND test_compute)

add_executable(test_tables test_tables.cpp)
target_link_libraries(test_tables PRIVATE base hash) #hash base udebug doctest::doctest
add_test(NAME hash_tables_0 COMMAND test_tables 0)
add_test(NAME hash_tables_1 COMMAND test_tables 1)
add_test(NAME hash_tables_10000 COMMAND test_tables 10000)
add_test(NAME hash_tables_1000000 COMMAND test_tables 1000000)

if(CMAKE_SYSTEM_NAME MATCHES "Windows")
  set_tests_properties(
    hash_tables_1000000
	PROPERTIES RUN_SERIAL TRUE)
endif()
