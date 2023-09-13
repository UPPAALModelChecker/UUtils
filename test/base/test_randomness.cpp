// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-

#include "base/random.h"

#include <boost/math/distributions/chi_squared.hpp>
#include <boost/math/distributions/uniform.hpp>
#include <boost/math/special_functions/beta.hpp>

#include <iomanip>
#include <iostream>
#include <limits>
#include <numeric>
#include <random>
#include <cmath>

static double fracInRange(const std::vector<int>& values, int length, double from, double till)
{
    double count = 0;
    for (int i = 0; i < length; ++i)
        if (from <= values[i] && values[i] < till)
            count++;
    return count / length;
}

using boost::math::chi_squared;
using boost::math::complement;
using boost::math::quantile;

using std::cout;
using std::endl;

static bool frequency_analysis(int n, const std::vector<int>& values, int range, double alpha)
{
    const auto sqrt_n = std::sqrt(n);
    auto sum = 0., sumsq = 0.;
    auto minv = std::numeric_limits<double>::infinity();
    auto maxv = -std::numeric_limits<double>::infinity();
    double chi2 = 0;  // Pearsons chi square test

    cout << "_________________________________________" << endl;
    cout << "Frequency analysis (vs. expected values):" << endl;
    cout << "Boundary values: " << values[0] << ", ..., " << values[range - 1] << endl;

    for (int i = 0; i < range; ++i) {
        if (values[i] < 0)
            cout << i << endl;
        if (values[i] == 0) {
            cout << "value " << i << " was never generated." << endl;
            exit(EXIT_FAILURE);
        }
        sum += values[i];
        sumsq += values[i] * values[i];
        if (values[i] < minv)
            minv = values[i];
        if (values[i] > maxv)
            maxv = values[i];
        chi2 += 1.0 * (values[i] - n) * (values[i] - n) / n;
    }
    double mean = sum / range;
    double var = sumsq / range - sum / range * sum / range;
    double Sd = sqrt(var);
    double skewness = 0, kurtosis = 0;
    for (int i = 0; i < range; ++i) {
        double g = (double)values[i] - mean;
        double g2 = g * g;
        skewness += g2 * g;
        kurtosis += g2 * g2;
    }
    skewness /= range * var * Sd;
    kurtosis = kurtosis / range / var / var - 3;
    cout << "Range:    " << minv << " .. " << maxv << endl;
    cout << "Mean:     " << std::fixed << std::setprecision(4) << mean << " (" << n << ")" << endl;
    cout << "Sd^2:     " << var << " (" << n << ")" << endl;
    cout << "Sd:       " << Sd << " (" << sqrt_n << ")" << endl;
    cout << "Sd/mean:  " << std::fixed << std::setprecision(4) << Sd / mean << " (" << sqrt_n / mean << ")" << endl;
    cout << "  -3*Sd:  " << fracInRange(values, range, 0, mean - 3 * Sd) * 100 << "% (0.1%)" << endl;
    cout << "-3-2*Sd:  " << fracInRange(values, range, mean - 3 * Sd, mean - 2 * Sd) * 100 << "% (2.1%)" << endl;
    cout << "-2-1*Sd:  " << fracInRange(values, range, mean - 2 * Sd, mean - 1 * Sd) * 100 << "% (13.6%)" << endl;
    cout << "-1-0*Sd:  " << fracInRange(values, range, mean - Sd, mean) * 100 << "% (34.1%)" << endl;
    cout << "+0-1*Sd:  " << fracInRange(values, range, mean, mean + 1 * Sd) * 100 << "% (34.1%)" << endl;
    cout << "+1-2*Sd:  " << fracInRange(values, range, mean + 1 * Sd, mean + 2 * Sd) * 100 << "% (13.6%)" << endl;
    cout << "+2-3*Sd:  " << fracInRange(values, range, mean + 2 * Sd, mean + 3 * Sd) * 100 << "% (2.1%)" << endl;
    cout << "+3- *Sd:  " << fracInRange(values, range, mean + 3 * Sd, std::numeric_limits<double>::infinity()) * 100
         << "% (0.1%)" << endl;
    cout << "Skew:     " << skewness << " (0.0)" << endl;
    cout << "Kurtosis: " << kurtosis << " (0.0)" << endl;

    boost::math::chi_squared dist(range - 1);
    const double lower_Sd = sqrt((range - 1) * var / quantile(complement(dist, alpha / 2)));
    const double upper_Sd = sqrt((range - 1) * var / quantile(dist, alpha / 2));

    cout << "________________________________________" << endl;
    cout << "Chi-square test for normal distribution:" << endl;
    cout << "Chi^2:   " << chi2 << " (" << range << ")" << endl;
    cout << "Sd lower: " << lower_Sd << endl;
    cout << "Sd upper: " << upper_Sd << endl;
    if (lower_Sd <= sqrt_n && sqrt_n <= upper_Sd) {  // check whether the interval covers the expected
        cout << "Test passed with " << alpha << " significance (probability of failure)." << endl;
        return true;
    } else {
        cout << "Sample was not good enough for " << alpha << " significance (probability of failure)." << endl;
        return false;
    }
}

