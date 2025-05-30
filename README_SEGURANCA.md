# 🔒 Guia de Segurança - Servidor de Desenvolvimento

## ⚠️ Problema Identificado

O arquivo `.htaccess` criado anteriormente **NÃO FUNCIONA** com `python -m http.server` porque:

- `.htaccess` é específico para **Apache Server**
- `python -m http.server` é um servidor HTTP simples que não interpreta arquivos `.htaccess`
- Ngrok apenas faz tunnel, não adiciona funcionalidades de segurança

## ✅ Soluções Implementadas

### **Opção 1: Servidor Python Seguro (RECOMENDADO)**

Use o arquivo `secure_server.py` que criamos:

```bash
# Em vez de: python -m http.server
python secure_server.py

# Ou especifique uma porta:
python secure_server.py 8080
```

**Recursos incluídos:**
- ❌ Directory listing DESABILITADO
- 🔒 Headers de segurança (XSS, Clickjacking, CSP, etc.)
- 🚫 Bloqueio de arquivos sensíveis (.htaccess, .env, .py, etc.)
- 🤖 Bloqueio de bots maliciosos (HTTrack, wget, etc.)
- 🛡️ Proteção contra directory traversal
- 📊 Logs detalhados de acesso

### **Opção 2: Script Batch Automático**

Execute o arquivo `start_secure_server.bat` (duplo clique):
- Interface amigável
- Escolha entre servidor seguro ou padrão
- Verificação automática do Python

### **Opção 3: Arquivos index.html em Diretórios**

Criados arquivos `index.html` em:
- `/assets/index.html` - Página de acesso negado
- `/css/index.html` - Página de acesso negado  
- `/js/index.html` - Página de acesso negado

Isso previne directory listing mesmo no servidor padrão Python.

## 🚀 Como Usar com Ngrok

### **Método Seguro (Recomendado):**
```bash
# Terminal 1: Servidor seguro
cd Documents/Donation-Daniel
python secure_server.py

# Terminal 2: Ngrok
ngrok http 8000
```

### **Método padrão (menos seguro):**
```bash
# Terminal 1: Servidor padrão 
cd Documents/Donation-Daniel
python -m http.server 8000

# Terminal 2: Ngrok
ngrok http 8000
```

## 🛡️ Recursos de Segurança Ativos

### **Headers HTTP Aplicados:**
- `X-Content-Type-Options: nosniff`
- `X-Frame-Options: DENY`
- `X-XSS-Protection: 1; mode=block`
- `Referrer-Policy: strict-origin-when-cross-origin`
- `Permissions-Policy: camera=(), microphone=(), geolocation=()`
- `Content-Security-Policy: ...` (CSP completo)
- `Strict-Transport-Security: ...` (HSTS quando HTTPS)

### **Proteções Ativas:**
- 🚫 Directory listing bloqueado
- 🔒 Arquivos sensíveis protegidos
- 🤖 Bots maliciosos bloqueados
- 🛡️ Directory traversal prevenido
- 📋 User-agents maliciosos filtrados

### **Arquivos Protegidos:**
- `.htaccess`, `.env`, `.git*`
- `*.py`, `*.log`, `*.bak`, `*.tmp`
- `*.ini`, `*.conf`
- `secure_server.py`, `nginx-security.conf`

### **Bots Bloqueados:**
- HTTrack, wget, curl
- Scrapy, python-requests
- Crawlers genéricos
- Email harvesters

## 📁 Estrutura de Arquivos de Segurança

```
Donation-Daniel/
├── .htaccess                    # Para Apache (produção)
├── nginx-security.conf          # Para Nginx (produção)
├── robots.txt                   # Controle de bots
├── secure_server.py             # Servidor Python seguro
├── start_secure_server.bat      # Script Windows
├── README_SEGURANCA.md          # Este arquivo
├── assets/index.html            # Proteção directory listing
├── css/index.html               # Proteção directory listing
└── js/index.html                # Proteção directory listing
```

## 🔧 Teste de Segurança

Para testar se a segurança está funcionando:

1. **Teste Directory Listing:**
   - Acesse: `http://localhost:8000/assets/`
   - Deve mostrar "Acesso Negado" em vez de listar arquivos

2. **Teste Arquivos Protegidos:**
   - Acesse: `http://localhost:8000/.htaccess`
   - Deve retornar erro 403 Forbidden

3. **Teste Bot Protection:**
   ```bash
   curl -H "User-Agent: HTTrack" http://localhost:8000/
   # Deve retornar 403 Forbidden
   ```

## ⚡ Performance

O servidor seguro inclui:
- Logs otimizados
- Headers de cache para recursos estáticos
- Compressão quando possível
- IP local automático detectado

## 🌐 Produção

Para produção, use:
- **Apache:** O arquivo `.htaccess` funcionará automaticamente
- **Nginx:** Inclua `nginx-security.conf` na configuração
- **Outros:** Adapte as regras conforme necessário

## 📞 Suporte

Se encontrar problemas:
1. Verifique se Python está instalado: `python --version`
2. Verifique se a porta está livre: `netstat -an | findstr :8000`
3. Use uma porta diferente: `python secure_server.py 8080`

---

**Criado para:** Todos Por Um Futuro Melhor  
**Data:** 2025  
**Versão:** 1.0 