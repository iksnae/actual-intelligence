/**
 * Fix code blocks in markdown files
 * 
 * This script processes markdown files to ensure code blocks are properly
 * formatted for line wrapping in PDF output.
 */

const fs = require('fs');
const path = require('path');
const { glob } = require('glob');

// Configuration
const MAX_LINE_LENGTH = 80; // Maximum line length for code blocks

/**
 * Process a single markdown file
 * @param {string} filePath Path to the markdown file
 */
function processFile(filePath) {
  console.log(`Processing ${filePath}...`);
  let content = fs.readFileSync(filePath, 'utf8');
  let modified = false;

  // Find all code blocks
  const codeBlockRegex = /```([a-zA-Z0-9]*)\n([\s\S]*?)```/g;
  const newContent = content.replace(codeBlockRegex, (match, language, code) => {
    // Process the code to ensure proper wrapping
    const processedCode = processCoreBlock(code, language);
    
    // Only mark as modified if something changed
    if (processedCode !== code) {
      modified = true;
    }
    
    return '```' + language + '\n' + processedCode + '```';
  });

  // Only write the file if it was modified
  if (modified) {
    fs.writeFileSync(filePath, newContent, 'utf8');
    console.log(`Updated ${filePath}`);
  } else {
    console.log(`No changes needed for ${filePath}`);
  }
}

/**
 * Process a code block to ensure proper wrapping
 * @param {string} code The code block content
 * @param {string} language The code language
 * @returns {string} The processed code
 */
function processCoreBlock(code, language) {
  // Split into lines
  const lines = code.split('\n');
  const processedLines = [];

  for (let line of lines) {
    // Skip comment lines and empty lines
    if (line.trim().startsWith('//') || line.trim().startsWith('#') || line.trim() === '') {
      processedLines.push(line);
      continue;
    }

    // Split long lines
    if (line.length > MAX_LINE_LENGTH) {
      // Handle different languages differently
      if (['javascript', 'js', 'typescript', 'ts'].includes(language.toLowerCase())) {
        // For JavaScript/TypeScript, try to break at operation boundaries
        const breakPoints = ['.', '+', '-', '*', '/', '=', '?', ':', '&&', '||', ','];
        processedLines.push(...breakLongLine(line, breakPoints));
      } else if (['python', 'py'].includes(language.toLowerCase())) {
        // For Python, prefer breaking at commas and operators
        const breakPoints = [',', '+', '-', '*', '/', '=', 'and', 'or', 'not'];
        processedLines.push(...breakLongLine(line, breakPoints));
      } else if (['html', 'xml'].includes(language.toLowerCase())) {
        // For HTML/XML, break at tags and attributes
        const breakPoints = ['>', '<', ' '];
        processedLines.push(...breakLongLine(line, breakPoints));
      } else {
        // Default breaking strategy
        processedLines.push(...breakLongLine(line, [',', ';', ' ']));
      }
    } else {
      processedLines.push(line);
    }
  }

  return processedLines.join('\n');
}

/**
 * Break a long line at suitable break points
 * @param {string} line The line to break
 * @param {string[]} breakPoints Array of characters/strings at which to break
 * @returns {string[]} Array of broken lines
 */
function breakLongLine(line, breakPoints) {
  const result = [];
  let currentLine = line;

  while (currentLine.length > MAX_LINE_LENGTH) {
    let breakIndex = -1;
    
    // Find the latest possible break point
    for (const point of breakPoints) {
      const index = currentLine.lastIndexOf(point, MAX_LINE_LENGTH);
      if (index > breakIndex) {
        breakIndex = index;
      }
    }

    // If no break point found, force break at MAX_LINE_LENGTH
    if (breakIndex === -1 || breakIndex === 0) {
      breakIndex = MAX_LINE_LENGTH;
    }

    // Add the part before break point
    result.push(currentLine.substring(0, breakIndex + 1));
    
    // Continue with the rest of the line, with proper indentation
    currentLine = ' '.repeat(getIndentation(line)) + currentLine.substring(breakIndex + 1);
  }

  // Add the remaining part if not empty
  if (currentLine.trim().length > 0) {
    result.push(currentLine);
  }

  return result;
}

/**
 * Get the indentation level of a line
 * @param {string} line The line
 * @returns {number} Number of spaces at the beginning
 */
function getIndentation(line) {
  const match = line.match(/^(\s*)/);
  return match ? match[1].length : 0;
}

/**
 * Main function
 */
async function main() {
  try {
    // Find all markdown files
    const files = await glob('book/**/*.md');
    
    // Process each file
    for (const file of files) {
      processFile(file);
    }
    
    console.log('All files processed successfully!');
  } catch (error) {
    console.error(`Error: ${error.message}`);
    process.exit(1);
  }
}

// Run the main function
main(); 