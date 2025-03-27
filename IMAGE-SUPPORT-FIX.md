# EPUB Image Support Fix

## Issue Description

After migrating the build dependencies to a custom solution using `book-tools` and the Docker image `book-builder`, support for cover and in-book images in EPUB files was lost. Images that were previously included in the EPUB file were no longer being embedded correctly.

## Root Cause

The issue was in the way the EPUB generation was handled in the `build-language.sh` script. It used a direct pandoc command that did not properly handle image extraction and inclusion, especially for images referenced in markdown files but located in various directories.

## Solution

The fix implements the following changes:

1. The `.github/scripts/post-install.sh` script was created to patch the book-tools installation by modifying the `build-language.sh` script to use the dedicated `generate-epub.sh` script instead of calling pandoc directly.

2. The custom installation script (`.github/custom-install.sh`) was updated to run this post-installation step.

3. The `generate-epub.sh` script contains enhanced logic for:
   - Finding images referenced in markdown
   - Copying those images to an accessible location
   - Setting up proper resource paths
   - Ensuring the cover image is correctly attached

## How to Apply the Fix

The fix is automatically applied during the build process in GitHub Actions. The custom installation script runs the post-installation script which modifies the book-tools code as needed.

### Manual Testing

To test the fix locally:

1. Run the test script:
   ```
   ./test-epub-images.sh
   ```

2. This will create a test book with images and verify that they are properly included in the EPUB file.

### Verifying the Fix

After building the book, you can verify the fix by:

1. Checking that the EPUB file has a reasonable size (should be larger than a few KB)
2. Opening the EPUB file in an e-reader and confirming that images appear
3. Using a utility to extract the EPUB contents and verifying image files are present:
   ```
   unzip -l build/en/Actual\ Intelligence-en.epub | grep -E "\.jpg|\.png|\.svg"
   ```

## References

- The original working implementation was from commit `5fd450bb61c8aeb167441079f4df67480f29ef86`
- The `generate-epub.sh` script in the book-tools repo contains the enhanced image extraction logic 