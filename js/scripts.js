document.addEventListener('DOMContentLoaded', function() {
    // Efeito de rolagem na navegação
    const header = document.querySelector('header');
    
    function handleScroll() {
        if (window.scrollY > 50) {
            header.classList.add('scrolled');
        } else {
            header.classList.remove('scrolled');
        }
    }

    // Initial check
    handleScroll();

    // Add scroll event listener
    window.addEventListener('scroll', handleScroll);

    // Rolagem suave para links de âncora
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

    // Contribution type toggle
    const contributionButtons = document.querySelectorAll('.type-btn');
    const subscriptionInfo = document.querySelector('.subscription-info');
    const submitButton = document.querySelector('.donation-form .btn');
    const paymentSelect = document.getElementById('payment');
    const singlePaymentOptions = paymentSelect.querySelectorAll('.single-payment');

    function updatePaymentOptions(isSubscription) {
        singlePaymentOptions.forEach(option => {
            option.style.display = isSubscription ? 'none' : '';
        });
        
        // If subscription is selected and a single-payment option was selected, switch to credit card
        if (isSubscription && paymentSelect.querySelector('.single-payment[selected]')) {
            paymentSelect.value = 'credit';
        }
    }

    contributionButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons
            contributionButtons.forEach(btn => btn.classList.remove('active'));
            
            // Add active class to clicked button
            this.classList.add('active');
            
            const isSubscription = this.getAttribute('data-type') === 'subscription';
            
            // Show/hide subscription info
            subscriptionInfo.style.display = isSubscription ? 'block' : 'none';
            
            // Update payment options
            updatePaymentOptions(isSubscription);
        });
    });

    // Initial setup
    const activeButton = document.querySelector('.type-btn.active');
    if (activeButton) {
        const isSubscription = activeButton.getAttribute('data-type') === 'subscription';
        subscriptionInfo.style.display = isSubscription ? 'block' : 'none';
        updatePaymentOptions(isSubscription);
    }

    // Botões de valor de doação
    const amountBtns = document.querySelectorAll('.amount-btn');
    const amountInput = document.getElementById('amount');

    if (amountBtns && amountInput) {
        amountBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                // Remove a classe ativa de todos os botões
                amountBtns.forEach(b => b.classList.remove('active'));
                
                // Adiciona a classe ativa ao botão clicado
                this.classList.add('active');
                
                // Define o valor do input
                if (this.textContent === 'Outro') {
                    amountInput.focus();
                } else {
                    const amount = this.textContent.replace('R$', '');
                    amountInput.value = amount;
                }
            });
        });
    }

    // Tratamento de envio do formulário de doação
    const donationForm = document.querySelector('.donation-form form');
    if (donationForm) {
        donationForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Coleta os dados do formulário
            const formData = {
                amount: document.getElementById('amount').value,
                name: document.getElementById('name').value,
                email: document.getElementById('email').value,
                payment: document.getElementById('payment').value
            };
            
            // Normalmente, você enviaria esses dados para um servidor
            // Para esta demonstração, mostraremos apenas um alerta
            let paymentMethod = '';
            switch(formData.payment) {
                case 'credit':
                    paymentMethod = 'Cartão de Crédito';
                    break;
                case 'pix':
                    paymentMethod = 'PIX';
                    break;
                case 'bank':
                    paymentMethod = 'Transferência Bancária';
                    break;
                default:
                    paymentMethod = formData.payment;
            }
            
            alert(`Obrigado, ${formData.name}! Sua doação de R$${formData.amount} está sendo processada via ${paymentMethod}.`);
            
            // Reseta o formulário
            this.reset();
            amountBtns.forEach(b => b.classList.remove('active'));
            document.querySelector('.amount-btn:nth-child(3)').classList.add('active');
            document.getElementById('amount').value = '100';
        });
    }

    // Galeria de fotos com lightbox simples
    const galleryItems = document.querySelectorAll('.gallery-item img');
    
    if (galleryItems.length > 0) {
        galleryItems.forEach(item => {
            item.addEventListener('click', function() {
                const lightbox = document.createElement('div');
                lightbox.id = 'lightbox';
                lightbox.style.position = 'fixed';
                lightbox.style.top = '0';
                lightbox.style.left = '0';
                lightbox.style.width = '100%';
                lightbox.style.height = '100%';
                lightbox.style.backgroundColor = 'rgba(0, 0, 0, 0.9)';
                lightbox.style.display = 'flex';
                lightbox.style.alignItems = 'center';
                lightbox.style.justifyContent = 'center';
                lightbox.style.zIndex = '1000';
                
                const img = document.createElement('img');
                img.src = this.src;
                img.style.maxHeight = '90%';
                img.style.maxWidth = '90%';
                img.style.objectFit = 'contain';
                img.style.border = '5px solid white';
                
                lightbox.appendChild(img);
                document.body.appendChild(lightbox);
                
                lightbox.addEventListener('click', function() {
                    document.body.removeChild(lightbox);
                });
            });
        });
    }

    // Contact form submission with EmailJS
    const contactForm = document.getElementById('contactForm');
    if (contactForm) {
        contactForm.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const submitButton = this.querySelector('button[type="submit"]');
            const formMessage = document.getElementById('form-message');
            submitButton.disabled = true;
            submitButton.textContent = 'Enviando...';
            
            const templateParams = {
                name: document.getElementById('contact-name').value,
                email: document.getElementById('contact-email').value,
                subject: document.getElementById('contact-subject').value,
                message: document.getElementById('contact-message').value,
                time: new Date().toLocaleString('pt-BR', {
                    timeZone: 'America/Sao_Paulo',
                    day: '2-digit',
                    month: '2-digit',
                    year: 'numeric',
                    hour: '2-digit',
                    minute: '2-digit'
                })
            };
            
            emailjs.send('service_solzm1l', 'template_t92sqy2', templateParams)
                .then(function() {
                    formMessage.textContent = 'Mensagem enviada com sucesso! Em breve entraremos em contato.';
                    formMessage.className = 'form-message success';
                    formMessage.style.display = 'block';
                    contactForm.reset();
                    
                    // Scroll to the message
                    formMessage.scrollIntoView({ behavior: 'smooth', block: 'center' });
                })
                .catch(function(error) {
                    formMessage.textContent = 'Erro ao enviar mensagem. Por favor, tente novamente.';
                    formMessage.className = 'form-message error';
                    formMessage.style.display = 'block';
                    console.error('EmailJS error:', error);
                })
                .finally(function() {
                    submitButton.disabled = false;
                    submitButton.textContent = 'Enviar Mensagem';
                });
        });
    }
});