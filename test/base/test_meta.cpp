#include "base/meta.hpp"

#include <doctest/doctest.h>

#include <memory>
#include <array>
#include <vector>
#include <string>
#include <string_view>
#include <list>
#include <deque>

TEST_CASE("meta predicates (type functions)")
{
    using namespace meta;

    static_assert(is_bool_v<bool>, "plain boolean");
    static_assert(is_bool_v<bool&>, "plain boolean references");
    static_assert(is_bool_v<const bool>, "const boolean");
    static_assert(is_bool_v<const bool&>, "const boolean reference");
    static_assert(!is_bool_v<bool*>, "pointer to boolean");
    static_assert(!is_bool_v<bool[2]>, "boolean array is not bool");
    static_assert(!is_bool_v<char>, "plain char is not bool");
    static_assert(!is_bool_v<int>, "plain int is not bool");
    static_assert(!is_bool_v<double>, "plain double is not bool");
    static_assert(!is_bool_v<char*>, "C string is not bool");
    static_assert(!is_bool_v<std::string>, "std::string is not bool");
    static_assert(!is_bool_v<std::string_view>, "std::string_view is not bool");
    static_assert(!is_bool_v<std::vector<bool>>, "vector of bool is not bool");

    static_assert(is_character_v<char>, "plain char");
    static_assert(is_character_v<char&>, "plain char references");
    static_assert(is_character_v<const char>, "const char");
    static_assert(is_character_v<const char&>, "const char reference");
    static_assert(!is_character_v<unsigned char>, "unsigned char is not char");
    static_assert(!is_character_v<signed char>, "signed char is not char");
    static_assert(!is_character_v<bool*>, "pointer to boolean");
    static_assert(!is_character_v<bool[2]>, "boolean array is not char");
    static_assert(!is_character_v<int>, "plain int is not char");
    static_assert(!is_character_v<double>, "plain double is not char");
    static_assert(!is_character_v<char*>, "C string is not char");
    static_assert(!is_character_v<std::string>, "std::string is not char");
    static_assert(!is_character_v<std::string_view>, "std::string_view is not char");
    static_assert(!is_character_v<std::vector<bool>>, "vector of bool is not char");

    static_assert(is_number_v<int>, "plain int");
    static_assert(is_number_v<int&>, "plain int references");
    static_assert(is_number_v<const int>, "const int");
    static_assert(is_number_v<const int&>, "const int reference");
    static_assert(is_number_v<double>, "plain double");
    static_assert(is_number_v<double&>, "plain double references");
    static_assert(is_number_v<const double>, "const double");
    static_assert(is_number_v<const double&>, "const double reference");
    static_assert(is_number_v<unsigned char>, "unsigned char");
    static_assert(is_number_v<signed char>, "unsigned char");
    static_assert(!is_number_v<int*>, "pointer to int is not a number");
    static_assert(!is_number_v<double*>, "pointer to double is not a number");
    static_assert(!is_number_v<int[2]>, "int array is not a number");
    static_assert(!is_number_v<double[2]>, "double array is not a number");
    static_assert(!is_number_v<char>, "plain char is not a number");
    static_assert(!is_number_v<char*>, "C string is not a number");
    static_assert(!is_number_v<std::string>, "std::string is not a number");
    static_assert(!is_number_v<std::string_view>, "std::string_view is not a number");
    static_assert(!is_number_v<std::vector<int>>, "vector of int is not a number");
    static_assert(!is_number_v<std::vector<double>>, "vector of double is not a number");

    static_assert(is_container_v<bool[2]>, "array of bool is a container");
    static_assert(is_container_v<char[2]>, "array of char is a container");
    static_assert(is_container_v<int[2]>, "array of int is a container");
    static_assert(is_container_v<const int[2]>, "array of const int is a container");
    static_assert(is_container_v<double[2]>, "array of double is a container");
    static_assert(is_container_v<std::vector<bool>>, "vector of bool is a container");
    static_assert(is_container_v<std::vector<int>>, "vector of int is a container");
    static_assert(is_container_v<std::vector<double>>, "vector of double is a container");
    static_assert(is_container_v<std::vector<std::string>>, "vector of std::string is a container");
    static_assert(is_container_v<std::initializer_list<int>>, "initializer list of int is a container");
    static_assert(is_container_v<std::list<int>>, "list of int is a container");
    static_assert(is_container_v<std::deque<int>>, "deque of int is a container");
    static_assert(is_container_v<std::string>, "string is a container");
    static_assert(is_container_v<std::string_view>, "string_view is a container");
    static_assert(is_container_v<char* [2]>, "array of pointers to char is a container");
    static_assert(!is_container_v<bool>, "bool is not a container");
    static_assert(!is_container_v<char>, "char is not a container");
    static_assert(!is_container_v<int>, "int is not a container");
    static_assert(!is_container_v<double>, "double is not a container");
    static_assert(!is_container_v<char*>, "pointer to char is not a container");
    static_assert(!is_container_v<int*>, "pointer to int is not a container");
    static_assert(!is_container_v<double*>, "pointer to double is not a container");

    static_assert(is_string_v<char*>, "C string");
    static_assert(is_string_v<const char*>, "C string");
    static_assert(is_string_v<char* const>, "C string");
    static_assert(is_string_v<const char* const>, "C string");
    static_assert(is_string_v<char[2]>, "character array is a string");
    static_assert(is_string_v<std::array<char, 2>>, "character array is a string");
    static_assert(is_string_v<std::vector<char>>, "vector of char is a string");
    static_assert(is_string_v<std::string>, "std::string is a string");
    static_assert(is_string_v<std::string_view>, "std::string_view is a string");
    static_assert(!is_string_v<std::vector<int>>, "vector of int is not a string");
    static_assert(!is_string_v<std::vector<double>>, "vector of double is not a string");
    static_assert(!is_string_v<bool>, "plain bool is not a string");
    static_assert(!is_string_v<char>, "plain char is not a string");
    static_assert(!is_string_v<int>, "plain int is not a string");
    static_assert(!is_string_v<double>, "plain double is not a string");

    const auto vi = std::vector{1, 2, 3};  // standard container
    static_assert(is_container_v<decltype(vi)>);
    static_assert(!is_unique_ptr_v<decltype(vi)>);
    static_assert(!is_shared_ptr_v<decltype(vi)>);
    static_assert(!is_smart_ptr_v<decltype(vi)>);

    const int ai[] = {1, 2, 3};  // int[3] is an array -> container
    static_assert(is_container_v<decltype(ai)>);
    static_assert(!is_unique_ptr_v<decltype(ai)>);
    static_assert(!is_shared_ptr_v<decltype(ai)>);
    static_assert(!is_smart_ptr_v<decltype(ai)>);

    const auto pc = "123";  // char* is just a pointer, not a container
    static_assert(!is_container_v<decltype(pc)>);
    static_assert(!is_unique_ptr_v<decltype(pc)>);
    static_assert(!is_shared_ptr_v<decltype(pc)>);
    static_assert(!is_smart_ptr_v<decltype(pc)>);

    const auto upi = std::make_unique<int>(5);
    static_assert(!is_container_v<decltype(upi)>);
    static_assert(is_unique_ptr_v<decltype(upi)>);
    static_assert(!is_shared_ptr_v<decltype(upi)>);
    static_assert(is_smart_ptr_v<decltype(upi)>);

    const auto spi = std::make_shared<int>(5);
    static_assert(!is_container_v<decltype(spi)>);
    static_assert(!is_unique_ptr_v<decltype(spi)>);
    static_assert(is_shared_ptr_v<decltype(spi)>);
    static_assert(is_smart_ptr_v<decltype(spi)>);
}
