/**
 * Format Book Content
 * 
 * This script adds extra whitespace and formatting to the book content files
 * to improve readability in PDF and EPUB outputs.
 */

const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// Configuration
const bookDir = path.resolve(__dirname, '../book');

// Process all chapter directories
function processChapters() {
  console.log('Formatting book content files...');
  
  // Find all chapters
  const chapters = fs.readdirSync(path.join(bookDir, 'en'))
    .filter(dir => dir.startsWith('chapter-'))
    .map(dir => path.join(bookDir, 'en', dir));
  
  chapters.forEach(chapterDir => {
    console.log(`Processing chapter: ${path.basename(chapterDir)}`);
    
    // Process all markdown files in the chapter directory
    const mdFiles = fs.readdirSync(chapterDir)
      .filter(file => file.endsWith('.md'))
      .map(file => path.join(chapterDir, file));
    
    mdFiles.forEach(formatFile);
  });
  
  console.log('Content formatting completed!');
}

// Format a single markdown file
function formatFile(filePath) {
  console.log(`Formatting file: ${path.basename(filePath)}`);
  
  // Read the file content
  let content = fs.readFileSync(filePath, 'utf8');
  
  // Add extra spacing between paragraphs
  content = content.replace(/([^\n])\n([^\n#])/g, '$1\n\n$2');
  
  // Add explicit page break before main sections
  content = content.replace(/(^# .*$)/gm, '\n\n---\n\n<div style="page-break-after: always;"></div>\n\n$1');
  
  // Add extra space before subsections
  content = content.replace(/(^## .*$)/gm, '\n\n$1\n\n');
  
  // Add extra space before activities
  content = content.replace(/(^\*\*Objective:|^\*\*What You'll Need:|^\*\*Instructions:|^\*\*Reflection Questions:)/gm, '\n\n$1');
  
  // Add extra space after code blocks
  content = content.replace(/(```\n[\s\S]*?```)/g, '$1\n\n');
  
  // Add extra space after lists
  content = content.replace(/(^[0-9]+\. .*$\n)(?!^[0-9]+\. )/gm, '$1\n');
  
  // Write the modified content back to the file
  fs.writeFileSync(filePath, content, 'utf8');
}

// Run the script
processChapters();
