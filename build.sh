#!/bin/bash
set -e

# Record start time for benchmarking
start_time=$(date +%s)

# Set colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${GREEN}Starting Actual Intelligence book build...${NC}"

# Generate version from current date and time
DATE_VERSION=$(date +'%Y.%m.%d')
TIME_VERSION=$(date +'%H%M')
VERSION="v${DATE_VERSION}-${TIME_VERSION}"
echo -e "${BLUE}Version: ${VERSION}${NC}"

# Create directory for all builds if it doesn't exist
echo "Creating build directory..."
mkdir -p build

# Call book-tools build with all languages flag
echo -e "${YELLOW}Building all language versions with book-tools...${NC}"
book-tools build --all-languages

# Failsafe: Check if Japanese build exists, if not, build it explicitly
if [ ! -f "build/ja/actual-intelligence.epub" ]; then
    echo -e "${YELLOW}Japanese build files not found. Building Japanese version explicitly...${NC}"
    echo -e "${BLUE}Setting up Japanese build...${NC}"
    
    # Ensure the Japanese build directory exists
    mkdir -p build/ja
    
    # Call book-tools build-language.sh directly for Japanese
    echo -e "${YELLOW}Building Japanese version...${NC}"
    "$HOME/.book-tools/scripts/build-language.sh" "ja"
    
    echo -e "${GREEN}✅ Japanese build completed${NC}"
fi

# Calculate and display the time taken
end_time=$(date +%s)
duration=$((end_time - start_time))
minutes=$((duration / 60))
seconds=$((duration % 60))

echo -e "${GREEN}✅ Build completed in ${minutes}m ${seconds}s${NC}"
echo -e "${BLUE}Generated version: ${VERSION}${NC}"
ls -la build/*/actual-intelligence.epub

# Tag the version if the BUILD_TAG environment variable is set
if [ "${BUILD_TAG}" = "true" ]; then
    echo -e "${YELLOW}Tagging version ${VERSION}...${NC}"
    git tag -a "${VERSION}" -m "Release ${VERSION}"
    git push origin "${VERSION}"
    echo -e "${GREEN}✅ Tagged version ${VERSION}${NC}"
fi

echo -e "${GREEN}All done!${NC}"
