#!/bin/bash

# Actual Intelligence Book Builder
# Main entry point for building the book using book-tools

# Check if running in Docker
if [ -f /.dockerenv ]; then
  echo "Running in Docker container..."
else
  echo "Running locally, using Docker..."
  docker run --rm -v "$(pwd):/book" iksnae/book-builder:latest book-tools build "$@"
  exit $?
fi

# Install book-tools if not already installed
if ! command -v book-tools &> /dev/null; then
  echo "Installing book-tools..."
  curl -sSL https://raw.githubusercontent.com/iksnae/book-tools/main/install.sh | bash
fi

# Run book-tools build with all arguments passed to this script
book-tools build "$@"
