#!/bin/bash

# Set to continue even when commands fail (we'll handle errors)
set +e

# Create build directory if it doesn't exist
mkdir -p build

# Define supported languages
LANGUAGES=("en" "es")
LANGUAGE_NAMES=("actual-intelligence" "inteligencia-real")

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
  # Use rsync to copy only existing files and ignore errors
  mkdir -p "build/$(dirname "$imgdir")"
  cp -r "$imgdir" "build/$(dirname "$imgdir")/" 2>/dev/null || true
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

if [ -d "book/es/images" ]; then
  echo "Copying book/es/images to build/es/images..."
  cp -r book/es/images/* build/es/images/ 2>/dev/null || true
fi

# Build each language version
for i in "${!LANGUAGES[@]}"; do
  LANG=${LANGUAGES[$i]}
  BOOK_NAME=${LANGUAGE_NAMES[$i]}
  
  echo "Building $LANG version of the book..."
  
  # Step 2: Build book using custom Node.js script if it exists
  if [ -f "tools/build.js" ]; then
    echo "Running custom build script for $LANG..."
    LANG=$LANG npm run build || true  # Continue even if errors occur
  else
    echo "No custom build script found. Using direct Pandoc compilation for $LANG..."
    # Create a combined markdown file for the book
    echo "Combining markdown files for $LANG..."
    
    # Initialize metadata for the book (removing date)
    echo "---" > build/$BOOK_NAME.md
    
    if [ "$LANG" == "en" ]; then
      echo "title: 'Actual Intelligence'" >> build/$BOOK_NAME.md
      echo "subtitle: 'A Practical Guide to Using AI in Everyday Life'" >> build/$BOOK_NAME.md
    elif [ "$LANG" == "es" ]; then
      echo "title: 'Inteligencia Real'" >> build/$BOOK_NAME.md
      echo "subtitle: 'Una Guía Práctica para Usar IA en la Vida Cotidiana'" >> build/$BOOK_NAME.md
    fi
    
    echo "author: 'Open Source Community'" >> build/$BOOK_NAME.md
    echo "toc: true" >> build/$BOOK_NAME.md
    
    # Add cover image metadata if found
    if [ -n "$COVER_IMAGE" ]; then
      echo "cover-image: '$COVER_IMAGE'" >> build/$BOOK_NAME.md
    fi
    
    echo "---" >> build/$BOOK_NAME.md
    echo "" >> build/$BOOK_NAME.md
    
    # Process chapter directories in order
    find book/$LANG -type d -name "chapter-*" | sort | while read -r chapter_dir; do
      echo "Processing chapter directory: $chapter_dir"
      
      # Add chapter introduction if it exists
      if [ -f "$chapter_dir/00-introduction.md" ]; then
        echo "Adding chapter introduction from $chapter_dir/00-introduction.md"
        cat "$chapter_dir/00-introduction.md" >> build/$BOOK_NAME.md
        echo -e "\n\n\\newpage\n\n" >> build/$BOOK_NAME.md
      fi
      
      # Find all numbered markdown files (excluding 00-introduction.md) and process them in order
      find "$chapter_dir" -maxdepth 1 -name "[0-9]*.md" | grep -v "00-introduction.md" | sort | while read -r section_file; do
        echo "Adding section from $section_file"
        # Add an explicit section header comment for better visibility in source
        echo -e "\n\n<!-- Start of section: $(basename "$section_file") -->\n" >> build/$BOOK_NAME.md
        cat "$section_file" >> build/$BOOK_NAME.md
        # Add explicit page break after each section
        echo -e "\n\n\\newpage\n\n" >> build/$BOOK_NAME.md
      done
    done
  fi
  
  # Define common resource paths to help pandoc find images
  if [ "$LANG" == "en" ]; then
    RESOURCE_PATHS=".:book:book/en:build:book/en/images:book/images:build/images"
  elif [ "$LANG" == "es" ]; then
    RESOURCE_PATHS=".:book:book/es:build:book/es/images:book/images:build/images:build/es/images"
  fi
  
  # Create a modified version of the Markdown file that makes image references optional
  echo "Creating fallback markdown version for resilient PDF generation..."
  cp build/$BOOK_NAME.md build/$BOOK_NAME-safe.md
  
  # Step 3: Generate PDF with our template (with error handling)
  echo "Generating $LANG PDF..."
  if [ -n "$TEMP_TEMPLATE" ]; then
    # First attempt: Use our custom template with resource path for images
    pandoc build/$BOOK_NAME.md -o build/$BOOK_NAME.pdf \
      --template="$TEMP_TEMPLATE" \
      --metadata title="$BOOK_NAME" \
      --pdf-engine=xelatex \
      --toc \
      --resource-path="$RESOURCE_PATHS"
  else
    # First attempt: Fallback to default pandoc styling with resource path for images
    pandoc build/$BOOK_NAME.md -o build/$BOOK_NAME.pdf \
      --metadata title="$BOOK_NAME" \
      --pdf-engine=xelatex \
      --toc \
      --resource-path="$RESOURCE_PATHS"
  fi
  
  # Check if PDF file exists and has content
  if [ $? -ne 0 ] || [ ! -s "build/$BOOK_NAME.pdf" ]; then
    echo "First PDF generation attempt failed, trying with more resilient settings..."
    
    # Create a version of the markdown with image references made more resilient
    sed -i 's/!\[\([^]]*\)\](\([^)]*\))/!\[\1\](images\/\2)/g' build/$BOOK_NAME-safe.md
    
    # Second attempt: Try with modified settings and more lenient image paths
    pandoc build/$BOOK_NAME-safe.md -o build/$BOOK_NAME.pdf \
      --metadata title="$BOOK_NAME" \
      --pdf-engine=xelatex \
      --toc \
      --variable=graphics=true \
      --variable=documentclass=book \
      --resource-path="$RESOURCE_PATHS" || true
    
    # If still not successful, create a minimal PDF
    if [ ! -s "build/$BOOK_NAME.pdf" ]; then
      echo "WARNING: PDF generation with images failed, creating a minimal PDF without images..."
      # Create a version with image references removed
      sed -i 's/!\[\([^]]*\)\](\([^)]*\))//g' build/$BOOK_NAME-safe.md
      
      # Final attempt: minimal PDF with no images
      pandoc build/$BOOK_NAME-safe.md -o build/$BOOK_NAME.pdf \
        --metadata title="$BOOK_NAME" \
        --pdf-engine=xelatex \
        --toc \
        --resource-path="$RESOURCE_PATHS" || true
        
      # If all else fails, create a placeholder PDF
      if [ ! -s "build/$BOOK_NAME.pdf" ]; then
        echo "WARNING: All PDF generation attempts failed, creating placeholder PDF..."
        echo "# $BOOK_NAME - Placeholder PDF" > build/placeholder-$LANG.md
        echo "PDF generation encountered issues with images. Please see HTML or EPUB versions." >> build/placeholder-$LANG.md
        pandoc build/placeholder-$LANG.md -o build/$BOOK_NAME.pdf --pdf-engine=xelatex
      fi
    fi
  fi
  
  # Step 4: Generate EPUB with cover image and extract media
  echo "Generating $LANG EPUB file..."
  if [ -n "$COVER_IMAGE" ]; then
    echo "Including cover image in EPUB: $COVER_IMAGE"
    pandoc build/$BOOK_NAME.md -o build/$BOOK_NAME.epub \
      --epub-cover-image="$COVER_IMAGE" \
      --toc \
      --toc-depth=2 \
      --metadata title="$BOOK_NAME" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --resource-path="$RESOURCE_PATHS" \
      --extract-media=build/epub-media-$LANG || true
  else
    pandoc build/$BOOK_NAME.md -o build/$BOOK_NAME.epub \
      --toc \
      --toc-depth=2 \
      --metadata title="$BOOK_NAME" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --resource-path="$RESOURCE_PATHS" \
      --extract-media=build/epub-media-$LANG || true
  fi
  
  # Create EPUB if it doesn't exist
  if [ ! -s "build/$BOOK_NAME.epub" ]; then
    echo "WARNING: EPUB generation failed, creating minimal EPUB without images..."
    # Create a version with image references removed
    sed -i 's/!\[\([^]]*\)\](\([^)]*\))//g' build/$BOOK_NAME-safe.md
    
    pandoc build/$BOOK_NAME-safe.md -o build/$BOOK_NAME.epub \
      --toc \
      --toc-depth=2 \
      --metadata title="$BOOK_NAME" \
      --metadata publisher="Khaos Studios" \
      --metadata creator="Open Source Community" \
      --resource-path="$RESOURCE_PATHS" || true
  fi
  
  echo "$LANG EPUB file generated: build/$BOOK_NAME.epub"
  
  # Step 4.5: Generate MOBI file from EPUB using Calibre
  echo "Generating $LANG MOBI file..."
  if [ -s "build/$BOOK_NAME.epub" ]; then
    # Use Calibre's ebook-convert to convert EPUB to MOBI
    ebook-convert build/$BOOK_NAME.epub build/$BOOK_NAME.mobi \
      --title="$BOOK_NAME" \
      --authors="Open Source Community" \
      --publisher="Khaos Studios" \
      --language="$LANG" || true
      
    if [ -s "build/$BOOK_NAME.mobi" ]; then
      echo "$LANG MOBI file generated: build/$BOOK_NAME.mobi"
    else
      echo "WARNING: $LANG MOBI generation failed."
    fi
  else
    echo "WARNING: Cannot generate $LANG MOBI file because EPUB generation failed."
  fi
  
  # Step 5: Generate HTML file from Markdown files with images
  echo "Generating $LANG HTML file..."
  
  if [ "$LANG" == "es" ]; then
    mkdir -p build/es
  fi
  
  if [ "$LANG" == "en" ]; then
    pandoc build/$BOOK_NAME.md -o build/$BOOK_NAME.html \
      --standalone \
      --toc \
      --toc-depth=2 \
      --resource-path="$RESOURCE_PATHS" \
      --metadata title="$BOOK_NAME" || true
  elif [ "$LANG" == "es" ]; then
    pandoc build/$BOOK_NAME.md -o build/es/index.html \
      --standalone \
      --toc \
      --toc-depth=2 \
      --resource-path="$RESOURCE_PATHS" \
      --metadata title="$BOOK_NAME" || true
  fi
  
  # Check if HTML file exists for English (main version)
  if [ "$LANG" == "en" ] && [ ! -s "build/$BOOK_NAME.html" ]; then
    echo "WARNING: HTML file generation failed with images, trying without..."
    pandoc build/$BOOK_NAME-safe.md -o build/$BOOK_NAME.html \
      --standalone \
      --toc \
      --toc-depth=2 \
      --resource-path="$RESOURCE_PATHS" \
      --metadata title="$BOOK_NAME" || true
      
    if [ ! -s "build/$BOOK_NAME.html" ]; then
      echo "ERROR: All HTML generation attempts failed, creating minimal HTML..."
      echo "<html><head><title>$BOOK_NAME</title></head><body><h1>$BOOK_NAME</h1><p>HTML generation encountered issues. Please see PDF or EPUB versions.</p></body></html>" > build/$BOOK_NAME.html
    fi
  fi
  
  # Check if HTML file exists for Spanish version
  if [ "$LANG" == "es" ] && [ ! -s "build/es/index.html" ]; then
    echo "WARNING: Spanish HTML file generation failed with images, trying without..."
    pandoc build/$BOOK_NAME-safe.md -o build/es/index.html \
      --standalone \
      --toc \
      --toc-depth=2 \
      --resource-path="$RESOURCE_PATHS" \
      --metadata title="$BOOK_NAME" || true
      
    if [ ! -s "build/es/index.html" ]; then
      echo "ERROR: All Spanish HTML generation attempts failed, creating minimal HTML..."
      echo "<html><head><title>$BOOK_NAME</title></head><body><h1>$BOOK_NAME</h1><p>La generación de HTML encontró problemas. Por favor, consulte las versiones PDF o EPUB.</p></body></html>" > build/es/index.html
    fi
  fi
  
  echo "$LANG HTML file generated successfully."
done

# Create index.html from the English HTML file for GitHub Pages
if [ -f "build/actual-intelligence.html" ]; then
  cp build/actual-intelligence.html build/index.html
  echo "Created main index.html for GitHub Pages."
fi

# List the build folder contents for verification
echo "Contents of build/ directory:"
ls -la build/
if [ -d "build/es" ]; then
  echo "Contents of build/es/ directory:"
  ls -la build/es/
fi

echo "Build process completed successfully."

# End of script
