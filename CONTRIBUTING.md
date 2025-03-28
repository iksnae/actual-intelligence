# Contributing to "Actual Intelligence"

Thank you for your interest in contributing to "Actual Intelligence"! This guide will help you understand how to contribute to this book project.

## Project Overview

"Actual Intelligence" is a practical guide designed to help non-technical people use AI tools like ChatGPT in their everyday lives. The book aims to be accessible, practical, and immediately useful to readers of all ages and backgrounds.

## How to Contribute

### Content Contributions

1. **Chapter Content**: Each chapter is organized into markdown files in the `book/[language]/chapter-XX/` directories.
2. **Activities and Examples**: We need practical, real-world examples and activities for readers to try.
3. **Case Studies**: Real-world stories of how AI tools have been used effectively by non-technical people.
4. **Illustrations and Diagrams**: Concepts that could benefit from visual explanation.

### Technical Contributions

1. **Build Process Improvements**: Enhancements to the book building process.
2. **Translations**: Help translate the book into other languages.
3. **Website and Distribution**: Improvements to how the book is distributed and accessed.

## Getting Started

1. **Fork the Repository**: Start by forking the repository to your own GitHub account.
2. **Clone the Repository**: Clone the forked repository to your local machine.
3. **Create a Branch**: Create a branch for your contribution.
4. **Make Changes**: Make your desired changes or additions.
5. **Test Locally**: If possible, build the book locally to verify your changes.
6. **Submit a Pull Request**: Push your changes and submit a pull request.

## Directory Structure

```
actual-intelligence/
├── book/
│   ├── en/              # English content
│   │   ├── chapter-01/  # Chapter 1 content
│   │   │   ├── images/  # Chapter-specific images and image descriptions
│   │   ├── chapter-02/  # Chapter 2 content
│   │   └── ...
│   └── images/          # Common images
├── tools/               # Build tools
└── README.md            # Project README
```

## Content Guidelines

1. **Accessibility**: Content should be accessible to readers with no technical background.
2. **Practicality**: Focus on practical applications and real-world usage.
3. **Examples**: Include concrete examples that readers can try immediately.
4. **Progressive Learning**: Build concepts progressively, don't introduce advanced topics too early.
5. **Language**: Use clear, simple language and avoid technical jargon when possible.

## Image Description Process

As part of our drafting workflow (where we use language models extensively), we follow this process for images:

1. **Create Image Descriptions First**: Before actual images are created, write detailed descriptions in text files within the `chapter-XX/images/` directories.
2. **Naming Convention**: Use the same base filename for the description and the future image:
   - Image: `concept-name.jpg` or `concept-name.png`
   - Description: `concept-name.txt`
3. **Description Content**: Each description should include:
   - What elements the image should contain
   - What the image is meant to convey
   - Any specific details about layout, style, or appearance
   - How the image connects to the book's content
4. **Accessibility**: These descriptions also serve as alt text for accessibility purposes.

This approach allows us to plan visual content during the writing phase, while the actual artwork can be created separately by designers.

## Markdown Formatting

Content files use Markdown with the following conventions:

1. **Chapter Titles**: Use `# Chapter X: Title`
2. **Section Headings**: Use `## Section Title`
3. **Subsections**: Use `### Subsection Title`
4. **Code Blocks**: Use triple backticks for code samples
5. **Lists**: 
   - Use dashes (`-`) for bulleted lists, not asterisks
   - Always precede lists with an empty line
   - Indent sublists with 3 spaces
6. **Images**:
   - Use the format: `![](./path/to/image.jpg){ width=90% }`
   - Include descriptive alt text when needed: `![Alt text](./path/to/image.jpg){ width=90% }`
   - Store images in the appropriate `images/` directory
7. **Activity Blocks**: Use the following format for activities:

```markdown
## Try This Now

1. Step one...
2. Step two...
3. Step three...
```

## Pull Request Process

1. **Description**: Provide a clear description of your changes.
2. **Issue Link**: Reference any relevant issues.
3. **Documentation**: Update documentation if needed.
4. **Review**: Be open to feedback and make requested changes.

## Code of Conduct

Please note that this project adheres to a Code of Conduct. By participating, you are expected to uphold this code.

## Questions?

If you have any questions or need help, please open an issue in the repository.

Thank you for contributing to make AI more accessible to everyone!
