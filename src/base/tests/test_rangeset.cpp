#include "base/rangeset.h"

#define DOCTEST_CONFIG_IMPLEMENT_WITH_MAIN
#include <doctest.h>
#include <vector>

using namespace base;
using UTAP::range_t;

TEST_CASE("range type")
{
    const auto ref = range_t(10, 20);

    SUBCASE("strictly below")
    {
        const auto r = range_t(3, 7);
        CHECK(r < ref);
        CHECK(r <= ref);
        CHECK(!(r >= ref));
        CHECK(!(r > ref));
        CHECK((r & ref).empty());
    }

    SUBCASE("strictly above")
    {
        const auto r = range_t(23, 27);
        CHECK(r > ref);
        CHECK(r >= ref);
        CHECK(!(r <= ref));
        CHECK(!(r < ref));
        CHECK((r & ref).empty());
    }

    SUBCASE("below")
    {
        const auto r = range_t(3, 17);
        CHECK(!(r < ref));
        CHECK(r <= ref);
        CHECK(r >= ref);
        CHECK(!(r > ref));
        CHECK(!(r & ref).empty());
    }

    SUBCASE("above")
    {
        const auto r = range_t(13, 27);
        CHECK(!(r < ref));
        CHECK(r <= ref);
        CHECK(r >= ref);
        CHECK(!(r > ref));
        CHECK(!(r & ref).empty());
    }

    SUBCASE("inside")
    {
        const auto r = range_t(13, 17);
        CHECK(!(r < ref));
        CHECK(r <= ref);
        CHECK(r >= ref);
        CHECK(!(r > ref));
        CHECK(!(r & ref).empty());
    }

    SUBCASE("outside")
    {
        const auto r = range_t(3, 27);
        CHECK(!(r < ref));
        CHECK(r <= ref);
        CHECK(r >= ref);
        CHECK(!(r > ref));
        CHECK(!(r & ref).empty());
    }

    SUBCASE("intersection and membership")
    {
        const auto empty = range_t(0, -1);
        CHECK(empty.empty());
        CHECK(!ref.empty());
        CHECK((ref & 5).empty());
        CHECK(!(ref && 5));
        CHECK(!(ref & 15).empty());
        CHECK((ref && 15));
        CHECK((ref & 25).empty());
        CHECK(!(ref && 25));
        const auto ref15 = (ref | 15);
        CHECK((ref15 && 15));
        const auto ref25 = ref | 25;
        CHECK((ref25 && 25));
        CHECK((ref25 && 23));  // convex
    }

    SUBCASE("union")
    {
        const auto first = rangeset_t(0, 1);
        CHECK(!first.empty());
        const auto second = rangeset_t(1, 2);
        CHECK(!second.empty());
        const auto third = rangeset_t(2, 3);
        CHECK(!third.empty());
        const auto fourth = rangeset_t(3, 4);
        CHECK(!fourth.empty());
        const auto two = first | second;
        CHECK(two == rangeset_t(0, 2));
        const auto three = first | third;
        CHECK(three == rangeset_t(0, 3));
        const auto four = first | fourth;
        CHECK(four == rangeset_t(range_t(0, 1), range_t(3, 4)));
        CHECK(!(four && 2));
    }

    SUBCASE("plus")
    {
        auto r = range_t(1, 2);
        r += range_t(9, 18);
        CHECK(r == ref);
    }

    SUBCASE("multiplication")
    {
        auto r = range_t(1, 2);
        r *= range_t(10, 10);
        CHECK(r == ref);

        auto r2 = range_t(5, 5);
        r2 *= range_t(2, 4);
        CHECK(r2 == ref);
    }

    SUBCASE("negative multiplication")
    {
        auto r = range_t(-2, 2);
        r *= range_t(-2, 2);
        CHECK(r == range_t(-4, 4));

        auto r2 = range_t(1, 2);
        r2 *= range_t(-2, -1);
        CHECK(r2 == range_t(-4, -1));
    }
}

