#!/bin/bash

set -e

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Testing EPUB image support...${NC}"

# Setup test environment
TEST_DIR="$(pwd)/test-epub-build"
mkdir -p "$TEST_DIR"
mkdir -p "$TEST_DIR/book/en/chapter-01/images"
mkdir -p "$TEST_DIR/book/images"
mkdir -p "$TEST_DIR/resources/images"

# Create a sample image
echo -e "${YELLOW}Creating test images...${NC}"
cat > "$TEST_DIR/book/images/test-image.svg" << 'EOF'
<svg width="200" height="100" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#f0f0f0"/>
  <text x="50%" y="50%" font-family="Arial" font-size="16" fill="#333" text-anchor="middle">Test Image</text>
</svg>
EOF

# Create a sample cover image
cat > "$TEST_DIR/book/images/cover.svg" << 'EOF'
<svg width="1000" height="1500" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#225577"/>
  <text x="50%" y="50%" font-family="Arial" font-size="64" fill="white" text-anchor="middle">Book Cover</text>
</svg>
EOF

# Create a chapter-specific image
cat > "$TEST_DIR/book/en/chapter-01/images/chapter-image.svg" << 'EOF'
<svg width="300" height="150" xmlns="http://www.w3.org/2000/svg">
  <rect width="100%" height="100%" fill="#e0e0ff"/>
  <text x="50%" y="50%" font-family="Arial" font-size="20" fill="#333" text-anchor="middle">Chapter Image</text>
</svg>
EOF

# Create book.yaml
cat > "$TEST_DIR/book.yaml" << 'EOF'
title: Test Book
subtitle: Testing EPUB Image Support
author: Test Author
language: en
version: 1.0.0

languages:
  - en

formats:
  - epub
EOF

# Create a test chapter with image references
cat > "$TEST_DIR/book/en/chapter-01/01-intro.md" << 'EOF'
# Introduction

This is a test chapter for EPUB image support.

## Common Image Test

Here is a test image:

![Test Image](test-image.svg)

## Chapter-Specific Image Test

Here is a chapter-specific image:

![Chapter Image](chapter-image.svg)

EOF

# Install book-tools if not already installed
if ! command -v book-tools &> /dev/null; then
    echo -e "${YELLOW}Installing book-tools...${NC}"
    cd "$TEST_DIR"
    bash ./.github/custom-install.sh
fi

# Build the test book
echo -e "${YELLOW}Building test EPUB...${NC}"
cd "$TEST_DIR"
book-tools build --verbose

# Check if EPUB was created
if [ -f "$TEST_DIR/build/en/Test Book-en.epub" ]; then
    echo -e "${GREEN}✅ EPUB file was created successfully!${NC}"
    
    # Get file size
    FILE_SIZE=$(du -h "$TEST_DIR/build/en/Test Book-en.epub" | cut -f1)
    echo -e "${GREEN}EPUB file size: $FILE_SIZE${NC}"
    
    # Verify it contains images
    if unzip -l "$TEST_DIR/build/en/Test Book-en.epub" | grep -q "\.svg\|\.png\|\.jpg"; then
        echo -e "${GREEN}✅ EPUB contains image files!${NC}"
        unzip -l "$TEST_DIR/build/en/Test Book-en.epub" | grep -E "\.svg|\.png|\.jpg" | head -5
    else
        echo -e "${RED}❌ EPUB does not contain image files!${NC}"
    fi
else
    echo -e "${RED}❌ EPUB file was not created!${NC}"
fi

echo -e "${YELLOW}Test complete. You can find the EPUB file at:${NC}"
echo -e "$TEST_DIR/build/en/Test Book-en.epub" 