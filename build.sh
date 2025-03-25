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
    mkdir -p ~/.local/bin
    git clone https://github.com/iksnae/book-tools.git ~/.book-tools
    cd ~/.book-tools
    chmod +x tools/scripts/*.sh
    export PATH=\"\$HOME/.local/bin:\$PATH\"
    cd /book
    pwd
    ls -la
    ~/.book-tools/tools/scripts/build-language.sh --all-languages
  "
  exit $?
fi

# If we're here, we're running in the container
# Setup book-tools if not already installed
if ! command -v book-tools &> /dev/null; then
  echo "Setting up book-tools..."
  mkdir -p ~/.local/bin
  git clone https://github.com/iksnae/book-tools.git ~/.book-tools
  cd ~/.book-tools
  chmod +x tools/scripts/*.sh
  export PATH="$HOME/.local/bin:$PATH"
  echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> ~/.bashrc
fi

# Run book-tools build with all arguments passed to this script
export PATH="$HOME/.local/bin:$PATH"
# Ensure we're in the correct directory
cd "$(dirname "$0")"
pwd
ls -la
~/.book-tools/tools/scripts/build-language.sh --all-languages
