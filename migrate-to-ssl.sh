#!/bin/bash

# Script de Migração para Nginx Nativo com SSL
# Migra do Docker para nginx nativo com certificado SSL

VPS_IP="144.91.122.53"
DOMAIN="todospor1.org"  # Altere para seu domínio
SITE_DIR="/var/www/todos-por-um"
NGINX_AVAILABLE="/etc/nginx/sites-available"
NGINX_ENABLED="/etc/nginx/sites-enabled"

echo "🔒 MIGRAÇÃO PARA NGINX NATIVO COM SSL"
echo "=========================================="
echo "🖥️ VPS IP: $VPS_IP"
echo "🌐 Domínio: $DOMAIN"
echo "📁 Diretório: $SITE_DIR"
echo ""

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script precisa ser executado como root"
    echo "💡 Execute: sudo ./migrate-to-ssl.sh"
    exit 1
fi

# 1. Parar container Docker (se estiver rodando)
echo "1️⃣ PARANDO CONTAINER DOCKER"
echo "-----------------------------------"
if docker ps -q -f name=donation-site | grep -q .; then
    echo "🛑 Parando container Docker..."
    docker stop donation-site
    docker rm donation-site
    echo "✅ Container parado"
else
    echo "ℹ️ Container não estava rodando"
fi
echo ""

# 2. Criar diretório do site
echo "2️⃣ CRIANDO DIRETÓRIO DO SITE"
echo "-----------------------------------"
mkdir -p $SITE_DIR
echo "✅ Diretório criado: $SITE_DIR"
echo ""

# 3. Copiar arquivos do site
echo "3️⃣ COPIANDO ARQUIVOS DO SITE"
echo "-----------------------------------"
echo "📁 Copiando arquivos..."

# Copiar arquivos HTML
cp *.html $SITE_DIR/ 2>/dev/null || echo "⚠️ Nenhum arquivo HTML encontrado"

# Copiar diretórios
[ -d "css" ] && cp -r css $SITE_DIR/ && echo "✅ CSS copiado"
[ -d "js" ] && cp -r js $SITE_DIR/ && echo "✅ JavaScript copiado"
[ -d "assets" ] && cp -r assets $SITE_DIR/ && echo "✅ Assets copiados"

# Copiar outros arquivos importantes
[ -f "robots.txt" ] && cp robots.txt $SITE_DIR/ && echo "✅ robots.txt copiado"

# Definir permissões
chown -R www-data:www-data $SITE_DIR
chmod -R 755 $SITE_DIR
echo "✅ Permissões configuradas"
echo ""

# 4. Verificar nginx nativo
echo "4️⃣ VERIFICANDO NGINX NATIVO"
echo "-----------------------------------"
if ! command -v nginx &> /dev/null; then
    echo "❌ Nginx nativo não está instalado!"
    echo "💡 Execute: apt update && apt install nginx"
    exit 1
fi

echo "✅ Nginx nativo encontrado"
echo "📊 Versão: $(nginx -v 2>&1)"

# Detectar domínio SSL válido
SSL_DOMAIN=""
SSL_AVAILABLE=false

