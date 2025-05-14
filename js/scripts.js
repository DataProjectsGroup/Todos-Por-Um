document.addEventListener('DOMContentLoaded', function() {
    // Efeito de rolagem na navegação
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
    const typeButtons = document.querySelectorAll('.type-btn');
    const subscriptionInfo = document.querySelector('.subscription-info');
    const submitButton = document.querySelector('.donation-form .btn');

    typeButtons.forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons
            typeButtons.forEach(btn => btn.classList.remove('active'));
            // Add active class to clicked button
            this.classList.add('active');
            
            // Show/hide subscription info based on selection
            if (this.dataset.type === 'subscription') {
                subscriptionInfo.style.display = 'block';
                submitButton.textContent = 'Assinar Agora';
            } else {
                subscriptionInfo.style.display = 'none';
                submitButton.textContent = 'Doar Agora';
            }
        });
    });

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
});