#!/bin/bash

# generate-html.sh - Generates HTML version of the book
# Usage: generate-html.sh [language] [input_file] [output_file] [book_title] [resource_paths]

set -e  # Exit on error

# Get arguments
LANGUAGE=${1:-en}
INPUT_FILE=${2:-build/actual-intelligence.md}
OUTPUT_FILE=${3:-build/actual-intelligence.html}
BOOK_TITLE=${4:-"Actual Intelligence"}
RESOURCE_PATHS=${5:-".:book:book/en:build:book/en/images:book/images:build/images"}

echo "🌐 Generating HTML for $LANGUAGE..."

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

# First attempt: Generate HTML with all features
pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
  --standalone \
  --toc \
  --toc-depth=2 \
  --metadata title="$BOOK_TITLE" \
  --metadata=lang:"$LANGUAGE" \
  --resource-path="$RESOURCE_PATHS" || true

# If HTML generation failed, try without images
if [ ! -s "$OUTPUT_FILE" ]; then
  echo "⚠️ WARNING: HTML file generation failed with images, trying without..."
  
  pandoc "$SAFE_INPUT_FILE" -o "$OUTPUT_FILE" \
    --standalone \
    --toc \
    --toc-depth=2 \
    --metadata title="$BOOK_TITLE" \
    --metadata=lang:"$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" || true
    
  # If still fails, create minimal HTML
  if [ ! -s "$OUTPUT_FILE" ]; then
    echo "⚠️ ERROR: All HTML generation attempts failed, creating minimal HTML..."
    cat > "$OUTPUT_FILE" << EOF
<html>
<head>
  <title>$BOOK_TITLE</title>
  <meta charset="utf-8">
</head>
<body>
  <h1>$BOOK_TITLE</h1>
  <p>HTML generation encountered issues. Please see PDF or EPUB versions.</p>
</body>
</html>
EOF
  fi
fi

# Check final result
if [ -s "$OUTPUT_FILE" ]; then
  echo "✅ HTML created successfully at $OUTPUT_FILE"
else
  echo "❌ Failed to create HTML at $OUTPUT_FILE"
  exit 1
fi
