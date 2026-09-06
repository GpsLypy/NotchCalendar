#include <libproc.h>
#include <CoreGraphics/CGSession.h>
#include <mach/mach_time.h>
#include <sys/resource.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static const char *json_bool(CFTypeRef value) {
    if (!value) return "null";
    if (CFGetTypeID(value) == CFBooleanGetTypeID()) return CFBooleanGetValue(value) ? "true" : "false";
    if (CFGetTypeID(value) == CFNumberGetTypeID()) {
        int result;
        if (CFNumberGetValue(value, kCFNumberIntType, &result)) return result ? "true" : "false";
    }
    return "null";
}

int main(int argc, char **argv) {
    if (argc != 2) return 64;
    char *end;
    long pid = strtol(argv[1], &end, 10);
    if (*end || pid <= 0 || pid > INT32_MAX) return 64;
    struct rusage_info_v4 info = {0};
    if (proc_pid_rusage((int)pid, RUSAGE_INFO_V4, (rusage_info_t *)&info) != 0) {
        perror("proc_pid_rusage"); return 1;
    }
    mach_timebase_info_data_t timebase;
    if (mach_timebase_info(&timebase) != KERN_SUCCESS) return 1;
    uint64_t cpu_ns = (uint64_t)(((__uint128_t)info.ri_user_time + info.ri_system_time) * timebase.numer / timebase.denom);
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) != 0) return 1;
    CFDictionaryRef session = CGSessionCopyCurrentDictionary();
    // Additional observed macOS key: unknown remains null, and no identity is emitted.
    CFTypeRef locked = session ? CFDictionaryGetValue(session, CFSTR("CGSSessionScreenIsLocked")) : NULL;
    CFTypeRef console = session ? CFDictionaryGetValue(session, kCGSessionOnConsoleKey) : NULL;
    CFTypeRef logged_in = session ? CFDictionaryGetValue(session, kCGSessionLoginDoneKey) : NULL;
    printf("{\"screen_locked\":%s,\"on_console\":%s,\"logged_in\":%s,\"time\":%.9f,\"cpu_ns\":%llu,\"interrupt_wakeups\":%llu,\"package_idle_wakeups\":%llu}\n",
        json_bool(locked), json_bool(console), json_bool(logged_in),
        (double)ts.tv_sec + (double)ts.tv_nsec / 1e9,
        (unsigned long long)cpu_ns,
        (unsigned long long)info.ri_interrupt_wkups, (unsigned long long)info.ri_pkg_idle_wkups);
    if (session) CFRelease(session);
    return 0;
}
