# EPUB Image Inclusion Troubleshooting Guide

This guide provides steps to troubleshoot and resolve the issue with images not being included in EPUB files when building the book in Docker.

## Problem Description

- The book builds successfully in the Docker container
- EPUB files are generated without errors
- However, the resulting EPUB files do not include images (file size is around 2.17MB instead of the expected 12.7MB)
- The issue began after refactoring from a monolithic script to modular scripts

## Diagnostic Tools

We've provided several diagnostic scripts in this directory:

1. `test-epub-images.sh` - A script that tests multiple Pandoc commands to see which one works for image inclusion
2. `old-working-approach.sh` - Recreates the approach from commit f5b41647 that was known to work

## Troubleshooting Steps

### 1. Verify Image Availability

First, ensure that images are available in the expected locations:

```bash
find book -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.svg" | sort
find build/images -type f | sort
```

### 2. Run the Diagnostic Test Script

Run the diagnostic script to test various Pandoc configurations:

```bash
# Make script executable
chmod +x tools/debug/test-epub-images.sh

# Run it
./tools/debug/test-epub-images.sh
```

This will create multiple EPUB files with different Pandoc options. Compare their file sizes to determine which approach works:

```bash
du -k test-epub/*.epub
```

Look for the largest file size, which likely indicates successful image inclusion.

### 3. Try the Known Working Approach

Run the script that recreates the previously working approach:

```bash
# Make script executable
chmod +x tools/debug/old-working-approach.sh

# Run it
./tools/debug/old-working-approach.sh
```

Check the resulting EPUB file size:

```bash
du -k build/actual-intelligence.epub
```

### 4. Verify Pandoc Version and Capabilities

Pandoc's behavior regarding image inclusion in EPUBs can vary between versions:

```bash
pandoc --version
```

Some flags work differently in different versions:
- `--extract-media` (newer versions)
- `--self-contained` vs. `--embed-resources` (version dependent)

### 5. Manual Inspection of EPUB Content

You can inspect the contents of the EPUB file:

```bash
# First, rename it to .zip
cp build/actual-intelligence.epub build/actual-intelligence.zip

# Then extract it
mkdir epub-contents
unzip build/actual-intelligence.zip -d epub-contents

# Look for image files
find epub-contents -type f | grep -i "\\.png\\|\\.jpg\\|\\.jpeg\\|\\.svg"
```

### 6. Known Solutions to Try

Based on our testing, these approaches might resolve the issue:

#### A. Update the generate-epub.sh script

After identifying which Pandoc command works from the diagnostic tests, update your `tools/scripts/generate-epub.sh` script to use that specific approach.

#### B. Fix Image Paths in Markdown

Sometimes the issue is with relative image paths in the markdown:

```bash
# Create a modified markdown file with adjusted image paths
cp build/actual-intelligence.md build/fixed-paths.md
sed -i 's|!\[\([^]]*\)\](\([^)]*\))|![\1](build/images/\2)|g' build/fixed-paths.md

# Try building EPUB with this file
pandoc build/fixed-paths.md -o build/test-epub.epub --extract-media=build/media
```

#### C. Use the Direct Approach from the Working Commit

If the diagnostic tests show that the old approach works, consider temporarily reverting to a monolithic script for EPUB generation until the module issues are resolved.

## Reporting Results

After trying the above steps, please document:

1. Which Pandoc command successfully included images
2. The file size of the successful EPUB
3. Any error messages encountered

This information will help us permanently fix the EPUB generation process.