TEST_CASE("rangeset")
{
    SUBCASE("construction")
    {
        auto rs0 = rangeset_t<int>();
        CHECK(rs0.empty());
        auto rs1 = rangeset_t(5);
        CHECK(rs1.size() == 1);
        auto rs2 = rangeset_t(5, 10);
        CHECK(rs2.size() == 6);
        auto range = range_t(20, 30);
        auto rs3 = rangeset_t(range);
        CHECK(rs3.size() == 11);
        rs3 |= rs2;
        CHECK(rs3.size() == 17);
        auto rs4 = rs3;
        CHECK(rs4.size() == 17);
        auto rs5 = std::move(rs3);
        CHECK(rs5.size() == 17);
        CHECK(rs3.size() == 0);
    }

    SUBCASE("with elements")
    {
        auto rs = rangeset_t<int>();
        CHECK(rs.empty());
        const auto r = range_t(10, 20);
        rs |= r;
        CHECK(!rs.empty());
        CHECK(rs.size() == 11);
        CHECK(!(rs && 9));
        CHECK((rs && 10));
        CHECK((rs && 15));
        CHECK((rs && 20));
        CHECK(!(rs && 21));
        CHECK((rs && range_t(5, 15)));
        rs |= range_t(30, 40);
        CHECK(!rs.empty());
        CHECK(rs.size() == 22);
        CHECK(!(rs && 5));
        CHECK((rs && 15));
        CHECK(!(rs && 25));
        CHECK((rs && 35));
        CHECK(!(rs && 45));
    }

    SUBCASE("with ranges")
    {
        auto os = std::ostringstream();
        auto rs = rangeset_t<int>();
        CHECK(rs.empty());
        const auto r1 = range_t(10, 20);
        rs |= r1;
        CHECK(!rs.empty());
        CHECK(rs.size() == 11);
        rs |= range_t(15, 25);
        CHECK(rs.size() == 16);
        CHECK(!(rs && 5));
        CHECK((rs && 15));
        CHECK((rs && 25));
        CHECK(!(rs && 30));
        CHECK((rs && range_t(5, 15)));
        rs |= range_t(30, 40);
        CHECK(rs.size() == 27);
        rs |= range_t(35, 45);
        os.str("");
        os << rs;
        CHECK(os.str() == "[10,25],[30,45]");
        CHECK(rs.size() == 32);
        CHECK(!(rs && 5));
        CHECK((rs && 15));
        CHECK((rs && 23));
        CHECK(!(rs && 28));
        CHECK((rs && 35));
        CHECK((rs && 43));
        CHECK(!(rs && 50));
        rs &= range_t(22, 32);
        os.str("");
        os << rs;
        CHECK(os.str() == "[22,25],[30,32]");
        CHECK(rs.size() == 7);
        CHECK(!(rs && 21));
        CHECK((rs && 22));
        CHECK((rs && 25));
        CHECK(!(rs && 26));
        CHECK(!(rs && 29));
        CHECK((rs && 30));
        CHECK((rs && 32));
        CHECK(!(rs && 33));
        rs |= range_t(0, 1);
        rs |= range_t(3, 4);
        rs |= range_t(5, 6);
        rs |= range_t(8, 9);
        rs |= range_t(11, 12);
        auto other = rs;
        rs &= range_t(5, 8);
        os.str("");
        os << rs;
        CHECK(os.str() == "[5,6],[8,8]");
        rs = other;
        rs &= range_t(5, 10);
        os.str("");
        os << rs;
        CHECK(os.str() == "[5,6],[8,9]");
        rs = other;
        CHECK((rs & -1).empty());
        CHECK((rs & 100).empty());
        CHECK((rs & 10).empty());
        rs.clear();
        rs |= range_t(20, 30);
        rs |= range_t(5, 10);
        os.str("");
        os << rs;
        CHECK(os.str() == "[5,10],[20,30]");
        rs.clear();
        rs |= range_t(-1, 9);
        rs |= range_t(15, 16);
        os.str("");
        os << rs;
        CHECK(os.str() == "[-1,9],[15,16]");
        os.str("");
        auto rsx = rangeset_t(3, 7) | range_t(9, 13);
        os << rsx;
        CHECK(os.str() == "[3,7],[9,13]");
        os.str("");
    }

    SUBCASE("with other rangesets")
    {
        auto os = std::ostringstream();
        auto rs1 = rangeset_t(10, 20);
        rs1 |= range_t(110, 120);
        rs1 |= range_t(30, 40);
        rs1 |= range_t(90, 100);
        rs1 |= range_t(50, 60);
        rs1 |= range_t(70, 80);
        rs1 |= range_t(130, 140);
        os.str("");
        os << rs1;
        CHECK(os.str() == "[10,20],[30,40],[50,60],[70,80],[90,100],[110,120],[130,140]");
        auto rs2 = rangeset_t(123, 127);  // outside below
        rs2 |= range_t(93, 97);           // overlap inside
        rs2 |= range_t(105, 115);         // overlap below
        rs2 |= range_t(35, 45);           // overlap above
        rs2 |= range_t(3, 7);             // outside among
        os.str("");
        os << rs2;
        CHECK(os.str() == "[3,7],[35,45],[93,97],[105,115],[123,127]");
        os.str("");
        os << (rs1 | rs2);
        CHECK(os.str() == "[3,7],[10,20],[30,45],[50,60],[70,80],[90,100],[105,120],[123,127],[130,140]");
        os.str("");
        os << (rs2 | rs1);
        CHECK(os.str() == "[3,7],[10,20],[30,45],[50,60],[70,80],[90,100],[105,120],[123,127],[130,140]");
        CHECK((rs1 | rs2) == (rs2 | rs1));

        os.str("");
        os << (rs1 & rs2);
        CHECK(os.str() == "[35,40],[93,97],[110,115]");
        os.str("");
        os << (rs2 & rs1);
        CHECK(os.str() == "[35,40],[93,97],[110,115]");
        CHECK((rs1 & rs2) == (rs2 & rs1));

        CHECK((rs1 | rs2) != (rs1 & rs2));
        auto rs = rangeset_t(-1, -1);
        rs |= range_t(0, 1);
        rs |= range_t(3, 4);
        rs |= range_t(5, 6);
        rs |= range_t(8, 9);
        rs |= range_t(11, 12);
        auto other = rs;
        CHECK((rs | other) == other);
    }

    SUBCASE("subtraction")
    {
        auto os = std::ostringstream();
        auto rs1 = rangeset_t(-17, -10);
        rs1 |= range_t(-8, -1);
        rs1 |= range_t(2, 2);
        rs1 |= range_t(9, 10);

        auto rs2 = rangeset_t(std::numeric_limits<int32_t>::min(), 0);
        rs1 -= rs2;

        os << rs1;
        REQUIRE(os.str() == "[2,2],[9,10]");
    }

    SUBCASE("dense sets")
    {
        auto os = std::ostringstream();
        rangeset_t<int> rs;
        for (int i = 0; i < 10; ++i)
            rs |= i;
        os.str("");
        os << rs;
        CHECK(os.str() == "[0,9]");
        rs |= range_t(-1, 0);
        os.str("");
        os << rs;
        CHECK(os.str() == "[-1,9]");
        rs |= range_t(-1, 0);
        os.str("");
        os << rs;
        CHECK(os.str() == "[-1,9]");
        rs |= range_t(15, 16);
        rs |= range_t(10, 14);
        os.str("");
        os << rs;
        CHECK(os.str() == "[-1,16]");
    }

    SUBCASE("iterators")
    {
        auto os = std::ostringstream();
        rangeset_t<int> rs;
        for (int i = 0; i < 10; ++i)
            rs |= i;
        os.str("");
        for (auto i : rs)
            os << i << ",";
        CHECK(os.str() == "0,1,2,3,4,5,6,7,8,9,");
        rs |= range_t(20, 30);
        rs |= range_t(44, 44);
        rs |= range_t(50, 51);
        os.str("");
        for (auto i : rs)
            os << i << ",";
        CHECK(os.str() == "0,1,2,3,4,5,6,7,8,9,20,21,22,23,24,25,26,27,28,29,30,44,50,51,");
    }
}

