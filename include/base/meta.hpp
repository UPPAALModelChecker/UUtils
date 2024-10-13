// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4;
// indent-tabs-mode: nil; -*-
////////////////////////////////////////////////////////////////////
//
// Filename : meta.hpp (base)
//
// Provides type predicates for metaprogramming purposes.
//
// This file is a part of the UPPAAL toolkit.
// Copyright (c) 2019, Uppsala University and Aalborg University.
// All right reserved.
//
///////////////////////////////////////////////////////////////////

#ifndef META_HPP
#define META_HPP

#include <iterator>
#include <memory>
#include <optional>
#include <type_traits>

namespace meta {
/// true if T is bool (or a reference to it)
template <typename T, typename TT = std::remove_cv_t<std::remove_reference_t<T>>>
struct is_bool : std::is_same<TT, bool>
{};

template <typename T>
constexpr auto is_bool_v = is_bool<T>::value;

/// Same as std::conditional, except with defaults for TrueType and FalseType
template <bool Condition, typename TrueType = std::true_type, typename FalseType = std::false_type>
struct conditional : std::conditional<Condition, TrueType, FalseType>
{};

template <bool Condition, typename TrueType = std::true_type, typename FalseType = std::false_type>
using conditional_t = typename conditional<Condition, TrueType, FalseType>::type;

/// True if T is equal to any of Types
template <typename T, typename... Types>
constexpr auto is_any_of_v = (... || std::is_same_v<T, Types>);

template <typename T, typename... Types>
struct is_any_of : conditional<is_any_of_v<T, Types...>>
{};

template <typename T, typename... Types>
using is_any_of_t = typename is_any_of<T, Types...>::type;

/// true if T is a character or a reference to it
template <typename T>
struct is_character : is_any_of_t<std::remove_cv_t<std::remove_reference_t<T>>, char, wchar_t>
{};

template <typename T>
constexpr auto is_character_v = is_character<T>::value;

/// true if T is a number or a reference to it
template <typename T, typename TT = std::remove_cv_t<std::remove_reference_t<T>>>
constexpr auto is_number_v = std::is_arithmetic_v<TT> && not is_bool_v<TT> && not is_character_v<TT>;

/// helper meta-function to extract the iterator type from container
template <typename T>
using iterator_type = decltype(std::begin(std::declval<T&>()));

/// The element type of a container if T is a container
template <typename T>
using element_type = typename std::iterator_traits<iterator_type<T>>::value_type;

/// true if T is a container or a reference to it
template <typename,         // primary "default" template with one argument
          typename = void>  // extra argument is used in SFINAE
struct is_container : std::false_type
{};

template <typename T>  // specialization for the iterable types
struct is_container<T, std::void_t<element_type<T>>> : std::true_type
{};

template <typename T>
constexpr auto is_container_v = is_container<T>::value;

/// true if T can be treated as a string
template <typename T, typename = void>  // primary template
struct is_string_cvref : std::false_type
{};

template <typename T>  // specialization for pointer types (like c-strings)
struct is_string_cvref<T*> : is_character<T>
{};

template <typename T>  // specialization for containers (like std::string and std::array<char>)
struct is_string_cvref<T, std::void_t<element_type<T>>> : is_character<element_type<T>>
{};

template <typename T>
using is_string = is_string_cvref<std::remove_cv_t<std::remove_reference_t<T>>>;

template <typename T>
constexpr auto is_string_v = is_string<T>::value;

/** true if T is a tuple */
template <typename T>
struct is_tuple : std::false_type
{};

template <typename... T>
struct is_tuple<std::tuple<T...>> : std::true_type
{};

template <typename T1, typename T2>
struct is_tuple<std::pair<T1, T2>> : std::true_type
{};

namespace details {
template <typename T>
struct is_optional : std::false_type
{};

template <typename T>
struct is_optional<std::optional<T>> : std::true_type
{};

template <typename T>
struct is_shared_ptr : std::false_type
{};

template <typename T>
struct is_shared_ptr<std::shared_ptr<T>> : std::true_type
{};

template <typename T>
struct is_unique_ptr : std::false_type
{};

template <typename T>
struct is_unique_ptr<std::unique_ptr<T>> : std::true_type
{};
}  // namespace details

template <typename T, typename Raw = std::decay_t<T>>
constexpr auto is_optional_v = details::is_optional<T>::value;

template <typename T, typename Raw = std::decay_t<T>>
constexpr auto is_shared_ptr_v = details::is_shared_ptr<Raw>::value;

template <typename T, typename Raw = std::decay_t<T>>
constexpr auto is_unique_ptr_v = details::is_unique_ptr<Raw>::value;

template <typename T>
constexpr auto is_smart_ptr_v = is_shared_ptr_v<T> || is_unique_ptr_v<T>;

/** undefined struct to expose the type T */
template <typename T>
struct TD;
}  // namespace meta
#endif /* META_HPP */
