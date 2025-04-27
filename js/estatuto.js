document.addEventListener('DOMContentLoaded', function() {
    // Handle download button click
    const downloadBtn = document.getElementById('download-estatuto');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', function() {
            // In a real application, this would link to an actual PDF file
            alert('Em uma implementação real, isto iniciaria o download do estatuto em formato PDF.');
            
            // For demonstration purposes, you can uncomment this line and replace with actual file path
            // window.location.href = 'assets/estatuto.pdf';
        });
    }

    // Add smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            const targetElement = document.querySelector(targetId);
            
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 100, // Offset for the navbar
                    behavior: 'smooth'
                });
            }
        });
    });

    // Optional: Add table of contents functionality or other interactive elements
    const sections = document.querySelectorAll('main section h2');
    const sectionsList = document.createElement('ul');
    sectionsList.classList.add('estatuto-toc');

    // Add highlighting for current section based on scroll position
    window.addEventListener('scroll', function() {
        const scrollPosition = window.scrollY;
        
        document.querySelectorAll('main section').forEach(section => {
            const sectionTop = section.offsetTop - 150;
            const sectionHeight = section.offsetHeight;
            
            if(scrollPosition >= sectionTop && scrollPosition < sectionTop + sectionHeight) {
                const id = section.querySelector('h2').id;
                document.querySelectorAll('.estatuto-toc a').forEach(link => {
                    link.classList.remove('active');
                    if(link.getAttribute('href') === '#' + id) {
                        link.classList.add('active');
                    }
                });
            }
        });
    });
});