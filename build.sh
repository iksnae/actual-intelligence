#!/bin/bash

# Ensure that any errors stop the script
set -e

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
  
  # Copy cover to book directories for consistency
  cp "$COVER_IMAGE" book/images/cover.png
  cp "$COVER_IMAGE" book/en/images/cover.png
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
  sed -i "s/\\\\\\\\newcommand{\\\\\\\\bookversion}{VERSION}/\\\\\\\\newcommand{\\\\\\\\bookversion}{}/g" "$TEMP_TEMPLATE"
  sed -i "s/\\\\\\\\newcommand{\\\\\\\\builddate}{BUILDDATE}/\\\\\\\\newcommand{\\\\\\\\builddate}{}/g" "$TEMP_TEMPLATE"
  
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

# Copy all image directories to the build folder to ensure proper path resolution
echo "Copying image directories..."
find book -path "*/images" -type d | while read -r imgdir; do
  echo "Found image directory: $imgdir"
  cp -r "$imgdir" build/
  echo "Copied $imgdir to build/"
done

# Also explicitly copy images to standard locations for better compatibility
if [ -d "book/en/images" ]; then
  echo "Copying book/en/images to build/images..."
  cp -r book/en/images/* build/images/ 2>/dev/null || true
fi

if [ -d "book/images" ]; then
  echo "Copying book/images to build/images..."
  cp -r book/images/* build/images/ 2>/dev/null || true
fi

# Step 2: Build book using custom Node.js script if it exists
if [ -f "tools/build.js" ]; then
  echo "Running custom build script..."
  npm run build  # This will execute node tools/build.js as per the package.json
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
RESOURCE_PATHS=".:book:book/en:build:book/en/images:book/images:build/images"

# Step 3: Generate PDF with our template
echo "Generating PDF..."
if [ -n "$TEMP_TEMPLATE" ]; then
  # Use our custom template with resource path for images
  pandoc build/actual-intelligence.md -o build/actual-intelligence.pdf \
    --template="$TEMP_TEMPLATE" \
    --pdf-engine=xelatex \
    --toc \
    --resource-path="$RESOURCE_PATHS"
else
  # Fallback to default pandoc styling with resource path for images
  pandoc build/actual-intelligence.md -o build/actual-intelligence.pdf \
    --pdf-engine=xelatex \
    --toc \
    --resource-path="$RESOURCE_PATHS"
fi

# Step 4: Check if PDF file exists and has content
if [ -f "build/actual-intelligence.pdf" ] && [ -s "build/actual-intelligence.pdf" ]; then
  echo "PDF file exists and has content."
else
  echo "WARNING: PDF file is missing or empty, creating a placeholder."
  echo "# Actual Intelligence - Placeholder PDF" > build/placeholder.md
  pandoc build/placeholder.md -o build/actual-intelligence.pdf --pdf-engine=xelatex
fi

# Step 5: Generate EPUB with cover image and extract media
echo "Generating EPUB file..."
if [ -n "$COVER_IMAGE" ]; then
  echo "Including cover image in EPUB: $COVER_IMAGE"
  pandoc build/actual-intelligence.md -o build/actual-intelligence.epub \
    --epub-cover-image="$COVER_IMAGE" \
    --toc \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media=build/epub-media
else
  pandoc build/actual-intelligence.md -o build/actual-intelligence.epub \
    --toc \
    --resource-path="$RESOURCE_PATHS" \
    --extract-media=build/epub-media
fi
echo "EPUB file generated: build/actual-intelligence.epub"

# Step 6: Generate HTML file from Markdown files with images
echo "Generating HTML file..."
pandoc build/actual-intelligence.md -o build/actual-intelligence.html \
  --standalone \
  --toc \
  --resource-path="$RESOURCE_PATHS" \
  --metadata title="Actual Intelligence"

# Check if HTML file exists
if [ ! -f "build/actual-intelligence.html" ]; then
  echo "ERROR: HTML file generation failed!"
  exit 1
fi
echo "HTML file generated: build/actual-intelligence.html"

# Create index.html from the HTML file for GitHub Pages
cp build/actual-intelligence.html build/index.html

# List the build folder contents for verification
echo "Contents of build/ directory:"
ls -la build/

echo "Build process completed successfully."

# End of script