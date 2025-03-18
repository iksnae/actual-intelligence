#!/bin/bash

# generate-epub.sh - Generates EPUB version of the book
# Usage: generate-epub.sh [language] [input_file] [output_file] [book_title] [book_subtitle] [resource_paths]

# Debugging - show exactly what we're doing
set -x

# Don't exit on error - we'll handle errors manually
set +e

# Get arguments
LANGUAGE=${1:-en}
INPUT_FILE=${2:-build/actual-intelligence.md}
OUTPUT_FILE=${3:-build/actual-intelligence.epub}
BOOK_TITLE=${4:-"Actual Intelligence"}
BOOK_SUBTITLE=${5:-"A Practical Guide to Using AI in Everyday Life"}

# Create a unique working directory for this build
WORK_DIR="build/epub_build_${LANGUAGE}_$(date +%s)"
mkdir -p "$WORK_DIR"

# Copy the Markdown file to our working directory
WORKING_MD="$WORK_DIR/content.md"
cp "$INPUT_FILE" "$WORKING_MD"

# Create an images directory 
mkdir -p "$WORK_DIR/images"

# Copy ALL images to our working directory to ensure they're found
echo "Copying all images to working directory..."
if [ -d "book/images" ]; then
  cp -r book/images/* "$WORK_DIR/images/" 2>/dev/null || true
fi

if [ -d "book/en/images" ]; then
  cp -r book/en/images/* "$WORK_DIR/images/" 2>/dev/null || true
fi

if [ -d "book/$LANGUAGE/images" ]; then
  cp -r book/$LANGUAGE/images/* "$WORK_DIR/images/" 2>/dev/null || true
fi

if [ -d "build/images" ]; then
  cp -r build/images/* "$WORK_DIR/images/" 2>/dev/null || true
fi

if [ -d "build/$LANGUAGE/images" ]; then
  cp -r build/$LANGUAGE/images/* "$WORK_DIR/images/" 2>/dev/null || true
fi

# Special handling for cover image
if [ -n "$COVER_IMAGE" ]; then
  # Copy cover image to our working directory
  cp "$COVER_IMAGE" "$WORK_DIR/cover.png"
  COVER_IMAGE_ARG="--epub-cover-image=$WORK_DIR/cover.png"
  
  # Update metadata in the markdown file
  sed -i "s|cover-image: '.*'|cover-image: 'cover.png'|g" "$WORKING_MD"
else
  COVER_IMAGE_ARG=""
fi

# Fix image paths in the markdown file to be relative to working directory
# This is critical for Pandoc to find the images
echo "Fixing image paths in Markdown..."
sed -i 's|!\[\([^]]*\)\](\([^)]*\))|![\1](images/\2)|g' "$WORKING_MD"
sed -i 's|!\[\([^]]*\)\](images/images/|![\1](images/|g' "$WORKING_MD"

# Make images directory easily available
ln -s "$WORK_DIR/images" "images" 2>/dev/null || true

# Change to working directory (CRITICAL for path resolution)
cd "$WORK_DIR"

echo "📱 Generating EPUB for $LANGUAGE from working directory $(pwd)..."
echo "Current directory contents:"
ls -la

echo "Images directory contents:"
ls -la images/

# Generate EPUB directly from the working directory
pandoc content.md -o "output.epub" \
  $COVER_IMAGE_ARG \
  --self-contained \
  --toc \
  --toc-depth=2 \
  --metadata title="$BOOK_TITLE" \
  --metadata subtitle="$BOOK_SUBTITLE" \
  --metadata publisher="Khaos Studios" \
  --metadata creator="Open Source Community" \
  --metadata lang="$LANGUAGE"

# Check if EPUB generation succeeded
if [ -s "output.epub" ]; then
  # Copy back to the intended location
  cp "output.epub" "../../../$OUTPUT_FILE"
  
  # Get file size for verification
  FILE_SIZE=$(du -k "../../../$OUTPUT_FILE" | cut -f1)
  echo "📊 EPUB file size: ${FILE_SIZE}KB"
  
  if [ "$FILE_SIZE" -lt 3000 ]; then
    echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
  else
    echo "✅ EPUB file size looks good (${FILE_SIZE}KB). Images likely included."
  fi
  
  echo "✅ EPUB created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create EPUB (first attempt)"
  
  # Try with explicit --extract-media approach
  cd "../.."
  echo "Attempting alternate EPUB generation approach..."
  
  # Create a separate extract media directory
  EXTRACT_DIR="$WORK_DIR/extract"
  mkdir -p "$EXTRACT_DIR"
  
  # Generate EPUB with extract-media
  pandoc "$WORKING_MD" -o "$OUTPUT_FILE" \
    $COVER_IMAGE_ARG \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata subtitle="$BOOK_SUBTITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --metadata lang="$LANGUAGE" \
    --extract-media="$EXTRACT_DIR" \
    --resource-path="$WORK_DIR:$WORK_DIR/images:."
  
  # Check results of second attempt
  if [ -s "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
    echo "📊 EPUB file size (second attempt): ${FILE_SIZE}KB"
    
    if [ "$FILE_SIZE" -lt 3000 ]; then
      echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
    else
      echo "✅ EPUB file size looks good (${FILE_SIZE}KB). Images likely included."
    fi
    
    echo "✅ EPUB created successfully at $OUTPUT_FILE"
  else
    echo "❌ Failed to create EPUB after multiple attempts"
    exit 1
  fi
fi