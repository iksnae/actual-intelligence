#!/bin/bash

# Verify if images are properly embedded in PDF
# Usage: ./verify-embedded-images.sh path/to/pdf

if [ $# -eq 0 ]; then
  echo "Error: No PDF file specified"
  echo "Usage: ./verify-embedded-images.sh path/to/pdf"
  exit 1
fi

PDF_FILE="$1"

if [ ! -f "$PDF_FILE" ]; then
  echo "Error: File not found: $PDF_FILE"
  exit 1
fi

echo "Analyzing PDF file: $PDF_FILE"

# Check if we have the necessary tools
if ! command -v pdfinfo &> /dev/null; then
  echo "pdfinfo not found. Installing poppler-utils..."
  if [ -n "$CI" ]; then
    # We're in CI, use apt-get
    apt-get update && apt-get install -y poppler-utils
  elif command -v brew &> /dev/null; then
    # We're on macOS with Homebrew
    brew install poppler
  else
    echo "Please install poppler-utils manually:"
    echo "  Ubuntu/Debian: sudo apt-get install poppler-utils"
    echo "  macOS: brew install poppler"
    exit 1
  fi
fi

# Get PDF metadata
echo -e "\nPDF Metadata:"
pdfinfo "$PDF_FILE"

# List embedded images if possible
if command -v pdfimages &> /dev/null; then
  echo -e "\nEmbedded Images:"
  pdfimages -list "$PDF_FILE"
  
  # Count the number of images
  IMAGE_COUNT=$(pdfimages -list "$PDF_FILE" | tail -n +2 | wc -l)
  echo -e "\nTotal embedded images found: $IMAGE_COUNT"
  
  if [ "$IMAGE_COUNT" -eq 0 ]; then
    echo -e "\n⚠️ Warning: No embedded images found in the PDF."
  else
    echo -e "\n✅ PDF contains embedded images."
  fi
else
  echo -e "\npdfimages not available. Cannot check embedded images."
fi

# Try to get embedded file information using pdftk if available
if command -v pdftk &> /dev/null; then
  echo -e "\nEmbedded Files (using pdftk):"
  pdftk "$PDF_FILE" dump_data | grep -i attach
  if [ $? -ne 0 ]; then
    echo "No embedded files found with pdftk."
  fi
fi

echo -e "\nPDF Validation Complete" 