/** returns true if passed, otherwise false. */
static bool floating_point_test(int n, int range, int offset, double alpha)
{
    auto values = std::vector<int>(range, 0);
    auto rand = RandomGenerator{};
    rand.seed((uint32_t)time(nullptr));
    cout << "_________________________________________" << endl;
    cout << "Random FLOATING POINT number test" << endl;
    cout << "Generating " << (n * range) << " random numbers from a range of " << range << "... ";
    cout.flush();
    for (int i = 0; i < n * range; ++i) {
        int r = (int)floor(rand.uni(offset, offset + range)) - offset;
        if (r >= 0 && r < range)
            values[r]++;
        else {
            cout << "range check failed" << endl;
            exit(EXIT_FAILURE);
        }
    }
    cout << endl;
    return frequency_analysis(n, values, range, alpha);
}

/** returns true if passed, otherwise false. */
static bool integer_test(int n, int range, int offset, double alpha)
{
    auto values = std::vector<int>(range, 0);
    auto rand = RandomGenerator{};
    rand.seed((uint32_t)time(nullptr));
    cout << "_________________________________________" << endl;
    cout << "Random INTEGER test" << endl;
    cout << "Generating " << (n * range) << " random numbers from a range of " << range << "... ";
    cout.flush();
    for (int i = 0; i < n * range; ++i) {
        int r = rand.uni(offset, offset + range - 1) - offset;
        if (r >= 0 && r < range)
            values[r]++;
        else {
            cout << "range check failed" << endl;
            exit(EXIT_FAILURE);
        }
    }
    cout << endl;
    return frequency_analysis(n, values, range, alpha);
}

struct step_t
{
    double from, till;
    double value{0};
};

std::ostream& operator<<(std::ostream& os, const std::vector<step_t>& fn)
{
    constexpr auto max_width = 80u;
    auto max_value = std::numeric_limits<double>::min();
    for (auto& step : fn)
        if (max_value < step.value)
            max_value = step.value;
    auto total = size_t{0};
    for (auto& step : fn) {
        total += step.value;
        os << '[' << step.from << ',' << step.till << "): " << step.value << ' ';
        if (step.value != 0) {
            auto value = static_cast<double>(step.value) / max_value * max_width;
            if (value < 1)
                os << '.';
            else
                os << std::setfill('#') << std::setw(static_cast<size_t>(value)) << "";
        }
        os << '\n';
    }
    os << "Total: " << total << '\n';
    return os;
}

