#!/bin/bash

# copy-images.sh - Handles image directory copying for the book build process
# This script ensures all images are properly copied to the build directories

set -e  # Exit on error

echo "🖼️ Setting up image directories..."

# Create the main images directory
mkdir -p build/images

# Copy all images from all language directories to the build/images directory
# This mimics how Rise and Code handles images - all in one common place
echo "🖼️ Copying all images to build/images..."

# First copy all common images
if [ -d "book/images" ]; then
  echo "Copying common images from book/images to build/images"
  cp -r book/images/* build/images/ 2>/dev/null || true
  echo "✓ Common images copied"
fi

# Then copy language-specific images, also to the common directory
for lang_dir in book/*/; do
  # Skip if not a directory
  if [ ! -d "$lang_dir" ]; then
    continue
  fi
  
  lang=$(basename "$lang_dir")
  
  # Skip if not a language directory (only process en, es, etc.)
  if [[ ! "$lang" =~ ^(en|es|fr|de)$ ]]; then
    continue
  fi
  
  # Check if this language has images
  if [ -d "${lang_dir}images" ]; then
    echo "Copying $lang images to build/images..."
    cp -r "${lang_dir}images/"* build/images/ 2>/dev/null || true
    echo "✓ $lang images copied to common directory"
    
    # For Spanish and other languages, also make sure the images are in the language folder
    # (primarily for web hosting with language subfolders)
    if [ "$lang" != "en" ]; then
      echo "Ensuring $lang has its own images directory for web..."
      mkdir -p "build/$lang/images"
      cp -r "${lang_dir}images/"* "build/$lang/images/" 2>/dev/null || true
      # Also copy common images
      cp -r build/images/* "build/$lang/images/" 2>/dev/null || true
      echo "✓ $lang web images directory created and populated"
    fi
  fi
done

# Special handling for cover images
echo "📚 Handling cover images..."
for lang in "en" "es"; do
  # Look for language-specific cover image first
  if [ -f "book/$lang/images/cover.png" ]; then
    echo "Found $lang cover at book/$lang/images/cover.png"
    cp "book/$lang/images/cover.png" "build/images/cover-$lang.png" 2>/dev/null || true
    # Also copy to root images directory with standard name for that language
    if [ "$lang" = "en" ]; then
      cp "book/$lang/images/cover.png" "build/images/cover.png" 2>/dev/null || true
    else
      cp "book/$lang/images/cover.png" "build/images/cover-$lang.png" 2>/dev/null || true
      # Also copy to language subdirectory for web use
      mkdir -p "build/$lang/images"
      cp "book/$lang/images/cover.png" "build/$lang/images/cover.png" 2>/dev/null || true
    fi
  fi
done

# If we have a generic cover image, make sure it's available for all languages
if [ -f "book/images/cover.png" ]; then
  echo "Found common cover image at book/images/cover.png"
  cp "book/images/cover.png" "build/images/cover.png" 2>/dev/null || true
  # Also copy to language directories for web use
  for lang in "es"; do
    mkdir -p "build/$lang/images"
    cp "book/images/cover.png" "build/$lang/images/cover.png" 2>/dev/null || true
  done
fi

# Check art directory for cover image if no cover found yet
if [ ! -f "build/images/cover.png" ] && [ -f "art/cover.png" ]; then
  echo "Using cover from art directory"
  cp "art/cover.png" "build/images/cover.png" 2>/dev/null || true
  # Copy to language directories too
  for lang in "es"; do
    mkdir -p "build/$lang/images"
    cp "art/cover.png" "build/$lang/images/cover.png" 2>/dev/null || true
  done
fi

# List what we've got
echo "📊 Image directories content:"
echo "build/images:"
ls -la build/images/
for lang in "es"; do
  if [ -d "build/$lang/images" ]; then
    echo "build/$lang/images:"
    ls -la "build/$lang/images/"
  fi
done

echo "✅ Image copying completed"
