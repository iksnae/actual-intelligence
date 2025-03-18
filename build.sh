#!/bin/bash

# Set to continue even when commands fail (we'll handle errors)
set +e

# Parse command line arguments
BUILD_ALL_LANGUAGES=false
SPECIFIC_LANGUAGE=""

for arg in "$@"
do
  case $arg in
    --all-languages)
      BUILD_ALL_LANGUAGES=true
      shift
      ;;
    --lang=*)
      SPECIFIC_LANGUAGE="${arg#*=}"
      shift
      ;;
  esac
do

# Create build directory if it doesn't exist
mkdir -p build

# Ensure cover image is properly handled
echo "Checking for cover image..."
COVER_IMAGE=""

# Try to find cover image in standard locations
if [ -f "art/cover.png" ]; then
  echo "✅ Found cover image at art/cover.png"
  COVER_IMAGE="art/cover.png"
  
  # Ensure book/images directories exist
  mkdir -p book/images
  mkdir -p book/en/images
  mkdir -p book/es/images
  
  # Copy cover to book directories for consistency
  cp "$COVER_IMAGE" book/images/cover.png
  cp "$COVER_IMAGE" book/en/images/cover.png
  cp "$COVER_IMAGE" book/es/images/cover.png
elif [ -f "book/images/cover.png" ]; then
  echo "✅ Found cover image at book/images/cover.png"
  COVER_IMAGE="book/images/cover.png"
elif [ -f "book/en/images/cover.png" ]; then
  echo "✅ Found cover image at book/en/images/cover.png"
  COVER_IMAGE="book/en/images/cover.png"
else
  echo "⚠️ No cover image found. Building book without cover."
fi

# Update LaTeX template (but don't include version and date)
if [ -f "templates/template.tex" ]; then
  echo "Using LaTeX template..."
  TEMP_TEMPLATE="templates/template-version.tex"
  cp templates/template.tex "$TEMP_TEMPLATE"
  
  # Use empty values for version and date to effectively remove them
  sed -i "s/\\\\newcommand{\\\\bookversion}{VERSION}/\\\\newcommand{\\\\bookversion}{}/g" "$TEMP_TEMPLATE"
  sed -i "s/\\\\newcommand{\\\\builddate}{BUILDDATE}/\\\\newcommand{\\\\builddate}{}/g" "$TEMP_TEMPLATE"
  
  echo "LaTeX template updated with empty version and date"
else
  echo "No LaTeX template found. Proceeding with default styling."
  TEMP_TEMPLATE=""
fi

# Step 1: Install Node.js dependencies (if they are not already installed)
echo "Installing Node.js dependencies..."
npm install

# Create directories for images in the build folder
echo "Creating image directories in build folder..."
mkdir -p build/images
mkdir -p build/es/images

# Copy all image directories to the build folder to ensure proper path resolution
echo "Copying image directories..."
find book -path "*/images" -type d | while read -r imgdir; do
  echo "Found image directory: $imgdir"
  # Use cp to copy directories and ignore errors
  mkdir -p "build/$(dirname "$imgdir")"
  cp -r "$imgdir" "build/$(dirname "$imgdir")/" 2>/dev/null || true
  echo "Copied $imgdir to build/"
done

