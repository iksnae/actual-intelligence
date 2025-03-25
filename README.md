![cover](./art/image.png)

# Actual Intelligence

A practical, non-technical guide to using AI tools like ChatGPT in everyday life.

## 📚 Download the Book

### English Version

<div align="center">

[![Download PDF](https://img.shields.io/badge/Download-PDF%20Version-blue?style=for-the-badge&logo=adobe-acrobat-reader)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence.pdf)
[![Download EPUB](https://img.shields.io/badge/Download-EPUB%20Version-green?style=for-the-badge&logo=apple)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence.epub)
[![Download MOBI](https://img.shields.io/badge/Download-Kindle%20Version-orange?style=for-the-badge&logo=amazon)](https://github.com/iksnae/actual-intelligence/releases/latest/download/actual-intelligence.mobi)
[![Read Online](https://img.shields.io/badge/Read-Web%20Version-purple?style=for-the-badge&logo=html5)](https://iksnae.github.io/actual-intelligence/)

</div>

### Spanish Version (Versión en Español)

<div align="center">

[![Download PDF](https://img.shields.io/badge/Descargar-Versión%20PDF-blue?style=for-the-badge&logo=adobe-acrobat-reader)](https://github.com/iksnae/actual-intelligence/releases/latest/download/inteligencia-real.pdf)
[![Download EPUB](https://img.shields.io/badge/Descargar-Versión%20EPUB-green?style=for-the-badge&logo=apple)](https://github.com/iksnae/actual-intelligence/releases/latest/download/inteligencia-real.epub)
[![Download MOBI](https://img.shields.io/badge/Descargar-Versión%20Kindle-orange?style=for-the-badge&logo=amazon)](https://github.com/iksnae/actual-intelligence/releases/latest/download/inteligencia-real.mobi)
[![Read Online](https://img.shields.io/badge/Leer-Versión%20Web-purple?style=for-the-badge&logo=html5)](https://iksnae.github.io/actual-intelligence/es/)

</div>

You can also view all previous versions and releases [here](https://github.com/iksnae/actual-intelligence/releases).

## About This Book

"Actual Intelligence" is designed to be a learning resource for people without technical backgrounds, helping them leverage AI in their personal and professional lives. Starting with ChatGPT as training wheels, this guide will help readers use AI to accomplish various goals.

## Available Languages

- **English**: Original version
- **Spanish (Español)**: Complete translation of Chapter 1

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

1. Clone the book-tools repository:
   ```bash
   git clone https://github.com/iksnae/book-tools.git ~/.book-tools
   ```

2. Make the scripts executable:
   ```bash
   chmod +x ~/.book-tools/src/scripts/*.sh
   chmod +x ~/.book-tools/bin/book.js
   ```

3. Create a symlink to the CLI:
   ```bash
   mkdir -p ~/.local/bin
   ln -s ~/.book-tools/bin/book.js ~/.local/bin/book
   chmod +x ~/.local/bin/book
   export PATH="$HOME/.local/bin:$PATH"
   ```

4. Build the book:
   ```bash
   book build --all-languages
   ```

5. For more options, use:
   ```bash
   book --help
   ```

Available commands include:
- `book build` - Build the book in various formats
- `book interactive` - Interactive build process
- `book create-chapter` - Create a new chapter
- `book check-chapter` - Check a chapter structure
- `book info` - Display book information
- `book clean` - Clean build artifacts
- `book validate` - Check configuration and dependencies

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
