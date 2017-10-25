#pragma once
#include "TargetConditionals.h"

#if TARGET_OS_SIMULATOR

#define __cpuid(__level, __eax, __ebx, __ecx, __edx) \
    __asm("  xchgq  %%rbx,%q1\n" \
          "  cpuid\n" \
          "  xchgq  %%rbx,%q1" \
        : "=a"(__eax), "=r" (__ebx), "=c"(__ecx), "=d"(__edx) \
        : "0"(__level))

#define __cpuid_count(__level, __count, __eax, __ebx, __ecx, __edx) \
    __asm("  xchgq  %%rbx,%q1\n" \
          "  cpuid\n" \
          "  xchgq  %%rbx,%q1" \
        : "=a"(__eax), "=r" (__ebx), "=c"(__ecx), "=d"(__edx) \
        : "0"(__level), "2"(__count))

#else

static inline __attribute__((always_inline))
void __cpuid_count(uint32_t eax, int32_t ecx, int32_t &v1, int32_t &v2, int32_t &v3, int32_t &v4)
{
    // arm can do just everything!
    v1 = v2 = v3 = v4 = -1;
}

#endif
