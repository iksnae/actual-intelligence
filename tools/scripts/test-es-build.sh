#!/bin/bash

# This is a test script to specifically build the Spanish version
# It helps us isolate any issues with the Spanish build process

set -x  # Enable debug output to see each command

echo "Creating build directories..."
mkdir -p build
mkdir -p build/es
mkdir -p build/es/images
mkdir -p build/images

echo "Making scripts executable..."
chmod +x tools/scripts/*.sh

echo "Setting up cover image..."
if [ -f "book/es/images/cover.png" ]; then
    COVER_IMAGE="book/es/images/cover.png"
elif [ -f "art/cover.png" ]; then
    COVER_IMAGE="art/cover.png"
elif [ -f "book/images/cover.png" ]; then
    COVER_IMAGE="book/images/cover.png"
else
    COVER_IMAGE=""
fi

echo "Using cover image: $COVER_IMAGE"
export COVER_IMAGE

echo "Checking available Spanish content..."
if [ -d "book/es" ]; then
    echo "Spanish directory exists"
    ls -la book/es/
else
    echo "No Spanish directory found!"
    exit 1
fi

if [ -d "book/es/chapter-01" ]; then
    echo "Spanish chapter content exists"
    ls -la book/es/chapter-01/
else
    echo "No Spanish chapter content found!"
    exit 1
fi

echo "Building ONLY Spanish version..."
source tools/scripts/build-language.sh es

echo "Build completed. Checking results..."
echo "Contents of build directory:"
ls -la build/

echo "Contents of Spanish directory:"
ls -la build/es/

if [ -f "build/inteligencia-real.epub" ]; then
    echo "SUCCESS: Spanish EPUB file exists in root build directory"
    du -h build/inteligencia-real.epub
else
    echo "ERROR: Spanish EPUB file missing from root build directory"
fi

if [ -f "build/es/inteligencia-real.epub" ]; then
    echo "SUCCESS: Spanish EPUB file exists in build/es directory"
    du -h build/es/inteligencia-real.epub
else
    echo "ERROR: Spanish EPUB file missing from build/es directory"
fi
