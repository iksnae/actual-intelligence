# Actual Intelligence

A practical, non-technical guide to using AI tools like ChatGPT in everyday life.

This project uses the `iksnae/book-builder` Docker image for building and publishing the book in various formats.

## Book Description

Actual Intelligence is a community-driven book designed to help everyday people understand and use artificial intelligence tools effectively in their daily lives. The book takes a practical, non-technical approach to explaining AI capabilities and limitations.

## Building the Book

The book is automatically built using GitHub Actions whenever changes are pushed to the repository. The build process uses the `iksnae/book-builder` Docker image which includes all necessary tools for generating PDF, EPUB, MOBI, and HTML versions of the book.

### Prerequisites

If you want to build the book locally, you can:

1. Use Docker:
   ```bash
   docker run -v $(pwd):/workspace iksnae/book-builder ./build.sh
   ```

2. Or install the required dependencies manually:
   ```bash
   npm install
   sudo apt-get install pandoc texlive-xetex calibre
   ```

### Build Process

Run the build script:
```bash
chmod +x build.sh
./build.sh
```

The built files will be available in the `build` directory.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
