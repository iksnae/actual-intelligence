#!/bin/bash

# generate-epub.sh - Generates EPUB version of the book
# Usage: generate-epub.sh [language] [input_file] [output_file] [book_title] [book_subtitle] [resource_paths]

set -e  # Exit on error

# Get arguments
LANGUAGE=${1:-en}
INPUT_FILE=${2:-build/actual-intelligence.md}
OUTPUT_FILE=${3:-build/actual-intelligence.epub}
BOOK_TITLE=${4:-"Actual Intelligence"}
BOOK_SUBTITLE=${5:-"A Practical Guide to Using AI in Everyday Life"}
RESOURCE_PATHS=${6:-".:book:book/en:build:book/en/images:book/images:build/images"}

echo "📱 Generating EPUB for $LANGUAGE..."

# Safety check to ensure input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Error: Input file $INPUT_FILE does not exist"
  exit 1
fi

# Safety copy for fallbacks
SAFE_INPUT_FILE="${INPUT_FILE%.*}-safe.md"
if [ ! -f "$SAFE_INPUT_FILE" ]; then
  cp "$INPUT_FILE" "$SAFE_INPUT_FILE"
fi

# Make sure the output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Figure out the cover image option
COVER_OPTION=""
if [ -n "$COVER_IMAGE" ]; then
  echo "Including cover image in EPUB: $COVER_IMAGE"
  COVER_OPTION="--epub-cover-image=\"$COVER_IMAGE\""
fi

# First attempt: Generate EPUB with all features
EXTRACT_DIR="build/epub-media/$LANGUAGE"
mkdir -p "$EXTRACT_DIR"

eval pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
  $COVER_OPTION \
  --toc \
  --toc-depth=2 \
  --metadata title="$BOOK_TITLE" \
  --metadata subtitle="$BOOK_SUBTITLE" \
  --metadata publisher="Khaos Studios" \
  --metadata creator="Open Source Community" \
  --metadata lang="$LANGUAGE" \
  --resource-path="$RESOURCE_PATHS" \
  --extract-media="$EXTRACT_DIR" || true

# If EPUB generation failed, try without images
if [ ! -s "$OUTPUT_FILE" ]; then
  echo "⚠️ WARNING: EPUB generation failed, creating minimal EPUB without images..."
  # Create a version with image references removed
  sed -i 's/!\[\([^]]*\)\](\([^)]*\))//g' "$SAFE_INPUT_FILE"
  
  pandoc "$SAFE_INPUT_FILE" -o "$OUTPUT_FILE" \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata subtitle="$BOOK_SUBTITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --metadata lang="$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" || true
fi

# Check final result
if [ -s "$OUTPUT_FILE" ]; then
  echo "✅ EPUB created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create EPUB at $OUTPUT_FILE"
  exit 1
fi
