#!/bin/bash

# Ensure that any errors stop the script
set -e

# Set version and date (same as in the workflow)
VERSION=$(date +'v%Y.%m.%d-%H%M')
DATE=$(date +'%B %d, %Y')

# Create build directory if it doesn't exist
mkdir -p build

# Update LaTeX template with version and date
if [ -f "templates/template.tex" ]; then
  echo "Updating LaTeX template with version and date info..."
  TEMP_TEMPLATE="templates/template-version.tex"
  cp templates/template.tex "$TEMP_TEMPLATE"
  
  # Replace version and build date in the template
  sed -i "s/\\newcommand{\\bookversion}{VERSION}/\\newcommand{\\bookversion}{${VERSION}}/g" "$TEMP_TEMPLATE"
  sed -i "s/\\newcommand{\\builddate}{BUILDDATE}/\\newcommand{\\builddate}{${DATE}}/g" "$TEMP_TEMPLATE"
  
  echo "LaTeX template updated with version: $VERSION and date: $DATE"
else
  echo "No LaTeX template found. Proceeding with default styling."
  TEMP_TEMPLATE=""
fi

# Step 1: Install Node.js dependencies (if they are not already installed)
echo "Installing Node.js dependencies..."
npm install

# Step 2: Build book using custom Node.js script if it exists
if [ -f "tools/build.js" ]; then
  echo "Running custom build script..."
  npm run build  # This will execute node tools/build.js as per the package.json
else
  echo "No custom build script found. Using direct Pandoc compilation."
  # Create a combined markdown file for the book
  echo "Combining markdown files..."
  
  # Initialize metadata for the book
  echo "---" > build/actual-intelligence.md
  echo "title: 'Actual Intelligence'" >> build/actual-intelligence.md
  echo "subtitle: 'A Practical Guide to Using AI in Everyday Life'" >> build/actual-intelligence.md
  echo "date: '$DATE'" >> build/actual-intelligence.md
  echo "author: 'Open Source Community'" >> build/actual-intelligence.md
  echo "toc: true" >> build/actual-intelligence.md
  echo "---" >> build/actual-intelligence.md
  echo "" >> build/actual-intelligence.md
  
  # Find and concatenate all markdown files in book directory
  # Sort alphabetically to ensure proper ordering
  find book -name "*.md" | sort | while read -r file; do
    echo "Adding $file to combined markdown"
    echo "\n\n" >> build/actual-intelligence.md  # Add newlines between files
    cat "$file" >> build/actual-intelligence.md
    
    # Add explicit page breaks after each file
    echo "\n\n\\newpage\n\n" >> build/actual-intelligence.md
  done
fi

# Step 3: Generate PDF with our template
echo "Generating PDF..."
if [ -n "$TEMP_TEMPLATE" ]; then
  # Use our custom template
  pandoc build/actual-intelligence.md -o build/actual-intelligence.pdf --template="$TEMP_TEMPLATE" --pdf-engine=xelatex --toc
else
  # Fallback to default pandoc styling
  pandoc build/actual-intelligence.md -o build/actual-intelligence.pdf --pdf-engine=xelatex --toc
fi

# Step 4: Check if PDF file exists and has content
if [ -f "build/actual-intelligence.pdf" ] && [ -s "build/actual-intelligence.pdf" ]; then
  echo "PDF file exists and has content."
else
  echo "WARNING: PDF file is missing or empty, creating a placeholder."
  echo "# Actual Intelligence - Placeholder PDF" > build/placeholder.md
  pandoc build/placeholder.md -o build/actual-intelligence.pdf --pdf-engine=xelatex
fi

# Step 5: Generate EPUB
echo "Generating EPUB file..."
pandoc build/actual-intelligence.md -o build/actual-intelligence.epub --toc
echo "EPUB file generated: build/actual-intelligence.epub"

# Step 6: Generate HTML file from Markdown files
echo "Generating HTML file..."
pandoc build/actual-intelligence.md -o build/actual-intelligence.html --standalone --toc --metadata title="Actual Intelligence"

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