#!/bin/bash
set -e

# Define colors for output
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Running post-installation script to fix image support...${NC}"

# Variables
BOOK_TOOLS_DIR="${HOME}/.book-tools"
BUILD_LANGUAGE_SCRIPT="${BOOK_TOOLS_DIR}/src/scripts/build-language.sh"

# Check if build-language.sh exists
if [ ! -f "$BUILD_LANGUAGE_SCRIPT" ]; then
    echo "❌ Error: Could not find build-language.sh at ${BUILD_LANGUAGE_SCRIPT}"
    exit 1
fi

# Make a backup of the original file
cp "$BUILD_LANGUAGE_SCRIPT" "${BUILD_LANGUAGE_SCRIPT}.bak"

# Replace the EPUB generation section in build-language.sh
if grep -q "pandoc \"\$COMBINED_MD\" .*--to epub" "$BUILD_LANGUAGE_SCRIPT"; then
    # Use sed to replace the EPUB generation part
    # This replaces from "# Check for cover image" to the line with "exit 1" inside the EPUB section
    sed -i.tmp '/# Check for cover image/,/exit 1/c\
    # Use the dedicated EPUB generation script for better image handling\
    SCRIPTS_PATH=$(dirname "$0")\
    "$SCRIPTS_PATH/generate-epub.sh" \\\
        "$LANG" \\\
        "$COMBINED_MD" \\\
        "$PROJECT_ROOT/build/$LANG/$BOOK_TITLE-$LANG.epub" \\\
        "$BOOK_TITLE" \\\
        "$BOOK_SUBTITLE" \\\
        "resources" \\\
        "$PROJECT_ROOT"' "$BUILD_LANGUAGE_SCRIPT"
    
    # Remove the temporary file
    rm -f "${BUILD_LANGUAGE_SCRIPT}.tmp"
    
    echo -e "${GREEN}✅ Successfully patched build-language.sh to use generate-epub.sh script${NC}"
else
    echo "⚠️ Could not find EPUB generation section in build-language.sh. The script might have changed."
    echo "Please manually update the file to use generate-epub.sh instead of calling pandoc directly."
fi

# Ensure all scripts are executable
find "${BOOK_TOOLS_DIR}/src/scripts" -name "*.sh" -exec chmod +x {} \;

echo -e "${GREEN}✅ Post-installation complete. Image support should now be fixed.${NC}" 