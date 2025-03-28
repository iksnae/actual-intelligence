#!/bin/bash

# enhance-html.sh - Improve HTML files after generation
# Usage: enhance-html.sh [html_file]

set -e  # Exit on error

# Get arguments
HTML_FILE=${1:-build/actual-intelligence.html}

echo "🎨 Enhancing HTML file: $HTML_FILE"

# Check if file exists
if [ ! -f "$HTML_FILE" ]; then
  echo "❌ Error: HTML file $HTML_FILE does not exist"
  exit 1
fi

# Directory containing the HTML file
HTML_DIR=$(dirname "$HTML_FILE")

# Make sure JS and CSS files are copied
for FILE in templates/book.js templates/book.css templates/images.css; do
  if [ -f "$FILE" ]; then
    cp "$FILE" "$HTML_DIR/"
    echo "✅ Copied $(basename $FILE) to output directory"
  else
    echo "⚠️ Warning: $FILE not found"
  fi
done

# Check if JavaScript is included
if ! grep -q "<script src=\"book.js\"></script>" "$HTML_FILE"; then
  echo "Adding JavaScript reference to HTML file..."
  sed -i.bak 's|</body>|<script src="book.js"></script>\n</body>|' "$HTML_FILE"
  rm -f "${HTML_FILE}.bak"
fi

# Check if CSS files are included
if ! grep -q "<link rel=\"stylesheet\" href=\"book.css\"" "$HTML_FILE"; then
  echo "Adding book.css reference to HTML file..."
  sed -i.bak 's|</head>|<link rel="stylesheet" href="book.css">\n</head>|' "$HTML_FILE"
  rm -f "${HTML_FILE}.bak"
fi

if ! grep -q "<link rel=\"stylesheet\" href=\"images.css\"" "$HTML_FILE"; then
  echo "Adding images.css reference to HTML file..."
  sed -i.bak 's|</head>|<link rel="stylesheet" href="images.css">\n</head>|' "$HTML_FILE"
  rm -f "${HTML_FILE}.bak"
fi

# Add meta viewport tag if not present
if ! grep -q "<meta name=\"viewport\"" "$HTML_FILE"; then
  echo "Adding viewport meta tag..."
  sed -i.bak 's|<head>|<head>\n  <meta name="viewport" content="width=device-width, initial-scale=1.0, user-scalable=yes" />|' "$HTML_FILE"
  rm -f "${HTML_FILE}.bak"
fi

# Improve image captions by converting markdown-style captions (image + em) to more semantic HTML
echo "Improving image captions..."
python3 -c '
import re
import sys
with open(sys.argv[1], "r") as f:
    html = f.read()

# Find patterns where an image is immediately followed by an <em> tag (common markdown caption)
pattern = r"(<img[^>]+>)\s*<em>([^<]+)</em>"
replacement = r"<figure>\1<figcaption>\2</figcaption></figure>"
html = re.sub(pattern, replacement, html)

with open(sys.argv[1], "w") as f:
    f.write(html)
' "$HTML_FILE"

echo "✅ HTML enhancement completed for $HTML_FILE" 