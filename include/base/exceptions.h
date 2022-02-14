// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-
////////////////////////////////////////////////////////////////////
//
// This file is a part of the UPPAAL toolkit.
// Copyright (c) 1995 - 2006, Uppsala University and Aalborg University.
// All right reserved.
//
///////////////////////////////////////////////////////////////////

#ifndef INCLUDE_BASE_EXCEPTIONS_H
#define INCLUDE_BASE_EXCEPTIONS_H

#include <exception>
#include <string>

// TODO: refactor the exceptions to have proper error position and behave like CannotEvaluateExpression in error.h

// Common base class.

class UppaalException : public std::exception
{
protected:
    char _what[256];

public:
    const char* what() const noexcept override;
};

// Specialized exceptions. Unfortunately
// it is difficult to factorize the code
// in the constructor due to the varying
// number of arguments.

class InvalidOptionsException : public UppaalException
{
public:
    InvalidOptionsException(const char* fmt, ...);
};

class RuntimeException : public UppaalException
{
public:
    RuntimeException(const char* fmt, ...);
};

class InterruptedException : public UppaalException
{
public:
    InterruptedException(const char* fmt, ...);
};

class SuccessorException : public RuntimeException
{
public:
    const char* state;
    const char* channel;
    SuccessorException(const char* state, const char* channel, const char* message);
    virtual ~SuccessorException();
};

class NoLicenseException : public std::exception
{
protected:
    char _what[256];

public:
    NoLicenseException(std::string feature) { snprintf(_what, 255, "License does not cover %s", feature.c_str()); }
    const char* what() const noexcept override { return _what; };
};

#endif  // INCLUDE_BASE_EXCEPTIONS_H
