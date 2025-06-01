# 🚀 Testando o Site com Nginx

## ✅ Compatibilidade
Este site é **100% compatível** com nginx por ser estático (HTML/CSS/JS).

## 🐳 Teste com Docker (Recomendado)

### Pré-requisitos:
- Docker Desktop instalado
- Docker Compose disponível

### Como testar:

#### Opção 1: Script Automático (Windows)
```batch
# Execute o script de teste
test-nginx.bat
```

#### Opção 2: Comandos Manuais
```bash
# 1. Construir a imagem
docker-compose build

# 2. Iniciar o servidor
docker-compose up -d

# 3. Acessar o site
# http://localhost:8080
```

### Comandos Úteis:
```bash
# Ver logs em tempo real
docker-compose logs -f

# Parar o servidor
docker-compose down

# Reiniciar
docker-compose restart

# Verificar status
docker-compose ps
```

## 🌐 Teste com Nginx Local

### Windows (com Chocolatey):
```batch
# Instalar nginx
choco install nginx

# Copiar arquivos para pasta do nginx
copy . C:\tools\nginx-1.x.x\html\

# Copiar configuração
copy nginx.conf C:\tools\nginx-1.x.x\conf\

# Iniciar nginx
nginx
```

### Linux/Mac:
```bash
# Instalar nginx
sudo apt install nginx  # Ubuntu/Debian
brew install nginx      # Mac

# Copiar configuração
sudo cp nginx.conf /etc/nginx/sites-available/todos-por-um
sudo ln -s /etc/nginx/sites-available/todos-por-um /etc/nginx/sites-enabled/

# Reiniciar nginx
sudo systemctl restart nginx
```

## 🔒 Recursos de Segurança Incluídos

✅ **Headers de Segurança:**
- X-Frame-Options: DENY
- X-XSS-Protection: 1; mode=block
- X-Content-Type-Options: nosniff
- Content Security Policy
- Permissions Policy

✅ **Proteção contra:**
- Directory browsing
- Acesso a arquivos sensíveis
- Bots maliciosos
- Ataques XSS e clickjacking

✅ **Performance:**
- Compressão Gzip
- Cache de assets estáticos
- Otimização de headers

## 🧪 Testes de Funcionalidade

Após iniciar o nginx, teste:

1. **Página principal:** http://localhost:8080
2. **Navegação:** Todos os links do menu
3. **Responsividade:** Redimensionar a janela
4. **Segurança:** Tentar acessar arquivos proibidos
5. **Performance:** Verificar velocidade de carregamento

## 📊 Monitoramento

### Verificar logs:
```bash
# Docker
docker-compose logs nginx-site

# Nginx local
sudo tail -f /var/log/nginx/access.log
sudo tail -f /var/log/nginx/error.log
```

### Testar headers de segurança:
```bash
curl -I http://localhost:8080
```

## 🚨 Solução de Problemas

**Erro: Porto 8080 ocupado**
```bash
# Alterar porta no docker-compose.yml
ports:
  - "8081:80"  # Use 8081 em vez de 8080
```

**Erro: Docker não encontrado**
- Instale o Docker Desktop
- Certifique-se que está rodando

**Erro: Permissão negada**
```bash
# Linux/Mac - executar com sudo se necessário
sudo docker-compose up -d
```

## 🌟 Próximos Passos

Para produção, considere:
- SSL/TLS (certificado HTTPS)
- Domínio personalizado
- CDN para assets
- Monitoramento avançado
- Backup automatizado 