TEST_CASE("rangeset subtraction")
{
    auto rs = rangeset_t{5, 15};
    auto os = std::ostringstream{};
    os << rs;
    CHECK(os.str() == "[5,15]");
    os.str("");

    SUBCASE("with element type")
    {
        os << rs - 10;
        CHECK(os.str() == "[5,9],[11,15]");
        os.str("");
        os << rs - 7 - 13;
        CHECK(os.str() == "[5,6],[8,12],[14,15]");
    }
    SUBCASE("with range type")
    {
        os << rs - range_t(8, 12);
        CHECK(os.str() == "[5,7],[13,15]");
    }
    SUBCASE("with rangeset type")
    {
        os << rs - (rangeset_t(7, 8) | range_t(11, 13));
        CHECK(os.str() == "[5,6],[9,10],[14,15]");
        os.str("");
        os << rs - rangeset_t(7, 8) - range_t(11, 13);
        CHECK(os.str() == "[5,6],[9,10],[14,15]");
    }
    SUBCASE("below")
    {
        os << rs - rangeset_t(1, 3);
        CHECK(os.str() == "[5,15]");
    }
    SUBCASE("above")
    {
        os << rs - rangeset_t(20, 30);
        CHECK(os.str() == "[5,15]");
    }
    SUBCASE("multiple")
    {
        os << rs - (rangeset_t(1, 3) | range_t(7, 8) | range_t(11, 13) | range_t(20, 30));
        CHECK(os.str() == "[5,6],[9,10],[14,15]");
    }
    SUBCASE("overlapping")
    {
        os << rs - (rangeset_t(1, 6) | range_t(10, 12) | range_t(15, 20));
        CHECK(os.str() == "[7,9],[13,14]");
    }
    SUBCASE("at bounds")
    {
        os << rs - (rangeset_t(1, 6) | range_t(5, 7) | range_t(13, 15) | range_t(20, 30));
        CHECK(os.str() == "[8,12]");
    }
    SUBCASE("many with many")
    {
        auto rs1 = rangeset_t(10, 20) | range_t(30, 40) | range_t(50, 60) | range_t(70, 80);
        auto rs2 = rangeset_t(1, 3) | range_t(6, 8) | range_t(10, 12) | range_t(15, 17) | range_t(23, 25) |
                   range_t(27, 28) | range_t(32, 35) | range_t(38, 45) | range_t(54, 56) | range_t(59, 60) |
                   range_t(85, 90);
        os << (rs1 - rs2);
        CHECK(os.str() == "[13,14],[18,20],[30,31],[36,37],[50,53],[57,58],[70,80]");
    }
}

