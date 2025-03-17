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
  languages: ['en'], // Currently only English
  defaultLanguage: 'en',
};

// Create build directory if it doesn't exist
fs.ensureDirSync(config.outputDir);

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

// Copy image directories to build folder
function copyImageDirectories(language) {
  console.log("Copying image directories...");
  
  // Create images directory in build folder
  fs.ensureDirSync(path.join(config.outputDir, 'images'));
  
  // Find all image directories and copy to build folder
  try {
    const imageDirs = glob.sync(`book/${language}/**/images`);
    imageDirs.forEach(dir => {
      const relativePath = dir.replace(`book/${language}/`, '');
      const targetDir = path.join(config.outputDir, relativePath);
      fs.copySync(dir, targetDir);
      console.log(`Copied ${dir} to ${targetDir}`);
    });
  } catch (error) {
    console.error(`Error copying image directories: ${error.message}`);
  }
}

// Build a single language version of the book
async function buildLanguage(language) {
  console.log(`Building ${language} version of the book...`);
  
  // Copy image directories
  copyImageDirectories(language);
  
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
  const outputMdFile = path.join(config.outputDir, language === config.defaultLanguage 
    ? `${config.bookName}.md` 
    : `${config.bookName}-${language}.md`);
  
  // Clear the file if it exists
  fs.writeFileSync(outputMdFile, '');
  
  // Concatenate all markdown files
  for (const file of markdownFiles) {
    const content = fs.readFileSync(file, 'utf-8');
    fs.appendFileSync(outputMdFile, content + '\n\n');
  }
  
  console.log(`Created concatenated markdown file: ${outputMdFile}`);
  
  // Generate PDF using Pandoc
  try {
    const pdfFile = path.join(config.outputDir, language === config.defaultLanguage 
      ? `${config.bookName}.pdf` 
      : `${config.bookName}-${language}.pdf`);
    
    const command = `pandoc "${outputMdFile}" -o "${pdfFile}" --pdf-engine=xelatex --toc --resource-path=.:book:book/${language}`;
    console.log(`Running: ${command}`);
    execSync(command, { stdio: 'inherit' });
    console.log(`PDF created: ${pdfFile}`);
  } catch (error) {
    console.error(`Error generating PDF: ${error.message}`);
  }
  
  // Generate EPUB using Pandoc
  try {
    const epubFile = path.join(config.outputDir, language === config.defaultLanguage 
      ? `${config.bookName}.epub` 
      : `${config.bookName}-${language}.epub`);
    
    // Check for cover image
    let coverImageOption = '';
    const coverImagePaths = [
      'art/cover.png',
      `book/images/cover.png`,
      `book/${language}/images/cover.png`
    ];
    
    for (const imgPath of coverImagePaths) {
      if (fs.existsSync(imgPath)) {
        coverImageOption = `--epub-cover-image="${imgPath}" `;
        break;
      }
    }
    
    const command = `pandoc "${outputMdFile}" -o "${epubFile}" ${coverImageOption}--toc --toc-depth=2 --resource-path=.:book:book/${language} --extract-media=${config.outputDir}/epub-media`;
    console.log(`Running: ${command}`);
    execSync(command, { stdio: 'inherit' });
    console.log(`EPUB created: ${epubFile}`);
  } catch (error) {
    console.error(`Error generating EPUB: ${error.message}`);
  }
  
  // Generate HTML using Pandoc
  try {
    const htmlFile = path.join(config.outputDir, language === config.defaultLanguage 
      ? `${config.bookName}.html` 
      : `${config.bookName}-${language}.html`);
    
    const command = `pandoc "${outputMdFile}" -o "${htmlFile}" --standalone --toc --toc-depth=2 --resource-path=.:book:book/${language}`;
    console.log(`Running: ${command}`);
    execSync(command, { stdio: 'inherit' });
    console.log(`HTML created: ${htmlFile}`);
  } catch (error) {
    console.error(`Error generating HTML: ${error.message}`);
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
    
    // Create index.html from the HTML file for GitHub Pages
    const htmlFile = path.join(config.outputDir, `${config.bookName}.html`);
    if (fs.existsSync(htmlFile)) {
      fs.copyFileSync(htmlFile, path.join(config.outputDir, 'index.html'));
    }
    
    console.log('Build completed successfully!');
  } catch (error) {
    console.error(`Build failed: ${error.message}`);
    process.exit(1);
  }
}

// Run the main function
main();