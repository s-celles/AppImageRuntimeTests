#!/usr/bin/env bash
set -e

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <arch> <output_binary>"
    exit 1
fi

ARCH="$1"
OUTPUT="$2"
SRC="tests/test_app.c"

case "$ARCH" in
    x86_64)
        CC="gcc"
        ;;
    i686)
        CC="i686-linux-gnu-gcc"
        ;;
    aarch64)
        CC="aarch64-linux-gnu-gcc"
        ;;
    armv7l)
        CC="arm-linux-gnueabihf-gcc"
        ;;
    *)
        echo "Unsupported architecture: $ARCH"
        exit 1
        ;;
esac

echo "Compiling $SRC for $ARCH using $CC"
# Build statically to avoid libc dependencies during testing
$CC -static -o "$OUTPUT" "$SRC"

echo "Compiled $OUTPUT successfully"
file "$OUTPUT"
