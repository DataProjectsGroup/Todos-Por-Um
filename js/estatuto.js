// JavaScript for Estatuto page

document.addEventListener('DOMContentLoaded', function() {
    // Smooth scrolling for table of contents links
    const tocLinks = document.querySelectorAll('.toc-link');
    
    tocLinks.forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 100,
                    behavior: 'smooth'
                });
                
                // Highlight the current section in TOC
                tocLinks.forEach(link => link.classList.remove('active'));
                this.classList.add('active');
            }
        });
    });
    
    // Highlight TOC item on scroll
    window.addEventListener('scroll', function() {
        const sections = document.querySelectorAll('.estatuto-section');
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop - 120;
            const sectionHeight = section.offsetHeight;
            const scrollPosition = window.scrollY;
            
            if (scrollPosition >= sectionTop && scrollPosition < sectionTop + sectionHeight) {
                const id = section.getAttribute('id');
                
                tocLinks.forEach(link => {
                    link.classList.remove('active');
                    if (link.getAttribute('href') === `#${id}`) {
                        link.classList.add('active');
                    }
                });
            }
        });
    });
    
    // Download button functionality
    const downloadButton = document.getElementById('downloadEstatuto');
    
    if (downloadButton) {
        downloadButton.addEventListener('click', function(e) {
            e.preventDefault();
            // Replace this with actual file path when available
            alert('Funcionalidade de download do PDF será implementada em breve.');
            
            // Uncomment when a PDF file is available
            // window.location.href = 'assets/documentos/estatuto.pdf';
        });
    }
});