constexpr auto d_inf = std::numeric_limits<double>::infinity();
constexpr auto d_ninf = -d_inf;

TEST_CASE("rangeset floating point")
{
    auto rs = rangeset_t{5., 15.};
    auto os = std::ostringstream();
    os << rs;
    CHECK(os.str() == "[5,15]");
    os.str("");

    SUBCASE("disjoint union")
    {
        rs |= range_t{20., 30.};
        os << rs;
        CHECK(os.str() == "[5,15],[20,30]");
    }

    SUBCASE("overlapping union")
    {
        rs |= range_t{10., 20.};
        os << rs;
        CHECK(os.str() == "[5,20]");
    }

    SUBCASE("infinit range union")
    {
        rs |= range_t{30., d_inf};
        os << rs;
        CHECK(os.str() == "[5,15],[30,inf]");
    }

    SUBCASE("infinit range union twice")
    {
        rs |= range_t{30., d_inf};
        rs |= range_t{20., d_inf};
        os << rs;
        CHECK(os.str() == "[5,15],[20,inf]");
    }

    SUBCASE("infinity union")
    {
        rs |= range_t{d_inf, d_inf};
        os << rs;
        CHECK(os.str() == "[5,15],[inf,inf]");
    }

    SUBCASE("infinity union twice")
    {
        rs |= range_t{d_inf, d_inf};
        rs |= range_t{d_inf, d_inf};
        os << rs;
        CHECK(os.str() == "[5,15],[inf,inf]");
    }

    SUBCASE("negative infinity union")
    {
        rs |= range_t{d_ninf, d_ninf};
        os << rs;
        CHECK(os.str() == "[-inf,-inf],[5,15]");
    }

    SUBCASE("dense check")
    {
        rs |= range_t{20., 30.};
        rs &= range_t{16.3, 30.};
        os << rs;
        CHECK(os.str() == "[20,30]");
    }
    SUBCASE("identical")
    {
        rs -= rangeset_t{5., 15.};
        CHECK(rs.empty());
    }
}

TEST_CASE("rangeset floating point intersect")
{
    auto rs = rangeset_t<double>(1, 10);
    auto os = std::ostringstream();
    os << rs;
    CHECK(os.str() == "[1,10]");

    SUBCASE("simple intersect")
    {
        rs -= range_t<double>(UTAP::next_value(5.5), UTAP::prev_value(5.7));
        os.str("");
        os << rs;
        CHECK(os.str() == "[1,5.5],[5.7,10]");
    }

    SUBCASE("simple begin intersect")
    {
        rs -= range_t<double>(UTAP::next_value(0.), UTAP::prev_value(1.5));
        os.str("");
        os << rs;
        CHECK(os.str() == "[1.5,10]");
    }

    SUBCASE("simple end intersect")
    {
        rs -= range_t<double>(UTAP::next_value(9.5), UTAP::prev_value(11.0));
        os.str("");
        os << rs;
        CHECK(os.str() == "[1,9.5]");
    }
}

