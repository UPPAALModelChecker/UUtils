// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-
///////////////////////////////////////////////////////////////////////////////
//
// This file is a part of UPPAAL.
// Copyright (c) 2011-2020, Aalborg University.
// All rights reserved.
// Author: Marius Mikucionis marius@cs.aau.dk
//
///////////////////////////////////////////////////////////////////////////////

#include "base/random.h"

#include <boost/random.hpp>
#include <boost/random/uniform_int_distribution.hpp>
#include <boost/random/uniform_real_distribution.hpp>
#include <boost/math/distributions/arcsine.hpp>
#include <boost/random/beta_distribution.hpp>
#include <boost/random/exponential_distribution.hpp>
#include <boost/random/gamma_distribution.hpp>
#include <boost/random/normal_distribution.hpp>
#include <boost/random/poisson_distribution.hpp>
#include <boost/random/weibull_distribution.hpp>
#include <boost/random/triangle_distribution.hpp>
// #include <random> standard implementation is 3-4x slower than boost (on Linux), see bm_random.cpp
#include <cassert>

using namespace boost::random;

struct RandomGenerator::internalstate
{
    mt19937 rnd;  // randomness generator
};

static uint32_t sharedseed = 42;

RandomGenerator::RandomGenerator(): s{new internalstate()} { seed(sharedseed++); }

RandomGenerator::~RandomGenerator() noexcept = default;

void RandomGenerator::set_seed(const uint32_t seed) { sharedseed = seed; }

void RandomGenerator::seed(const uint32_t seed) { s->rnd.seed(seed); }

uint32_t RandomGenerator::uni(const uint32_t max) { return uniform_int_distribution<uint32_t>{0, max}(s->rnd); }

uint32_t RandomGenerator::uni(const uint32_t from, const uint32_t till)
{
    assert(from <= till);
    return uniform_int_distribution<uint32_t>{from, till}(s->rnd);
}

int32_t RandomGenerator::uni(const int32_t from, const int32_t till)
{
    assert(from <= till);
    return uniform_int_distribution<int32_t>{from, till}(s->rnd);
}

double RandomGenerator::uni_1() { return uniform_real_distribution<double>{0.0, 1.0}(s->rnd); }

double RandomGenerator::uni_r(const double max) { return uniform_real_distribution<double>{0.0, max}(s->rnd); }

double RandomGenerator::uni_r(const double from, const double till)
{
    assert(till - from >= 0);
    return uniform_real_distribution<double>{from, till}(s->rnd);
}

double RandomGenerator::exp(const double rate)
{
    assert(rate != 0);
    return exponential_distribution<double>{rate}(s->rnd);
}

double RandomGenerator::arcsine(const double minv, const double maxv)
{
    assert(minv <= maxv);
    boost::math::arcsine_distribution<double> dis{minv,maxv};
    return quantile(dis, uniform_real_distribution<double>{0.0, 1.0}(s->rnd));
}

double RandomGenerator::beta(const double alpha, const double beta)
{
    assert(alpha > 0 && beta > 0);
    return beta_distribution<double>{alpha,beta}(s->rnd);
}

double RandomGenerator::gamma(const double shape, const double scale)
{
    assert(shape > 0 && scale > 0);
    return gamma_distribution<double>{shape,scale}(s->rnd);
}

double RandomGenerator::normal(const double mean, const double stddev)
{
    return normal_distribution<double>{mean, stddev}(s->rnd);
}

double RandomGenerator::poisson(const double mean_rate)
{
    assert(mean_rate > 0);
    return poisson_distribution<int,double>{mean_rate}(s->rnd);
}

double RandomGenerator::weibull(const double shape, const double scale)
{
    assert(shape > 0 && scale > 0);
    return weibull_distribution<double>{shape,scale}(s->rnd);
}

double RandomGenerator::tri(const double lower, const double mode, const double upper)
{
    assert(lower <= mode && mode <= upper);
    return triangle_distribution<double>{lower,mode,upper}(s->rnd);
}
