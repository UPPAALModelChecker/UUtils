/* -*- mode: C++; c-file-style: "stroustrup"; c-basic-offset: 4; indent-tabs-mode: nil; -*- */
/*********************************************************************
 *
 * Filename : platform.c
 *
 * This file is a part of the UPPAAL toolkit.
 * Copyright (c) 1995 - 2003, Uppsala University and Aalborg University.
 * All right reserved.
 *
 * v 1.2 reviewed.
 * $Id: platform.c,v 1.5 2004/04/02 22:50:43 behrmann Exp $
 *
 *********************************************************************/

#include "base/platform.h"

#include <string.h>
#include <time.h>
#include <ctype.h>

/* GCC -- ANSI C */

#ifdef __GNUC__
#include <stdio.h>
#include <stdlib.h>
#elif defined(_WIN32)
#include <sys/types.h>
#endif

#ifdef _WIN32
#include <windows.h>
/* strerror is inconsistent with errno.h numbers on MinGW32 (only?) */
const char* oserror(int error_code)
{
    DWORD dwError = error_code;
    char* lpMsgBuf;
    if (!FormatMessage(FORMAT_MESSAGE_ALLOCATE_BUFFER | FORMAT_MESSAGE_FROM_SYSTEM | FORMAT_MESSAGE_IGNORE_INSERTS,
                       NULL, dwError, MAKELANGID(LANG_NEUTRAL, SUBLANG_NEUTRAL), (LPTSTR)&lpMsgBuf, 0, NULL)) {
        return "(error message not available)";
    } else {
        char* eol = lpMsgBuf;  // remove end of lines from M$ idiocracies:
        while (NULL != (eol = strchr(eol, '\n'))) {
            if (eol[1] == 0)
                eol[0] = 0;
            else
                *eol = '.';
        }
        return lpMsgBuf;
    }
}

#else /* UNIX */

#include <string.h>
const char* oserror(int error_code) { return strerror(error_code); }

#endif

#ifdef _WIN32

void base_getMemInfo(meminfo_t* info)
{
    MEMORYSTATUSEX status;
    status.dwLength = sizeof(status);
    GlobalMemoryStatusEx(&status);

    /* the following does not seem to be available in MinGW:
    PERFORMANCE_INFORMATION pi;
    DWORD cb = sizeof(pi);
    GetPerformanceInfo(&pi, cb);
    DWORDLONG cache = pi.SystemCache;
    cache = (cache * pi.PageSize) >> 10;
    info[PHYS_CACHE] = cache;
    */

    info->phys_total = status.ullTotalPhys >> 10;
    info->phys_avail = status.ullAvailPhys >> 10;
    info->phys_cache = 0;
    info->swap_total = status.ullTotalPageFile >> 10;
    info->swap_avail = status.ullAvailPageFile >> 10;
    info->virt_total = status.ullTotalVirtual >> 10;
    info->virt_avail = status.ullAvailVirtual >> 10;
}

#elif __linux__

static uint64_t read_key_mem_kb(FILE* f, const char* key)
{
    int match = 0;
    int c = fgetc(f);
    for (; c != EOF; c = fgetc(f))
        if (key[match] == c) {
            ++match;
            if (key[match] == '\0')
                break;
        } else
            match = 0;
    if (c == EOF)
        return 0;
    for (c = fgetc(f); c != EOF && isspace(c); c = fgetc(f))
        ;
    if (c == EOF)
        return 0;
    if (ungetc(c, f) == EOF)
        return 0;
    uint64_t res = 0;
    c = fscanf(f, "%" SCNu64, &res);
    if (c == EOF)
        return 0;
    return res;
}

void base_getMemInfo(meminfo_t* info)
{
    /* based on Linux/Documentation/filesystems/proc.txt#meminfo */
    memset(info, 0, sizeof(*info));
    FILE* ps = fopen("/proc/meminfo", "r");
    if (!ps)
        return;
    info->phys_total = read_key_mem_kb(ps, "MemTotal:");
    info->phys_avail = read_key_mem_kb(ps, "MemFree:");
    info->phys_cache = read_key_mem_kb(ps, "Buffers:");
    info->phys_cache += read_key_mem_kb(ps, "Cached:");
    info->swap_total = read_key_mem_kb(ps, "SwapTotal:");
    info->swap_avail = read_key_mem_kb(ps, "SwapFree:");
    fclose(ps);
    info->virt_total = info->phys_total + info->swap_total;
    info->virt_avail = info->phys_avail + info->swap_avail;
}

#elif defined(__APPLE__) && defined(__MACH__)

#include <mach/host_info.h>
#include <mach/mach_host.h>
#include <sys/sysctl.h>
#include <sys/types.h>

void base_getMemInfo(meminfo_t* info)
{
    int mib[2];
    int64_t memory = 0;
    struct xsw_usage swapu;
    size_t len;

    int res;

    // Total physical memory
    mib[0] = CTL_HW;
    mib[1] = HW_PHYSMEM;
    len = sizeof(memory);
    res = sysctl(mib, 2, &memory, &len, NULL, 0);
    if (res == 0) {
        info->phys_total = memory / 1024;  // in kB
    }

    // Cached memory
    info->phys_cache = 0;

    // Swap
    mib[0] = CTL_VM;
    mib[1] = VM_SWAPUSAGE;
    len = sizeof(swapu);
    res = sysctl(mib, 2, &swapu, &len, NULL, 0);
    if (res == 0) {
        info->swap_total = swapu.xsu_total / 1024;  // in kB
        info->swap_avail = swapu.xsu_avail / 1024;  // in kB

        info->virt_total = info->phys_total + info->swap_total;
        info->virt_avail = info->phys_avail + info->swap_avail;
    }

    // Free memory
    struct vm_statistics page_info;
    vm_size_t pagesize;
    mach_msg_type_number_t count;
    kern_return_t kret;

    pagesize = 0;
    kret = host_page_size(mach_host_self(), &pagesize);

    // vm stats
    count = HOST_VM_INFO_COUNT;
    kret = host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&page_info, &count);
    if (kret == KERN_SUCCESS)
        info->phys_avail = page_info.free_count * pagesize / 1024;
    else
        info->phys_avail = 0;
}

