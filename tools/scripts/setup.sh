#!/bin/bash

# setup.sh - Prepares the environment for book building
# This script handles initial setup, directories and cover image detection

set -e  # Exit on error

echo "🔄 Running setup script..."

# Create build directory if it doesn't exist
mkdir -p build
mkdir -p build/images
mkdir -p build/es
mkdir -p build/es/images

# Create templates directory if it doesn't exist
mkdir -p templates

# Check that source book directories exist
echo "📚 Verifying language directories..."
if [ ! -d "book/en" ]; then
  echo "⚠️ ERROR: English content directory (book/en) not found!" 
  exit 1
else
  echo "✅ Found English content directory"
  echo "English content:"
  ls -la book/en/
fi

if [ ! -d "book/es" ]; then
  echo "⚠️ WARNING: Spanish content directory (book/es) not found!"
  echo "The Spanish version will not be built"
else
  echo "✅ Found Spanish content directory"
  echo "Spanish content:"
  ls -la book/es/
fi

# Process cover image
echo "🔎 Checking for cover image..."
COVER_IMAGE=""

# Try to find cover image in standard locations
if [ -f "art/cover.png" ]; then
  echo "✅ Found cover image at art/cover.png"
  COVER_IMAGE="art/cover.png"
  cp "$COVER_IMAGE" build/images/cover.png
  
elif [ -f "book/images/cover.png" ]; then
  echo "✅ Found cover image at book/images/cover.png"
  COVER_IMAGE="book/images/cover.png"
  cp "$COVER_IMAGE" build/images/cover.png
  
elif [ -f "book/en/images/cover.png" ]; then
  echo "✅ Found cover image at book/en/images/cover.png"
  COVER_IMAGE="book/en/images/cover.png"
  cp "$COVER_IMAGE" build/images/cover.png
  
elif [ -f "book/es/images/cover.png" ]; then
  echo "✅ Found cover image at book/es/images/cover.png"
  COVER_IMAGE="book/es/images/cover.png"
  cp "$COVER_IMAGE" build/images/cover.png
else
  echo "⚠️ No cover image found. Building book without cover."
fi

# Export the cover image path as an environment variable
export COVER_IMAGE

# Copy images to the build directory
echo "🖼️ Copying images to build directory..."

# Copy English images
if [ -d "book/en/images" ]; then
  echo "Copying English images..."
  cp -r book/en/images/* build/images/ 2>/dev/null || true
fi

# Copy Spanish images
if [ -d "book/es/images" ]; then
  echo "Copying Spanish images..."
  cp -r book/es/images/* build/images/ 2>/dev/null || true
  cp -r book/es/images/* build/es/images/ 2>/dev/null || true
fi

# Copy common images
if [ -d "book/images" ]; then
  echo "Copying common images..."
  cp -r book/images/* build/images/ 2>/dev/null || true
fi

# Check EPUB processor
if command -v generate-epub &> /dev/null; then
  echo "✅ Container generate-epub utility found"
else
  echo "⚠️ Container generate-epub utility not found, will use direct pandoc commands"
fi

echo "📋 Environment Summary:"
echo "   - COVER_IMAGE: $COVER_IMAGE"
echo "   - Working Directory: $(pwd)"
echo "   - Build directories:"
ls -la build/
echo "   - Images directory:"
ls -la build/images/

echo "✅ Setup completed successfully"
