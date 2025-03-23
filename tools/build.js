/**
 * Build script for "Actual Intelligence" book
 */

const fs = require('fs-extra');
const path = require('path');
const { glob } = require('glob');
const { execSync } = require('child_process');

// Configuration
const config = {
  bookName: 'actual-intelligence',
  outputDir: 'build',
  languages: ['en', 'es'], // Added Spanish language
  defaultLanguage: 'en',
  titles: {
    en: 'Actual Intelligence',
    es: 'Inteligencia Real'  // Spanish title
  },
  subtitles: {
    en: 'A Practical Guide to Using AI in Everyday Life',
    es: 'Una Guía Práctica para Usar la IA en la Vida Cotidiana'  // Spanish subtitle
  },
  esOutputFiles: {
    pdf: 'inteligencia-real.pdf',
    epub: 'inteligencia-real.epub',
    mobi: 'inteligencia-real.mobi',
    html: 'inteligencia-real.html',
    markdown: 'inteligencia-real.md'
  }
};

// Create build directory if it doesn't exist
fs.ensureDirSync(config.outputDir);

// Create language-specific directories in build folder
config.languages.forEach(lang => {
  if (lang !== config.defaultLanguage) {
    fs.ensureDirSync(path.join(config.outputDir, lang));
  }
});

// Function to get command line arguments
function getArguments() {
  const args = process.argv.slice(2);
  return {
    buildAllLanguages: args.includes('--all-languages'),
    specificLanguage: args.find(arg => arg.startsWith('--lang='))?.split('=')[1],
  };
}

// Determine which languages to build
function getLanguagesToBuild(args) {
  if (args.specificLanguage && config.languages.includes(args.specificLanguage)) {
    return [args.specificLanguage];
  }
  
  if (args.buildAllLanguages) {
    return config.languages;
  }
  
  return [config.defaultLanguage];
}

// Copy image directories to build folder for proper path resolution
function copyImageDirectories(language) {
  console.log(`Copying image directories for ${language}...`);
  
  // Create images directory in build folder
  fs.ensureDirSync(path.join(config.outputDir, 'images'));
  
  // For non-default languages, create language-specific images directory
  if (language !== config.defaultLanguage) {
    fs.ensureDirSync(path.join(config.outputDir, language, 'images'));
  }
  
  // Find all image directories and copy to build folder
  try {
    // Create a comprehensive list of image paths to search
    const imageDirs = glob.sync(`book/${language}/**/images`);
    
    // Copy each directory to build maintaining structure
    imageDirs.forEach(dir => {
      // Extract relative path (after language directory)
      const relativeToLang = dir.replace(`book/${language}/`, '');
      const targetDir = path.join(config.outputDir, language === config.defaultLanguage ? relativeToLang : `${language}/${relativeToLang}`);
      
      // Copy the entire directory
      fs.copySync(dir, targetDir);
      console.log(`Copied ${dir} to ${targetDir}`);
      
      // Also copy to a central images directory for better discovery
      const files = glob.sync(`${dir}/**/*.*`);
      files.forEach(file => {
        const filename = path.basename(file);
        const centralImagesPath = language === config.defaultLanguage 
          ? path.join(config.outputDir, 'images', filename)
          : path.join(config.outputDir, language, 'images', filename);
        
        fs.copySync(file, centralImagesPath);
        console.log(`Copied ${file} to ${centralImagesPath}`);
      });
    });
    
    // Also handle root level images if they exist
    const rootImages = glob.sync(`book/images/**/*.*`);
    rootImages.forEach(file => {
      const filename = path.basename(file);
      fs.copySync(file, path.join(config.outputDir, 'images', filename));
      console.log(`Copied root image ${file} to ${path.join(config.outputDir, 'images', filename)}`);
      
      // Copy to language-specific folder as well for non-default languages
      if (language !== config.defaultLanguage) {
        fs.copySync(file, path.join(config.outputDir, language, 'images', filename));
        console.log(`Copied root image ${file} to ${path.join(config.outputDir, language, 'images', filename)}`);
      }
    });
    
  } catch (error) {
    console.error(`Error copying image directories: ${error.message}`);
  }
}

// Get output filename for a specific language
function getOutputFilename(language, type) {
  if (language === 'es') {
    return config.esOutputFiles[type];
  }
  
  return `${config.bookName}.${type}`;
}

