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
  LANGUAGES=("en" "es")
elif [ -n "$SPECIFIC_LANGUAGE" ]; then
  echo "Building specific language: $SPECIFIC_LANGUAGE"
  LANGUAGES=("$SPECIFIC_LANGUAGE")
else
  # By default, build all languages in CI
  if [ -n "$CI" ]; then
    echo "Running in CI environment, building all languages by default"
    LANGUAGES=("en" "es")
  else
    echo "Building only English by default"
    LANGUAGES=("en")
  fi
fi

# Build each language
for lang in "${LANGUAGES[@]}"; do
  echo "📚 Building $lang version..."
  source tools/scripts/build-language.sh "$lang" $SKIP_FLAGS
done

# List the build folder contents for verification
echo "\n📝 Contents of build/ directory:"
ls -la build/

# Show language-specific directories if they exist
for lang in "${LANGUAGES[@]}"; do
  if [ "$lang" != "en" ] && [ -d "build/$lang" ]; then
    echo "\n📝 Contents of build/$lang/ directory:"
    ls -la "build/$lang/"
  fi
done

echo "✅ Build process completed successfully!"
