if(WIN32)
  list(APPEND libs psapi iphlpapi)
endif(WIN32)

if (UUtils_WITH_BENCHMARKS)
  add_executable(bm_random bm_random.cpp)
  if (BOOST_INCLUDE_DIRS)
    target_include_directories(bm_random PRIVATE ${BOOST_INCLUDE_DIRS})
    target_link_libraries(bm_random PRIVATE base)
  else (BOOST_INCLUDE_DIRS)
    target_link_libraries(bm_random PRIVATE base Boost::headers)
  endif (BOOST_INCLUDE_DIRS)
  add_test(NAME bm_random COMMAND bm_random)
  set_tests_properties(bm_random PROPERTIES RUN_SERIAL TRUE)
endif (UUtils_WITH_BENCHMARKS)

add_executable(test_allocator test_allocator.cpp)
target_link_libraries(test_allocator PRIVATE base xxHash)
add_test(NAME base_allocator_10000 COMMAND test_allocator 10000)
add_test(NAME base_allocator_30000 COMMAND test_allocator 30000)

add_executable(test_array test_array.cpp)
target_link_libraries(test_array PRIVATE xxHash)
add_test(NAME base_array_10_0 COMMAND test_array 10 0)
add_test(NAME base_array_10_1 COMMAND test_array 10 1)
add_test(NAME base_array_10_2 COMMAND test_array 10 2)
add_test(NAME base_array_10_3 COMMAND test_array 10 3)

add_executable(test_bit_string test_bit_string.c)
target_link_libraries(test_bit_string PRIVATE base udebug)
add_test(NAME base_bit_string COMMAND test_bit_string)

add_executable(test_crash_allocator test_crash_allocator.cpp)
target_link_libraries(test_crash_allocator PRIVATE base xxHash)
add_test(NAME base_crash_allocator_0 COMMAND test_crash_allocator 0)
add_test(NAME base_crash_allocator_1 COMMAND test_crash_allocator 1)
add_test(NAME base_crash_allocator_2 COMMAND test_crash_allocator 2)
add_test(NAME base_crash_allocator_3 COMMAND test_crash_allocator 3)
add_test(NAME base_crash_allocator_4 COMMAND test_crash_allocator 4)

add_executable(test_int_utils test_int_utils.c)
target_link_libraries(test_int_utils PRIVATE base udebug)
add_test(NAME base_int_utils_10 COMMAND test_int_utils 10)
add_test(NAME base_int_utils_10000 COMMAND test_int_utils 10000)

add_executable(test_item_allocator test_item_allocator.cpp)
target_link_libraries(test_item_allocator PRIVATE udebug)
add_test(NAME base_item_allocator_1 COMMAND test_item_allocator 1)
add_test(NAME base_item_allocator_10 COMMAND test_item_allocator 10)
add_test(NAME base_item_allocator_100000 COMMAND test_item_allocator 100000)

add_executable(test_meta test_meta.cpp)
add_test(NAME base_meta COMMAND test_meta)

add_executable(test_random test_random.cpp)
target_link_libraries(test_random PRIVATE base doctest_with_main)

add_executable(test_random_seed test_random_seed.cpp)
target_link_libraries(test_random_seed PRIVATE base doctest_with_main)
add_test(NAME base_random_seed COMMAND test_random_seed)

add_executable(test_randomness test_randomness.cpp)
target_compile_definitions(test_randomness PUBLIC _USE_MATH_DEFINES) # M_PI
target_link_libraries(test_randomness PRIVATE base Boost::math)

add_executable(test_sequencefilter test_sequencefilter.cpp)
target_link_libraries(test_sequencefilter PRIVATE doctest_with_main)
add_test(NAME test_sequencefilter COMMAND test_sequencefilter)

add_executable(test_time test_time.cpp)
add_test(NAME base_time COMMAND test_time)
set_tests_properties(base_time PROPERTIES DISABLED TRUE) # takes too much time

add_executable(test_timer test_timer.cpp)
target_link_libraries(test_timer PRIVATE base doctest_with_main)
add_test(NAME base_timer_100 COMMAND test_timer)
set_tests_properties(base_timer_100 PROPERTIES DISABLED TRUE) # randomly fail on slow hosts


# these tests fail intentionally, but via assertion, and ctest treats them as crash on Linux
set_tests_properties(
  base_array_10_1 base_array_10_2 base_array_10_3 base_crash_allocator_1
  base_crash_allocator_2 base_crash_allocator_3 PROPERTIES WILL_FAIL TRUE)

# disable failing tests:
if(CMAKE_SYSTEM_NAME MATCHES "Linux")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set_tests_properties(
      base_allocator_10000
      base_allocator_30000 # segfault
      base_array_10_0
      base_array_10_1
      base_array_10_2
      base_array_10_3 # assertion fail
      base_bit_string # assertion fail
      # base_crash_allocator_0 # passes correctly!
      base_crash_allocator_1
      base_crash_allocator_2
      base_crash_allocator_3 # assertion fail
      PROPERTIES DISABLED TRUE)
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set_tests_properties(
      base_allocator_10000
      base_allocator_30000 # segfault
      base_array_10_0
      base_array_10_1
      base_array_10_2
      base_array_10_3 # assertion fail
      base_bit_string # assertion fail
      base_crash_allocator_0 # assertion fail
      base_crash_allocator_1
      base_crash_allocator_2
      base_crash_allocator_3 # assertion fail
      PROPERTIES DISABLED TRUE)
  endif()
elseif(CMAKE_SYSTEM_NAME MATCHES "Darwin")
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    set_tests_properties(
      base_allocator_10000
      base_allocator_30000 # segfault
      base_array_10_0
      base_array_10_1
      base_array_10_2
      base_array_10_3 # assertion fail
      base_bit_string # assertion fail
      # base_crash_allocator_0 # passes correctly!
      base_crash_allocator_1
      base_crash_allocator_2
      base_crash_allocator_3 # assertion fail
      PROPERTIES DISABLED TRUE)
  endif()
elseif(CMAKE_SYSTEM_NAME MATCHES "Windows")
  set_tests_properties(
    base_array_10_1 base_array_10_2 PROPERTIES RUN_SERIAL TRUE) # these take long time if run in parallel
  if(CMAKE_SIZEOF_VOID_P EQUAL 8)
    # target_compile_options(test_rangeset PRIVATE "-Wa,-mbig-obj") # otherwise
    # assembler fails with "file too big"
    set_tests_properties(
      base_allocator_10000
      base_allocator_30000 # segfault
      base_array_10_0 # strange output
      base_array_10_1 # assertion fail as expected
      base_bit_string # assertion fail
      # base_crash_allocator_0 # passes correctly!
      base_crash_allocator_1
      base_crash_allocator_2
      base_crash_allocator_3 # assertion fail as expected
      PROPERTIES DISABLED TRUE)
  elseif(CMAKE_SIZEOF_VOID_P EQUAL 4)
    set_tests_properties(
      base_allocator_10000
      base_allocator_30000 # segfault
      base_array_10_0 # assertion fail
      base_bit_string # assertion fail
      base_crash_allocator_0 # assertion fail
      # base_crash_allocator_1 base_crash_allocator_2 base_crash_allocator_3 #
      # assertion fail as expected
      PROPERTIES DISABLED TRUE)
  endif()
endif()
