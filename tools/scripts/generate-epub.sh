#!/bin/bash

# generate-epub.sh - Generates EPUB version of the book
# Usage: generate-epub.sh [language] [input_file] [output_file] [book_title] [book_subtitle] [resource_paths]

# Get arguments
LANGUAGE=${1:-en}
INPUT_FILE=${2:-build/actual-intelligence.md}
OUTPUT_FILE=${3:-build/actual-intelligence.epub}
BOOK_TITLE=${4:-"Actual Intelligence"}
BOOK_SUBTITLE=${5:-"A Practical Guide to Using AI in Everyday Life"}
RESOURCE_PATHS=${6:-".:book:book/$LANGUAGE:build:book/$LANGUAGE/images:book/images:build/images"}

echo "📱 Generating EPUB for $LANGUAGE..."

# Safety check to ensure input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Error: Input file $INPUT_FILE does not exist"
  exit 1
fi

# Make sure the output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Ensure images directory exists
mkdir -p build/images

# Copy all images to build/images directory for easy access
if [ -d "book/images" ]; then
  echo "Copying from book/images"
  cp -r book/images/* build/images/ 2>/dev/null || true
fi

if [ -d "book/en/images" ]; then
  echo "Copying from book/en/images"
  cp -r book/en/images/* build/images/ 2>/dev/null || true
fi

if [ -d "book/$LANGUAGE/images" ]; then
  echo "Copying from book/$LANGUAGE/images"
  cp -r book/$LANGUAGE/images/* build/images/ 2>/dev/null || true
fi

if [ -n "$COVER_IMAGE" ]; then
  echo "Using cover image: $COVER_IMAGE"
  # Copy to build/images for accessibility
  cp "$COVER_IMAGE" build/images/cover.png 2>/dev/null || true
  COVER_OPTION="--epub-cover-image=$COVER_IMAGE"
else
  COVER_OPTION=""
fi

# Create a version for debug logs
mkdir -p build/logs
LOG_FILE="build/logs/pandoc-epub-$LANGUAGE-$(date +%s).log"

# Generate EPUB with the simplest possible approach, following container conventions
echo "Running pandoc to generate EPUB..."

# First try - standard approach
pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
  $COVER_OPTION \
  --toc \
  --toc-depth=2 \
  --resource-path="$RESOURCE_PATHS" \
  --verbose \
  --metadata title="$BOOK_TITLE" \
  --metadata subtitle="$BOOK_SUBTITLE" \
  --metadata publisher="Khaos Studios" \
  --metadata creator="Open Source Community" \
  --metadata lang="$LANGUAGE" \
  --metadata-file=<(echo -e "---\ntitle: \"$BOOK_TITLE\"\nsubtitle: \"$BOOK_SUBTITLE\"\npublisher: \"Khaos Studios\"\ncreator: \"Open Source Community\"\nlanguage: \"$LANGUAGE\"\n---") 2>&1 | tee "$LOG_FILE"

# Check if EPUB was generated successfully
if [ -s "$OUTPUT_FILE" ]; then
  FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
  echo "📊 EPUB file size: ${FILE_SIZE}KB"
  
  if [ "$FILE_SIZE" -lt 3000 ]; then
    echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
    echo "Trying with self-contained flag..."
    
    pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
      $COVER_OPTION \
      --toc \
      --toc-depth=2 \
      --resource-path="$RESOURCE_PATHS" \
      --metadata title="$BOOK_TITLE" \
      --metadata subtitle="$BOOK_SUBTITLE" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --metadata lang="$LANGUAGE" \
      --self-contained 2>&1 | tee -a "$LOG_FILE"
      
    FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
    echo "📊 EPUB file size after second attempt: ${FILE_SIZE}KB"
  fi
  
  echo "✅ EPUB created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create EPUB. See log at $LOG_FILE"
  exit 1
fi