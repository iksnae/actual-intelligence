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