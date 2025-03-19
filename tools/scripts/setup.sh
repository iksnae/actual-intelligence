#!/bin/bash

# setup.sh - Sets up the build environment for the Actual Intelligence book
# This script is the first to run during the build process

echo "🔧 Setting up build environment..."

# Make build directory if it doesn't exist
mkdir -p build

# Make necessary language directories
mkdir -p build/es
mkdir -p build/images
mkdir -p build/es/images

# Make templates directory if it doesn't exist
mkdir -p templates

# Export language settings
export AVAILABLE_LANGUAGES="en es"
export DEFAULT_LANGUAGE="en"

echo "✅ Build environment setup complete."
echo "Available languages: $AVAILABLE_LANGUAGES"
echo "Default language: $DEFAULT_LANGUAGE"

# Look for cover images and make them available in the right places
if [ -f "art/cover.png" ]; then
  echo "🖼️  Found cover image in art/cover.png"
  export COVER_IMAGE="art/cover.png"
  # Copy it to the build directory too
  cp "art/cover.png" "build/images/cover.png"
elif [ -f "book/images/cover.png" ]; then
  echo "🖼️  Found cover image in book/images/cover.png"
  export COVER_IMAGE="book/images/cover.png"
  # Copy it to the build directory
  cp "book/images/cover.png" "build/images/cover.png"
fi

# Look for language-specific cover images
if [ -f "book/es/images/cover.png" ]; then
  echo "🖼️  Found Spanish cover image in book/es/images/cover.png"
  export ES_COVER_IMAGE="book/es/images/cover.png"
  # Copy it to the Spanish build directory
  cp "book/es/images/cover.png" "build/es/images/cover.png"
else
  # If no Spanish-specific cover, copy the default one
  if [ -n "$COVER_IMAGE" ]; then
    echo "📋 Using default cover image for Spanish"
    cp "$COVER_IMAGE" "build/es/images/cover.png"
  fi
fi

# Look for chapter images and make them available
for lang in en es; do
  if [ -d "book/$lang/chapter-01/images" ]; then
    echo "🖼️  Found chapter images for $lang"
    mkdir -p "build/$lang/images"
    cp -r "book/$lang/chapter-01/images/"* "build/$lang/images/" || true
    
    # Also copy to main images directory for EPUB generation
    if [ "$lang" = "es" ]; then
      cp -r "book/$lang/chapter-01/images/"* "build/images/" || true
    fi
  fi
done

echo "🔧 Environment setup completed."
