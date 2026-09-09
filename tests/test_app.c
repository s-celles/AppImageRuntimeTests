#include <stdio.h>

#if defined(__x86_64__)
#define ARCH "x86_64"
#elif defined(__i386__)
#define ARCH "i686"
#elif defined(__aarch64__)
#define ARCH "aarch64"
#elif defined(__arm__)
#if defined(ARCH_ARMV6L)
#define ARCH "armv6l"
#else
#define ARCH "armv7l"
#endif
#elif defined(__powerpc__) || defined(__PPC64__)
#define ARCH "powerpc64le"
#elif defined(__riscv) || defined(__riscv__)
#define ARCH "riscv64"
#else
#define ARCH "unknown"
#endif

int main() {
    printf("AppImage runtime integration test\n");
    printf("architecture: %s\n", ARCH);
    printf("success: true\n");
    return 0;
}
