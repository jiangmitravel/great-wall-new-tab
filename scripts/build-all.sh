#!/bin/bash

# Build all platforms
# Usage: ./build-all.sh [version]

VERSION=${1:-"1.0.0"}

echo "🏗️  Building all platforms for version $VERSION"
echo ""

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Build Chrome
"$SCRIPT_DIR/build.sh" chrome "$VERSION"
echo ""

# Build Edge
"$SCRIPT_DIR/build.sh" edge "$VERSION"
echo ""

echo "✅ All platforms built successfully!"
echo ""
echo "📦 Generated packages:"
ls -lh "$SCRIPT_DIR/../build"/*.zip
