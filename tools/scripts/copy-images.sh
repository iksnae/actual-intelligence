#!/bin/bash

# copy-images.sh - Handles image directory copying for the book build process
# This script ensures all images are properly copied to the build directories

set -e  # Exit on error

echo "🖼️ Setting up image directories..."

# Copy all image directories to the build folder to ensure proper path resolution
find book -path "*/images" -type d | while read -r imgdir; do
  echo "Found image directory: $imgdir"
  # Create parent directory in build directory
  mkdir -p "build/$(dirname "$imgdir")"
  # Copy directory
  cp -r "$imgdir" "build/$(dirname "$imgdir")/" 2>/dev/null || true
  echo "Copied $imgdir to build/$(dirname "$imgdir")/"
done

# Handle language-specific image copying

# English images
if [ -d "book/en/images" ]; then
  echo "Copying book/en/images to build/images..."
  cp -r book/en/images/* build/images/ 2>/dev/null || true
fi

# Spanish images
if [ -d "book/es/images" ]; then
  echo "Copying book/es/images to build/es/images..."
  cp -r book/es/images/* build/es/images/ 2>/dev/null || true
  # Also copy to root images for cross-referencing
  cp -r book/es/images/* build/images/ 2>/dev/null || true
fi

# Common images
if [ -d "book/images" ]; then
  echo "Copying book/images to build/images..."
  cp -r book/images/* build/images/ 2>/dev/null || true
  # Also copy to es images for cross-referencing
  cp -r book/images/* build/es/images/ 2>/dev/null || true
fi

echo "✅ Image copying completed"
