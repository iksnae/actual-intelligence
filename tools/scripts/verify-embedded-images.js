/**
 * Verify embedded images in PDF
 * 
 * This script uses the pdfjs library to analyze a PDF file
 * and check if images are properly embedded.
 * 
 * Usage: node verify-embedded-images.js path/to/pdf
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');

const pdfFile = process.argv[2];

if (!pdfFile) {
  console.error('Error: No PDF file specified');
  console.log('Usage: node verify-embedded-images.js path/to/pdf');
  process.exit(1);
}

if (!fs.existsSync(pdfFile)) {
  console.error(`Error: File not found: ${pdfFile}`);
  process.exit(1);
}

console.log(`Analyzing PDF file: ${pdfFile}`);

// We'll use pdfinfo to get basic info about the PDF
exec(`pdfinfo "${pdfFile}"`, (error, stdout, stderr) => {
  if (error) {
    console.error(`Error running pdfinfo: ${error.message}`);
    return;
  }
  
  console.log('\nPDF Metadata:');
  console.log(stdout);
  
  // Now use pdfimages to list embedded images
  exec(`pdfimages -list "${pdfFile}"`, (error, stdout, stderr) => {
    if (error) {
      console.error(`Error running pdfimages: ${error.message}`);
      console.log('You may need to install poppler-utils: sudo apt-get install poppler-utils');
      return;
    }
    
    console.log('\nEmbedded Images:');
    console.log(stdout);
    
    // Count the number of images
    const imageLines = stdout.trim().split('\n').slice(1); // Remove header line
    console.log(`\nTotal embedded images found: ${imageLines.length}`);
    
    if (imageLines.length === 0) {
      console.log('\n⚠️ Warning: No embedded images found in the PDF.');
    } else {
      console.log('\n✅ PDF contains embedded images.');
    }
  });
}); 