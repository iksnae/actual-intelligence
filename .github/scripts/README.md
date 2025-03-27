# Custom Scripts for Book Building

This directory contains custom scripts to enhance the book building process.

## post-install.sh

This script fixes the image support issue in the EPUB generation process. It runs after the main book-tools installation and:

1. Makes a backup of the original `build-language.sh` script
2. Modifies the script to use the dedicated `generate-epub.sh` instead of calling Pandoc directly
3. Ensures all scripts are executable

The modification ensures that:
- Images are properly extracted from the markdown source
- Referenced images are correctly included in the EPUB file
- The cover image is properly attached to the EPUB

## Usage

These scripts are automatically run by the custom-install.sh script in the parent directory. You don't need to run them manually. 