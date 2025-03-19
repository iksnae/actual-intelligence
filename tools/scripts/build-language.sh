#!/bin/bash

# build-language.sh - Builds a specific language version of the book
# Usage: build-language.sh [language] [--skip-pdf] [--skip-epub] [--skip-mobi] [--skip-html]

set -e  # Exit on error

# Get the language from the first argument
LANGUAGE=${1:-en}

# Define skip flags with defaults
SKIP_PDF=false
SKIP_EPUB=false
SKIP_MOBI=false
SKIP_HTML=false

# Process additional arguments
shift
while [[ $# -gt 0 ]]; do
  case "$1" in
    --skip-pdf) SKIP_PDF=true ;;
    --skip-epub) SKIP_EPUB=true ;;
    --skip-mobi) SKIP_MOBI=true ;;
    --skip-html) SKIP_HTML=true ;;
  esac
  shift
done

echo "📚 Building $LANGUAGE version of the book..."

# Check if this language directory exists
if [ ! -d "book/$LANGUAGE" ]; then
  echo "⚠️ Warning: Language directory book/$LANGUAGE doesn't exist!"
  ls -la book/
  exit 1
fi

# Debug: List content of the language directory
echo "Content of book/$LANGUAGE:"
ls -la "book/$LANGUAGE/"

# Get book title and output filenames based on language
if [ "$LANGUAGE" = "es" ]; then
  BOOK_TITLE="Inteligencia Real"
  BOOK_SUBTITLE="Una Guía Práctica para Usar la IA en la Vida Cotidiana"
  PDF_FILENAME="inteligencia-real.pdf"
  EPUB_FILENAME="inteligencia-real.epub"
  MOBI_FILENAME="inteligencia-real.mobi"
  HTML_FILENAME="inteligencia-real.html"
  MARKDOWN_FILENAME="inteligencia-real.md"
else
  BOOK_TITLE="Actual Intelligence"
  BOOK_SUBTITLE="A Practical Guide to Using AI in Everyday Life"
  PDF_FILENAME="actual-intelligence.pdf"
  EPUB_FILENAME="actual-intelligence.epub"
  MOBI_FILENAME="actual-intelligence.mobi"
  HTML_FILENAME="actual-intelligence.html"
  MARKDOWN_FILENAME="actual-intelligence.md"
fi

# Define output paths - PUT ALL FILES IN BUILD ROOT DIRECTORY
# This is the key change - all files go to the root build directory
MARKDOWN_PATH="build/$MARKDOWN_FILENAME"
PDF_PATH="build/$PDF_FILENAME"
EPUB_PATH="build/$EPUB_FILENAME"
MOBI_PATH="build/$MOBI_FILENAME"
HTML_PATH="build/$HTML_FILENAME"

# Create a language directory for web pages only
if [ "$LANGUAGE" != "en" ]; then
  mkdir -p "build/$LANGUAGE"
  mkdir -p "build/$LANGUAGE/images"
fi

# Set up resource paths for pandoc
# Improve path handling - list all possible resource paths explicitly
RESOURCE_PATHS=".:book:book/$LANGUAGE:build:book/$LANGUAGE/images:book/images:build/images:build/$LANGUAGE/images"

# Step 1: Generate combined markdown file from source files
echo "📝 Combining markdown files for $LANGUAGE..."
source tools/scripts/combine-markdown.sh "$LANGUAGE" "$MARKDOWN_PATH" "$BOOK_TITLE" "$BOOK_SUBTITLE"

# Verify the combined markdown file was created
if [ ! -f "$MARKDOWN_PATH" ] || [ ! -s "$MARKDOWN_PATH" ]; then
  echo "⚠️ Error: Combined markdown file wasn't created or is empty!"
  exit 1
fi

# Create a safety copy for fallbacks
cp "$MARKDOWN_PATH" "${MARKDOWN_PATH%.*}-safe.md"

# Step 2: Generate PDF
if [ "$SKIP_PDF" = false ]; then
  echo "📄 Generating PDF for $LANGUAGE..."
  source tools/scripts/generate-pdf.sh "$LANGUAGE" "$MARKDOWN_PATH" "$PDF_PATH" "$BOOK_TITLE" "$RESOURCE_PATHS"
  # Verify PDF was created
  if [ -f "$PDF_PATH" ]; then
    echo "✅ PDF created successfully: $PDF_PATH"
    du -h "$PDF_PATH"
  else
    echo "⚠️ PDF generation failed!"
  fi
fi

# Step 3: Generate EPUB
if [ "$SKIP_EPUB" = false ]; then
  echo "📱 Generating EPUB for $LANGUAGE..."
  source tools/scripts/generate-epub.sh "$LANGUAGE" "$MARKDOWN_PATH" "$EPUB_PATH" "$BOOK_TITLE" "$BOOK_SUBTITLE" "$RESOURCE_PATHS"
  # Verify EPUB was created
  if [ -f "$EPUB_PATH" ]; then
    echo "✅ EPUB created successfully: $EPUB_PATH"
    du -h "$EPUB_PATH"
  else
    echo "⚠️ EPUB generation failed!"
  fi
fi

# Step 4: Generate MOBI
if [ "$SKIP_MOBI" = false ] && [ "$SKIP_EPUB" = false ]; then
  echo "📚 Generating MOBI for $LANGUAGE..."
  source tools/scripts/generate-mobi.sh "$LANGUAGE" "$EPUB_PATH" "$MOBI_PATH" "$BOOK_TITLE"
  # Verify MOBI was created
  if [ -f "$MOBI_PATH" ]; then
    echo "✅ MOBI created successfully: $MOBI_PATH"
    du -h "$MOBI_PATH"
  else
    echo "⚠️ MOBI generation failed or was skipped!"
  fi
fi

# Step 5: Generate HTML
if [ "$SKIP_HTML" = false ]; then
  echo "🌐 Generating HTML for $LANGUAGE..."
  source tools/scripts/generate-html.sh "$LANGUAGE" "$MARKDOWN_PATH" "$HTML_PATH" "$BOOK_TITLE" "$RESOURCE_PATHS"
  
  # Create index.html in appropriate directory
  if [ "$LANGUAGE" = "en" ]; then
    cp "$HTML_PATH" "build/index.html"
    echo "Created index.html for English"
  else
    mkdir -p "build/$LANGUAGE"
    cp "$HTML_PATH" "build/$LANGUAGE/index.html"
    echo "Created index.html for $LANGUAGE"
  fi
fi

# List final build directory contents for this language
echo "📂 Contents of build directory for $LANGUAGE:"
ls -la "build/$MARKDOWN_FILENAME" "build/$PDF_FILENAME" "build/$EPUB_FILENAME" "build/$MOBI_FILENAME" "build/$HTML_FILENAME" 2>/dev/null || echo "Some files may be missing"

echo "✅ Successfully built $LANGUAGE version of the book"
