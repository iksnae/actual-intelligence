# Book Building Tools

This directory contains tools for building the book.

## Main Build Script

- `build.js` - The main Node.js script for building the book

## Usage

Run the build script with Node.js:

```
node build.js [options]
```

Options:
- `--all-languages` - Build the book in all available languages
- `--lang=<language-code>` - Build the book in a specific language

If no options are provided, the script will build the book in the default language (English).