#!/usr/bin/env bash
set -e

if [ -z "$1" ]; then
    echo "Usage: $0 <arch>"
    echo "Supported arch: x86_64, i686, aarch64, armv7l"
    exit 1
fi

ARCH="$1"
OUTPUT_FILE="runtime-${ARCH}"

# Map our arch names to AppImageKit/type2-runtime names if necessary
# AppImage type2-runtime uses aarch64, x86_64, i686, armhf
DL_ARCH="$ARCH"
if [ "$ARCH" = "armv7l" ]; then
    DL_ARCH="armhf"
fi

# If RUNTIME_URL is set, use it. If it ends with a slash, append runtime-${ARCH}
if [ -n "$RUNTIME_URL" ]; then
    if [[ "$RUNTIME_URL" == */ ]]; then
        URL="${RUNTIME_URL}runtime-${ARCH}"
    else
        URL="$RUNTIME_URL"
    fi
else
    # Default to AppImageKit's type2-runtime for testing the framework
    URL="https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-${DL_ARCH}"
fi

echo "Downloading runtime for $ARCH from $URL"
HTTP_STATUS=$(curl -sL -w "%{http_code}" "$URL" -o "$OUTPUT_FILE")

if [ "$HTTP_STATUS" != "200" ] && [ "$HTTP_STATUS" != "302" ]; then
    echo "Error: Failed to download runtime. HTTP Status: $HTTP_STATUS"
    echo "This architecture might not be published by the upstream source yet."
    exit 1
fi

chmod +x "$OUTPUT_FILE"

echo "Downloaded $OUTPUT_FILE"
file "$OUTPUT_FILE"
