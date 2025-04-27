document.addEventListener('DOMContentLoaded', function() {
    // Highlight active section in TOC when scrolling
    const sections = document.querySelectorAll('.estatuto-section');
    const tocLinks = document.querySelectorAll('.toc-link');
    
    window.addEventListener('scroll', function() {
        let current = '';
        
        sections.forEach(section => {
            const sectionTop = section.offsetTop - 100;
            const sectionHeight = section.clientHeight;
            
            if (scrollY >= sectionTop && scrollY < sectionTop + sectionHeight) {
                current = section.getAttribute('id');
            }
        });
        
        tocLinks.forEach(link => {
            link.classList.remove('active');
            if (link.getAttribute('href').substring(1) === current) {
                link.classList.add('active');
            }
        });
    });
    
    // Smooth scrolling for TOC links
    document.querySelectorAll('.toc-link').forEach(link => {
        link.addEventListener('click', function(e) {
            e.preventDefault();
            
            const targetId = this.getAttribute('href').substring(1);
            const targetElement = document.getElementById(targetId);
            
            window.scrollTo({
                top: targetElement.offsetTop - 50,
                behavior: 'smooth'
            });
        });
    });
    
    // Handle PDF download
    document.getElementById('download-estatuto').addEventListener('click', function() {
        // In a real application, this would link to an actual PDF file
        alert('O download do estatuto em PDF iniciará em breve.');
        
        // Simulate download by creating a dummy PDF link
        // In a production environment, replace with actual PDF file URL
        const link = document.createElement('a');
        link.href = 'assets/documents/estatuto.pdf';
        link.download = 'Estatuto_Donation_Daniel.pdf';
        link.target = '_blank';
        document.body.appendChild(link);
        link.click();
        document.body.removeChild(link);
    });
});