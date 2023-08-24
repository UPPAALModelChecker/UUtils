// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-
///////////////////////////////////////////////////////////////////////////////
//
// This file is a part of UPPAAL.
// Copyright (c) 2019, Aalborg University.
// All right reserved.
//
///////////////////////////////////////////////////////////////////////////////
#include "base/sequence_filter.hpp"
#include <doctest/doctest.h>
#include <sstream>
#include <vector>

using namespace std;

TEST_CASE("Filter Iterator")
{
    stringstream out;
    SUBCASE("all successful")
    {
        vector<int> nums{2, 4, 6, 8};
        auto filter = sequence_filter(nums, [](int i) { return i % 2 == 0; });
        for (auto i : filter) {
            out << i << " ";
        }
        CHECK(out.str() == "2 4 6 8 ");
    }

    SUBCASE("start and end successful")
    {
        vector<int> nums{2, 3, 4, 5, 6};
        auto filter = sequence_filter(nums, [](int i) { return i % 2 == 0; });
        for (auto i : filter) {
            out << i << " ";
        }
        CHECK(out.str() == "2 4 6 ");
    }

    SUBCASE("start and end unsuccessful")
    {
        vector<int> nums{1, 2, 3, 4, 5, 6, 7, 8, 9};
        auto filter = sequence_filter(nums, [](int i) { return i % 2 == 0; });
        for (auto i : filter) {
            out << i << ' ';
        }
        CHECK(out.str() == "2 4 6 8 ");
    }

    SUBCASE("none successful")
    {
        vector<int> nums{1, 3, 5, 7};
        auto filter = sequence_filter(nums, [](int i) { return i % 2 == 0; });
        for (auto i : filter) {
            out << i << " ";
        }
        CHECK(out.str() == "");
    }
}
