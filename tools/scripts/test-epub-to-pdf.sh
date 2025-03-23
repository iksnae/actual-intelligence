#!/bin/bash

# Test script for EPUB to PDF conversion
# This script helps test the EPUB-to-PDF conversion without running the full build

echo "Testing EPUB to PDF conversion..."

# Check if an EPUB file is provided
if [ -z "$1" ]; then
  echo "Usage: $0 <epub-file>"
  echo "Example: $0 build/actual-intelligence.epub"
  exit 1
fi

EPUB_FILE="$1"
PDF_OUTPUT="${EPUB_FILE%.epub}.from-epub.pdf"

# Create a custom CSS file for better PDF styling
CSS_FILE=$(mktemp --suffix=.css)
cat > "$CSS_FILE" << 'EOF'
pre, code {
  white-space: pre-wrap;
  word-wrap: break-word;
  background-color: #f5f5f5;
  border: 1px solid #ddd;
  border-radius: 3px;
  padding: 0.5em;
  font-family: monospace;
}
body {
  font-family: 'Helvetica', sans-serif;
  line-height: 1.5;
}
h1, h2, h3, h4, h5, h6 {
  color: #2c3e50;
}
EOF

echo "Converting $EPUB_FILE to $PDF_OUTPUT..."

# Use ebook-convert from Calibre to convert EPUB to PDF with embedded images
ebook-convert "$EPUB_FILE" "$PDF_OUTPUT" \
  --pdf-page-numbers \
  --pdf-page-margin-bottom=36 \
  --pdf-page-margin-top=36 \
  --pdf-page-margin-left=36 \
  --pdf-page-margin-right=36 \
  --extra-css="$CSS_FILE" \
  --pdf-default-font-size=11 \
  --pdf-mono-font-size=10 \
  --embed-all-fonts \
  --pdf-add-toc

# Check if conversion was successful
if [ $? -eq 0 ]; then
  echo "✅ Conversion successful! PDF created at: $PDF_OUTPUT"
  echo "File size: $(du -h "$PDF_OUTPUT" | cut -f1)"
else
  echo "❌ Conversion failed!"
  exit 1
fi

# Clean up
rm "$CSS_FILE"

echo "Test completed." 