// Build a single language version of the book
async function buildLanguage(language) {
  console.log(`Building ${language} version of the book...`);
  
  // Copy image directories
  copyImageDirectories(language);
  
  // Process code blocks to ensure proper wrapping in PDF
  try {
    console.log('Processing code blocks for proper wrapping...');
    execSync('chmod +x tools/scripts/fix-code-blocks.sh', { stdio: 'inherit' });
    execSync('./tools/scripts/fix-code-blocks.sh', { stdio: 'inherit' });
  } catch (error) {
    console.warn(`Warning: Failed to process code blocks: ${error.message}`);
    console.log('Continuing with build process...');
  }
  
  // Find all markdown files for this language
  const markdownFiles = await glob(`book/${language}/**/*.md`, { ignore: '**/README.md' });
  
  // Sort files to ensure correct order
  markdownFiles.sort((a, b) => {
    // First by chapter
    const chapterA = a.match(/chapter-(\d+)/);
    const chapterB = b.match(/chapter-(\d+)/);
    
    if (chapterA && chapterB) {
      const chapterNumA = parseInt(chapterA[1]);
      const chapterNumB = parseInt(chapterB[1]);
      
      if (chapterNumA !== chapterNumB) {
        return chapterNumA - chapterNumB;
      }
    }
    
    // Then by section/activity number if within same chapter
    const sectionA = a.match(/\/(\d+)-/);
    const sectionB = b.match(/\/(\d+)-/);
    
    if (sectionA && sectionB) {
      return parseInt(sectionA[1]) - parseInt(sectionB[1]);
    }
    
    // Finally alphabetically if no other ordering is available
    return a.localeCompare(b);
  });
  
  // Ensure title page comes first
  const titlePageIndex = markdownFiles.findIndex(file => file.includes('title-page.md'));
  if (titlePageIndex > 0) {
    const titlePage = markdownFiles.splice(titlePageIndex, 1)[0];
    markdownFiles.unshift(titlePage);
  }
  
  // Create a temporary concatenated markdown file
  const outputMdFilename = getOutputFilename(language, 'markdown');
  const outputMdFile = path.join(config.outputDir, language === config.defaultLanguage ? outputMdFilename : `${language}/${outputMdFilename}`);
  
  // Clear the file if it exists
  fs.writeFileSync(outputMdFile, '');
  
  // Add metadata header
  const metadataHeader = `---
title: "${config.titles[language] || config.titles.en}"
subtitle: "${config.subtitles[language] || config.subtitles.en}"
author: "K Mills"
publisher: "Khaos Studios"
language: "${language}"
toc: true
---

`;
  fs.appendFileSync(outputMdFile, metadataHeader);
  
  // Concatenate all markdown files
  for (const file of markdownFiles) {
    const content = fs.readFileSync(file, 'utf-8');
    fs.appendFileSync(outputMdFile, content + '\n\n');
  }
  
  console.log(`Created concatenated markdown file: ${outputMdFile}`);
  
  // Define common resource paths to help pandoc find images
  const resourcePaths = [
    '.',
    'book',
    `book/${language}`,
    config.outputDir,
    `book/${language}/images`,
    'book/images',
    `${config.outputDir}/images`,
    `${config.outputDir}/${language}/images`,
  ].join(':');
  
  // Generate EPUB using Pandoc first, as it handles code blocks and images well
  try {
    const epubFilename = getOutputFilename(language, 'epub');
    const epubFile = path.join(config.outputDir, language === config.defaultLanguage ? epubFilename : `${language}/${epubFilename}`);
    
    // Check for cover image
    let coverImageOption = '';
    const coverPaths = [
      'art/cover.png',
      'book/images/cover.png',
      `book/${language}/images/cover.png`
    ];
    
    for (const imgPath of coverPaths) {
      if (fs.existsSync(imgPath)) {
        coverImageOption = `--epub-cover-image="${imgPath}" `;
        break;
      }
    }
    
    const bookTitle = config.titles[language] || config.titles.en;
    const bookSubtitle = config.subtitles[language] || config.subtitles.en;
    
    const command = `pandoc "${outputMdFile}" -o "${epubFile}" ${coverImageOption}--toc --toc-depth=2 --metadata=title:"${bookTitle}" --metadata=subtitle:"${bookSubtitle}" --metadata=author:"K Mills" --metadata=publisher:"Khaos Studios" --metadata=lang:${language} --resource-path="${resourcePaths}" --extract-media=${config.outputDir}/epub-media --highlight-style=tango`;
    console.log(`Running: ${command}`);
    execSync(command, { stdio: 'inherit' });
    console.log(`EPUB created: ${epubFile}`);
    
    // For non-default languages, copy to root folder for release assets
    if (language !== config.defaultLanguage) {
      fs.copySync(epubFile, path.join(config.outputDir, epubFilename));
      console.log(`Copied ${epubFile} to ${path.join(config.outputDir, epubFilename)}`);
    }
    
    // Generate PDF from EPUB using Calibre
    await generatePDFFromEPUB(epubFile, language);
  } catch (error) {
    console.error(`Error generating EPUB: ${error.message}`);
    console.log('Falling back to direct PDF generation...');
    generatePDFFromMarkdown(outputMdFile, resourcePaths, language);
  }
  
  // Generate MOBI using Calibre (from EPUB)
  try {
    const epubFilename = getOutputFilename(language, 'epub');
    const epubFile = path.join(config.outputDir, language === config.defaultLanguage ? epubFilename : `${language}/${epubFilename}`);
    
    const mobiFilename = getOutputFilename(language, 'mobi');
    const mobiFile = path.join(config.outputDir, language === config.defaultLanguage ? mobiFilename : `${language}/${mobiFilename}`);
    
    if (fs.existsSync(epubFile)) {
      const bookTitle = config.titles[language] || config.titles.en;
      
      const command = `ebook-convert "${epubFile}" "${mobiFile}" --title="${bookTitle}" --authors="K Mills" --publisher="Khaos Studios" --language="${language}"`;
      console.log(`Running: ${command}`);
      execSync(command, { stdio: 'inherit' });
      console.log(`MOBI created: ${mobiFile}`);
      
      // For non-default languages, copy to root folder for release assets
      if (language !== config.defaultLanguage) {
        fs.copySync(mobiFile, path.join(config.outputDir, mobiFilename));
        console.log(`Copied ${mobiFile} to ${path.join(config.outputDir, mobiFilename)}`);
      }
    } else {
      console.error(`EPUB file not found, skipping MOBI generation: ${epubFile}`);
    }
  } catch (error) {
    console.error(`Error generating MOBI: ${error.message}`);
  }
  
  // Generate HTML using Pandoc
  try {
    const htmlFilename = getOutputFilename(language, 'html');
    const htmlFile = path.join(config.outputDir, language === config.defaultLanguage ? htmlFilename : `${language}/${htmlFilename}`);
    
    const bookTitle = config.titles[language] || config.titles.en;
    
    const command = `pandoc "${outputMdFile}" -o "${htmlFile}" --standalone --toc --toc-depth=2 --metadata=title:"${bookTitle}" --metadata=lang:${language} --resource-path="${resourcePaths}" --highlight-style=tango --css=templates/book.css`;
    console.log(`Running: ${command}`);
    execSync(command, { stdio: 'inherit' });
    console.log(`HTML created: ${htmlFile}`);
    
    // Create index.html in appropriate directory
    if (language === config.defaultLanguage) {
      fs.copyFileSync(htmlFile, path.join(config.outputDir, 'index.html'));
      console.log(`Created index.html from ${htmlFile}`);
    } else {
      fs.copyFileSync(htmlFile, path.join(config.outputDir, language, 'index.html'));
      console.log(`Created ${language}/index.html from ${htmlFile}`);
      
      // For non-default languages, copy to root folder for release assets
      fs.copySync(htmlFile, path.join(config.outputDir, htmlFilename));
      console.log(`Copied ${htmlFile} to ${path.join(config.outputDir, htmlFilename)}`);
    }
  } catch (error) {
    console.error(`Error generating HTML: ${error.message}`);
  }
}

