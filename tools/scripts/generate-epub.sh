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

# Get absolute path to working directory
WORK_DIR=$(pwd)
echo "📱 Generating EPUB for $LANGUAGE from $WORK_DIR..."
echo "📊 Input: $INPUT_FILE"
echo "📊 Output: $OUTPUT_FILE"

# Simplify the approach for Docker environment

# Step 1: Copy all images to build/images directory
echo "📁 Ensuring all images are available..."
mkdir -p build/images

# Copy images from all possible sources
if [ -d "book/images" ]; then
  echo "Copying from book/images"
  find book/images -type f -exec cp {} build/images/ \; 2>/dev/null || true
fi

if [ -d "book/en/images" ]; then
  echo "Copying from book/en/images"
  find book/en/images -type f -exec cp {} build/images/ \; 2>/dev/null || true
fi

if [ -d "book/$LANGUAGE/images" ]; then
  echo "Copying from book/$LANGUAGE/images"
  find book/$LANGUAGE/images -type f -exec cp {} build/images/ \; 2>/dev/null || true
fi

if [ -n "$COVER_IMAGE" ]; then
  echo "Copying cover image: $COVER_IMAGE"
  cp "$COVER_IMAGE" build/images/cover.png 2>/dev/null || true
fi

# Step 2: Create a modified markdown file with fixed image paths
MODIFIED_MD="build/epub-ready-$LANGUAGE.md"
cp "$INPUT_FILE" "$MODIFIED_MD"

# Try to fix image paths to use absolute paths
echo "🔄 Updating image paths in markdown..."
sed -i 's|!\[\([^]]*\)\](\([^)]*\))|![\1]('"$WORK_DIR"'/build/images/\2)|g' "$MODIFIED_MD"
sed -i 's|cover-image: .*|cover-image: '"$WORK_DIR"'/build/images/cover.png|g' "$MODIFIED_MD"

# List the image folder contents for debugging
echo "📸 Available images:"
ls -la build/images/

# Step 3: Generate the EPUB with maximum debugging
echo "🔄 Running pandoc with absolute paths..."

# First try: Generate with absolute paths
pandoc "$MODIFIED_MD" -o "$OUTPUT_FILE" \
  --epub-cover-image="$WORK_DIR/build/images/cover.png" \
  --self-contained \
  --verbose \
  --toc \
  --toc-depth=2 \
  --metadata title="$BOOK_TITLE" \
  --metadata subtitle="$BOOK_SUBTITLE" \
  --metadata publisher="Khaos Studios" \
  --metadata creator="Open Source Community" \
  --metadata lang="$LANGUAGE" 2>&1 | tee build/pandoc-output.log

# Check if EPUB was generated successfully
if [ -s "$OUTPUT_FILE" ]; then
  FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
  echo "📊 EPUB file size: ${FILE_SIZE}KB"
  
  if [ "$FILE_SIZE" -lt 3000 ]; then
    echo "⚠️ WARNING: EPUB file size is smaller than expected (${FILE_SIZE}KB). Images may be missing."
    echo "🔍 Trying with relative paths..."
    
    # Second try: Use relative paths
    RELATIVE_MD="build/epub-ready-relative-$LANGUAGE.md"
    cp "$INPUT_FILE" "$RELATIVE_MD"
    sed -i 's|!\[\([^]]*\)\](\([^)]*\))|![\1](build/images/\2)|g' "$RELATIVE_MD"
    sed -i 's|cover-image: .*|cover-image: build/images/cover.png|g' "$RELATIVE_MD"
    
    pandoc "$RELATIVE_MD" -o "$OUTPUT_FILE" \
      --epub-cover-image="build/images/cover.png" \
      --embed-resources \
      --toc \
      --toc-depth=2 \
      --resource-path=".:build:build/images" \
      --metadata title="$BOOK_TITLE" \
      --metadata subtitle="$BOOK_SUBTITLE" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --metadata lang="$LANGUAGE" 2>&1 | tee -a build/pandoc-output.log
      
    # Check file size again
    if [ -s "$OUTPUT_FILE" ]; then
      FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
      echo "📊 EPUB file size (second attempt): ${FILE_SIZE}KB"
      
      if [ "$FILE_SIZE" -lt 3000 ]; then
        echo "⚠️ WARNING: Images still missing. Final attempt with local paths..."
        
        # Final attempt with local directory
        TEMP_DIR="build/epub-temp"
        mkdir -p "$TEMP_DIR/images"
        
        # Copy content to temp directory
        cp "$INPUT_FILE" "$TEMP_DIR/content.md"
        cp -r build/images/* "$TEMP_DIR/images/" 2>/dev/null || true
        
        # Fix image paths for local directory
        sed -i 's|!\[\([^]]*\)\](\([^)]*\))|![\1](images/\2)|g' "$TEMP_DIR/content.md"
        sed -i 's|cover-image: .*|cover-image: images/cover.png|g' "$TEMP_DIR/content.md"
        
        # Save current directory
        CURRENT_DIR=$(pwd)
        
        # Change to temp directory and run pandoc
        cd "$TEMP_DIR"
        echo "Changed directory to $(pwd)"
        ls -la
        echo "Images directory contents:"
        ls -la images/
        
        pandoc content.md -o "output.epub" \
          --epub-cover-image="images/cover.png" \
          --toc \
          --toc-depth=2 \
          --metadata title="$BOOK_TITLE" \
          --metadata subtitle="$BOOK_SUBTITLE" \
          --metadata publisher="Khaos Studios" \
          --metadata creator="Open Source Community" \
          --metadata lang="$LANGUAGE" 2>&1 | tee ../pandoc-output-final.log
          
        # Go back to original directory
        cd "$CURRENT_DIR"
        
        # Copy result if successful
        if [ -s "$TEMP_DIR/output.epub" ]; then
          cp "$TEMP_DIR/output.epub" "$OUTPUT_FILE"
          FILE_SIZE=$(du -k "$OUTPUT_FILE" | cut -f1)
          echo "📊 EPUB file size (final attempt): ${FILE_SIZE}KB"
        fi
      fi
    fi
  fi
  
  if [ -s "$OUTPUT_FILE" ]; then
    echo "✅ EPUB created successfully at $OUTPUT_FILE"
    
    # For diagnostics, copy the EPUB to a readable filename
    cp "$OUTPUT_FILE" "build/epub-$(date +%s).epub"
  else
    echo "❌ Failed to create EPUB after multiple attempts"
    exit 1
  fi
else
  echo "❌ Failed to create EPUB. Check pandoc-output.log for details."
  exit 1
fi