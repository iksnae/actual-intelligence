#!/bin/bash

# setup.sh - Prepares the environment for book building
# This script handles initial setup, directories and cover image detection

set -e  # Exit on error

echo "🔄 Running setup script..."

# Create build directory if it doesn't exist
mkdir -p build

# Create templates directory if it doesn't exist
mkdir -p templates

# Create language-specific directories
mkdir -p build/images
mkdir -p build/es

# Process cover image
echo "🔎 Checking for cover image..."
COVER_IMAGE=""

# Try to find cover image in standard locations
if [ -f "art/cover.png" ]; then
  echo "✅ Found cover image at art/cover.png"
  COVER_IMAGE="art/cover.png"
  
  # Copy to build directory
  cp "$COVER_IMAGE" build/images/cover.png
  
elif [ -f "book/images/cover.png" ]; then
  echo "✅ Found cover image at book/images/cover.png"
  COVER_IMAGE="book/images/cover.png"
  
  # Copy to build directory
  cp "$COVER_IMAGE" build/images/cover.png
  
elif [ -f "book/en/images/cover.png" ]; then
  echo "✅ Found cover image at book/en/images/cover.png"
  COVER_IMAGE="book/en/images/cover.png"
  
  # Copy to build directory
  cp "$COVER_IMAGE" build/images/cover.png
  
elif [ -f "book/es/images/cover.png" ]; then
  echo "✅ Found cover image at book/es/images/cover.png"
  COVER_IMAGE="book/es/images/cover.png"
  
  # Copy to build directory
  cp "$COVER_IMAGE" build/images/cover.png
else
  echo "⚠️ No cover image found. Building book without cover."
fi

# Export the cover image path as an environment variable
export COVER_IMAGE

# Check for locales to support international characters
echo "🌐 Checking system locales..."
if command -v locale-gen &> /dev/null; then
  echo "Ensuring locales are properly set up..."
  # Generate common locales if locale-gen is available
  locale-gen en_US.UTF-8 || echo "Could not generate en_US.UTF-8 locale"
  locale-gen es_ES.UTF-8 || echo "Could not generate es_ES.UTF-8 locale"
else
  echo "locale-gen command not found. Using system default locales."
fi

# Set default locale to UTF-8 for better international text support
export LC_ALL=C.UTF-8 || export LC_ALL=en_US.UTF-8 || true
export LANG=C.UTF-8 || export LANG=en_US.UTF-8 || true

# Update LaTeX template (but don't include version and date)
if [ -f "templates/template.tex" ]; then
  echo "📝 Using LaTeX template..."
  TEMP_TEMPLATE="templates/template-version.tex"
  cp templates/template.tex "$TEMP_TEMPLATE"
  
  # Use empty values for version and date to effectively remove them
  sed -i "s/\\\\newcommand{\\\\bookversion}{VERSION}/\\\\newcommand{\\\\bookversion}{}/g" "$TEMP_TEMPLATE"
  sed -i "s/\\\\newcommand{\\\\builddate}{BUILDDATE}/\\\\newcommand{\\\\builddate}{}/g" "$TEMP_TEMPLATE"
  
  echo "✅ LaTeX template updated with empty version and date"
  export TEMP_TEMPLATE
else
  echo "ℹ️ No LaTeX template found. Proceeding with default styling."
  TEMP_TEMPLATE=""
  export TEMP_TEMPLATE
fi

# Copy image resources to build directory
echo "🖼️ Copying image directories..."
source tools/scripts/copy-images.sh

echo "📋 Environment Summary:"
echo "   - COVER_IMAGE: $COVER_IMAGE"
echo "   - TEMP_TEMPLATE: $TEMP_TEMPLATE"
echo "   - Working Directory: $(pwd)"
echo "   - Language Support: en_US.UTF-8, es_ES.UTF-8"

# List all image directories
echo "   - Image directories:"
ls -la "build/images/"
echo "   - Spanish web images:"
ls -la "build/es/"

echo "✅ Setup completed successfully"
