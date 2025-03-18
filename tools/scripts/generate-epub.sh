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

# Use the container's generate-epub utility if available
if command -v generate-epub &> /dev/null; then
  echo "Using container's dedicated generate-epub utility..."
  
  # Use the container's utility with appropriate options
  generate-epub \
    --title "$BOOK_TITLE" \
    --author "Open Source Community" \
    --publisher "Khaos Studios" \
    --language "$LANGUAGE" \
    --resource-path "$RESOURCE_PATHS" \
    --verbose \
    "$INPUT_FILE" "$OUTPUT_FILE"
    
  # Check if cover image exists and add it
  if [ -n "$COVER_IMAGE" ]; then
    generate-epub \
      --title "$BOOK_TITLE" \
      --author "Open Source Community" \
      --publisher "Khaos Studios" \
      --language "$LANGUAGE" \
      --cover "$COVER_IMAGE" \
      --resource-path "$RESOURCE_PATHS" \
      --verbose \
      "$INPUT_FILE" "$OUTPUT_FILE"
  fi
  
  # Check file size
  if [ -s "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
    echo "📊 EPUB file size: ${FILE_SIZE}KB"
    
    if [ "$FILE_SIZE" -lt 3000 ]; then
      echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
    else
      echo "✅ EPUB file size looks good (${FILE_SIZE}KB). Images included."
    fi
  fi
  
  exit 0
fi

# Fall back to direct pandoc command if utility not available
echo "Container utility not found, using direct pandoc command..."

# Safety check to ensure input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Error: Input file $INPUT_FILE does not exist"
  exit 1
fi

# Make sure the output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Try the approach that worked in commit f5b41647482d6446ca40a9db9d7c71bb423c2b02
if [ -n "$COVER_IMAGE" ]; then
  echo "Including cover image in EPUB: $COVER_IMAGE"
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --epub-cover-image="$COVER_IMAGE" \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media=build/epub-media
else
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media=build/epub-media
fi

# Check if EPUB was generated successfully
if [ -s "$OUTPUT_FILE" ]; then
  FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
  echo "📊 EPUB file size: ${FILE_SIZE}KB"
  
  if [ "$FILE_SIZE" -lt 3000 ]; then
    echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
  else
    echo "✅ EPUB file size looks good (${FILE_SIZE}KB). Images included."
  fi
  
  echo "✅ EPUB created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create EPUB."
  exit 1
fi