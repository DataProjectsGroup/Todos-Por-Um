document.addEventListener('DOMContentLoaded', function() {
    // Download PDF functionality
    const downloadBtn = document.querySelector('.btn-download');
    if (downloadBtn) {
        downloadBtn.addEventListener('click', function() {
            // In a real implementation, this would generate or serve a PDF
            // For now, we're just showing an alert
            alert('Funcionalidade de download do PDF será implementada em breve!');
            
            // Alternatively, you could redirect to a pre-generated PDF:
            // window.location.href = 'assets/estatuto-tofm.pdf';
        });
    }

    // Add animations and highlighting effects to sections when they come into view
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('animate-in');
            }
        });
    }, {
        threshold: 0.1
    });

    // Observe all section headers
    document.querySelectorAll('.estatuto-content h2').forEach(section => {
        observer.observe(section);
    });
});