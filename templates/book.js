// Reading Progress Bar
document.addEventListener('DOMContentLoaded', function() {
  // Create progress container and bar elements
  const progressContainer = document.createElement('div');
  progressContainer.className = 'progress-container';
  
  const progressBar = document.createElement('div');
  progressBar.className = 'progress-bar';
  
  progressContainer.appendChild(progressBar);
  document.body.appendChild(progressContainer);
  
  // Update progress bar as user scrolls
  window.addEventListener('scroll', function() {
    const winScroll = document.body.scrollTop || document.documentElement.scrollTop;
    const height = document.documentElement.scrollHeight - document.documentElement.clientHeight;
    const scrolled = (winScroll / height) * 100;
    progressBar.style.width = scrolled + '%';
  });
  
  // Enhanced image handling
  enhanceImages();
  
  // Add smooth scroll for anchor links
  document.querySelectorAll('a[href^="#"]').forEach(anchor => {
    anchor.addEventListener('click', function (e) {
      e.preventDefault();
      
      const targetId = this.getAttribute('href');
      const targetElement = document.querySelector(targetId);
      
      if (targetElement) {
        window.scrollTo({
          top: targetElement.offsetTop - 20,
          behavior: 'smooth'
        });
      }
    });
  });
  
  // Add estimated reading time
  const content = document.querySelector('body');
  if (content) {
    const text = content.textContent || content.innerText;
    const wordCount = text.split(/\s+/).length;
    const readingTime = Math.ceil(wordCount / 200); // Assuming 200 words per minute
    
    const readingTimeElement = document.createElement('div');
    readingTimeElement.className = 'reading-time';
    readingTimeElement.innerHTML = `<span>📚 ${readingTime} min read</span>`;
    readingTimeElement.style.fontSize = '0.9em';
    readingTimeElement.style.color = '#666';
    readingTimeElement.style.marginBottom = '2em';
    readingTimeElement.style.textAlign = 'right';
    
    // Insert after the table of contents, or at the beginning of the content
    const toc = document.getElementById('TOC');
    if (toc) {
      toc.parentNode.insertBefore(readingTimeElement, toc.nextSibling);
    } else {
      const firstHeading = document.querySelector('h1, h2, h3');
      if (firstHeading) {
        firstHeading.parentNode.insertBefore(readingTimeElement, firstHeading.nextSibling);
      }
    }
  }
  
  // Add theme toggle for light/dark mode
  addThemeToggle();
});

// Function to enhance images
function enhanceImages() {
  const images = document.querySelectorAll('img:not(.no-zoom)');
  
  images.forEach((img, index) => {
    // Add zoom functionality
    img.addEventListener('click', function() {
      this.classList.toggle('zoomed');
      
      if (this.classList.contains('zoomed')) {
        this.style.cursor = 'zoom-out';
        this.style.maxWidth = '95%';
        this.style.margin = '2em auto';
        this.style.transition = 'all 0.3s ease';
      } else {
        this.style.cursor = 'zoom-in';
        this.style.maxWidth = '100%';
      }
    });
    
    // Add zoom-in cursor by default
    img.style.cursor = 'zoom-in';
    
    // Check if image has a caption (markdown typically uses <em> after image for captions)
    const nextElement = img.nextElementSibling;
    if (nextElement && nextElement.tagName.toLowerCase() === 'em') {
      // Wrap both in a figure element for better semantics
      const figure = document.createElement('figure');
      const figcaption = document.createElement('figcaption');
      
      // Get the parent element
      const parent = img.parentNode;
      
      // Move the caption text to the figcaption
      figcaption.innerHTML = nextElement.innerHTML;
      
      // Replace the img with the figure containing both img and figcaption
      parent.insertBefore(figure, img);
      figure.appendChild(img);
      figure.appendChild(figcaption);
      
      // Remove the original em element
      parent.removeChild(nextElement);
    }
    
    // Add alt text if missing
    if (!img.alt) {
      img.alt = `Figure ${index + 1}`;
    }
    
    // Add lazy loading for performance
    img.loading = 'lazy';
    
    // Detect diagrams and charts
    if (img.src.includes('diagram') || img.src.includes('chart') || 
        img.alt.includes('diagram') || img.alt.includes('chart')) {
      img.classList.add('diagram');
    }
  });
  
  // Group adjacent images into galleries
  createImageGalleries();
}

// Function to create image galleries from adjacent images
function createImageGalleries() {
  const content = document.querySelector('body');
  const paragraphs = content.querySelectorAll('p');
  
  paragraphs.forEach(p => {
    const images = p.querySelectorAll('img');
    if (images.length > 1) {
      // Create gallery container
      const gallery = document.createElement('div');
      gallery.className = 'image-gallery';
      
      // Move images to gallery
      images.forEach(img => {
        gallery.appendChild(img.cloneNode(true));
      });
      
      // Replace paragraph with gallery
      p.parentNode.insertBefore(gallery, p);
      p.parentNode.removeChild(p);
      
      // Re-add event listeners to gallery images
      gallery.querySelectorAll('img').forEach(img => {
        img.addEventListener('click', function() {
          this.classList.toggle('zoomed');
          
          if (this.classList.contains('zoomed')) {
            this.style.cursor = 'zoom-out';
          } else {
            this.style.cursor = 'zoom-in';
          }
        });
        
        img.style.cursor = 'zoom-in';
      });
    }
  });
}

// Function to add theme toggle
function addThemeToggle() {
  const toggle = document.createElement('button');
  toggle.className = 'theme-toggle';
  toggle.innerHTML = '🌙'; // Default icon
  toggle.setAttribute('title', 'Toggle light/dark mode');
  
  // Style the button
  toggle.style.position = 'fixed';
  toggle.style.bottom = '20px';
  toggle.style.right = '20px';
  toggle.style.width = '40px';
  toggle.style.height = '40px';
  toggle.style.borderRadius = '50%';
  toggle.style.backgroundColor = 'rgba(0, 0, 0, 0.1)';
  toggle.style.border = 'none';
  toggle.style.fontSize = '20px';
  toggle.style.cursor = 'pointer';
  toggle.style.zIndex = '999';
  toggle.style.display = 'flex';
  toggle.style.alignItems = 'center';
  toggle.style.justifyContent = 'center';
  toggle.style.boxShadow = '0 2px 5px rgba(0, 0, 0, 0.15)';
  
  // Check if dark mode is preferred
  const prefersDarkMode = window.matchMedia('(prefers-color-scheme: dark)').matches;
  let isDarkMode = prefersDarkMode;
  
  // Apply initial theme
  toggle.innerHTML = isDarkMode ? '☀️' : '🌙';
  
  // Toggle theme on click
  toggle.addEventListener('click', function() {
    isDarkMode = !isDarkMode;
    toggle.innerHTML = isDarkMode ? '☀️' : '🌙';
    
    // Add dark mode class to body
    if (isDarkMode) {
      document.body.classList.add('dark-mode');
    } else {
      document.body.classList.remove('dark-mode');
    }
  });
  
  // Add the toggle to the page
  document.body.appendChild(toggle);
} 