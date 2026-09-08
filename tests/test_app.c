#include <stdio.h>

#if defined(__x86_64__)
#define ARCH "x86_64"
#elif defined(__i386__)
#define ARCH "i686"
#elif defined(__aarch64__)
#define ARCH "aarch64"
#elif defined(__arm__)
#define ARCH "armv7l"
#else
#define ARCH "unknown"
#endif

int main() {
    printf("AppImage runtime integration test\n");
    printf("architecture: %s\n", ARCH);
    printf("success: true\n");
    return 0;
}
