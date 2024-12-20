// -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*-
////////////////////////////////////////////////////////////////////
//
// Filename : ItemAllocator.h (base)
//
// This file is a part of the UPPAAL toolkit.
// Copyright (c) 1995 - 2003, Uppsala University and Aalborg University.
// Copyright (c) 2020, Aalborg University.
// All right reserved.
//
///////////////////////////////////////////////////////////////////

#ifndef INCLUDE_BASE_ITEMALLOCATOR_H
#define INCLUDE_BASE_ITEMALLOCATOR_H

#include <cassert>
#include <cstdint>

namespace base {
/** Simple (and fast) item allocator.
 * The interest of it, compared
 * to DataAllocator is to have a different memory area (and thus
 * avoid messing up with the pages) for another kind of data. This
 * is particularly fitted to the waiting queue vs explored states
 * stored.
 *
 * Working of ItemAllocator: it allocates a
 * continuous chunk of numberOfItems items (=pool) and
 * initializes the list of free items. Allocation
 * and deallocation just pop and push items on
 * this list. When the list is empty, a new pool
 * of items is allocated.
 * Template arguments:
 * @param ITEM: type of object to allocate
 * Default = 128k items
 * @pre ITEM size is at least 1 int.
 */
template <class ITEM>
class ItemAllocator
{
public:
    /** Default number of items.
     */
    enum { NB_ITEMS = (1 << 17) };

    /** Constructor: check precondition & init to nullptr
     * @param nbItems: number of items per pool.
     * @pre nbItems > 1
     */
    ItemAllocator(std::uintptr_t nbItems = NB_ITEMS): numberOfItems{nbItems}, pool{nullptr}, freeItem{nullptr}
    {
        assert(sizeof(ITEM) >= sizeof(void*));
        assert(nbItems > 1);
    }

    /** Destructor = reset
     */
    ~ItemAllocator() { reset(); }

    /** Allocate a new item.
     * @return new allocated item.
     * @post result != nullptr
     */
    ITEM* allocate()
    {
        if (!freeItem)
            addPool();
        AllocCell_t* cell = freeItem;
        freeItem = cell->next;
        return &cell->item;
    }

    /** Deallocate an item.
     * @param item: item to deallocate.
     * @pre
     * - item allocated with this allocator
     * - item != nullptr
     */
    void deallocate(ITEM* item)
    {
        assert(item);
        AllocCell_t* cell = (AllocCell_t*)item;
        cell->next = freeItem;
        freeItem = cell;
    }

    /** Reset the allocator: free all pools
     * and reset the list of free items.
     */
    void reset()
    {
        AllocPool_t* p = pool;
        pool = nullptr;
        freeItem = nullptr;
        while (p) {
            AllocPool_t* next = p->next;
            delete[] (char*)p;
            p = next;
        }
    }

private:
    /** Add a new pool of items.
     */
    void addPool()
    {
        // Add new pool to list of pools
        AllocPool_t* newPool = (AllocPool_t*)new char[sizeof(AllocPool_t) + sizeof(AllocCell_t) * numberOfItems];
        newPool->next = pool;
        pool = newPool;

        // Init beginning of the list of free items
        // Also, do not try this at home kids.
        AllocCell_t* item = &(newPool->items);
        assert(!freeItem);
        freeItem = item;

        // Init list of free items
        auto n = numberOfItems - 1;
        assert(numberOfItems > 1);
        do {
            item[0].next = &item[1];
            item++;
        } while (--n);
        item[0].next = nullptr;  // last item: no next
    }

    /** UNION to manage list of
     * free items (next) and allocation
     * of items (item).
     * Guarantee at compile time that
     * ITEM does not have a constructor.
     */
    union AllocCell_t
    {
        AllocCell_t* next;
        ITEM item;
    };

    /** Pool of items.
     */
    struct AllocPool_t
    {
        AllocPool_t* next;
        AllocCell_t items;
    };

    std::uintptr_t numberOfItems; /**< number of items per pool */
    AllocPool_t* pool;            /**< allocated pools          */
    AllocCell_t* freeItem;        /**< list of free items       */
};

}  // namespace base

#endif  // INCLUDE_BASE_ITEMALLOCATOR_H
