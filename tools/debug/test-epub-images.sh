#!/bin/bash
# Test script to debug EPUB image inclusion in Docker environment
# This script tests various Pandoc commands to determine what works for image inclusion

set -x  # Show all commands being run

# Create test directory
mkdir -p test-epub
cd test-epub

# Create a simple markdown file with an image
cat > test.md << EOF
---
title: "EPUB Image Test"
author: "Debugging Team"
---

# EPUB Image Test

This is a test document with an image:

![Test Image](test-image.png)

EOF

# Create a simple test image
echo "Creating test image..."
convert -size 300x200 xc:blue test-image.png || echo "Could not create test image with convert, trying other method"

# Alternative way to create test image if convert fails
if [ ! -f "test-image.png" ]; then
  echo '<svg width="300" height="200"><rect width="300" height="200" style="fill:blue"/></svg>' > test.svg
  rsvg-convert -f png -o test-image.png test.svg || echo "Could not create test image with rsvg-convert"
fi

# Another fallback for image creation
if [ ! -f "test-image.png" ]; then
  cp ../../../book/en/images/cover.png test-image.png || echo "Could not copy existing image"
fi

# List contents for verification
echo "Working directory contents:"
ls -la

# Test various EPUB generation options
echo "Testing EPUB generation with different options..."

# Test 1: Basic command
echo "Test 1: Basic command"
pandoc test.md -o test1.epub
du -k test1.epub

# Test 2: With resource path
echo "Test 2: With resource path"
pandoc test.md -o test2.epub --resource-path="."
du -k test2.epub

# Test 3: With self-contained flag
echo "Test 3: With self-contained flag"
pandoc test.md -o test3.epub --self-contained
du -k test3.epub

# Test 4: With embed-resources flag
echo "Test 4: With embed-resources flag"
pandoc test.md -o test4.epub --embed-resources
du -k test4.epub

# Test 5: With data-dir
echo "Test 5: With data-dir"
pandoc test.md -o test5.epub --data-dir=.
du -k test5.epub

# Test 6: With extract-media
echo "Test 6: With extract-media"
pandoc test.md -o test6.epub --extract-media=extracted
du -k test6.epub

# Test 7: With absolute path to image
echo "Test 7: With absolute path to image"
WORKING_DIR=$(pwd)
sed "s|test-image.png|$WORKING_DIR/test-image.png|g" test.md > test-abs-path.md
pandoc test-abs-path.md -o test7.epub
du -k test7.epub

# Test 8: Try from parent directory
echo "Test 8: Try from parent directory"
cd ..
pandoc test-epub/test.md -o test-epub/test8.epub --resource-path="test-epub"
du -k test-epub/test8.epub

# Test 9: Try Pandoc version 2 approach
echo "Test 9: Try Pandoc version 2 approach"
pandoc test-epub/test.md -o test-epub/test9.epub --epub-embed-font=test-epub/test-image.png
du -k test-epub/test9.epub

# Gather info about environment
echo "Pandoc version:"
pandoc --version

echo "System info:"
uname -a

echo "Container environment variables:"
env

echo "Test complete. Results located in test-epub directory."
