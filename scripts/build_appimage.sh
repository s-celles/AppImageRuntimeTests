#!/usr/bin/env bash
set -e

if [ "$#" -ne 4 ]; then
    echo "Usage: $0 <runtime_path> <test_app_path> <compression_type> <output_appimage>"
    exit 1
fi

RUNTIME="$1"
TEST_APP="$2"
COMP="$3"
OUTPUT="$4"

if [ ! -f "$RUNTIME" ]; then
    echo "Runtime not found: $RUNTIME"
    exit 1
fi

if [ ! -f "$TEST_APP" ]; then
    echo "Test application not found: $TEST_APP"
    exit 1
fi

# Create AppDir structure
APPDIR=$(mktemp -d)
mkdir -p "$APPDIR/usr/bin"
cp "$TEST_APP" "$APPDIR/usr/bin/test_app"

# Create a minimal AppRun
cat << 'EOF' > "$APPDIR/AppRun"
#!/bin/sh
APPDIR="${APPDIR:-$(dirname "$(readlink -f "$0")")}"
exec "$APPDIR/usr/bin/test_app" "$@"
EOF
chmod +x "$APPDIR/AppRun"

# Add dummy .desktop and icon to satisfy some AppImage tools, though maybe not strict for runtime itself
cat << 'EOF' > "$APPDIR/test.desktop"
[Desktop Entry]
Type=Application
Name=TestApp
Exec=test_app
Icon=test
Categories=Utility;
EOF
touch "$APPDIR/test.png"

SQUASHFS_IMG=$(mktemp)

# Build squashfs
# -comp sets compression (gzip, zstd)
# -root-owned makes files owned by root
# -noappend creates a new image
mksquashfs "$APPDIR" "$SQUASHFS_IMG" -comp "$COMP" -root-owned -noappend -quiet

# Assemble AppImage
cat "$RUNTIME" "$SQUASHFS_IMG" > "$OUTPUT"
chmod +x "$OUTPUT"

# Cleanup
rm -rf "$APPDIR"
rm -f "$SQUASHFS_IMG"

echo "Created AppImage: $OUTPUT"
