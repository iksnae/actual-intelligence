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

# Find all chapter directories for the specified language and sort them numerically
find "book/$LANGUAGE" -type d -name "chapter-*" | sort -V | while read -r chapter_dir; do
  echo "Processing chapter directory: $chapter_dir"
  
  # Look for title-page.md first if it exists (only for first chapter)
  if [ "$(basename "$chapter_dir")" = "chapter-01" ]; then
    title_page="book/$LANGUAGE/title-page.md"
    if [ -f "$title_page" ]; then
      echo "Adding title page from $title_page"
      cat "$title_page" >> "$OUTPUT_PATH"
      # No additional page break needed
    fi
  fi
  
  # Look for chapter introduction file
  if [ -f "$chapter_dir/00-introduction.md" ]; then
    echo "Adding chapter introduction from $chapter_dir/00-introduction.md"
    cat "$chapter_dir/00-introduction.md" >> "$OUTPUT_PATH"
    # No additional page break needed
  fi
  
  # Process all section files in correct numeric order
  # Find all numeric prefixed markdown files (excluding introduction) and sort them properly
  find "$chapter_dir" -maxdepth 1 -type f -name "[0-9]*.md" | grep -v "00-introduction.md" | sort -V | while read -r section_file; do
    echo "Adding section from $section_file"
    # Add an explicit section header comment for better visibility in source
    echo -e "\n\n<!-- Start of section: $(basename "$section_file") -->\n" >> "$OUTPUT_PATH"
    cat "$section_file" >> "$OUTPUT_PATH"
    # No additional page break needed
  done
done

# Process appendices if they exist, ensuring numeric sorting
appendices_dir="book/$LANGUAGE/appendices"
if [ -d "$appendices_dir" ]; then
  echo "Processing appendices from $appendices_dir"
  
  echo -e "\n\n# Appendices\n\n" >> "$OUTPUT_PATH"
  
  find "$appendices_dir" -type f -name "*.md" | sort -V | while read -r appendix_file; do
    echo "Adding appendix: $appendix_file"
    cat "$appendix_file" >> "$OUTPUT_PATH"
    # Only add page break if file doesn't already have one
    if ! grep -q '<div style="page-break-after: always;"></div>' "$appendix_file"; then
      echo -e "\n\n---\n\n<div style=\"page-break-after: always;\"></div>\n\n" >> "$OUTPUT_PATH"
    fi
  done
fi

# Process glossary if it exists
glossary_file="book/$LANGUAGE/glossary.md"
if [ -f "$glossary_file" ]; then
  echo "Adding glossary from $glossary_file"
  echo -e "\n\n# Glossary\n\n" >> "$OUTPUT_PATH"
  cat "$glossary_file" >> "$OUTPUT_PATH"
  # Only add page break if file doesn't already have one
  if ! grep -q '<div style="page-break-after: always;"></div>' "$glossary_file"; then
    echo -e "\n\n---\n\n<div style=\"page-break-after: always;\"></div>\n\n" >> "$OUTPUT_PATH"
  fi
fi

echo "✅ Markdown files combined into $OUTPUT_PATH"
