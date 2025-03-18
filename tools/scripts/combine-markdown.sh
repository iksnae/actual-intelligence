#!/bin/bash

# combine-markdown.sh - Combines markdown files for a specific language
# Usage: combine-markdown.sh [language] [output_path] [book_title] [book_subtitle]

set -e  # Exit on error

# Get arguments
LANGUAGE=${1:-en}
OUTPUT_PATH=${2:-build/actual-intelligence.md}
BOOK_TITLE=${3:-"Actual Intelligence"}
BOOK_SUBTITLE=${4:-"A Practical Guide to Using AI in Everyday Life"}

echo "📝 Combining markdown files for $LANGUAGE..."

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
  echo "cover-image: '$COVER_IMAGE'" >> "$OUTPUT_PATH"
fi

# Close the metadata block
cat >> "$OUTPUT_PATH" << EOF
---

EOF

# Find all chapter directories for the specified language
find "book/$LANGUAGE" -type d -name "chapter-*" | sort | while read -r chapter_dir; do
  echo "Processing chapter directory: $chapter_dir"
  
  # Look for title-page.md first if it exists (only for first chapter)
  if [ "$(basename "$chapter_dir")" = "chapter-01" ]; then
    title_page="book/$LANGUAGE/title-page.md"
    if [ -f "$title_page" ]; then
      echo "Adding title page from $title_page"
      cat "$title_page" >> "$OUTPUT_PATH"
      echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
    fi
  fi
  
  # Look for chapter introduction file
  if [ -f "$chapter_dir/00-introduction.md" ]; then
    echo "Adding chapter introduction from $chapter_dir/00-introduction.md"
    cat "$chapter_dir/00-introduction.md" >> "$OUTPUT_PATH"
    echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
  fi
  
  # Process all section files in order
  find "$chapter_dir" -maxdepth 1 -name "[0-9]*.md" | grep -v "00-introduction.md" | sort | while read -r section_file; do
    echo "Adding section from $section_file"
    # Add an explicit section header comment for better visibility in source
    echo -e "\n\n<!-- Start of section: $(basename "$section_file") -->\n" >> "$OUTPUT_PATH"
    cat "$section_file" >> "$OUTPUT_PATH"
    # Add explicit page break after each section
    echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
  done
done

# Process appendices if they exist
appendices_dir="book/$LANGUAGE/appendices"
if [ -d "$appendices_dir" ]; then
  echo "Processing appendices from $appendices_dir"
  
  echo -e "\n\n# Appendices\n\n" >> "$OUTPUT_PATH"
  
  find "$appendices_dir" -name "*.md" | sort | while read -r appendix_file; do
    echo "Adding appendix: $appendix_file"
    cat "$appendix_file" >> "$OUTPUT_PATH"
    echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
  done
fi

# Process glossary if it exists
glossary_file="book/$LANGUAGE/glossary.md"
if [ -f "$glossary_file" ]; then
  echo "Adding glossary from $glossary_file"
  echo -e "\n\n# Glossary\n\n" >> "$OUTPUT_PATH"
  cat "$glossary_file" >> "$OUTPUT_PATH"
  echo -e "\n\n\\newpage\n\n" >> "$OUTPUT_PATH"
fi

echo "✅ Markdown files combined into $OUTPUT_PATH"
