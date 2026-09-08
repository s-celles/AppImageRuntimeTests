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

# If BUILDKITE_BUILD is set, download artifacts from Yggdrasil Buildkite
if [ -n "$BUILDKITE_BUILD" ]; then
    echo "Fetching artifacts list from Buildkite Build $BUILDKITE_BUILD for $ARCH..."
    
    # We map to the exact string used in Buildkite job names for the architecture
    BK_ARCH_MATCH="$ARCH"
    if [ "$ARCH" = "x86_64" ]; then BK_ARCH_MATCH="x86-64"; fi
    if [ "$ARCH" = "powerpc64le" ]; then BK_ARCH_MATCH="powerpc64le"; fi

    # Fetch the buildkite page which contains the job UUIDs
    # Note: we use api.buildkite.com if possible, but without token we might have to scrape
    # Actually, gh cli might be tricky. Let's just use the known URL pattern for artifacts
    
    # Wait, the easiest way is to use Julia's jlbuild comment or gh run.
    # Since we need to download from Buildkite without auth in bash:
    JOB_URLS=$(curl -sL "https://buildkite.com/julialang/yggdrasil/builds/${BUILDKITE_BUILD}" | grep -o 'href="/julialang/yggdrasil/builds/'${BUILDKITE_BUILD}'#[-a-z0-9]*"' | cut -d'"' -f2 || true)
    
    # We must find the job ID corresponding to the current architecture
    JOB_ID=""
    
    # Alternatively, Yggdrasil uploads the artifacts to a public S3 bucket or similar
    # A reliable way without scraping Buildkite HTML (which is an SPA) is to find the job ID via Buildkite API
    # But Buildkite API requires a token.
    
    # Let's write a python or bash scraper that uses the public buildkite JSON endpoints
    # Actually, there is a public JSON endpoint: https://buildkite.com/julialang/yggdrasil/builds/32624.json?include_setup_instructions=false
    echo "Querying Buildkite JSON API..."
    JOB_ID=$(curl -sL "https://buildkite.com/julialang/yggdrasil/builds/${BUILDKITE_BUILD}.json" | grep -o '"id":"[a-f0-9-]*","name":"buildkite/yggdrasil/build-a-slash-appimageruntime-'${BK_ARCH_MATCH}'-[a-z-]*"' | grep -o '"id":"[a-f0-9-]*"' | cut -d'"' -f4 | head -n 1)

    if [ -z "$JOB_ID" ]; then
        echo "Error: Could not find job ID for $ARCH in Buildkite build $BUILDKITE_BUILD"
        exit 1
    fi
    echo "Found Job ID: $JOB_ID"

    ARTIFACT_JSON=$(curl -sL "https://buildkite.com/organizations/julialang/pipelines/yggdrasil/builds/${BUILDKITE_BUILD}/jobs/${JOB_ID}/artifacts")
    
    # The artifact URL is in the "url" field of the tar.gz that does NOT have "logs" in the name
    ARTIFACT_PATH=$(echo "$ARTIFACT_JSON" | jq -r '.[] | select(.file_name | test(".*\\.tar\\.gz")) | select(.file_name | contains("-logs") | not) | .url' | head -n 1)

    if [ -z "$ARTIFACT_PATH" ]; then
        echo "Error: Could not find artifact URL in job $JOB_ID"
        exit 1
    fi
    
    URL="https://buildkite.com${ARTIFACT_PATH}"
    echo "Downloading runtime tarball from $URL"
    curl -sL "$URL" -o runtime_archive.tar.gz
    
    # Extract the runtime binary from the tarball
    echo "Extracting bin/runtime..."
    tar -xzf runtime_archive.tar.gz bin/runtime
    mv bin/runtime "$OUTPUT_FILE"
    rm runtime_archive.tar.gz

else
    # Default to AppImageKit's type2-runtime for testing the framework
    URL="https://github.com/AppImage/type2-runtime/releases/download/continuous/runtime-${DL_ARCH}"
    echo "Downloading runtime for $ARCH from $URL"
    HTTP_STATUS=$(curl -sL -w "%{http_code}" "$URL" -o "$OUTPUT_FILE")

    if [ "$HTTP_STATUS" != "200" ] && [ "$HTTP_STATUS" != "302" ]; then
        echo "Error: Failed to download runtime. HTTP Status: $HTTP_STATUS"
        echo "This architecture might not be published by the upstream source yet."
        exit 1
    fi
fi

chmod +x "$OUTPUT_FILE"

echo "Downloaded $OUTPUT_FILE"
file "$OUTPUT_FILE"
