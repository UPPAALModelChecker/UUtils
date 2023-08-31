// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-
////////////////////////////////////////////////////////////////////
//
// Wrap C FILE* to std::streambuf and provide std::ostream interface.
//
// This file is a part of the UPPAAL toolkit.
// Copyright (c) 2022, Aalborg University.
// Copyright (c) 1995 - 2003, Uppsala University and Aalborg University.
// All right reserved.
//
///////////////////////////////////////////////////////////////////

#ifndef INCLUDE_BASE_FILESTREAMBUFFER_H
#define INCLUDE_BASE_FILESTREAMBUFFER_H

#include <iostream>
#include <cstdio>

namespace base {
/** Simple wrapper of FILE* to std::streambuf to use C-style API.
 * This class does not open or close the file, it only uses it. */
class file_streambuf : public std::streambuf
{
public:
    /** Constructor:
     * @param theFile: file stream (in C) to wrapp.
     * @pre theFile != NULL
     */
    file_streambuf(FILE* file): file{file} {}

    /** Destructor: just flush, no close. */
    virtual ~file_streambuf() { std::fflush(file); }

    /** overrides default overflow. */
    int overflow(int c) override { return std::fputc(c, file); }

private:
    FILE* file;
};

/** Provides std::ostream adapter over the FILE* handle from C.
 * Destructor only flushes the content and does NOT close the file handle.
 * Usage: some_thing::print(file_ostream{file}) */
class file_ostream
{
    file_streambuf buffer;
    std::ostream os;

public:
    file_ostream(FILE* file): buffer{file}, os{&buffer} {}
    operator std::ostream&() { return os; }
};

}  // namespace base

#endif  // INCLUDE_BASE_FILESTREAMBUFFER_H
