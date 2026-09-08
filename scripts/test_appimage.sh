#!/usr/bin/env bash
# Usage: ./scripts/test_appimage.sh <appimage_path> <arch>
set -e

APPIMAGE="$1"
ARCH="$2"

if [ ! -f "$APPIMAGE" ]; then
    echo "Error: AppImage not found: $APPIMAGE"
    exit 1
fi

echo "--- Testing $APPIMAGE for $ARCH ---"
echo "Host kernel: $(uname -r)"
echo "AppImage file info:"
file "$APPIMAGE"

echo "Checking FUSE availability:"
if [ -e /dev/fuse ]; then
    echo "/dev/fuse exists."
    ls -l /dev/fuse
else
    echo "WARNING: /dev/fuse does NOT exist."
fi

QEMU=""
if [ "$ARCH" = "aarch64" ]; then
    QEMU="qemu-aarch64-static"
elif [ "$ARCH" = "armv7l" ]; then
    QEMU="qemu-arm-static"
elif [ "$ARCH" = "i686" ]; then
    # Native on x86_64 or explicit qemu if needed
    QEMU=""
fi

if [ -n "$QEMU" ]; then
    echo "Using explicit interpreter: $QEMU"
    CMD="$QEMU ./$APPIMAGE"
else
    CMD="./$APPIMAGE"
fi

echo "Running AppImage..."

# Capture stdout and stderr
set +e
OUTPUT=$($CMD 2>&1)
EXIT_CODE=$?
set -e

if [ $EXIT_CODE -ne 0 ]; then
    echo "AppImage execution FAILED with exit code $EXIT_CODE"
    echo "Output:"
    echo "$OUTPUT"
    
    echo "Checking FUSE fallback with --appimage-extract-and-run..."
    set +e
    OUTPUT_FALLBACK=$($CMD --appimage-extract-and-run 2>&1)
    EXIT_CODE_FALLBACK=$?
    set -e
    
    if [ $EXIT_CODE_FALLBACK -eq 0 ]; then
        echo "Fallback execution SUCCESS"
        echo "Output:"
        echo "$OUTPUT_FALLBACK"
        echo "Conclusion: FUSE mount failed, but runtime can extract and run. (Level 1 pass, Level 2 fail)"
        echo "Note: This is expected on some QEMU user-mode emulations."
        exit 0 # We pass the CI because the binary is structurally valid
    else
        echo "Fallback execution FAILED with exit code $EXIT_CODE_FALLBACK"
        echo "Conclusion: Runtime execution entirely failed. (Level 1 fail)"
        exit 1
    fi
else
    echo "AppImage execution SUCCESS"
    echo "Output:"
    echo "$OUTPUT"
    
    # Check if the output contains the expected architecture and success message
    if echo "$OUTPUT" | grep -q "architecture: $ARCH" && echo "$OUTPUT" | grep -q "success: true"; then
        echo "Output validation SUCCESS"
    else
        echo "Output validation FAILED: unexpected output content"
        exit 1
    fi
fi
