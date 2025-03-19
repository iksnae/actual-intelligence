#!/bin/bash

# generate-epub.sh - Generates EPUB version of the book
# Usage: generate-epub.sh [language] [input_file] [output_file] [book_title] [book_subtitle] [resource_paths]

# Get arguments
LANGUAGE=${1:-en}
INPUT_FILE=${2:-build/actual-intelligence.md}
OUTPUT_FILE=${3:-build/actual-intelligence.epub}
BOOK_TITLE=${4:-"Actual Intelligence"}
BOOK_SUBTITLE=${5:-"A Practical Guide to Using AI in Everyday Life"}
RESOURCE_PATHS=${6:-".:book:book/$LANGUAGE:build:book/$LANGUAGE/images:book/images:build/images:build/$LANGUAGE/images"}

echo "📱 Generating EPUB for $LANGUAGE..."
echo "  - Input File: $INPUT_FILE"
echo "  - Output File: $OUTPUT_FILE" 
echo "  - Resource Paths: $RESOURCE_PATHS"

# Determine cover image path based on language
if [ -n "$COVER_IMAGE" ]; then
  echo "  - Using defined cover image: $COVER_IMAGE"
elif [ -f "book/$LANGUAGE/images/cover.png" ]; then
  COVER_IMAGE="book/$LANGUAGE/images/cover.png"
  echo "  - Using language-specific cover: $COVER_IMAGE"
elif [ -f "art/cover.png" ]; then
  COVER_IMAGE="art/cover.png"
  echo "  - Using art/cover.png"
elif [ -f "book/images/cover.png" ]; then
  COVER_IMAGE="book/images/cover.png"
  echo "  - Using book/images/cover.png"
else
  COVER_IMAGE=""
  echo "  - No cover image found"
fi

# Create output directory if it doesn't exist
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Use the container's generate-epub utility if available
if command -v generate-epub &> /dev/null; then
  echo "Using container's dedicated generate-epub utility..."
  
  # Use the container's utility with appropriate options
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
  else
    generate-epub \
      --title "$BOOK_TITLE" \
      --author "Open Source Community" \
      --publisher "Khaos Studios" \
      --language "$LANGUAGE" \
      --resource-path "$RESOURCE_PATHS" \
      --verbose \
      "$INPUT_FILE" "$OUTPUT_FILE"
  fi
  
  # Check file size
  if [ -s "$OUTPUT_FILE" ]; then
    FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
    echo "📊 EPUB file size: ${FILE_SIZE}KB"
    
    if [ "$FILE_SIZE" -lt 30 ]; then
      echo "⚠️ WARNING: EPUB file size is extremely small (${FILE_SIZE}KB). File may be empty or corrupt."
    elif [ "$FILE_SIZE" -lt 300 ]; then
      echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
    else
      echo "✅ EPUB file size looks good (${FILE_SIZE}KB). Images likely included."
    fi
  else
    echo "⚠️ WARNING: Output file is empty or doesn't exist"
  fi
  
  # Additional debugging for failures
  if [ ! -s "$OUTPUT_FILE" ]; then
    echo "DEBUGGING: Attempting to identify the issue..."
    echo "  - Input file exists: $(test -f "$INPUT_FILE" && echo "Yes" || echo "No")"
    echo "  - Input file size: $(test -f "$INPUT_FILE" && du -h "$INPUT_FILE" || echo "N/A")"
    echo "  - Output directory writable: $(test -w "$(dirname "$OUTPUT_FILE")" && echo "Yes" || echo "No")"
    
    # Try fallback method
    echo "Trying direct pandoc fallback method..."
    pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
      --toc \
      --toc-depth=2 \
      --metadata title="$BOOK_TITLE" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --metadata language="$LANGUAGE" \
      --resource-path="$RESOURCE_PATHS" \
      --extract-media="build/$LANGUAGE/epub-media"
  fi
  
  exit $?
fi

# Fall back to direct pandoc command if utility not available
echo "Container utility not found, using direct pandoc command..."

# Safety check to ensure input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Error: Input file $INPUT_FILE does not exist"
  exit 1
fi

# Try the pandoc approach with cover image if available
if [ -n "$COVER_IMAGE" ]; then
  echo "Including cover image in EPUB: $COVER_IMAGE"
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --epub-cover-image="$COVER_IMAGE" \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --metadata language="$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media="build/$LANGUAGE/epub-media"
else
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --metadata language="$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media="build/$LANGUAGE/epub-media"
fi

# Check if EPUB was generated successfully
if [ -s "$OUTPUT_FILE" ]; then
  FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
  echo "📊 EPUB file size: ${FILE_SIZE}KB"
  
  if [ "$FILE_SIZE" -lt 30 ]; then
    echo "⚠️ WARNING: EPUB file size is extremely small (${FILE_SIZE}KB). File may be empty or corrupt."
  elif [ "$FILE_SIZE" -lt 300 ]; then
    echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
  else
    echo "✅ EPUB file size looks good (${FILE_SIZE}KB). Images likely included."
  fi
  
  echo "✅ EPUB created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create EPUB. Trying alternative approach..."
  
  # Try alternative approach with explicit image path
  if [ -n "$COVER_IMAGE" ]; then
    echo "Trying alternative approach with explicit image path..."
    pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
      --epub-cover-image="$COVER_IMAGE" \
      --toc \
      --toc-depth=2 \
      --metadata title="$BOOK_TITLE" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --resource-path="$RESOURCE_PATHS" \
      --extract-media="build/$LANGUAGE/epub-media"
  fi
  
  if [ -s "$OUTPUT_FILE" ]; then
    echo "✅ Alternative approach succeeded!"
  else
    echo "❌ All attempts to create EPUB failed."
    exit 1
  fi
fi
