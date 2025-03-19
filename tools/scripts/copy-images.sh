#!/bin/bash

# copy-images.sh - Handles image directory copying for the book build process
# This script ensures all images are properly copied to the build directories

set -e  # Exit on error

echo "🖼️ Setting up image directories..."

# Create required image directories if they don't exist
mkdir -p build/images
mkdir -p build/es/images

# Copy all image directories to the build folder to ensure proper path resolution
find book -path "*/images" -type d | while read -r imgdir; do
  echo "Found image directory: $imgdir"
  # Extract the parent directory (e.g., "en" or "es")
  parent_dir=$(dirname "$imgdir")
  parent_name=$(basename "$parent_dir")
  
  # Create parent directory in build directory
  if [[ "$parent_name" == "en" || "$parent_name" == "es" ]]; then
    echo "  - Language-specific image directory ($parent_name)"
    mkdir -p "build/$parent_name"
    # Copy directory
    echo "  - Copying to build/$parent_name/"
    cp -r "$imgdir" "build/$parent_name/" 2>/dev/null || true
  else
    # For non-language directories (like common images)
    echo "  - Common image directory"
    mkdir -p "build/$(dirname "$imgdir")"
    # Copy directory
    echo "  - Copying to build/$(dirname "$imgdir")/"
    cp -r "$imgdir" "build/$(dirname "$imgdir")//" 2>/dev/null || true
  fi
done

# Handle language-specific image copying with more detailed logging

# English images (copy to both English and build root for availability)
if [ -d "book/en/images" ]; then
  echo "Copying book/en/images to build/images..."
  
  # Count images for better debugging
  img_count=$(find "book/en/images" -type f | wc -l)
  echo "  - Found $img_count images in book/en/images"
  
  # Copy with verbose flag
  cp -rv book/en/images/* build/images/ 2>/dev/null || true
  
  # Verify copy
  copied_count=$(find "build/images" -type f | wc -l)
  echo "  - Copied $copied_count images to build/images/"
fi

# Spanish images (copy to Spanish directory AND build root for consistency)
if [ -d "book/es/images" ]; then
  echo "Copying book/es/images to build/es/images..."
  
  # Count images for better debugging
  img_count=$(find "book/es/images" -type f | wc -l)
  echo "  - Found $img_count images in book/es/images"
  
  # Make sure the target directory exists
  mkdir -p build/es/images
  
  # Copy with verbose flag
  cp -rv book/es/images/* build/es/images/ 2>/dev/null || true
  
  # Also copy to root images for cross-referencing (required for reliable HTML generation)
  echo "  - Also copying Spanish images to build/images/"
  cp -rv book/es/images/* build/images/ 2>/dev/null || true
  
  # Verify copies
  es_copied_count=$(find "build/es/images" -type f | wc -l)
  root_copied_count=$(find "build/images" -type f -name "$(basename "book/es/images/*")" 2>/dev/null | wc -l)
  echo "  - Copied $es_copied_count images to build/es/images/"
  echo "  - Copied Spanish images to build/images/"
fi

# Common images (copy to all language directories)
if [ -d "book/images" ]; then
  echo "Copying book/images to all language directories..."
  
  # Count images for better debugging
  img_count=$(find "book/images" -type f | wc -l)
  echo "  - Found $img_count images in book/images"
  
  # Copy to build/images
  echo "  - Copying to build/images/"
  cp -rv book/images/* build/images/ 2>/dev/null || true
  
  # Also copy to es images for cross-referencing
  echo "  - Copying to build/es/images/"
  mkdir -p build/es/images
  cp -rv book/images/* build/es/images/ 2>/dev/null || true
  
  # Verify copies
  root_copied_count=$(find "build/images" -type f | wc -l)
  es_copied_count=$(find "build/es/images" -type f | wc -l)
  echo "  - Images in build/images/: $root_copied_count"
  echo "  - Images in build/es/images/: $es_copied_count"
fi

# Handle special case for cover images
# Ensure cover images are available in all required locations
for cover_location in "art/cover.png" "book/images/cover.png" "book/en/images/cover.png" "book/es/images/cover.png"; do
  if [ -f "$cover_location" ]; then
    echo "Found cover image at $cover_location"
    
    # Copy to all required locations
    mkdir -p build/images
    mkdir -p build/es/images
    cp -v "$cover_location" build/images/cover.png 2>/dev/null || true
    cp -v "$cover_location" build/es/images/cover.png 2>/dev/null || true
    
    echo "  - Copied cover to build/images/ and build/es/images/"
  fi
done

echo "✅ Image copying completed"
echo "Final image counts in build directories:"
find build -path "*/images" -type d | while read -r imgdir; do
  count=$(find "$imgdir" -type f | wc -l)
  echo "  - $imgdir: $count files"
done
