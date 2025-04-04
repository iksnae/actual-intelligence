![cover](./art/image.jpg)

# Actual Intelligence

A practical, non-technical guide to using AI tools like ChatGPT in everyday life.

## 📚 Download the Book

### English Version

<div align="center">

[![Download PDF](https://img.shields.io/badge/Download-PDF%20Version-blue?style=for-the-badge&logo=adobe-acrobat-reader)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-en.pdf)
[![Download EPUB](https://img.shields.io/badge/Download-EPUB%20Version-green?style=for-the-badge&logo=apple)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-en.epub)
[![Download MOBI](https://img.shields.io/badge/Download-Kindle%20Version-orange?style=for-the-badge&logo=amazon)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-en.mobi)
[![Read Online](https://img.shields.io/badge/Read-Web%20Version-purple?style=for-the-badge&logo=html5)](https://iksnae.github.io/actual-intelligence/)

</div>

### Spanish Version (Versión en Español)

<div align="center">

[![Download PDF](https://img.shields.io/badge/Descargar-Versión%20PDF-blue?style=for-the-badge&logo=adobe-acrobat-reader)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-es.pdf)
[![Download EPUB](https://img.shields.io/badge/Descargar-Versión%20EPUB-green?style=for-the-badge&logo=apple)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-es.epub)
[![Download MOBI](https://img.shields.io/badge/Descargar-Versión%20Kindle-orange?style=for-the-badge&logo=amazon)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-es.mobi)
[![Read Online](https://img.shields.io/badge/Leer-Versión%20Web-purple?style=for-the-badge&logo=html5)](https://iksnae.github.io/actual-intelligence/es/)

</div>

### Japanese Version (日本語版)

<div align="center">

[![Download PDF](https://img.shields.io/badge/ダウンロード-PDF%20版-blue?style=for-the-badge&logo=adobe-acrobat-reader)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-ja.pdf)
[![Download EPUB](https://img.shields.io/badge/ダウンロード-EPUB%20版-green?style=for-the-badge&logo=apple)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-ja.epub)
[![Download MOBI](https://img.shields.io/badge/ダウンロード-Kindle%20版-orange?style=for-the-badge&logo=amazon)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence-ja.mobi)
[![Read Online](https://img.shields.io/badge/閲覧-Web%20版-purple?style=for-the-badge&logo=html5)](https://iksnae.github.io/actual-intelligence/ja/)

</div>

You can also view all previous versions and releases [here](https://github.com/iksnae/actual-intelligence/releases).

## About This Book

"Actual Intelligence" is designed to be a learning resource for people without technical backgrounds, helping them leverage AI in their personal and professional lives. Starting with ChatGPT as training wheels, this guide will help readers use AI to accomplish various goals.

## Available Languages

- **English**: Original version
- **Spanish (Español)**: Complete translation of Chapters 1 and 2
- **Japanese (日本語)**: Complete translation of Chapters 1 and 2

## Publisher

This book is published by Khaos Studios.

## Target Audience

This book is intended for all ages and backgrounds, with a focus on those who are curious about AI but may find the technology intimidating.

## Book Structure

The book is organized into five main parts:

1. **Getting Started** - Introduction to AI assistants and setting up a free ChatGPT account
2. **Building a Mental Model** - Understanding how these systems work in non-technical terms
3. **Practical Applications** - Using AI for personal assistance, learning, creativity, and research
4. **Hands-On Workshops** - Step-by-step examples with screenshots and customizable prompts
5. **Advanced Topics & Beyond** - Moving to paid tiers and introduction to other AI tools

## Building the Book

### Using the CLI (Recommended)

We now use the `book-tools` CLI directly. To build the book:

1. Install the CLI using our robust installation method:
   ```bash
   # Clone the repository
   git clone https://github.com/iksnae/book-tools.git ~/.book-tools
   
   # Make scripts executable
   cd ~/.book-tools/src
   chmod +x make-scripts-executable.sh
   ./make-scripts-executable.sh
   
   # Create wrapper script
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
   ```

2. Add the CLI to your PATH:
   ```bash
   export PATH="$HOME/.local/bin:$PATH"
   ```

3. Build the book:
   ```bash
   book-tools build --all-languages
   ```

4. For more options, use:
   ```bash
   book-tools help
   ```

Available commands include:
- `book-tools build` - Build the book in various formats
- `book-tools create` - Create a new book project
- `book-tools setup` - Setup the book environment
- `book-tools help` - Show help information

### Prerequisites

- Node.js
- Pandoc
- Calibre (for MOBI conversion)
- A text editor

### Building Locally

1. Clone this repository
2. Run `npm install` to install dependencies
3. Run `./build.sh` to build the book

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for details.

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Creating a Release

To create a new release that will automatically build and publish all book formats:

1. Make sure all your changes are committed and pushed to the main branch
2. Run the release script with the desired version number:
   ```bash
   ./tag-release.sh v1.0.0
   ```
3. The script will create a git tag and push it to GitHub
4. The GitHub Actions workflow will automatically build all book formats and create a release

You can find all releases on the [GitHub Releases page](https://github.com/iksnae/actual-intelligence/releases).

## 🛠️ Development Information

### GitHub Pages Deployment

The book is automatically deployed to GitHub Pages after each successful build. The deployment is handled by the GitHub Actions workflow in `.github/workflows/pages.yml`.

To manually trigger a deployment:
1. Go to the [Actions tab](https://github.com/iksnae/actual-intelligence/actions)
2. Select the "Deploy to GitHub Pages" workflow
3. Click "Run workflow" and select the branch to deploy from (usually `main`)

The HTML version will be available at:
- English: https://iksnae.github.io/actual-intelligence/
- Spanish: https://iksnae.github.io/actual-intelligence/es/
- Japanese: https://iksnae.github.io/actual-intelligence/ja/

## GitHub Pages Setup

For the GitHub Pages deployment to work correctly, please follow these steps:

1. Go to the repository settings: https://github.com/iksnae/actual-intelligence/settings/pages
2. Under "Build and deployment":
   - Source: Select "Deploy from a branch"
   - Branch: Select "gh-pages" and "/ (root)"
   - Click "Save"
3. Under "GitHub Pages visibility", select:
   - "Public" (if you want everyone to be able to view the page)
4. The workflow will automatically deploy to the gh-pages branch when code is pushed to main or a new tag is created
5. After the workflow completes, your site will be available at: https://iksnae.github.io/actual-intelligence/

**Note**: The first deployment will automatically create the gh-pages branch. After the workflow runs successfully, return to the Pages settings to select the gh-pages branch as your source.
