#!/bin/bash

# build-spanish.sh - Dedicated script for building only the Spanish version of the book
# Created to directly test Spanish book generation and troubleshoot multilingual issues

set -e  # Exit on error

echo "📚 Dedicated Spanish Build Script"
echo "=================================="

# Create necessary directories
mkdir -p build
mkdir -p build/es
mkdir -p build/es/images
mkdir -p build/images

# Copy Spanish chapter images to build directory
if [ -d "book/es/chapter-01/images" ]; then
  echo "🖼️  Copying Spanish chapter images to build directory..."
  cp -r book/es/chapter-01/images/* build/es/images/ || true
  # Also copy to the main images directory for EPUB inclusion
  cp -r book/es/chapter-01/images/* build/images/ || true
else
  echo "⚠️  No Spanish chapter images found in book/es/chapter-01/images"
fi

# Set Spanish cover image
COVER_IMAGE=""
if [ -f "book/es/images/cover.png" ]; then
  COVER_IMAGE="book/es/images/cover.png"
  echo "🖼️  Using Spanish cover image: $COVER_IMAGE"
  cp "$COVER_IMAGE" build/images/cover.png
elif [ -f "art/cover.png" ]; then
  COVER_IMAGE="art/cover.png"
  echo "🖼️  Using default cover image: $COVER_IMAGE"
  cp "$COVER_IMAGE" build/images/cover.png
else
  echo "⚠️  WARNING: No cover image found!"
fi

# Export cover image for other scripts to use
export COVER_IMAGE

# Fix permissions on script files
chmod +x tools/scripts/*.sh

# Define outputs for Spanish book
BOOK_TITLE="Inteligencia Real"
BOOK_SUBTITLE="Una Guía Práctica para Usar la IA en la Vida Cotidiana"
LANGUAGE="es"
MARKDOWN_PATH="build/$LANGUAGE/inteligencia-real.md"
PDF_PATH="build/$LANGUAGE/inteligencia-real.pdf"
EPUB_PATH="build/$LANGUAGE/inteligencia-real.epub"
MOBI_PATH="build/$LANGUAGE/inteligencia-real.mobi"
HTML_PATH="build/$LANGUAGE/inteligencia-real.html"

# Set up resource paths for pandoc (with detailed resource paths)
RESOURCE_PATHS=".:book:book/$LANGUAGE:build:book/$LANGUAGE/images:book/images:build/images:build/$LANGUAGE/images:book/$LANGUAGE/chapter-01/images"

echo "📋 Build configuration:"
echo "  - Language: $LANGUAGE"
echo "  - Title: $BOOK_TITLE"
echo "  - Subtitle: $BOOK_SUBTITLE"
echo "  - Resource paths: $RESOURCE_PATHS"
echo "  - Output paths:"
echo "    - Markdown: $MARKDOWN_PATH"
echo "    - PDF: $PDF_PATH"
echo "    - EPUB: $EPUB_PATH"
echo "    - MOBI: $MOBI_PATH"
echo "    - HTML: $HTML_PATH"
echo ""

# Step 1: Combine markdown files
echo "📝 Combining markdown files for Spanish..."
source tools/scripts/combine-markdown.sh "$LANGUAGE" "$MARKDOWN_PATH" "$BOOK_TITLE" "$BOOK_SUBTITLE"

# Create a safety copy
cp "$MARKDOWN_PATH" "${MARKDOWN_PATH%.*}-safe.md"

# Step 2: Generate PDF
echo "📄 Generating Spanish PDF..."
source tools/scripts/generate-pdf.sh "$LANGUAGE" "$MARKDOWN_PATH" "$PDF_PATH" "$BOOK_TITLE" "$RESOURCE_PATHS"

# Step 3: Generate EPUB
echo "📱 Generating Spanish EPUB..."
source tools/scripts/generate-epub.sh "$LANGUAGE" "$MARKDOWN_PATH" "$EPUB_PATH" "$BOOK_TITLE" "$BOOK_SUBTITLE" "$RESOURCE_PATHS"

# Step 4: Generate MOBI
echo "📚 Generating Spanish MOBI..."
source tools/scripts/generate-mobi.sh "$LANGUAGE" "$EPUB_PATH" "$MOBI_PATH" "$BOOK_TITLE"

# Step 5: Generate HTML
echo "🌐 Generating Spanish HTML..."
source tools/scripts/generate-html.sh "$LANGUAGE" "$MARKDOWN_PATH" "$HTML_PATH" "$BOOK_TITLE" "$RESOURCE_PATHS"

# Copy outputs to root build directory
echo "📋 Copying Spanish files to root build directory..."
cp "$PDF_PATH" "build/inteligencia-real.pdf"
cp "$EPUB_PATH" "build/inteligencia-real.epub"
cp "$MOBI_PATH" "build/inteligencia-real.mobi"
cp "$HTML_PATH" "build/inteligencia-real.html"

# Verify outputs
echo "✅ Verifying outputs..."
echo "Files in build directory:"
ls -la build/
echo ""
echo "Files in build/es directory:"
ls -la build/es/
echo ""
echo "File sizes:"
du -h build/inteligencia-real.*

echo "✅ Spanish build completed!"