/**
 * Generate PDF from EPUB using Calibre
 * @param {string} epubFile Path to the EPUB file
 * @param {string} language Language code
 */
async function generatePDFFromEPUB(epubFile, language) {
  try {
    const pdfFilename = getOutputFilename(language, 'pdf');
    const pdfFile = path.join(config.outputDir, language === config.defaultLanguage ? pdfFilename : `${language}/${pdfFilename}`);
    
    console.log(`Generating PDF from EPUB: ${epubFile} -> ${pdfFile}`);
    
    const bookTitle = config.titles[language] || config.titles.en;
    
    // Create a custom CSS file for better PDF styling
    const cssFile = path.join(config.outputDir, 'pdf-styles.css');
    fs.writeFileSync(cssFile, `
      pre, code {
        white-space: pre-wrap;
        word-wrap: break-word;
        background-color: #f5f5f5;
        border: 1px solid #ddd;
        border-radius: 3px;
        padding: 0.5em;
        font-family: monospace;
      }
      body {
        font-family: 'Helvetica', sans-serif;
        line-height: 1.5;
      }
      h1, h2, h3, h4, h5, h6 {
        color: #2c3e50;
      }
    `);
    
    // Use ebook-convert from Calibre to convert EPUB to PDF with embedded images
    const command = `ebook-convert "${epubFile}" "${pdfFile}" --title="${bookTitle}" --authors="K Mills" --publisher="Khaos Studios" --language="${language}" --pdf-page-numbers --pdf-page-margin-bottom=36 --pdf-page-margin-top=36 --pdf-page-margin-left=36 --pdf-page-margin-right=36 --extra-css="${cssFile}" --pdf-default-font-size=11 --pdf-mono-font-size=10 --embed-all-fonts --pdf-add-toc`;
    console.log(`Running: ${command}`);
    execSync(command, { stdio: 'inherit' });
    console.log(`PDF created from EPUB: ${pdfFile}`);
    
    // For non-default languages, copy to root folder for release assets
    if (language !== config.defaultLanguage) {
      fs.copySync(pdfFile, path.join(config.outputDir, pdfFilename));
      console.log(`Copied ${pdfFile} to ${path.join(config.outputDir, pdfFilename)}`);
    }
  } catch (error) {
    console.error(`Error generating PDF from EPUB: ${error.message}`);
    console.log('Falling back to direct PDF generation...');
    const outputMdFile = path.join(config.outputDir, language === config.defaultLanguage ? getOutputFilename(language, 'markdown') : `${language}/${getOutputFilename(language, 'markdown')}`);
    const resourcePaths = [
      '.',
      'book',
      `book/${language}`,
      config.outputDir,
      `book/${language}/images`,
      'book/images',
      `${config.outputDir}/images`,
      `${config.outputDir}/${language}/images`,
    ].join(':');
    generatePDFFromMarkdown(outputMdFile, resourcePaths, language);
  }
}

