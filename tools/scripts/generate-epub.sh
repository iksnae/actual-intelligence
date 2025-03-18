#!/bin/bash

# generate-epub.sh - Generates EPUB version of the book
# Usage: generate-epub.sh [language] [input_file] [output_file] [book_title] [book_subtitle] [resource_paths]

# Don't exit on error - we'll handle errors manually
set +e

# Get arguments
LANGUAGE=${1:-en}
INPUT_FILE=${2:-build/actual-intelligence.md}
OUTPUT_FILE=${3:-build/actual-intelligence.epub}
BOOK_TITLE=${4:-"Actual Intelligence"}
BOOK_SUBTITLE=${5:-"A Practical Guide to Using AI in Everyday Life"}

# Set up resource paths based on language
if [ "$LANGUAGE" = "en" ]; then
  RESOURCE_PATHS=${6:-".:book:book/en:build:book/en/images:book/images:build/images"}
else
  RESOURCE_PATHS=${6:-".:book:book/$LANGUAGE:build:book/$LANGUAGE/images:book/images:build/$LANGUAGE/images:build/images"}
fi

echo "📱 Generating EPUB for $LANGUAGE..."

# Safety check to ensure input file exists
if [ ! -f "$INPUT_FILE" ]; then
  echo "❌ Error: Input file $INPUT_FILE does not exist"
  exit 1
fi

# Create a safety copy for fallbacks
SAFE_INPUT_FILE="${INPUT_FILE%.*}-safe.md"
cp "$INPUT_FILE" "$SAFE_INPUT_FILE"

# Make sure the output directory exists
mkdir -p "$(dirname "$OUTPUT_FILE")"

# Set up extract media directory
EXTRACT_DIR="build/epub-media"
if [ "$LANGUAGE" != "en" ]; then
  EXTRACT_DIR="build/epub-media/$LANGUAGE"
fi
mkdir -p "$EXTRACT_DIR"

# Print debug info
echo "📋 EPUB Generation Details:"
echo "   - Input file: $INPUT_FILE"
echo "   - Output file: $OUTPUT_FILE"
echo "   - Language: $LANGUAGE"
echo "   - Resource paths: $RESOURCE_PATHS"
echo "   - Extract media directory: $EXTRACT_DIR"
if [ -n "$COVER_IMAGE" ]; then
  echo "   - Cover image: $COVER_IMAGE"
else
  echo "   - Cover image: None detected"
fi

# Generate EPUB with cover image if available
echo "🔄 Generating EPUB..."
if [ -n "$COVER_IMAGE" ]; then
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --epub-cover-image="$COVER_IMAGE" \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata subtitle="$BOOK_SUBTITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --metadata lang="$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media="$EXTRACT_DIR"
else
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata subtitle="$BOOK_SUBTITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --metadata lang="$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media="$EXTRACT_DIR"
fi

# Check if EPUB was generated successfully
if [ ! -s "$OUTPUT_FILE" ]; then
  echo "⚠️ First EPUB generation attempt failed, trying with adjusted image paths..."
  
  # Make image references more resilient by prepending "images/"
  sed -i 's/!\[\([^]]*\)\](\([^)]*\))/![\1](images\/\2)/g' "$SAFE_INPUT_FILE"
  
  # Try with modified image paths
  pandoc "$SAFE_INPUT_FILE" -o "$OUTPUT_FILE" \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata subtitle="$BOOK_SUBTITLE" \
    --metadata publisher="Khaos Studios" \
    --metadata creator="Open Source Community" \
    --metadata lang="$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media="$EXTRACT_DIR"
  
  # Final fallback: try without images if still not successful
  if [ ! -s "$OUTPUT_FILE" ]; then
    echo "⚠️ WARNING: EPUB generation with images failed, creating minimal EPUB without images..."
    sed -i 's/!\[\([^]]*\)\](\([^)]*\))//g' "$SAFE_INPUT_FILE"
    
    pandoc "$SAFE_INPUT_FILE" -o "$OUTPUT_FILE" \
      --toc \
      --toc-depth=2 \
      --metadata title="$BOOK_TITLE" \
      --metadata subtitle="$BOOK_SUBTITLE" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --metadata lang="$LANGUAGE" \
      --resource-path="$RESOURCE_PATHS"
  fi
fi

# Another key difference - run a file size check to verify images were included
if [ -s "$OUTPUT_FILE" ]; then
  FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
  echo "📊 EPUB file size: ${FILE_SIZE}KB"
  
  # Warn if file seems too small (likely missing images)
  if [ "$FILE_SIZE" -lt 3000 ]; then
    echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
  else
    echo "✅ EPUB file size looks good (${FILE_SIZE}KB). Images likely included."
  fi
  
  echo "✅ EPUB created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create EPUB at $OUTPUT_FILE"
  exit 1
fi