#!/bin/bash

# generate-mobi.sh - Generates MOBI (Kindle) version of the book from EPUB
# Usage: generate-mobi.sh [language] [input_epub] [output_mobi] [book_title]

set -e  # Exit on error

# Get arguments
LANGUAGE=${1:-en}
INPUT_EPUB=${2:-build/actual-intelligence.epub}
OUTPUT_MOBI=${3:-build/actual-intelligence.mobi}
BOOK_TITLE=${4:-"Actual Intelligence"}

echo "📚 Generating MOBI for $LANGUAGE..."

# Safety check to ensure input EPUB exists
if [ ! -f "$INPUT_EPUB" ]; then
  echo "❌ Error: Input EPUB file $INPUT_EPUB does not exist"
  exit 1
fi

# Make sure the output directory exists
mkdir -p "$(dirname "$OUTPUT_MOBI")"

# Use Calibre's ebook-convert to convert EPUB to MOBI
ebook-convert "$INPUT_EPUB" "$OUTPUT_MOBI" \
  --title="$BOOK_TITLE" \
  --authors="Open Source Community" \
  --publisher="Khaos Studios" \
  --language="$LANGUAGE" || true

# Check if MOBI file was created successfully
if [ -s "$OUTPUT_MOBI" ]; then
  echo "✅ MOBI created successfully at $OUTPUT_MOBI"
else
  echo "❌ Failed to create MOBI at $OUTPUT_MOBI"
  exit 1
fi