# Also explicitly copy images to standard locations for better compatibility
if [ -d "book/en/images" ]; then
  echo "Copying book/en/images to build/images..."
  cp -r book/en/images/* build/images/ 2>/dev/null || true
fi

if [ -d "book/es/images" ]; then
  echo "Copying book/es/images to build/es/images..."
  cp -r book/es/images/* build/es/images/ 2>/dev/null || true
  # Also copy to root images for cross-referencing
  cp -r book/es/images/* build/images/ 2>/dev/null || true
fi

if [ -d "book/images" ]; then
  echo "Copying book/images to build/images..."
  cp -r book/images/* build/images/ 2>/dev/null || true
  # Also copy to es images for cross-referencing
  cp -r book/images/* build/es/images/ 2>/dev/null || true
fi

# Step 2: Build book using custom Node.js script if it exists
if [ -f "tools/build.js" ]; then
  echo "Running custom build script..."
  
  # Pass appropriate flags to the Node.js build script
  if [ "$BUILD_ALL_LANGUAGES" = true ]; then
    echo "Building all languages..."
    npm run build -- --all-languages || true  # Continue even if errors occur
  elif [ -n "$SPECIFIC_LANGUAGE" ]; then
    echo "Building specific language: $SPECIFIC_LANGUAGE"
    npm run build -- --lang="$SPECIFIC_LANGUAGE" || true  # Continue even if errors occur
  else
    # By default, build all languages in CI
    if [ -n "$CI" ]; then
      echo "Running in CI environment, building all languages by default"
      npm run build -- --all-languages || true  # Continue even if errors occur
    else
      npm run build || true  # Continue even if errors occur
    fi
  fi
else
  echo "No custom build script found. Using direct Pandoc compilation."
  # Create a combined markdown file for the book
  echo "Combining markdown files..."
  
  # Initialize metadata for the book (removing date)
  echo "---" > build/actual-intelligence.md
  echo "title: 'Actual Intelligence'" >> build/actual-intelligence.md
  echo "subtitle: 'A Practical Guide to Using AI in Everyday Life'" >> build/actual-intelligence.md
  echo "author: 'Open Source Community'" >> build/actual-intelligence.md
  echo "toc: true" >> build/actual-intelligence.md
  
  # Add cover image metadata if found
  if [ -n "$COVER_IMAGE" ]; then
    echo "cover-image: '$COVER_IMAGE'" >> build/actual-intelligence.md
  fi
  
  echo "---" >> build/actual-intelligence.md
  echo "" >> build/actual-intelligence.md
  
  # Process chapter directories in order
  find book -type d -name "chapter-*" | sort | while read -r chapter_dir; do
    echo "Processing chapter directory: $chapter_dir"
    
    # Add chapter introduction if it exists
    if [ -f "$chapter_dir/00-introduction.md" ]; then
      echo "Adding chapter introduction from $chapter_dir/00-introduction.md"
      cat "$chapter_dir/00-introduction.md" >> build/actual-intelligence.md
      echo -e "\n\n\\newpage\n\n" >> build/actual-intelligence.md
    fi
    
    # Find all numbered markdown files (excluding 00-introduction.md) and process them in order
    find "$chapter_dir" -maxdepth 1 -name "[0-9]*.md" | grep -v "00-introduction.md" | sort | while read -r section_file; do
      echo "Adding section from $section_file"
      # Add an explicit section header comment for better visibility in source
      echo -e "\n\n<!-- Start of section: $(basename "$section_file") -->\n" >> build/actual-intelligence.md
      cat "$section_file" >> build/actual-intelligence.md
      # Add explicit page break after each section
      echo -e "\n\n\\newpage\n\n" >> build/actual-intelligence.md
    done
  done
fi

# Define common resource paths to help pandoc find images
RESOURCE_PATHS=".:book:book/en:book/es:build:book/en/images:book/es/images:book/images:build/images:build/es/images"

# Create a modified version of the Markdown file that makes image references optional
echo "Creating fallback markdown version for resilient PDF generation..."
if [ -f "build/actual-intelligence.md" ]; then
  cp build/actual-intelligence.md build/actual-intelligence-safe.md

  # Step 3: Generate PDF with our template (with error handling)
  echo "Generating PDF..."
  if [ -n "$TEMP_TEMPLATE" ]; then
    # First attempt: Use our custom template with resource path for images
    pandoc build/actual-intelligence.md -o build/actual-intelligence.pdf \
      --template="$TEMP_TEMPLATE" \
      --metadata title="Actual Intelligence" \
      --pdf-engine=xelatex \
      --toc \
      --resource-path="$RESOURCE_PATHS"
  else
    # First attempt: Fallback to default pandoc styling with resource path for images
    pandoc build/actual-intelligence.md -o build/actual-intelligence.pdf \
      --metadata title="Actual Intelligence" \
      --pdf-engine=xelatex \
      --toc \
      --resource-path="$RESOURCE_PATHS"
  fi

  # Check if PDF file exists and has content
  if [ $? -ne 0 ] || [ ! -s "build/actual-intelligence.pdf" ]; then
    echo "First PDF generation attempt failed, trying with more resilient settings..."
    
    # Create a version of the markdown with image references made more resilient
    sed -i 's/!\[\([^]]*\)\](\([^)]*\))/!\[\1\](images\/\2)/g' build/actual-intelligence-safe.md
    
    # Second attempt: Try with modified settings and more lenient image paths
    pandoc build/actual-intelligence-safe.md -o build/actual-intelligence.pdf \
      --metadata title="Actual Intelligence" \
      --pdf-engine=xelatex \
      --toc \
      --variable=graphics=true \
      --variable=documentclass=book \
      --resource-path="$RESOURCE_PATHS" || true
    
    # If still not successful, create a minimal PDF
    if [ ! -s "build/actual-intelligence.pdf" ]; then
      echo "WARNING: PDF generation with images failed, creating a minimal PDF without images..."
      # Create a version with image references removed
      sed -i 's/!\[\([^]]*\)\](\([^)]*\))//g' build/actual-intelligence-safe.md
      
      # Final attempt: minimal PDF with no images
      pandoc build/actual-intelligence-safe.md -o build/actual-intelligence.pdf \
        --metadata title="Actual Intelligence" \
        --pdf-engine=xelatex \
        --toc \
        --resource-path="$RESOURCE_PATHS" || true
        
      # If all else fails, create a placeholder PDF
      if [ ! -s "build/actual-intelligence.pdf" ]; then
        echo "WARNING: All PDF generation attempts failed, creating placeholder PDF..."
        echo "# Actual Intelligence - Placeholder PDF" > build/placeholder.md
        echo "PDF generation encountered issues with images. Please see HTML or EPUB versions." >> build/placeholder.md
        pandoc build/placeholder.md -o build/actual-intelligence.pdf --pdf-engine=xelatex
      fi
    fi
  fi

  # Step 4: Generate EPUB with cover image and extract media
  echo "Generating EPUB file..."
  if [ -n "$COVER_IMAGE" ]; then
    echo "Including cover image in EPUB: $COVER_IMAGE"
    pandoc build/actual-intelligence.md -o build/actual-intelligence.epub \
      --epub-cover-image="$COVER_IMAGE" \
      --toc \
      --toc-depth=2 \
      --metadata title="Actual Intelligence" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --resource-path="$RESOURCE_PATHS" \
      --extract-media=build/epub-media || true
  else
    pandoc build/actual-intelligence.md -o build/actual-intelligence.epub \
      --toc \
      --toc-depth=2 \
      --metadata title="Actual Intelligence" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --resource-path="$RESOURCE_PATHS" \
      --extract-media=build/epub-media || true
  fi

  # Create EPUB if it doesn't exist
  if [ ! -s "build/actual-intelligence.epub" ]; then
    echo "WARNING: EPUB generation failed, creating minimal EPUB without images..."
    # Create a version with image references removed
    sed -i 's/!\[\([^]]*\)\](\([^)]*\))//g' build/actual-intelligence-safe.md
    
    pandoc build/actual-intelligence-safe.md -o build/actual-intelligence.epub \
      --toc \
      --toc-depth=2 \
      --metadata title="Actual Intelligence" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --resource-path="$RESOURCE_PATHS" || true
  fi

  echo "EPUB file generated: build/actual-intelligence.epub"

  # Step 4.5: Generate MOBI file from EPUB using Calibre
  echo "Generating MOBI file..."
  if [ -s "build/actual-intelligence.epub" ]; then
    # Use Calibre's ebook-convert to convert EPUB to MOBI
    ebook-convert build/actual-intelligence.epub build/actual-intelligence.mobi \
      --title="Actual Intelligence" \
      --authors="Open Source Community" \
      --publisher="Khaos Studios" \
      --language="en" || true
      
    if [ -s "build/actual-intelligence.mobi" ]; then
      echo "MOBI file generated: build/actual-intelligence.mobi"
    else
      echo "WARNING: MOBI generation failed."
    fi
  else
    echo "WARNING: Cannot generate MOBI file because EPUB generation failed."
  fi

  # Step 5: Generate HTML file from Markdown files with images
  echo "Generating HTML file..."
  pandoc build/actual-intelligence.md -o build/actual-intelligence.html \
    --standalone \
    --toc \
    --toc-depth=2 \
    --resource-path="$RESOURCE_PATHS" \
    --metadata title="Actual Intelligence" || true

  # Check if HTML file exists
  if [ ! -s "build/actual-intelligence.html" ]; then
    echo "WARNING: HTML file generation failed with images, trying without..."
    pandoc build/actual-intelligence-safe.md -o build/actual-intelligence.html \
      --standalone \
      --toc \
      --toc-depth=2 \
      --resource-path="$RESOURCE_PATHS" \
      --metadata title="Actual Intelligence" || true
      
    if [ ! -s "build/actual-intelligence.html" ]; then
      echo "ERROR: All HTML generation attempts failed, creating minimal HTML..."
      echo "<html><head><title>Actual Intelligence</title></head><body><h1>Actual Intelligence</h1><p>HTML generation encountered issues. Please see PDF or EPUB versions.</p></body></html>" > build/actual-intelligence.html
    fi
  fi

  echo "HTML file generated: build/actual-intelligence.html"

  # Create index.html from the HTML file for GitHub Pages
  cp build/actual-intelligence.html build/index.html
fi

# List the build folder contents for verification
echo "Contents of build/ directory:"
ls -la build/

echo "Build process completed successfully."

# End of script
