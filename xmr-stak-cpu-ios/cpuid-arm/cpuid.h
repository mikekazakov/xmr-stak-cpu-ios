#pragma once
#include "TargetConditionals.h"
#if TARGET_OS_SIMULATOR
#define __cpuid_count(__level, __count, __eax, __ebx, __ecx, __edx) \
    __asm("  xchgq  %%rbx,%q1\n" \
          "  cpuid\n" \
          "  xchgq  %%rbx,%q1" \
        : "=a"(__eax), "=r" (__ebx), "=c"(__ecx), "=d"(__edx) \
        : "0"(__level), "2"(__count))
#else
static inline __attribute__((always_inline))
void __cpuid_count(uint32_t __level, int32_t __count,
                   int32_t &__eax, int32_t &__ebx, int32_t &__ecx, int32_t &__edx)
{
    __eax = __ebx = __ecx = __edx = -1;
}
#endif