/**
 * Generate PDF directly from Markdown using Pandoc and LaTeX
 * This is a fallback method if EPUB conversion fails
 * @param {string} outputMdFile Path to the markdown file
 * @param {string} resourcePaths Resource paths for Pandoc
 * @param {string} language Language code
 */
async function generatePDFFromMarkdown(outputMdFile, resourcePaths, language) {
  try {
    const pdfFilename = getOutputFilename(language, 'pdf');
    const pdfFile = path.join(config.outputDir, language === config.defaultLanguage ? pdfFilename : `${language}/${pdfFilename}`);
    
    // Check for cover image
    let coverImagePath = '';
    const coverPaths = [
      'art/cover.png',
      'book/images/cover.png',
      `book/${language}/images/cover.png`
    ];
    
    for (const imgPath of coverPaths) {
      if (fs.existsSync(imgPath)) {
        coverImagePath = imgPath;
        break;
      }
    }
    
    const bookTitle = config.titles[language] || config.titles.en;
    
    // Use LuaLaTeX instead of XeLaTeX to better handle image embedding
    const command = `pandoc "${outputMdFile}" -o "${pdfFile}" --pdf-engine=lualatex --toc --metadata=title:"${bookTitle}" --metadata=lang:${language} --resource-path="${resourcePaths}" --template=templates/template.tex --listings --embed-resources --standalone --columns=80 --wrap=auto`;
    console.log(`Running: ${command}`);
    execSync(command, { stdio: 'inherit' });
    console.log(`PDF created from Markdown: ${pdfFile}`);
    
    // Verify that images are embedded in the PDF
    try {
      console.log(`Verifying embedded images in ${pdfFile}...`);
      execSync(`chmod +x tools/scripts/verify-embedded-images.sh`, { stdio: 'inherit' });
      execSync(`tools/scripts/verify-embedded-images.sh "${pdfFile}"`, { stdio: 'inherit' });
    } catch (verifyError) {
      console.error(`Warning: Image verification failed: ${verifyError.message}`);
      console.log('The PDF may still be valid, but images might not be properly embedded.');
    }
    
    // For non-default languages, copy to root folder for release assets
    if (language !== config.defaultLanguage) {
      fs.copySync(pdfFile, path.join(config.outputDir, pdfFilename));
      console.log(`Copied ${pdfFile} to ${path.join(config.outputDir, pdfFilename)}`);
    }
  } catch (error) {
    console.error(`Error generating PDF from Markdown: ${error.message}`);
  }
}

// Main function
async function main() {
  try {
    const args = getArguments();
    const languagesToBuild = getLanguagesToBuild(args);
    
    // Create placeholder file in case PDF generation fails
    fs.writeFileSync(
      path.join(config.outputDir, 'placeholder.md'),
      `# ${config.bookName} - Placeholder\n\nThis is a placeholder file for when PDF generation fails.`
    );
    
    // Build each language
    for (const language of languagesToBuild) {
      await buildLanguage(language);
    }
    
    console.log('Build completed successfully!');
  } catch (error) {
    console.error(`Build failed: ${error.message}`);
    process.exit(1);
  }
}

// Run the main function
main();