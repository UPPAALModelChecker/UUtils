#include "hash/compute.h"

#include <algorithm>
#include <random>
#include <vector>

#define XXH_INLINE_ALL
#include <xxhash.h>

#include <benchmark/benchmark.h>

/**
 * Benchmarks can be plotted using plot.py:
 * https://github.com/lakshayg/google_benchmark_plot
 * For example:
 * ./bm_compute --benchmark_format=csv > bm_compute.csv
 * plot.py -f bm_compute.csv --logx --title "Linux 64" -r bm_xxhash3
 */

auto rdev = std::random_device{};
auto rng = std::mt19937{rdev()};
auto dist = std::uniform_int_distribution<uint8_t>{0, 255};
auto seed = std::uniform_int_distribution<uint32_t>()(rng);

std::vector<uint8_t> random_data(size_t size)
{
    auto res = std::vector<uint8_t>(size);
    std::generate(std::begin(res), std::end(res), [] { return dist(rng); });
    return res;
};

// uint32_t hash_murmur2_U8(const uint8_t *data, size_t length, uint32_t initval);

static void bm_murmur2(benchmark::State& state)
{
    auto data = random_data(state.range(0));
    for (auto _ : state) {
        auto res = hash_murmur2_U8(data.data(), data.size(), seed);
        benchmark::DoNotOptimize(res);
        benchmark::ClobberMemory();
    }
}
BENCHMARK(bm_murmur2)->Range(8, 8 << 18);

static void bm_xxhash3(benchmark::State& state)
{
    auto data = random_data(state.range(0));
    for (auto _ : state) {
        auto res = XXH3_64bits_withSeed(data.data(), data.size(), seed);
        benchmark::DoNotOptimize(res);
        benchmark::ClobberMemory();
    }
}
BENCHMARK(bm_xxhash3)->Range(8, 8 << 18);

static void bm_xxhash128(benchmark::State& state)
{
    auto data = random_data(state.range(0));
    for (auto _ : state) {
        auto res = XXH3_128bits_withSeed(data.data(), data.size(), seed);
        benchmark::DoNotOptimize(res);
        benchmark::ClobberMemory();
    }
}
BENCHMARK(bm_xxhash128)->Range(8, 8 << 18);

static void bm_xxhash64(benchmark::State& state)
{
    auto data = random_data(state.range(0));
    for (auto _ : state) {
        auto res = XXH64(data.data(), data.size(), seed);
        benchmark::DoNotOptimize(res);
        benchmark::ClobberMemory();
    }
}
BENCHMARK(bm_xxhash64)->Range(8, 8 << 18);

static void bm_xxhash32(benchmark::State& state)
{
    auto data = random_data(state.range(0));
    for (auto _ : state) {
        auto res = XXH32(data.data(), data.size(), seed);
        benchmark::DoNotOptimize(res);
        benchmark::ClobberMemory();
    }
}
BENCHMARK(bm_xxhash32)->Range(8, 8 << 18);

static void bm_hash_compute(benchmark::State& state)
{
    auto data = random_data(state.range(0));
    for (auto _ : state) {
        auto res = hash_compute(data, seed);
        benchmark::DoNotOptimize(res);
        benchmark::ClobberMemory();
    }
}
BENCHMARK(bm_hash_compute)->Range(8, 8 << 18);

static void bm_murmur2_2(benchmark::State& state)
{
    auto data = random_data(state.range(0));
    for (auto _ : state) {
        auto res = hash_murmur2_U8(data.data(), data.size(), seed);
        benchmark::DoNotOptimize(res);
        benchmark::ClobberMemory();
    }
}
BENCHMARK(bm_murmur2_2)->Range(8, 8 << 18);