TEST_CASE("rangeset floating point subtraction")
{
    SUBCASE("infinit-infinit = empty")
    {
        // For relative complement, it must be true that A∖A = ∅
        // Even if infinity is in the set
        auto rs = rangeset_t{0., d_inf};
        rs -= rangeset_t{0., d_inf};
        CHECK(rs.empty());
    }

    SUBCASE("negatively infinit - negatively infinit = empty")
    {
        // For relative complement, it must be true that A∖A = ∅
        // Even if -infinity is in the set
        auto rs = rangeset_t{-d_inf, 0.};
        rs -= rangeset_t{-d_inf, 0.};
        CHECK(rs.empty());
    }

    SUBCASE("infinit-infinit = something")
    {
        auto rs = rangeset_t{0., d_inf};
        rs -= rangeset_t{1., d_inf};
        CHECK(rs == rangeset_t{0., UTAP::prev_value(1.)});
    }

    SUBCASE("negatively infinit - negatively infinit = something")
    {
        // For relative complement, it must be true that A∖A = ∅
        // Even if -infinity is in the set
        auto rs = rangeset_t{-d_inf, 0.};
        rs -= rangeset_t{-d_inf, -1.};
        CHECK(rs == rangeset_t{UTAP::next_value(-1.), 0.});
    }

    SUBCASE("infinite range - infinity = max range")
    {
        constexpr auto d_max = std::numeric_limits<double>::max();
        auto rs = rangeset_t{0., d_inf};
        rs -= rangeset_t{d_inf, d_inf};
        CHECK(rs == rangeset_t{0., d_max});
    }
}

TEST_CASE("rangeset plus")
{
    auto rs = rangeset_t<int>();
    rs |= range_t<int>(4, 4);
    rs |= range_t<int>(10, 10);
    auto os = std::ostringstream();
    os << rs;
    CHECK(os.str() == "[4,4],[10,10]");
    os.str("");

    SUBCASE("[4,4],[10,10] plus [0,2] minus [0,2] minus [0,2]")
    {
        auto r = range_t<int>(0, 2);
        rs.plus(r);
        os.str("");
        os << rs;
        CHECK(os.str() == "[4,6],[10,12]");
        rs.minus(range_t<int>(0, 2));
        os.str("");
        os << rs;
        CHECK(os.str() == "[2,6],[8,12]");
        rs.minus(range_t<int>(0, 2));
        os.str("");
        os << rs;
        CHECK(os.str() == "[0,12]");
    }

    SUBCASE("[4,4],[10,10] plus 2")
    {
        rs.plus(2);
        os.str("");
        os << rs;
        CHECK(os.str() == "[6,6],[12,12]");
    }

    SUBCASE("[4,4],[10,10] plus [1,10]")
    {
        rs.plus(range_t<int>(1, 10));
        os.str("");
        os << rs;
        CHECK(os.str() == "[5,20]");
    }
}

TEST_CASE("range type contains")
{
    auto rs = rangeset_t<double>();
    rs |= range_t<double>(4, 4);
    rs |= range_t<double>(10, 10);
    SUBCASE("[4,4],[10,10] contains 4, 10")
    {
        CHECK(rs.contains(4));
        CHECK(!rs.contains(5));
        CHECK(rs.contains(10));
        CHECK(!rs.contains(11));
        CHECK(!rs.contains(20));
    }

    SUBCASE("[4, 5] contains")
    {
        rs |= range_t<double>(4, 5);
        CHECK(rs.contains(4));
        CHECK(rs.contains(4.1));
        CHECK(rs.contains(4.2));
        CHECK(rs.contains(4.3));
        CHECK(rs.contains(4.4));
        CHECK(rs.contains(4.5));
        CHECK(rs.contains(4.6));
        CHECK(rs.contains(4.6));
        CHECK(rs.contains(4.7));
        CHECK(rs.contains(4.9));
        CHECK(rs.contains(5.0));
    }

    SUBCASE("some pi contains")
    {
        auto rs = rangeset_t<double>();
        rs |= range_t<double>(0, 1.57);
        rs |= range_t<double>(3.14, 4.71);
        CHECK(rs.contains(0));
        CHECK(rs.contains(1));
        CHECK(!rs.contains(2));
        CHECK(!rs.contains(3));
        CHECK(rs.contains(4));
    }
}
