#include "base/random.h"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest/doctest.h>

auto rng = RandomGenerator{};

TEST_CASE("uniform integer")
{
    SUBCASE("signed")
    {
        bool lower_bound = false;
        bool upper_bound = false;
        for (auto i = 0; i < 100; ++i) {
            auto r = rng.uni(-5, 5);
            CHECK(-5 <= r);
            CHECK(r <= 5);
            if (r == -5)
                lower_bound = true;
            if (r == 5)
                upper_bound = true;
        }
        CHECK(lower_bound);
        CHECK(upper_bound);
        auto r = rng.uni(std::numeric_limits<int32_t>::min(), std::numeric_limits<int32_t>::max());
        CHECK(std::numeric_limits<int32_t>::min() <= r);
        CHECK(r <= std::numeric_limits<int32_t>::max());
        r = rng.uni(5, 6);
        CHECK(5 <= r);
        CHECK(r <= 6);
        r = rng.uni(5, 5);
        CHECK(r == 5);
        r = rng.uni(-5, -5);
        CHECK(r == -5);
        r = rng.uni(0, 0);
        CHECK(r == 0);
    }
    SUBCASE("unsigned")
    {
        bool lower_bound = false;
        bool upper_bound = false;
        for (auto i = 0; i < 100; ++i) {
            auto r = rng.uni(5u, 10u);
            CHECK(5u <= r);
            CHECK(r <= 10u);
            if (r == 5u)
                lower_bound = true;
            if (r == 10u)
                upper_bound = true;
        }
        CHECK(lower_bound);
        CHECK(upper_bound);
        auto r = rng.uni(std::numeric_limits<uint32_t>::min(), std::numeric_limits<uint32_t>::max());
        CHECK(std::numeric_limits<uint32_t>::min() <= r);
        CHECK(r <= std::numeric_limits<uint32_t>::max());
        r = rng.uni(5, 6);
        CHECK(5 <= r);
        CHECK(r <= 6);
        r = rng.uni(5, 5);
        CHECK(r == 5);
        r = rng.uni(0, 0);
        CHECK(r == 0);
        r = rng.uni(5u);
        CHECK(r <= 5);
        r = rng.uni(1u);
        CHECK(r <= 1);
        r = rng.uni(0u);
        CHECK(r == 0u);
    }
}

TEST_CASE("uniform floating point")
{
    for (auto i = 0; i < 100; ++i) {
        auto r = rng.uni_r(-2, 2);
        CHECK(-2 <= r);
        CHECK(r < 2);
    }
    auto r = rng.uni_r(std::numeric_limits<double>::lowest(), std::numeric_limits<double>::max());
    CHECK(std::numeric_limits<double>::lowest() <= r);
    CHECK(r <= std::numeric_limits<double>::max());
    r = rng.uni_r(5, 6);
    CHECK(5 <= r);
    CHECK(r < 6);
    r = rng.uni_r(std::numeric_limits<double>::lowest(), 0);
    CHECK(r < 0);
    r = rng.uni_r(0, std::numeric_limits<double>::max());
    CHECK(r >= 0);
}