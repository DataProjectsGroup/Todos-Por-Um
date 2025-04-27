document.addEventListener('DOMContentLoaded', function() {
    // Handle PDF download functionality
    const downloadBtn = document.querySelector('.btn-download');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', function() {
            // Alert to inform user this feature is coming soon
            alert('O download do PDF estará disponível em breve!');
            
            // In the future, this can be replaced with actual PDF generation and download code
            // For example:
            // window.location.href = 'assets/docs/estatuto.pdf';
        });
    }
    
    // Initialize any additional functionality specific to the estatuto page
    function initEstatutoPage() {
        // Add smooth scrolling to the document sections
        const estatutoContent = document.querySelector('.estatuto-content');
        
        // Add class to headings after they've been viewed
        if (estatutoContent) {
            const headings = estatutoContent.querySelectorAll('h2');
            
            // Create an intersection observer
            const observer = new IntersectionObserver((entries) => {
                entries.forEach(entry => {
                    if (entry.isIntersecting) {
                        entry.target.classList.add('viewed');
                    }
                });
            }, {
                threshold: 0.5
            });
            
            // Observe each heading
            headings.forEach(heading => {
                observer.observe(heading);
            });
        }
    }
    
    // Initialize the estatuto page
    initEstatutoPage();
});