if [ -d "/etc/letsencrypt/live" ]; then
    echo "🔍 Procurando certificados SSL..."
    
    # Procurar por diretórios que não sejam README
    for domain_dir in /etc/letsencrypt/live/*/; do
        if [ -d "$domain_dir" ]; then
            domain=$(basename "$domain_dir")
            
            # Ignorar README e outros arquivos que não sejam domínios
            if [ "$domain" != "README" ] && [ "$domain" != "." ] && [ "$domain" != ".." ]; then
                # Verificar se existe o certificado
                if [ -f "$domain_dir/fullchain.pem" ] && [ -f "$domain_dir/privkey.pem" ]; then
                    SSL_DOMAIN="$domain"
                    SSL_AVAILABLE=true
                    echo "✅ Certificado SSL encontrado para: $domain"
                    
                    # Verificar validade do certificado
                    if openssl x509 -checkend 86400 -noout -in "$domain_dir/fullchain.pem" 2>/dev/null; then
                        echo "✅ Certificado válido por mais de 24 horas"
                    else
                        echo "⚠️ Certificado expira em menos de 24 horas"
                    fi
                    break
                fi
            fi
        fi
    done
    
    if [ "$SSL_AVAILABLE" = false ]; then
        echo "❌ Nenhum certificado SSL válido encontrado"
        echo "💡 Execute: certbot --nginx -d $DOMAIN"
        echo "ℹ️ Configurando sem SSL por enquanto..."
    fi
else
    echo "❌ Diretório Let's Encrypt não encontrado"
    echo "💡 Execute: certbot --nginx -d $DOMAIN"
    echo "ℹ️ Configurando sem SSL por enquanto..."
fi
echo ""

# 5. Criar configuração nginx
echo "5️⃣ CRIANDO CONFIGURAÇÃO NGINX"
echo "-----------------------------------"

if [ "$SSL_AVAILABLE" = true ] && [ ! -z "$SSL_DOMAIN" ]; then
    echo "🔒 Configurando com SSL para domínio: $SSL_DOMAIN"
    
    # Configuração com SSL
    cat > $NGINX_AVAILABLE/todos-por-um << EOF
# Configuração para Todos Por Um Futuro Melhor
# Nginx nativo com SSL

# Redirect HTTP to HTTPS
server {
    listen 80;
    server_name $SSL_DOMAIN $VPS_IP;
    return 301 https://\$server_name\$request_uri;
}

# HTTPS Server
server {
    listen 443 ssl http2;
    server_name $SSL_DOMAIN $VPS_IP;
    
    root $SITE_DIR;
    index index.html index.htm;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/$SSL_DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/$SSL_DOMAIN/privkey.pem;
    include /etc/letsencrypt/options-ssl-nginx.conf;
    ssl_dhparam /etc/letsencrypt/ssl-dhparams.pem;

    # Headers de segurança
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Strict-Transport-Security "max-age=63072000; includeSubDomains; preload" always;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;

    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://www.youtube.com; style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' data:; frame-src 'self' https://www.youtube.com; connect-src 'self'" always;

    # Configuração principal
    location / {
        try_files \$uri \$uri/ =404;
        
        # Headers para arquivos HTML
        location ~* \.(html?)\$ {
            expires -1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
    }

    # Cache para assets estáticos
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|webp|pdf)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Prevenir acesso a arquivos sensíveis
    location ~ /\.ht {
        deny all;
    }

    location ~ /\. {
        deny all;
    }

    location ~* \.(htaccess|htpasswd|ini|log|sh|inc|bak|sql)\$ {
        deny all;
    }

    # Disable directory browsing
    autoindex off;

    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    # Logs
    access_log /var/log/nginx/todos-por-um-access.log;
    error_log /var/log/nginx/todos-por-um-error.log;
}
EOF

else
    echo "🌐 Configurando sem SSL (HTTP apenas)"
    
    # Configuração sem SSL
    cat > $NGINX_AVAILABLE/todos-por-um << EOF
# Configuração para Todos Por Um Futuro Melhor
# Nginx nativo sem SSL (HTTP apenas)

server {
    listen 80;
    server_name $DOMAIN $VPS_IP;
    
    root $SITE_DIR;
    index index.html index.htm;

    # Headers de segurança
    add_header X-Frame-Options "DENY" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;
    add_header Permissions-Policy "camera=(), microphone=(), geolocation=()" always;

    # Content Security Policy
    add_header Content-Security-Policy "default-src 'self'; script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://www.youtube.com; style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com; font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; img-src 'self' data:; frame-src 'self' https://www.youtube.com; connect-src 'self'" always;

    # Configuração principal
    location / {
        try_files \$uri \$uri/ =404;
        
        # Headers para arquivos HTML
        location ~* \.(html?)\$ {
            expires -1;
            add_header Cache-Control "no-cache, no-store, must-revalidate";
        }
    }

    # Cache para assets estáticos
    location ~* \.(css|js|png|jpg|jpeg|gif|ico|svg|webp|pdf)\$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
        access_log off;
    }

    # Prevenir acesso a arquivos sensíveis
    location ~ /\.ht {
        deny all;
    }

    location ~ /\. {
        deny all;
    }

    location ~* \.(htaccess|htpasswd|ini|log|sh|inc|bak|sql)\$ {
        deny all;
    }

    # Disable directory browsing
    autoindex off;

    # Custom error pages
    error_page 404 /404.html;
    error_page 500 502 503 504 /50x.html;

    # Logs
    access_log /var/log/nginx/todos-por-um-access.log;
    error_log /var/log/nginx/todos-por-um-error.log;
}
EOF
fi

echo "✅ Configuração nginx criada"
echo ""

# 6. Ativar site
echo "6️⃣ ATIVANDO SITE"
echo "-----------------------------------"

# Criar link simbólico
ln -sf $NGINX_AVAILABLE/todos-por-um $NGINX_ENABLED/
echo "✅ Site ativado"

# Testar configuração
echo "🧪 Testando configuração nginx..."
if nginx -t; then
    echo "✅ Configuração nginx válida"
else
    echo "❌ Erro na configuração nginx"
    echo "💡 Verifique os logs: nginx -t"
    exit 1
fi
echo ""

# 7. Recarregar nginx
echo "7️⃣ RECARREGANDO NGINX"
echo "-----------------------------------"
systemctl reload nginx
echo "✅ Nginx recarregado"
echo ""

# 8. Verificar status
echo "8️⃣ VERIFICANDO STATUS"
echo "-----------------------------------"
if systemctl is-active --quiet nginx; then
    echo "✅ Nginx está rodando"
else
    echo "❌ Nginx não está rodando"
    echo "💡 Execute: systemctl start nginx"
fi

# Verificar portas
echo "📡 Portas ativas:"
ss -tlnp | grep nginx | grep -E ":(80|443)"
echo ""

# 9. Testar conectividade
echo "9️⃣ TESTANDO CONECTIVIDADE"
echo "-----------------------------------"
echo "🔍 Testando HTTP:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 2>/dev/null || echo "000")
echo "   HTTP Response: $HTTP_CODE"

if [ "$SSL_AVAILABLE" = true ]; then
    echo "🔒 Testando HTTPS:"
    HTTPS_CODE=$(curl -s -o /dev/null -w "%{http_code}" https://127.0.0.1 -k 2>/dev/null || echo "000")
    echo "   HTTPS Response: $HTTPS_CODE"
fi
echo ""

# 10. Instruções finais
echo "🎉 MIGRAÇÃO CONCLUÍDA!"
echo "=========================================="

if [ "$SSL_AVAILABLE" = true ]; then
    echo "🔒 Site migrado com sucesso para nginx nativo com SSL!"
    echo ""
    echo "📋 URLs de acesso:"
    echo "   • HTTP: http://$VPS_IP (redireciona para HTTPS)"
    echo "   • HTTPS: https://$VPS_IP"
    echo "   • Domínio: https://$SSL_DOMAIN"
    echo ""
    echo "🔧 Se precisar reconfigurar SSL:"
    echo "   • Execute: certbot --nginx -d $SSL_DOMAIN"
else
    echo "🌐 Site migrado para nginx nativo (HTTP apenas)"
    echo ""
    echo "📋 URLs de acesso:"
    echo "   • HTTP: http://$VPS_IP"
    echo "   • HTTP: http://$DOMAIN"
    echo ""
    echo "🔒 Para adicionar SSL:"
    echo "   • Execute: certbot --nginx -d $DOMAIN"
    echo "   • Depois execute novamente: ./migrate-to-ssl.sh"
fi

echo ""
echo "📊 Comandos úteis:"
echo "   • Status nginx: systemctl status nginx"
echo "   • Recarregar: systemctl reload nginx"
echo "   • Logs: tail -f /var/log/nginx/todos-por-um-*.log"
echo "   • Testar config: nginx -t"
if [ "$SSL_AVAILABLE" = true ]; then
echo "   • Renovar SSL: certbot renew"
fi
echo ""
echo "✅ Site está rodando no nginx nativo!"
echo "=========================================="