template <typename Generator>
std::vector<step_t> histogram(Generator&& gen, size_t value_count, size_t bar_count = 30,
                              double min_value = std::numeric_limits<double>::quiet_NaN(),
                              double max_value = std::numeric_limits<double>::quiet_NaN())
{
    if (value_count < 2)
        throw std::logic_error{"need at least 2 values"};
    auto values = std::vector<double>(value_count);
    std::generate(std::begin(values), std::end(values), gen);
    if (std::isnan(min_value))
        min_value = *std::min_element(std::begin(values), std::end(values));
    if (std::isnan(max_value))
        max_value = *std::max_element(std::begin(values), std::end(values));

    auto range = max_value - min_value;
    if (range == 0.0)
        throw std::logic_error{"cannot handle all equal values"};
    auto res = std::vector<step_t>(bar_count);
    res[0].from = min_value;
    for (auto i = 1u; i < bar_count; ++i) {
        res[i].from = min_value + range * i / bar_count;
        res[i - 1].till = res[i].from;
    }
    res.back().till = max_value;
    for (const auto& value : values) {
        auto i = static_cast<size_t>((value - min_value) * bar_count / range);
        if (i == bar_count)
            i = bar_count - 1;
        ++res[i].value;
    }
    return res;
}

/**
 * Computes the chi-squared statistic based on the expected distribution and compares it with chi-squared distribution.
 * @tparam CumFn cummulative count function over the hist domain
 * @param hist histogram -- number of values falling into ranges
 * @param expected expected cummulative distribution function
 * @param alpha the level of significance
 * @return
 */
template <typename CumFn>
void chi_squared_test(const std::vector<step_t>& hist, CumFn&& expected, const double alpha = 0.05)
{
    if (hist.size() < 2)
        throw std::logic_error{"need at least 2 bars"};
    auto chi_sq = 0.;
    for (auto& step : hist) {
        auto observe = static_cast<double>(step.value);
        if (step.till <= step.from)
            throw std::logic_error("step width must be positive");
        auto expect = expected(step.till) - expected(step.from);
        if (expect < 0)
            throw std::logic_error("expected CumFn must be monotonically increasing (PDF cannot be negative)");
        if (expect == 0 && step.value > 0)
            throw std::logic_error("found data where the expected probability is zero");
        auto diff = observe - expect;
        chi_sq += diff * diff / expect;
    }
    auto chi_sq_dist = boost::math::chi_squared_distribution<double>{static_cast<double>(hist.size()) - 1};
    auto lower_critical_value = quantile(chi_sq_dist, alpha / 2);
    auto upper_critical_value = quantile(chi_sq_dist, 1.0 - alpha / 2);
    if (chi_sq < lower_critical_value)
        throw std::logic_error{"data seems to be too good to be random"};
    if (upper_critical_value < chi_sq)
        throw std::logic_error{"data does not follow the expected distribution"};
}

std::vector<step_t> normalize(std::vector<step_t> hist)
{
    auto total = std::accumulate(std::begin(hist), std::end(hist), size_t{0u},
                                 [](size_t init, const step_t step) { return init + step.value; });
    for (auto& step : hist)
        step.value /= total;
    return std::move(hist);
}

auto rng = RandomGenerator();

void test_random_uniform(const size_t value_count = 10000, const double alpha = 0.05)
{
    constexpr auto from = -100.;
    constexpr auto till = 200.;
    constexpr auto range = till - from;
    auto uni_hist = histogram([&]() { return rng.uni_r(from, till); }, value_count, 30, from, till);
    // std::cout << uni_hist;
    auto uni_cum_fn = [&](double x) { return (x - from) / range * value_count; };
    chi_squared_test(uni_hist, uni_cum_fn, alpha);
}

