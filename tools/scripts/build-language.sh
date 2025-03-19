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

# Define output paths based on language
if [ "$LANGUAGE" = "en" ]; then
  MARKDOWN_PATH="build/$MARKDOWN_FILENAME"
  PDF_PATH="build/$PDF_FILENAME"
  EPUB_PATH="build/$EPUB_FILENAME"
  MOBI_PATH="build/$MOBI_FILENAME"
  HTML_PATH="build/$HTML_FILENAME"
else
  MARKDOWN_PATH="build/$LANGUAGE/$MARKDOWN_FILENAME"
  PDF_PATH="build/$LANGUAGE/$PDF_FILENAME"
  EPUB_PATH="build/$LANGUAGE/$EPUB_FILENAME"
  MOBI_PATH="build/$LANGUAGE/$MOBI_FILENAME"
  HTML_PATH="build/$LANGUAGE/$HTML_FILENAME"
  
  # Create language directory if it doesn't exist
  mkdir -p "build/$LANGUAGE"
  # Also create images directory for the language
  mkdir -p "build/$LANGUAGE/images"
fi

# Set up resource paths for pandoc
# Improve path handling - list all possible resource paths explicitly
RESOURCE_PATHS=".:book:book/$LANGUAGE:build:book/$LANGUAGE/images:book/images:build/images:build/$LANGUAGE/images"

# Step 1: Generate combined markdown file from source files
echo "📝 Combining markdown files for $LANGUAGE..."
source tools/scripts/combine-markdown.sh "$LANGUAGE" "$MARKDOWN_PATH" "$BOOK_TITLE" "$BOOK_SUBTITLE"

# Create a safety copy for fallbacks
cp "$MARKDOWN_PATH" "${MARKDOWN_PATH%.*}-safe.md"

# Step 2: Generate PDF
if [ "$SKIP_PDF" = false ]; then
  echo "📄 Generating PDF for $LANGUAGE..."
  source tools/scripts/generate-pdf.sh "$LANGUAGE" "$MARKDOWN_PATH" "$PDF_PATH" "$BOOK_TITLE" "$RESOURCE_PATHS"
fi

# Step 3: Generate EPUB
if [ "$SKIP_EPUB" = false ]; then
  echo "📱 Generating EPUB for $LANGUAGE..."
  source tools/scripts/generate-epub.sh "$LANGUAGE" "$MARKDOWN_PATH" "$EPUB_PATH" "$BOOK_TITLE" "$BOOK_SUBTITLE" "$RESOURCE_PATHS"
fi

# Step 4: Generate MOBI
if [ "$SKIP_MOBI" = false ] && [ "$SKIP_EPUB" = false ]; then
  echo "📚 Generating MOBI for $LANGUAGE..."
  source tools/scripts/generate-mobi.sh "$LANGUAGE" "$EPUB_PATH" "$MOBI_PATH" "$BOOK_TITLE"
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

# Copy outputs to root directory for release assets if not English
# This is critical for the release process!
if [ "$LANGUAGE" != "en" ]; then
  echo "🔄 Copying $LANGUAGE files to root build directory for release..."
  
  # Be more explicit about copying files - check if they exist first
  if [ "$SKIP_PDF" = false ] && [ -f "$PDF_PATH" ]; then
    echo "Copying $PDF_PATH to build/$PDF_FILENAME"
    cp "$PDF_PATH" "build/$PDF_FILENAME"
  else
    echo "⚠️ Warning: $PDF_PATH does not exist or was skipped"
  fi
  
  if [ "$SKIP_EPUB" = false ] && [ -f "$EPUB_PATH" ]; then
    echo "Copying $EPUB_PATH to build/$EPUB_FILENAME"
    cp "$EPUB_PATH" "build/$EPUB_FILENAME"
  else
    echo "⚠️ Warning: $EPUB_PATH does not exist or was skipped"
  fi
  
  if [ "$SKIP_MOBI" = false ] && [ -f "$MOBI_PATH" ]; then
    echo "Copying $MOBI_PATH to build/$MOBI_FILENAME"
    cp "$MOBI_PATH" "build/$MOBI_FILENAME"
  else
    echo "⚠️ Warning: $MOBI_PATH does not exist or was skipped"
  fi
  
  if [ "$SKIP_HTML" = false ] && [ -f "$HTML_PATH" ]; then
    echo "Copying $HTML_PATH to build/$HTML_FILENAME"
    cp "$HTML_PATH" "build/$HTML_FILENAME"
  else
    echo "⚠️ Warning: $HTML_PATH does not exist or was skipped"
  fi
  
  # Copy markdown for completeness
  if [ -f "$MARKDOWN_PATH" ]; then
    echo "Copying $MARKDOWN_PATH to build/$MARKDOWN_FILENAME"
    cp "$MARKDOWN_PATH" "build/$MARKDOWN_FILENAME"
  else
    echo "⚠️ Warning: $MARKDOWN_PATH does not exist"
  fi
fi

echo "✅ Successfully built $LANGUAGE version of the book"
