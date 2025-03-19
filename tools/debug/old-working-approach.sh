#!/bin/bash
# Recreate the working approach from commit f5b41647482d6446ca40a9db9d7c71bb423c2b02

# Don't exit on error
set +e

# Set up basic variables
LANGUAGE=${1:-en}
INPUT_FILE=build/actual-intelligence.md
OUTPUT_FILE=build/actual-intelligence.epub
RESOURCE_PATHS=".:book:book/en:build:book/en/images:book/images:build/images"

echo "📱 Recreating working EPUB generation approach from f5b41647..."

# Create build directory if it doesn't exist
mkdir -p build

# Ensure cover image is properly handled
echo "Checking for cover image..."
COVER_IMAGE=""

# Try to find cover image in standard locations
if [ -f "art/cover.png" ]; then
  echo "✅ Found cover image at art/cover.png"
  COVER_IMAGE="art/cover.png"
  
  # Ensure book/images directories exist
  mkdir -p book/images
  mkdir -p book/en/images
  
  # Copy cover to book directories for consistency
  cp "$COVER_IMAGE" book/images/cover.png
  cp "$COVER_IMAGE" book/en/images/cover.png
elif [ -f "book/images/cover.png" ]; then
  echo "✅ Found cover image at book/images/cover.png"
  COVER_IMAGE="book/images/cover.png"
elif [ -f "book/en/images/cover.png" ]; then
  echo "✅ Found cover image at book/en/images/cover.png"
  COVER_IMAGE="book/en/images/cover.png"
else
  echo "⚠️ No cover image found. Building book without cover."
fi

# Copy all image directories to the build folder to ensure proper path resolution
echo "Copying image directories..."
find book -path "*/images" -type d | while read -r imgdir; do
  echo "Found image directory: $imgdir"
  # Create parent directory in build directory
  mkdir -p "build/$(dirname "$imgdir")"
  # Copy directory
  cp -r "$imgdir" "build/$(dirname "$imgdir")/" 2>/dev/null || true
  echo "Copied $imgdir to build/$(dirname "$imgdir")/"
done

# Also explicitly copy images to standard locations for better compatibility
if [ -d "book/en/images" ]; then
  echo "Copying book/en/images to build/images..."
  mkdir -p build/images
  cp -r book/en/images/* build/images/ 2>/dev/null || true
fi

if [ -d "book/images" ]; then
  echo "Copying book/images to build/images..."
  mkdir -p build/images
  cp -r book/images/* build/images/ 2>/dev/null || true
fi

# Now run the exact command used in the previous working version
echo "Generating EPUB file..."
if [ -n "$COVER_IMAGE" ]; then
  echo "Including cover image in EPUB: $COVER_IMAGE"
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --epub-cover-image="$COVER_IMAGE" \
    --toc \
    --toc-depth=2 \
    --metadata title="Actual Intelligence" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="K Mills" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media=build/epub-media
else
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --toc \
    --toc-depth=2 \
    --metadata title="Actual Intelligence" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="K Mills" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media=build/epub-media
fi

# Check file size to verify image inclusion
if [ -s "$OUTPUT_FILE" ]; then
  FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
  echo "📊 EPUB file size: ${FILE_SIZE}KB"
  
  if [ "$FILE_SIZE" -lt 3000 ]; then
    echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
  else
    echo "✅ EPUB file size looks good (${FILE_SIZE}KB). Images likely included."
  fi
  
  echo "✅ EPUB created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create EPUB."
fi

echo "Original working approach completed!"
