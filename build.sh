#!/bin/bash

# Actual Intelligence Book Builder
# Main entry point for building the book using book-tools

# Function to install book-tools reliably
install_book_tools() {
  echo "Installing book-tools..."
  # Clone the repository directly
  git clone https://github.com/iksnae/book-tools.git ~/.book-tools
  
  # Make scripts executable
  cd ~/.book-tools/src
  chmod +x make-scripts-executable.sh
  ./make-scripts-executable.sh
  
  # Create the bin directory and wrapper script
  mkdir -p ~/.local/bin
  
  cat > ~/.local/bin/book-tools << 'EOF'
#!/bin/bash

BOOK_TOOLS_DIR="$HOME/.book-tools"
COMMAND=$1
shift

# Check for commands
case "$COMMAND" in
  create)
    "$BOOK_TOOLS_DIR/src/scripts/create-book.sh" "$@"
    ;;
  build)
    # Just run the build script without any directory parameter
    "$BOOK_TOOLS_DIR/src/scripts/build.sh" "$@"
    ;;
  build-docker)
    echo "Docker build not available in this installation"
    exit 1
    ;;
  setup)
    "$BOOK_TOOLS_DIR/src/scripts/setup.sh" "$@"
    ;;
  help)
    echo "Usage: book-tools COMMAND [options]"
    echo ""
    echo "Commands:"
    echo "  create    Create a new book project"
    echo "  build     Build a book in the current directory"
    echo "  setup     Setup the book environment"
    echo "  help      Show this help message"
    ;;
  *)
    echo "Unknown command: $COMMAND"
    echo "Use 'book-tools help' for usage information"
    exit 1
    ;;
esac
EOF
  
  chmod +x ~/.local/bin/book-tools
  echo "book-tools installed successfully!"
}

# Check if running in Docker
if [ -f /.dockerenv ]; then
  echo "Running in Docker container..."
else
  echo "Running locally, using Docker..."
  docker run --rm -v "$(pwd):/book" iksnae/book-builder:latest /bin/bash -c "
    # Setup book-tools using our custom installation function
    cd /book
    source ./build.sh
    install_book_tools
    export PATH=\"\$HOME/.local/bin:\$PATH\"
    book-tools build --all-languages --verbose
  "
  exit $?
fi

# If we're here, we're running in the container
# Setup book-tools CLI if not already installed
if ! command -v book-tools &> /dev/null; then
  echo "Setting up book-tools CLI..."
  install_book_tools
  export PATH="$HOME/.local/bin:$PATH"
fi

# Run book CLI with all arguments passed to this script
cd "$(dirname "$0")"
echo "Building book with book-tools CLI..."
export PATH="$HOME/.local/bin:$PATH"
book-tools build --all-languages --verbose
