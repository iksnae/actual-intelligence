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
mkdir -p build/es/images

# Process cover image
echo "🔎 Checking for cover image..."
COVER_IMAGE=""

# Try to find cover image in standard locations
if [ -f "art/cover.png" ]; then
  echo "✅ Found cover image at art/cover.png"
  COVER_IMAGE="art/cover.png"
  
  # Ensure book/images directories exist
  mkdir -p book/images
  mkdir -p book/en/images
  mkdir -p book/es/images
  
  # Copy cover to book directories for consistency
  cp "$COVER_IMAGE" book/images/cover.png
  cp "$COVER_IMAGE" book/en/images/cover.png
  cp "$COVER_IMAGE" book/es/images/cover.png
elif [ -f "book/images/cover.png" ]; then
  echo "✅ Found cover image at book/images/cover.png"
  COVER_IMAGE="book/images/cover.png"
elif [ -f "book/en/images/cover.png" ]; then
  echo "✅ Found cover image at book/en/images/cover.png"
  COVER_IMAGE="book/en/images/cover.png"
else
  echo "⚠️ No cover image found. Building book without cover."
fi

# Export the cover image path as an environment variable
export COVER_IMAGE

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

echo "✅ Setup completed successfully"
