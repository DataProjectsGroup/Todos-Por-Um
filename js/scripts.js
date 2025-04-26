document.addEventListener('DOMContentLoaded', function() {
    // Navigation scroll effect
    window.addEventListener('scroll', function() {
        const header = document.querySelector('header');
        if (window.scrollY > 50) {
            header.style.backgroundColor = '#fff';
            header.style.boxShadow = '0 2px 5px rgba(0,0,0,0.1)';
        } else {
            header.style.backgroundColor = '#fff';
            header.style.boxShadow = '0 2px 5px rgba(0,0,0,0.1)';
        }
    });

    // Smooth scrolling for anchor links
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function(e) {
            e.preventDefault();
            const targetId = this.getAttribute('href');
            if (targetId === '#') return;
            
            const targetElement = document.querySelector(targetId);
            if (targetElement) {
                window.scrollTo({
                    top: targetElement.offsetTop - 100,
                    behavior: 'smooth'
                });
            }
        });
    });

    // Donation amount buttons
    const amountBtns = document.querySelectorAll('.amount-btn');
    const amountInput = document.getElementById('amount');

    if (amountBtns && amountInput) {
        amountBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                // Remove active class from all buttons
                amountBtns.forEach(b => b.classList.remove('active'));
                
                // Add active class to clicked button
                this.classList.add('active');
                
                // Set amount input value
                const amount = this.textContent.replace('$', '');
                if (amount !== 'Other') {
                    amountInput.value = amount;
                } else {
                    amountInput.value = '';
                    amountInput.focus();
                }
            });
        });
    }

    // Form submission handling
    const donationForm = document.querySelector('.donation-form form');
    if (donationForm) {
        donationForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Collect form data
            const formData = {
                amount: document.getElementById('amount').value,
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                payment: document.getElementById('payment').value
            };
            
            // Here you would typically send this data to a server
            // For this demo, we'll just show an alert
            alert(`Thank you, ${formData.name}! Your donation of $${formData.amount} is being processed.`);
            
            // Reset form
            this.reset();
            amountBtns.forEach(b => b.classList.remove('active'));
            document.querySelector('.amount-btn:nth-child(3)').classList.add('active');
            document.getElementById('amount').value = '100';
        });
    }

    // Volunteer form handling
    const volunteerForm = document.querySelector('.volunteer-form form');
    if (volunteerForm) {
        volunteerForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Collect form data
            const formData = {
                name: document.getElementById('volunteer-name').value,
                email: document.getElementById('volunteer-email').value,
                phone: document.getElementById('volunteer-phone').value,
                interest: document.getElementById('volunteer-interest').value
            };
            
            // Here you would typically send this data to a server
            // For this demo, we'll just show an alert
            alert(`Thank you, ${formData.name}! We'll contact you soon about volunteering for our ${formData.interest.replace('-', ' ')} program.`);
            
            // Reset form
            this.reset();
        });
    }
});