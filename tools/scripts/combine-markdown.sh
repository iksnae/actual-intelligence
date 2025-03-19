#!/bin/bash

# combine-markdown.sh - Combines markdown files for a specific language
# Usage: combine-markdown.sh [language] [output_path] [book_title] [book_subtitle]

set -e  # Exit on error
set -x  # Enable debug mode to see commands

# Get arguments
LANGUAGE=${1:-en}
OUTPUT_PATH=${2:-build/actual-intelligence.md}
BOOK_TITLE=${3:-"Actual Intelligence"}
BOOK_SUBTITLE=${4:-"A Practical Guide to Using AI in Everyday Life"}

echo "📝 Combining markdown files for $LANGUAGE..."
echo "  - Output path: $OUTPUT_PATH"
echo "  - Book title: $BOOK_TITLE"
echo "  - Subtitle: $BOOK_SUBTITLE"

# Make sure the parent directory exists
mkdir -p "$(dirname "$OUTPUT_PATH")"

# Clear the file if it exists
true > "$OUTPUT_PATH"

# Add metadata header
cat > "$OUTPUT_PATH" << EOF
---
title: "$BOOK_TITLE"
subtitle: "$BOOK_SUBTITLE"
author: "Open Source Community"
publisher: "Khaos Studios"
language: "$LANGUAGE"
toc: true
EOF

# Add cover image metadata if a cover image exists
if [ -n "$COVER_IMAGE" ]; then
  echo "  - Using cover image: $COVER_IMAGE"
  echo "cover-image: '$COVER_IMAGE'" >> "$OUTPUT_PATH"
else
  echo "  - No cover image specified"
  
  # Try to find language-specific cover
  if [ -f "book/$LANGUAGE/images/cover.png" ]; then
    echo "  - Found language-specific cover: book/$LANGUAGE/images/cover.png"
    echo "cover-image: 'book/$LANGUAGE/images/cover.png'" >> "$OUTPUT_PATH"
  elif [ -f "art/cover.png" ]; then
    echo "  - Found art/cover.png"
    echo "cover-image: 'art/cover.png'" >> "$OUTPUT_PATH"
  elif [ -f "book/images/cover.png" ]; then
    echo "  - Found book/images/cover.png"
    echo "cover-image: 'book/images/cover.png'" >> "$OUTPUT_PATH"
  fi
fi

# Close the metadata block
cat >> "$OUTPUT_PATH" << EOF
---

EOF

# Check if the language directory exists
if [ ! -d "book/$LANGUAGE" ]; then
  echo "⚠️ WARNING: Language directory book/$LANGUAGE does not exist!"
  echo "Available languages:"
  ls -la book/ | grep -v "^total" | grep "^d"
  exit 1
fi

# Find all chapter directories for the specified language
echo "Looking for chapter directories in book/$LANGUAGE"
CHAPTER_DIRS=$(find "book/$LANGUAGE" -type d -name "chapter-*" | sort)

if [ -z "$CHAPTER_DIRS" ]; then
  echo "⚠️ WARNING: No chapter directories found for language $LANGUAGE in book/$LANGUAGE"
  echo "Available directories:"
  ls -la "book/$LANGUAGE"
  exit 1
fi

echo "Found chapter directories:"
echo "$CHAPTER_DIRS"

# Process each chapter directory
echo "$CHAPTER_DIRS" | while read -r chapter_dir; do
  echo "Processing chapter directory: $chapter_dir"
  
  # Look for title-page.md first if it exists (only for first chapter)
  if [ "$(basename "$chapter_dir")" = "chapter-01" ]; then
    title_page="book/$LANGUAGE/title-page.md"
    if [ -f "$title_page" ]; then
      echo "Adding title page from $title_page"
      cat "$title_page" >> "$OUTPUT_PATH"
      echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
    else
      echo "  - No title page found at $title_page"
    fi
  fi
  
  # Look for chapter introduction file
  if [ -f "$chapter_dir/00-introduction.md" ]; then
    echo "Adding chapter introduction from $chapter_dir/00-introduction.md"
    cat "$chapter_dir/00-introduction.md" >> "$OUTPUT_PATH"
    echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
  else
    echo "  - No introduction file found in $chapter_dir"
  fi
  
  # Process all section files in order
  echo "Searching for section files in $chapter_dir"
  SECTION_FILES=$(find "$chapter_dir" -maxdepth 1 -name "[0-9]*.md" | grep -v "00-introduction.md" | sort)
  
  if [ -z "$SECTION_FILES" ]; then
    echo "  - No section files found in $chapter_dir"
  else
    echo "  - Found sections:"
    echo "$SECTION_FILES"
    
    echo "$SECTION_FILES" | while read -r section_file; do
      echo "Adding section from $section_file"
      # Add an explicit section header comment for better visibility in source
      echo -e "\n\n<!-- Start of section: $(basename "$section_file") -->\n" >> "$OUTPUT_PATH"
      cat "$section_file" >> "$OUTPUT_PATH"
      # Add explicit page break after each section
      echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
    done
  fi
done

# Process appendices if they exist
appendices_dir="book/$LANGUAGE/appendices"
if [ -d "$appendices_dir" ]; then
  echo "Processing appendices from $appendices_dir"
  
  APPENDIX_FILES=$(find "$appendices_dir" -name "*.md" | sort)
  
  if [ -n "$APPENDIX_FILES" ]; then
    echo -e "\n\n# Appendices\n\n" >> "$OUTPUT_PATH"
    
    echo "$APPENDIX_FILES" | while read -r appendix_file; do
      echo "Adding appendix: $appendix_file"
      cat "$appendix_file" >> "$OUTPUT_PATH"
      echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
    done
  else
    echo "  - No appendix files found in $appendices_dir"
  fi
else
  echo "  - No appendices directory found for $LANGUAGE"
fi

# Process glossary if it exists
glossary_file="book/$LANGUAGE/glossary.md"
if [ -f "$glossary_file" ]; then
  echo "Adding glossary from $glossary_file"
  echo -e "\n\n# Glossary\n\n" >> "$OUTPUT_PATH"
  cat "$glossary_file" >> "$OUTPUT_PATH"
  echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
else
  echo "  - No glossary file found for $LANGUAGE"
fi

# Check the final output
if [ -s "$OUTPUT_PATH" ]; then
  FILESIZE=$(du -k "$OUTPUT_PATH" | cut -f1)
  echo "✅ Markdown files combined into $OUTPUT_PATH (${FILESIZE}KB)"
  
  # Count sections as a sanity check
  SECTION_COUNT=$(grep -c "<!-- Start of section:" "$OUTPUT_PATH")
  echo "  - Combined $SECTION_COUNT sections"
else
  echo "⚠️ WARNING: Output file $OUTPUT_PATH is empty or wasn't created properly"
  exit 1
fi

# Disable debug mode
set +x
