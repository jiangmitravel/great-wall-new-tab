#!/bin/bash

# Great Wall Extension - Multi-Platform Build Script
# Usage: ./build.sh [chrome|edge] [version]

set -e  # Exit on error

PLATFORM=$1
VERSION=${2:-"1.0.0"}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check arguments
if [ -z "$PLATFORM" ] || [ "$PLATFORM" != "chrome" ] && [ "$PLATFORM" != "edge" ]; then
    echo -e "${RED}❌ Error: Platform must be 'chrome' or 'edge'${NC}"
    echo "Usage: ./build.sh [chrome|edge] [version]"
    exit 1
fi

echo -e "${GREEN}🏗️  Building Great Wall Extension for ${PLATFORM} v${VERSION}${NC}"

# Get script directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
CONFIG_FILE="$SCRIPT_DIR/config.json"

# Read configuration
if [ ! -f "$CONFIG_FILE" ]; then
    echo -e "${RED}❌ Config file not found: $CONFIG_FILE${NC}"
    exit 1
fi

# Extract platform config using jq (or fallback to grep/sed)
if command -v jq &> /dev/null; then
    OUTPUT_DIR=$(jq -r ".platforms.$PLATFORM.output_dir" "$CONFIG_FILE")
    PLATFORM_NAME=$(jq -r ".platforms.$PLATFORM.PLATFORM_NAME" "$CONFIG_FILE")
    PLATFORM_FULL=$(jq -r ".platforms.$PLATFORM.PLATFORM_FULL" "$CONFIG_FILE")
    BROWSER_NAME=$(jq -r ".platforms.$PLATFORM.BROWSER_NAME" "$CONFIG_FILE")
    STORE_NAME=$(jq -r ".platforms.$PLATFORM.STORE_NAME" "$CONFIG_FILE")
    STORE_POLICY=$(jq -r ".platforms.$PLATFORM.STORE_POLICY" "$CONFIG_FILE")
    STORE_URL=$(jq -r ".platforms.$PLATFORM.STORE_URL" "$CONFIG_FILE")
else
    echo -e "${YELLOW}⚠️  jq not found, using fallback parsing${NC}"
    # Fallback: simple grep/sed parsing
    if [ "$PLATFORM" = "chrome" ]; then
        OUTPUT_DIR="build/chrome"
        PLATFORM_NAME="Chrome"
        PLATFORM_FULL="Chrome Extension"
        BROWSER_NAME="Chrome browser"
        STORE_NAME="Chrome Web Store"
        STORE_POLICY="Chrome Web Store Developer Program Policies"
        STORE_URL="chrome://extensions/"
    else
        OUTPUT_DIR="build/edge"
        PLATFORM_NAME="Browser"
        PLATFORM_FULL="Browser Extension"
        BROWSER_NAME="browser"
        STORE_NAME="extension store"
        STORE_POLICY="Browser Extension Store Developer Program Policies"
        STORE_URL="edge://extensions/"
    fi
fi

# Full paths
OUTPUT_PATH="$PROJECT_ROOT/$OUTPUT_DIR"
SRC_PATH="$PROJECT_ROOT/src"

echo -e "${YELLOW}📂 Source: $SRC_PATH${NC}"
echo -e "${YELLOW}📦 Output: $OUTPUT_PATH${NC}"

# Clean and create output directory
rm -rf "$OUTPUT_PATH"
mkdir -p "$OUTPUT_PATH"

# Copy all source files
echo -e "${GREEN}📋 Copying source files...${NC}"
cp -r "$SRC_PATH"/* "$OUTPUT_PATH/"

# Process template files
echo -e "${GREEN}🔄 Processing templates...${NC}"

for template_file in "$OUTPUT_PATH"/*.template.*; do
    if [ -f "$template_file" ]; then
        # Get output filename (remove .template)
        output_file="${template_file/.template/}"
        
        echo -e "  ${YELLOW}→${NC} $(basename "$template_file") ${YELLOW}→${NC} $(basename "$output_file")"
        
        # Replace all template variables
        sed -e "s/{{PLATFORM_NAME}}/$PLATFORM_NAME/g" \
            -e "s/{{PLATFORM_FULL}}/$PLATFORM_FULL/g" \
            -e "s/{{BROWSER_NAME}}/$BROWSER_NAME/g" \
            -e "s/{{STORE_NAME}}/$STORE_NAME/g" \
            -e "s|{{STORE_POLICY}}|$STORE_POLICY|g" \
            -e "s|{{STORE_URL}}|$STORE_URL|g" \
            "$template_file" > "$output_file"
        
        # Remove template file
        rm "$template_file"
    fi
done

# Remove unnecessary files from extension package
echo -e "${GREEN}🗑️  Removing unnecessary files...${NC}"
rm -f "$OUTPUT_PATH/index.html"
rm -f "$OUTPUT_PATH/index.template.html"

# Update version in manifest.json
if [ -f "$OUTPUT_PATH/manifest.json" ]; then
    echo -e "${GREEN}📝 Updating version to $VERSION...${NC}"
    if command -v jq &> /dev/null; then
        jq ".version = \"$VERSION\"" "$OUTPUT_PATH/manifest.json" > "$OUTPUT_PATH/manifest.json.tmp"
        mv "$OUTPUT_PATH/manifest.json.tmp" "$OUTPUT_PATH/manifest.json"
    else
        # Fallback: sed replacement
        sed -i.bak "s/\"version\": \".*\"/\"version\": \"$VERSION\"/" "$OUTPUT_PATH/manifest.json"
        rm "$OUTPUT_PATH/manifest.json.bak" 2>/dev/null || true
    fi
fi

# Create ZIP package
ZIP_NAME="great-wall-$PLATFORM-v$VERSION.zip"
ZIP_PATH="$PROJECT_ROOT/build/$ZIP_NAME"

echo -e "${GREEN}📦 Creating ZIP package...${NC}"
cd "$OUTPUT_PATH"
zip -r "$ZIP_PATH" . \
    -x "*.DS_Store" \
    -x "*.git*" \
    -x "*.template.*" \
    > /dev/null

# Get file size
if [ -f "$ZIP_PATH" ]; then
    FILE_SIZE=$(ls -lh "$ZIP_PATH" | awk '{print $5}')
    echo -e "${GREEN}✅ Build complete!${NC}"
    echo -e "${GREEN}📦 Package: $ZIP_NAME ($FILE_SIZE)${NC}"
    echo -e "${GREEN}📂 Location: $ZIP_PATH${NC}"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    if [ "$PLATFORM" = "chrome" ]; then
        echo -e "  1. Visit: ${YELLOW}https://chrome.google.com/webstore/devconsole${NC}"
    else
        echo -e "  1. Visit: ${YELLOW}https://partner.microsoft.com/dashboard/microsoftedge${NC}"
    fi
    echo -e "  2. Upload: ${YELLOW}$ZIP_NAME${NC}"
else
    echo -e "${RED}❌ Failed to create ZIP package${NC}"
    exit 1
fi
