// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-
////////////////////////////////////////////////////////////////////
//
// Filename : property.h (base)
//
// This file is a part of the UPPAAL toolkit.
// Copyright (c) 1995 - 2003, Uppsala University and Aalborg University.
// All right reserved.
//
// $Id: property.h,v 1.9 2004/08/17 14:55:18 behrmann Exp $
//
/////////////////////////////////////////////////////////////////////

#ifndef INCLUDE_BASE_PROPERTY_H
#define INCLUDE_BASE_PROPERTY_H

#include "base/inttypes.h"

namespace base {
/** Global property types.
 * On a number of components there is
 * a setProperty method used to set a particular property. If we take
 * pipeline/components.h as an example we may have properties for
 * different kinds of buffers, such as, PWList. Implementations are
 * scattered in several modules so it is better to centralize all the
 * properties in one place.
 * Properties are expected to be used with methods
 * setProperty(property_t, const void*): for a given property there is
 * an expected type of data to read.
 */
typedef int const* property_t;

/** We choose to let the compiler generate unique IDs for
 * the properties. This will also work for imported properties
 * from external plugins and it will ensure compatibility between
 * properties in different modules. This macro declares a property
 * (in a .cpp file). The property name must be declared extern in
 * a .h header (property.h in a proper module). For this to work
 * the macro MODULE_NAME must be declared locally in the .cpp file.
 */
#define DEF_PROPERTY(NAME)                                     \
    static const char string_##NAME[] = MODULE_NAME ":" #NAME; \
    base::property_t NAME = (base::property_t)string_##NAME

/** PROPERTY2STRING is only for debugging to print the internal string used as a unique ID.
 */
#define PROPERTY2STRING(NAME) ((const char*)(NAME))

/* Properties for module "base" */
extern property_t EXACT_RELATION;  ///< sets a relation flag, expects bool*
extern property_t FLAG;            ///< sets a generic flag, expects bool*
extern property_t SIZE;            ///< sets a generic size, expects uint32_t*
}  // namespace base

#endif  // INCLUDE_BASE_PROPERTY_H
