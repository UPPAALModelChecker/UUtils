// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-
///////////////////////////////////////////////////////////////////////////////
//
// This file is a part of UPPAAL.
// Copyright (c) 2011-2020, Aalborg University.
// All right reserved.
// Author: Marius Mikucionis marius@cs.aau.dk
//
///////////////////////////////////////////////////////////////////////////////

#ifndef INCLUDE_BASE_RANDOM_H
#define INCLUDE_BASE_RANDOM_H

#include <memory>
#include <cinttypes>

class RandomGenerator
{
public:
    RandomGenerator();
    ~RandomGenerator() noexcept;

    /** set globally shared random seed */
    static void set_seed(uint32_t seed);

    /** random seed */
    void seed(uint32_t seed);

    /** uniform distribution for [0,max] */
    uint32_t uni(uint32_t max);

    /** uniform distribution for unsigned [from,till] */
    uint32_t uni(uint32_t from, uint32_t till);

    /** uniform distribution for signed [from,till] */
    int32_t uni(int32_t from, int32_t till);

    /** uniform distribution for double [0,1) */
    double uni_1();

    /** uniform distribution for double [0,max)
     * @param max exclusive upper bound should be positive and finite */
    double uni_r(double max);

    /** uniform distribution for double [from,till)
     * @param from inclusive lower bound should be finite
     * @param till exclusive upper bound should be finite
     */
    double uni_r(double from, double till);

    /** exponential distribution for double with given rate */
    double exp(double rate);

    /** arcsine distribution with given min and max values */
    double arcsine(const double minv, const double maxv);

    /** beta distribution with given min and max values */
    double beta(const double alpha, const double beta);

    /** gamma distribution with given shape and max scale */
    double gamma(const double shape, const double scale);

    /** Gaussian/Normal distribution with given mean and standard deviation */
    double normal(double mean, double stddev);

    /** Poisson distribution with given mean */
    double poisson(const double mean);

    /** Weibull distribution with given shape and max scale */
    double weibull(const double shape, const double scale);

    /** triangular distribution with given lower, mode and upper points */
    double tri(const double lower, const double mode, const double upper);

private:
    struct internalstate;              // hide the complexity of internal details
    std::unique_ptr<internalstate> s;  // pIMPL pattern
};

#endif