#endif

#ifdef _WIN32

#include <psapi.h>
#include <stdint.h>
#include <windows.h>

static HANDLE hThisProcess = NULL;

void base_initProcInfo() { hThisProcess = GetCurrentProcess(); }

void base_getProcInfo(procinfo_t* info)
{
    FILETIME now;
    LARGE_INTEGER li;
    FILETIME ftCreationTime;
    FILETIME ftExitTime;
    FILETIME ftKernelTime;
    FILETIME ftUserTime;
    PROCESS_MEMORY_COUNTERS pmc;
    pmc.cb = sizeof(pmc);

    GetSystemTimeAsFileTime(&now);
    GetProcessMemoryInfo(hThisProcess, &pmc, sizeof(pmc));
    if (GetProcessTimes(hThisProcess, &ftCreationTime, &ftExitTime, &ftKernelTime, &ftUserTime)) {
        li.LowPart = ftUserTime.dwLowDateTime;
        li.HighPart = ftUserTime.dwHighDateTime;
        info->time_user = li.QuadPart / 10000;  // 100 nano-secs to millis

        li.LowPart = ftKernelTime.dwLowDateTime;
        li.HighPart = ftKernelTime.dwHighDateTime;
        info->time_sys = li.QuadPart / 10000;  // 100 nano-secs to millis
    }
    info->mem_virt = (pmc.WorkingSetSize + pmc.PagefileUsage) >> 10;
    info->mem_work = pmc.WorkingSetSize >> 10;
    info->mem_swap = pmc.PagefileUsage >> 10;

    li.LowPart = now.dwLowDateTime;
    li.HighPart = now.dwHighDateTime;
    info->time_real = li.QuadPart / 10000;  // to milliseconds
}

#elif __linux__

#include <inttypes.h>
#include <unistd.h>

#include <sys/resource.h>
#include <sys/time.h>

void base_initProcInfo()
{
    // Nothing
}

void base_getProcInfo(procinfo_t* info)
{
    {
        struct timeval now;
        gettimeofday(&now, NULL);
        info->time_real = 1000LLU * now.tv_sec + now.tv_usec / 1000;
    }
    {
        struct rusage usage;
        int res = getrusage(RUSAGE_SELF, &usage);
        if (res != 0)
            return;
        info->time_user = 1000LLU * usage.ru_utime.tv_sec + usage.ru_utime.tv_usec / 1000;
        info->time_sys = 1000LLU * usage.ru_stime.tv_sec + usage.ru_stime.tv_usec / 1000;
    }
    // /proc/self/status includes VmSize and VmSwap (absent in /statm and /stat)
    FILE* ps = fopen("/proc/self/status", "r");
    if (ps == NULL)
        return;
    info->mem_virt = read_key_mem_kb(ps, "VmSize:");
    info->mem_work = read_key_mem_kb(ps, "VmRSS:");
    info->mem_swap = read_key_mem_kb(ps, "VmSwap:");
    fclose(ps);
}

#elif defined(__APPLE__) && defined(__MACH__)

#include <mach/task.h>
#include <mach/task_info.h>
#include <sys/resource.h>
#include <sys/time.h>

void base_initProcInfo()
{
    // Nothing
}

void base_getProcInfo(procinfo_t* info)
{
    struct timeval now;
    gettimeofday(&now, NULL);

    info->time_real = 1000LLU * now.tv_sec + now.tv_usec / 1000;

    // Process stats
    struct task_basic_info tinfo;
    struct task_thread_times_info thinfo;
    mach_msg_type_number_t count;
    kern_return_t kret;

    count = TASK_BASIC_INFO_COUNT;
    kret = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&tinfo, &count);
    if (kret == KERN_SUCCESS) {
        info->mem_virt = tinfo.virtual_size / 1024;
        info->mem_work = tinfo.resident_size / 1024;
        info->mem_swap = 0;
    }

    count = TASK_THREAD_TIMES_INFO_COUNT;
    kret = task_info(mach_task_self(), TASK_THREAD_TIMES_INFO, (task_info_t)&thinfo, &count);
    if (kret == KERN_SUCCESS) {
        info->time_user = 1000LLU * thinfo.user_time.seconds + thinfo.user_time.microseconds / 1000;
        info->time_sys = 1000LLU * thinfo.system_time.seconds + thinfo.system_time.microseconds / 1000;
    }
}

#endif

void base_getProcInfoMax(procinfo_t* info)
{
    procinfo_t c;
    base_getProcInfo(&c);
#ifndef MAX
#define MAX(a, b) (((a) > (b)) ? (a) : (b))
#endif /* MAX */
    info->mem_virt = MAX(info->mem_virt, c.mem_virt);
    info->mem_work = MAX(info->mem_work, c.mem_work);
    info->mem_swap = MAX(info->mem_swap, c.mem_swap);
    info->time_user = MAX(info->time_user, c.time_user);
    info->time_sys = MAX(info->time_sys, c.time_sys);
    info->time_real = MAX(info->time_real, c.time_real);
}
