#!/bin/bash

# generate-pdf.sh - Generates PDF version of the book
# Usage: generate-pdf.sh [language] [input_file] [output_file] [book_title] [resource_paths]

set -e  # Exit on error

# Get arguments
LANGUAGE=${1:-en}
INPUT_FILE=${2:-build/actual-intelligence.md}
OUTPUT_FILE=${3:-build/actual-intelligence.pdf}
BOOK_TITLE=${4:-"Actual Intelligence"}
RESOURCE_PATHS=${5:-".:book:book/en:build:book/en/images:book/images:build/images"}

echo "📄 Generating PDF for $LANGUAGE..."

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

# First attempt: Use LaTeX template if available
if [ -n "$TEMP_TEMPLATE" ]; then
  echo "Using LaTeX template: $TEMP_TEMPLATE"
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --template="$TEMP_TEMPLATE" \
    --metadata title="$BOOK_TITLE" \
    --metadata=lang:"$LANGUAGE" \
    --pdf-engine=xelatex \
    --toc \
    --resource-path="$RESOURCE_PATHS"
else
  # First attempt: Fallback to default pandoc styling
  echo "Using default PDF styling"
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --metadata title="$BOOK_TITLE" \
    --metadata=lang:"$LANGUAGE" \
    --pdf-engine=xelatex \
    --toc \
    --resource-path="$RESOURCE_PATHS"
fi

# Check if PDF file was created successfully
if [ $? -ne 0 ] || [ ! -s "$OUTPUT_FILE" ]; then
  echo "⚠️ First PDF generation attempt failed, trying with more resilient settings..."
  
  # Create a version of the markdown with image references made more resilient
  sed -i 's/!\[\([^]]*\)\](\([^)]*\))/!\[\1\](images\/\2)/g' "$SAFE_INPUT_FILE"
  
  # Second attempt: Try with modified settings and more lenient image paths
  pandoc "$SAFE_INPUT_FILE" -o "$OUTPUT_FILE" \
    --metadata title="$BOOK_TITLE" \
    --metadata=lang:"$LANGUAGE" \
    --pdf-engine=xelatex \
    --toc \
    --variable=graphics=true \
    --variable=documentclass=book \
    --resource-path="$RESOURCE_PATHS" || true
  
  # If still not successful, create a minimal PDF
  if [ ! -s "$OUTPUT_FILE" ]; then
    echo "⚠️ WARNING: PDF generation with images failed, creating a minimal PDF without images..."
    # Create a version with image references removed
    sed -i 's/!\[\([^]]*\)\](\([^)]*\))//g' "$SAFE_INPUT_FILE"
    
    # Final attempt: minimal PDF with no images
    pandoc "$SAFE_INPUT_FILE" -o "$OUTPUT_FILE" \
      --metadata title="$BOOK_TITLE" \
      --metadata=lang:"$LANGUAGE" \
      --pdf-engine=xelatex \
      --toc \
      --resource-path="$RESOURCE_PATHS" || true
      
    # If all else fails, create a placeholder PDF
    if [ ! -s "$OUTPUT_FILE" ]; then
      echo "⚠️ WARNING: All PDF generation attempts failed, creating placeholder PDF..."
      PLACEHOLDER_FILE="$(dirname "$INPUT_FILE")/placeholder.md"
      echo "# $BOOK_TITLE - Placeholder PDF" > "$PLACEHOLDER_FILE"
      echo "PDF generation encountered issues with images. Please see HTML or EPUB versions." >> "$PLACEHOLDER_FILE"
      pandoc "$PLACEHOLDER_FILE" -o "$OUTPUT_FILE" --pdf-engine=xelatex
    fi
  fi
fi

# Check final result
if [ -s "$OUTPUT_FILE" ]; then
  echo "✅ PDF created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create PDF at $OUTPUT_FILE"
  exit 1
fi
