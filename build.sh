#!/bin/bash

# Actual Intelligence Book Builder
# Main entry point for building the book using book-tools

# Check if running in Docker
if [ -f /.dockerenv ]; then
  echo "Running in Docker container..."
else
  echo "Running locally, using Docker..."
  docker run --rm -v "$(pwd):/book" iksnae/book-builder:latest /bin/bash -c "
    # Setup book-tools
    cd /book
    npm install -g iksnae/book-tools
    book build --all-languages --verbose
  "
  exit $?
fi

# If we're here, we're running in the container
# Setup book-tools CLI if not already installed
if ! command -v book &> /dev/null; then
  echo "Setting up book-tools CLI..."
  npm install -g iksnae/book-tools
fi

# Run book CLI with all arguments passed to this script
cd "$(dirname "$0")"
echo "Building book with book-tools CLI..."
book build --all-languages --verbose
