# Book Building Scripts

## Overview

This directory contains modular scripts for building the Actual Intelligence book. Each script handles a specific aspect of the build process, making it easier to debug, maintain, and extend.

## Script Organization

The scripts are organized to mirror the workflow phases:

1. **Setup Phase**
   - `setup.sh`: Prepares the build environment
   - `copy-images.sh`: Copies images to build directory

2. **Build Phase**
   - `build.sh`: Main entry point for the build process
   - `build-language.sh`: Builds a specific language version
   - `combine-markdown.sh`: Combines markdown files into a single document

3. **Format Generation**
   - `generate-pdf.sh`: Creates PDF version
   - `generate-epub.sh`: Creates EPUB version
   - `generate-mobi.sh`: Creates MOBI (Kindle) version
   - `generate-html.sh`: Creates HTML version

## Usage

### Basic Usage

For most users, simply run the main build script:

```bash
./build.sh
```

This will build the English version of the book by default.

### Advanced Options

1. **Build all languages**:
   ```bash
   ./build.sh --all-languages
   ```

2. **Build a specific language**:
   ```bash
   ./build.sh --lang=es  # Build Spanish version
   ```

3. **Skip specific formats**:
   ```bash
   ./build.sh --skip-pdf --skip-mobi  # Skip PDF and MOBI generation
   ```

4. **Combine options**:
   ```bash
   ./build.sh --all-languages --skip-mobi
   ```

## Debugging

If you encounter issues with a specific part of the build process, you can run individual scripts directly to debug the problem:

```bash
# Debug PDF generation for Spanish
source tools/scripts/setup.sh
source tools/scripts/build-language.sh es --skip-epub --skip-mobi --skip-html
```

This modular approach makes it easier to isolate and fix issues without running the entire build process.

## Adding New Languages

To add a new language:

1. Add the language code to the `LANGUAGES` array in `build.sh`
2. Create the corresponding directory structure in `book/[language-code]/`
3. Update titles and subtitles in `build-language.sh`

## Adding New Output Formats

To add a new output format:

1. Create a new script in `tools/scripts/generate-[format].sh`
2. Update `build-language.sh` to include the new format
3. Add a corresponding skip flag (e.g., `--skip-[format]`) for consistency
