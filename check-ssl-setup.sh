#!/bin/bash

# Script para Verificar Configuração SSL Existente
# Verifica o que seu amigo já configurou no servidor

echo "🔍 VERIFICANDO CONFIGURAÇÃO SSL EXISTENTE"
echo "================================================"
echo "📅 Data/Hora: $(date)"
echo ""

# 1. Verificar nginx nativo
echo "1️⃣ NGINX NATIVO"
echo "-----------------------------------"
if command -v nginx &> /dev/null; then
    echo "✅ Nginx nativo instalado"
    echo "📊 Versão: $(nginx -v 2>&1)"
    
    if systemctl is-active --quiet nginx; then
        echo "✅ Nginx está rodando"
    else
        echo "❌ Nginx não está rodando"
    fi
    
    # Verificar configuração
    echo "🧪 Testando configuração:"
    if nginx -t 2>/dev/null; then
        echo "✅ Configuração nginx válida"
    else
        echo "⚠️ Problemas na configuração nginx"
        echo "📝 Detalhes:"
        nginx -t
    fi
else
    echo "❌ Nginx nativo não está instalado"
fi
echo ""

# 2. Verificar certbot/Let's Encrypt
echo "2️⃣ CERTIFICADOS SSL"
echo "-----------------------------------"
if command -v certbot &> /dev/null; then
    echo "✅ Certbot instalado"
    echo "📊 Versão: $(certbot --version 2>/dev/null | head -n1)"
    
    # Verificar certificados
    if [ -d "/etc/letsencrypt/live" ]; then
        echo "🔒 Certificados SSL encontrados:"
        ls -la /etc/letsencrypt/live/ | grep -v "^total" | grep -v "README"
        
        # Mostrar detalhes dos certificados
        for domain_dir in /etc/letsencrypt/live/*/; do
            if [ -d "$domain_dir" ]; then
                domain=$(basename "$domain_dir")
                echo ""
                echo "📋 Certificado para: $domain"
                if [ -f "$domain_dir/fullchain.pem" ]; then
                    expire_date=$(openssl x509 -enddate -noout -in "$domain_dir/fullchain.pem" 2>/dev/null | cut -d= -f2)
                    echo "   📅 Expira em: $expire_date"
                    
                    # Verificar se está próximo do vencimento (30 dias)
                    if openssl x509 -checkend 2592000 -noout -in "$domain_dir/fullchain.pem" 2>/dev/null; then
                        echo "   ✅ Certificado válido por mais de 30 dias"
                    else
                        echo "   ⚠️ Certificado expira em menos de 30 dias"
                    fi
                fi
            fi
        done
    else
        echo "❌ Nenhum certificado SSL encontrado"
        echo "💡 Execute: certbot --nginx"
    fi
else
    echo "❌ Certbot não está instalado"
    echo "💡 Execute: apt install certbot python3-certbot-nginx"
fi
echo ""

# 3. Verificar portas
echo "3️⃣ PORTAS DE REDE"
echo "-----------------------------------"
echo "📡 Portas ativas:"
ss -tlnp | grep -E ":(80|443|22)" | while read line; do
    port=$(echo "$line" | grep -o ":[0-9]*" | head -n1 | cut -d: -f2)
    process=$(echo "$line" | grep -o "users:(([^)]*" | cut -d'(' -f3 | cut -d',' -f1)
    
    case $port in
        80)  echo "   🌐 HTTP  (80):  $process" ;;
        443) echo "   🔒 HTTPS (443): $process" ;;
        22)  echo "   🔑 SSH   (22):  $process" ;;
        *)   echo "   📡 Port ($port): $process" ;;
    esac
done
echo ""

# 4. Verificar sites nginx
echo "4️⃣ SITES NGINX CONFIGURADOS"
echo "-----------------------------------"
if [ -d "/etc/nginx/sites-available" ]; then
    echo "📁 Sites disponíveis:"
    ls -la /etc/nginx/sites-available/ | grep -v "^total" | grep -v "^d" | awk '{print "   📄 " $9}'
    
    echo ""
    echo "🔗 Sites habilitados:"
    if [ -d "/etc/nginx/sites-enabled" ]; then
        ls -la /etc/nginx/sites-enabled/ | grep -v "^total" | grep -v "^d" | awk '{print "   ✅ " $9}'
    else
        echo "   ❌ Diretório sites-enabled não existe"
    fi
else
    echo "❌ Estrutura de sites nginx não encontrada"
    echo "💡 Nginx pode estar usando /etc/nginx/conf.d/"
    
    if [ -d "/etc/nginx/conf.d" ]; then
        echo "📁 Configurações em conf.d:"
        ls -la /etc/nginx/conf.d/ | grep -v "^total" | grep "\.conf" | awk '{print "   📄 " $9}'
    fi
fi
echo ""

# 5. Verificar diretório web
echo "5️⃣ DIRETÓRIO WEB"
echo "-----------------------------------"
common_dirs=("/var/www/html" "/var/www" "/usr/share/nginx/html")

for dir in "${common_dirs[@]}"; do
    if [ -d "$dir" ]; then
        echo "📁 $dir existe"
        if [ -f "$dir/index.html" ] || [ -f "$dir/index.nginx-debian.html" ]; then
            echo "   ✅ Contém arquivos web"
        else
            echo "   📝 Vazio ou sem index"
        fi
    fi
done
echo ""

# 6. Verificar firewall
echo "6️⃣ FIREWALL"
echo "-----------------------------------"
if command -v ufw &> /dev/null; then
    echo "🔥 UFW Status:"
    ufw status | head -20
else
    echo "ℹ️ UFW não está instalado"
fi

if command -v iptables &> /dev/null; then
    echo ""
    echo "🔥 Regras iptables para HTTP/HTTPS:"
    iptables -L INPUT -n | grep -E "(80|443)" | head -5 || echo "   Nenhuma regra específica"
fi
echo ""

# 7. Testar conectividade
echo "7️⃣ TESTE DE CONECTIVIDADE"
echo "-----------------------------------"
echo "🌐 Testando HTTP (porta 80):"
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 --max-time 5 2>/dev/null | grep -q "200\|301\|302"; then
    http_code=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 --max-time 5 2>/dev/null)
    echo "   ✅ Respondendo: HTTP $http_code"
else
    echo "   ❌ Não responde na porta 80"
fi

echo "🔒 Testando HTTPS (porta 443):"
if curl -s -o /dev/null -w "%{http_code}" https://127.0.0.1 -k --max-time 5 2>/dev/null | grep -q "200\|301\|302"; then
    https_code=$(curl -s -o /dev/null -w "%{http_code}" https://127.0.0.1 -k --max-time 5 2>/dev/null)
    echo "   ✅ Respondendo: HTTPS $https_code"
else
    echo "   ❌ Não responde na porta 443"
fi
echo ""

# 8. Verificar Docker
echo "8️⃣ CONTAINERS DOCKER"
echo "-----------------------------------"
if command -v docker &> /dev/null; then
    echo "🐳 Docker instalado"
    
    running_containers=$(docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null)
    if [ ! -z "$running_containers" ]; then
        echo "📦 Containers rodando:"
        echo "$running_containers"
    else
        echo "📦 Nenhum container rodando"
    fi
    
    # Verificar se existe container do site
    if docker ps -a -q -f name=donation-site | grep -q .; then
        echo "🎯 Container donation-site encontrado"
        docker ps -a --filter name=donation-site --format "table {{.Names}}\t{{.Status}}"
    fi
else
    echo "ℹ️ Docker não está instalado"
fi
echo ""

# 9. Resumo e recomendações
echo "🎯 RESUMO E RECOMENDAÇÕES"
echo "================================================"

# Verificar se tudo está pronto para migração
ssl_ready=false
nginx_ready=false

if [ -d "/etc/letsencrypt/live" ] && command -v nginx &> /dev/null; then
    ssl_ready=true
fi

if systemctl is-active --quiet nginx; then
    nginx_ready=true
fi

if [ "$ssl_ready" = true ] && [ "$nginx_ready" = true ]; then
    echo "✅ PRONTO PARA MIGRAÇÃO!"
    echo "   • Nginx nativo funcionando"
    echo "   • Certificados SSL configurados"
    echo "   • Portas 80 e 443 ativas"
    echo ""
    echo "📋 Próximos passos:"
    echo "   1. Execute: git pull origin main"
    echo "   2. Execute: chmod +x migrate-to-ssl.sh"
    echo "   3. Execute: sudo ./migrate-to-ssl.sh"
else
    echo "⚠️ CONFIGURAÇÃO INCOMPLETA"
    
    if [ "$nginx_ready" = false ]; then
        echo "   ❌ Nginx nativo não está funcionando"
        echo "      💡 Execute: systemctl start nginx"
    fi
    
    if [ "$ssl_ready" = false ]; then
        echo "   ❌ Certificados SSL não encontrados"
        echo "      💡 Execute: certbot --nginx"
    fi
fi

echo ""
echo "📞 COMANDOS ÚTEIS PARA SEU AMIGO:"
echo "   • Instalar certbot: apt install certbot python3-certbot-nginx"
echo "   • Configurar SSL: certbot --nginx"
echo "   • Verificar nginx: systemctl status nginx"
echo "   • Testar config: nginx -t"
echo "================================================"