void test_random_triangular(const size_t value_count = 10000, const double alpha = 0.05)
{
    constexpr auto from = -100.;
    constexpr auto till = 200.;
    constexpr auto mode = 100.;
    constexpr auto range = till - from;
    auto tri_hist = histogram([&]() { return rng.tri(from, mode, till); }, value_count, 30, from, till);
    // std::cout << uni_hist;
    auto tri_cum_fn = [&](double x) {
        if (x <= mode)
            return (x - from) * (x - from) / range / (mode - from) * value_count;
        else
            return (1. - (till - x) * (till - x) / range / (till - mode)) * value_count;
    };
    chi_squared_test(tri_hist, tri_cum_fn, alpha);
}

void test_random_exponential(const size_t value_count = 20000, const double alpha = 0.05)
{
    constexpr auto rate = 0.5;
    auto exp_hist = histogram([&]() { return rng.exp(rate); }, value_count, 30, 0);
    // std::cout << exp_hist;
    auto exp_cum_fn = [&](double x) { return (1.0 - std::exp(-rate * x)) * value_count; };
    chi_squared_test(exp_hist, exp_cum_fn, alpha);
}

void test_random_beta(const size_t value_count = 20000, const double alpha = 0.05)
{
    constexpr auto a = 0.5;
    constexpr auto b = 0.5;
    auto beta_hist = histogram([&]() { return rng.beta(a, b); }, value_count, 30, 0, 1);
    // std::cout << beta_hist;
    auto beta_cum_fn = [&](double x) { return boost::math::ibeta(a, b, x) * value_count; };
    chi_squared_test(beta_hist, beta_cum_fn, alpha);
}

void test_random_gamma(const size_t value_count = 20000, const double alpha = 0.05)
{
    constexpr auto shape = 2.;  // k
    constexpr auto scale = 2.;  // theta
    auto gamma_hist = histogram([&]() { return rng.gamma(shape, scale); }, value_count, 30, 0);
    std::cout << gamma_hist;
    auto gamma_cum_fn = [&](double x) { return value_count; };
    chi_squared_test(gamma_hist, gamma_cum_fn, alpha);
}

void test_random_poisson(const size_t value_count = 20000, const double alpha = 0.05)
{
    constexpr auto rate = 0.5;
    auto poisson_hist = histogram([&]() { return rng.poisson(1. / rate); }, value_count, 30, 0);
    // std::cout << exp_hist;
    auto poisson_cum_fn = [&](double x) { return value_count; };
    chi_squared_test(poisson_hist, poisson_cum_fn, alpha);
}

void test_random_arcsine(const size_t value_count = 20000, const double alpha = 0.05)
{
    constexpr auto from = -100.;
    constexpr auto till = 200.;
    constexpr auto range = till - from;
    auto arcsine_hist = histogram([&]() { return rng.arcsine(from, till); }, value_count, 30, from, till);
    // std::cout << arcsine_hist;
    auto arcsine_cum_fn = [&](double x) { return 2. / M_PI * std::asin(std::sqrt(x)) * value_count; };
    chi_squared_test(arcsine_hist, arcsine_cum_fn, alpha);
}

void test_random_weibull(const size_t value_count = 20000, const double alpha = 0.05)
{
    constexpr auto shape = 1.5;  // k
    constexpr auto scale = 1.;   // lambda
    auto weibull_hist = histogram([&]() { return rng.weibull(shape, scale); }, value_count, 30, 0);
    // std::cout << weibull_hist;
    auto weibull_cum_fn = [&](double x) { return (1. - std::exp(-std::pow(x / scale, shape))) * value_count; };
    chi_squared_test(weibull_hist, weibull_cum_fn, alpha);
}

int main(const int, const char*[])
{
    test_random_uniform();
    test_random_triangular();
    test_random_exponential();
    test_random_beta();
    test_random_arcsine();
    test_random_weibull();
    const int n = 30000;
    const int range = 2000;
    const int offset = 5000;
    const double alpha = 0.01;  // level of significance (probability of failure)
    if (integer_test(n, range, offset, alpha)) {
        if (floating_point_test(n, range, offset, alpha)) {
            return 0;
        } else {
            return 1;
        }
    } else {
        return 1;
    }
}
