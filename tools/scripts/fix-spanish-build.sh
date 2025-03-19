#!/bin/bash
# fix-spanish-build.sh - Explicit script to ensure Spanish build completes successfully
# Usage: ./tools/scripts/fix-spanish-build.sh

set -e  # Exit on error

echo "🔧 Running Spanish build fix script..."

# 1. Make sure the Spanish output directory exists
mkdir -p build/es
mkdir -p build/es/images

# 2. Copy Spanish cover image if needed
if [ -f "book/es/images/cover.png" ]; then
  cp book/es/images/cover.png build/es/images/
  echo "✅ Copied Spanish cover image to build/es/images/"
else
  # Fallback to English cover
  cp book/en/images/cover.png build/es/images/
  echo "⚠️ Using English cover image for Spanish build"
fi

# 3. Explicitly build the Spanish version
echo "🔄 Explicitly building Spanish version..."
LANG="es"
BOOK_TITLE="Inteligencia Real"
BOOK_SUBTITLE="Una Guía Práctica para Usar la IA en la Vida Cotidiana"
OUTPUT_NAME="inteligencia-real"

# Define resource paths for pandoc
RESOURCE_PATHS=".:book:book/$LANG:build:book/$LANG/images:book/images:build/images:build/$LANG/images"

# 3.1 Combine markdown files
echo "📝 Combining markdown files for Spanish..."
source tools/scripts/combine-markdown.sh "$LANG" "build/$OUTPUT_NAME.md" "$BOOK_TITLE" "$BOOK_SUBTITLE"

# Create a safety copy for fallbacks
cp "build/$OUTPUT_NAME.md" "build/$OUTPUT_NAME-safe.md"

# 3.2 Generate PDF
echo "📄 Generating Spanish PDF..."
source tools/scripts/generate-pdf.sh "$LANG" "build/$OUTPUT_NAME.md" "build/$OUTPUT_NAME.pdf" "$BOOK_TITLE" "$RESOURCE_PATHS"

# 3.3 Generate EPUB
echo "📱 Generating Spanish EPUB..."
source tools/scripts/generate-epub.sh "$LANG" "build/$OUTPUT_NAME.md" "build/$OUTPUT_NAME.epub" "$BOOK_TITLE" "$BOOK_SUBTITLE" "$RESOURCE_PATHS"

# 4. Verify the output
echo "🔍 Verifying Spanish build outputs..."
if [ -f "build/$OUTPUT_NAME.pdf" ]; then
  echo "✅ Spanish PDF exists: build/$OUTPUT_NAME.pdf"
  du -h "build/$OUTPUT_NAME.pdf"
else
  echo "❌ Spanish PDF is missing"
fi

if [ -f "build/$OUTPUT_NAME.epub" ]; then
  echo "✅ Spanish EPUB exists: build/$OUTPUT_NAME.epub"
  du -h "build/$OUTPUT_NAME.epub"
else
  echo "❌ Spanish EPUB is missing"
fi

echo "✅ Spanish build fix completed"
