#include "base/random.h"

#include <boost/random/uniform_real_distribution.hpp>
#include <boost/random/exponential_distribution.hpp>
#include <boost/random.hpp>

#include <iostream>
#include <map>
#include <random>
#include <chrono>

struct result_t
{
    double mean;
    double seconds;
};

template <typename Generator>
result_t benchmark_random(Generator&& gen, size_t count = 100'000'000u)
{
    auto res = std::vector<double>(count);
    auto t0 = std::chrono::high_resolution_clock::now();
    std::generate(std::begin(res), std::end(res), gen);
    auto t1 = std::chrono::high_resolution_clock::now();
    auto sum = std::accumulate(std::begin(res), std::end(res), 0.);
    return { sum / count, std::chrono::duration<double>(t1-t0).count() };
}

constexpr auto from = -100.;
constexpr auto till =  200.;
constexpr auto rate = 0.5;

auto rd = std::random_device{};
auto std_gen = std::mt19937{rd()};
auto std_uni = std::uniform_real_distribution<double>{from,till};
auto std_exp = std::exponential_distribution<double>{rate};

auto boost_gen = boost::random::mt19937{rd()};
auto boost_uni = boost::random::uniform_real_distribution<double>{from, till};
auto boost_exp = boost::random::exponential_distribution<double>{rate};

RandomGenerator rng;

int main()
{
    auto res = std::map<std::string, result_t>{};
    res["uni   std"] = benchmark_random([](){ return std_uni(std_gen); });
    res["uni boost"] = benchmark_random([](){ return boost_uni(boost_gen); });
    res["uni   rng"] = benchmark_random([](){ return rng.uni_r(from, till); });

    res["exp   std"] = benchmark_random([](){ return std_exp(std_gen); });
    res["exp boost"] = benchmark_random([](){ return boost_exp(boost_gen); });
    res["exp   rng"] = benchmark_random([](){ return rng.exp(rate); });

    for (auto& [name, res]: res)
        std::cout << name << ": " << res.mean << " in " << res.seconds << "\n";
}