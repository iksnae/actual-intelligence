# Book Builder Docker Image

This Docker image contains all the dependencies needed to build the "Actual Intelligence" book in various formats:

- PDF (via pandoc and LaTeX)
- EPUB
- MOBI (via Calibre)
- HTML

## Included Tools

- Node.js and npm
- Pandoc
- XeLaTeX (for PDF generation)
- Calibre (for MOBI conversion)
- Git
- Other build tools (rsync, curl, wget, make)

## Using the Image

### In GitHub Actions

The image is used automatically in our GitHub Actions workflow. See `.github/workflows/build-book.yml`.

### Running Locally

To use this image locally:

```bash
# Pull the image
docker pull ghcr.io/iksnae/book-builder:latest

# Run the container with your repository mounted
docker run -it --rm -v $(pwd):/app ghcr.io/iksnae/book-builder:latest bash

# Inside the container, you can run the build script
./build.sh
```

## Building the Image Locally

If you want to build the image locally:

```bash
# Build
docker build -t ghcr.io/iksnae/book-builder:latest .

# Run
docker run -it --rm -v $(pwd):/app ghcr.io/iksnae/book-builder:latest bash
```

## Troubleshooting

If you encounter issues with the build process:

1. Check if all dependencies are correctly installed in the Dockerfile
2. Verify that the build script has execution permissions (`chmod +x build.sh`)
3. Ensure all image paths in your Markdown files are correct
