// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-
////////////////////////////////////////////////////////////////////
//
// This file is a part of the UPPAAL toolkit.
// Copyright (c) 1995 - 2006, Uppsala University and Aalborg University.
// All right reserved.
//
///////////////////////////////////////////////////////////////////

#include "base/exceptions.h"

#include <cstdarg>
#include <cstdio>
#include <cstdlib>
#include <cstring>

const char* UppaalException::what() const noexcept { return _what; }

InvalidOptionsException::InvalidOptionsException(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(_what, 256, fmt, ap);
    va_end(ap);
}

RuntimeException::RuntimeException(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(_what, 256, fmt, ap);
    va_end(ap);
}

InterruptedException::InterruptedException(const char* fmt, ...)
{
    va_list ap;
    va_start(ap, fmt);
    vsnprintf(_what, 256, fmt, ap);
    va_end(ap);
}

SuccessorException::SuccessorException(const char* s, const char* c, const char* message):
    RuntimeException(message), state(strdup(s)), channel(strdup(c))
{}

SuccessorException::~SuccessorException()
{
    free((void*)state);
    free((void*)channel);
}
