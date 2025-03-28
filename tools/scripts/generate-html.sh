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
OUTPUT_DIR="$(dirname "$OUTPUT_FILE")"
mkdir -p "$OUTPUT_DIR"

# Copy CSS and JavaScript files to the output directory
if [ -f "templates/book.css" ]; then
  cp "templates/book.css" "$OUTPUT_DIR/"
  echo "✅ Copied main CSS file to output directory"
fi

if [ -f "templates/images.css" ]; then
  cp "templates/images.css" "$OUTPUT_DIR/"
  echo "✅ Copied images CSS file to output directory"
fi

if [ -f "templates/book.js" ]; then
  cp "templates/book.js" "$OUTPUT_DIR/"
  echo "✅ Copied JavaScript file to output directory"
fi

# Path to the HTML template
TEMPLATE_PATH="templates/template.html"
if [ ! -f "$TEMPLATE_PATH" ]; then
  echo "⚠️ WARNING: Custom HTML template not found, using pandoc default"
  TEMPLATE_OPTION=""
else
  TEMPLATE_OPTION="--template=$TEMPLATE_PATH"
fi

# First attempt: Generate HTML with all features
pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
  --standalone \
  --toc \
  --toc-depth=2 \
  $TEMPLATE_OPTION \
  --css="book.css" \
  --css="images.css" \
  --metadata title="$BOOK_TITLE" \
  --metadata=lang:"$LANGUAGE" \
  --resource-path="$RESOURCE_PATHS" || true

# If HTML generation failed, try without custom template
if [ ! -s "$OUTPUT_FILE" ]; then
  echo "⚠️ WARNING: HTML file generation failed with template, trying without..."
  
  pandoc "$INPUT_FILE" -o "$OUTPUT_FILE" \
    --standalone \
    --toc \
    --toc-depth=2 \
    --css="book.css" \
    --css="images.css" \
    --metadata title="$BOOK_TITLE" \
    --metadata=lang:"$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" || true
fi

# If still fails, try without images
if [ ! -s "$OUTPUT_FILE" ]; then
  echo "⚠️ WARNING: HTML file generation failed, trying with safe MD..."
  
  pandoc "$SAFE_INPUT_FILE" -o "$OUTPUT_FILE" \
    --standalone \
    --toc \
    --toc-depth=2 \
    --css="book.css" \
    --css="images.css" \
    --metadata title="$BOOK_TITLE" \
    --metadata=lang:"$LANGUAGE" \
    --resource-path="$RESOURCE_PATHS" || true
    
  # If still fails, create minimal HTML
  if [ ! -s "$OUTPUT_FILE" ]; then
    echo "⚠️ ERROR: All HTML generation attempts failed, creating minimal HTML..."
    cat > "$OUTPUT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
  <title>$BOOK_TITLE</title>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <link rel="stylesheet" href="book.css">
  <link rel="stylesheet" href="images.css">
</head>
<body>
  <h1>$BOOK_TITLE</h1>
  <p>HTML generation encountered issues. Please see PDF or EPUB versions.</p>
  <script src="book.js"></script>
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

# Add JavaScript if not included in the template
if ! grep -q "<script src=\"book.js\"></script>" "$OUTPUT_FILE"; then
  echo "Adding JavaScript reference to HTML file..."
  sed -i.bak 's|</body>|<script src="book.js"></script>\n</body>|' "$OUTPUT_FILE"
  rm -f "${OUTPUT_FILE}.bak"
fi

# Add CSS link for images if not included
if ! grep -q "<link rel=\"stylesheet\" href=\"images.css\"" "$OUTPUT_FILE"; then
  echo "Adding images CSS reference to HTML file..."
  sed -i.bak 's|<link rel="stylesheet" href="book.css"|<link rel="stylesheet" href="book.css">\n  <link rel="stylesheet" href="images.css"|' "$OUTPUT_FILE"
  rm -f "${OUTPUT_FILE}.bak"
fi
