#!/bin/bash

# build.sh - Main entry point for the book building process
# Usage: build.sh [--all-languages] [--lang=XX] [--skip-pdf] [--skip-epub] [--skip-mobi] [--skip-html]

set -e  # Exit on error

# Parse command line arguments
BUILD_ALL_LANGUAGES=false
SPECIFIC_LANGUAGE=""
SKIP_FLAGS=""

for arg in "$@"
do
  case $arg in
    --all-languages)
      BUILD_ALL_LANGUAGES=true
      ;;
    --lang=*)
      SPECIFIC_LANGUAGE="${arg#*=}"
      ;;
    --skip-*)
      SKIP_FLAGS="$SKIP_FLAGS $arg"
      ;;
  esac
done

echo "📚 Building Actual Intelligence Book..."

# Make scripts executable
chmod +x tools/scripts/*.sh

# Run the setup script
source tools/scripts/setup.sh

# Determine which languages to build
if [ "$BUILD_ALL_LANGUAGES" = true ]; then
  echo "Building all languages..."
  # Verify which languages are available
  echo "Checking available languages:"
  # Use languages from setup.sh
  LANGUAGES=($AVAILABLE_LANGUAGES)
  
  echo "Will build languages: ${LANGUAGES[*]}"
elif [ -n "$SPECIFIC_LANGUAGE" ]; then
  echo "Building specific language: $SPECIFIC_LANGUAGE"
  if [ -d "book/$SPECIFIC_LANGUAGE/chapter-01" ]; then
    echo "✓ Found chapter content for $SPECIFIC_LANGUAGE"
    LANGUAGES=("$SPECIFIC_LANGUAGE")
  else
    echo "⚠️ WARNING: No chapter content found for $SPECIFIC_LANGUAGE!"
    echo "Defaulting to English."
    LANGUAGES=("en")
  fi
else
  # By default, build all languages in CI
  if [ -n "$CI" ]; then
    echo "Running in CI environment, building all languages by default"
    LANGUAGES=($AVAILABLE_LANGUAGES)
  else
    echo "Building only English by default"
    LANGUAGES=("en")
  fi
fi

# Build each language
for lang in "${LANGUAGES[@]}"; do
  echo "📚 Building $lang version..."
  if [ ! -d "book/$lang" ]; then
    echo "⚠️ WARNING: Language directory book/$lang does not exist, skipping!"
    continue
  fi
  
  if [ ! -d "book/$lang/chapter-01" ]; then
    echo "⚠️ WARNING: No chapter content found for $lang, skipping!"
    continue
  fi
  
  source tools/scripts/build-language.sh "$lang" $SKIP_FLAGS
done

# Ensure we copy Spanish files to the root directory
if [[ " ${LANGUAGES[*]} " =~ " es " ]]; then
  echo "📋 Ensuring Spanish files are copied to root build directory..."
  # Check if Spanish files exist in the es directory
  if [ -f "build/es/inteligencia-real.epub" ]; then
    cp "build/es/inteligencia-real.epub" "build/inteligencia-real.epub"
    echo "  - Copied EPUB: build/es/inteligencia-real.epub -> build/inteligencia-real.epub"
  fi
  
  if [ -f "build/es/inteligencia-real.pdf" ]; then
    cp "build/es/inteligencia-real.pdf" "build/inteligencia-real.pdf"
    echo "  - Copied PDF: build/es/inteligencia-real.pdf -> build/inteligencia-real.pdf"
  fi
  
  if [ -f "build/es/inteligencia-real.mobi" ]; then
    cp "build/es/inteligencia-real.mobi" "build/inteligencia-real.mobi"
    echo "  - Copied MOBI: build/es/inteligencia-real.mobi -> build/inteligencia-real.mobi"
  fi
  
  if [ -f "build/es/inteligencia-real.html" ]; then
    cp "build/es/inteligencia-real.html" "build/inteligencia-real.html"
    echo "  - Copied HTML: build/es/inteligencia-real.html -> build/inteligencia-real.html"
  fi
fi

# List the build folder contents for verification
echo -e "\n📝 Contents of build/ directory:"
ls -la build/

# Show language-specific directories if they exist
for lang in "${LANGUAGES[@]}"; do
  if [ "$lang" != "en" ] && [ -d "build/$lang" ]; then
    echo -e "\n📝 Contents of build/$lang/ directory:"
    ls -la "build/$lang/"
  fi
done

# Check for specific Spanish outputs
if [[ " ${LANGUAGES[*]} " =~ " es " ]]; then
  if [ -f "build/inteligencia-real.epub" ]; then
    echo -e "\n✅ Spanish EPUB (inteligencia-real.epub) found in build directory"
    du -h "build/inteligencia-real.epub"
  else
    echo -e "\n❌ Spanish EPUB (inteligencia-real.epub) NOT found in build directory!"
  fi
  
  if [ -f "build/es/inteligencia-real.epub" ]; then
    echo -e "\n✅ Spanish EPUB found in build/es directory"
    du -h "build/es/inteligencia-real.epub"
  fi
fi

echo "✅ Build process completed successfully!"
