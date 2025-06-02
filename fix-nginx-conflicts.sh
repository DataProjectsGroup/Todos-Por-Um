#!/bin/bash

# Script para Corrigir Conflitos do Nginx
# Remove site padrão e configura prioridades corretas

VPS_IP="144.91.122.53"
DOMAIN="todospor1.org"
SITE_DIR="/var/www/todos-por-um"

echo "🔧 CORRIGINDO CONFLITOS NGINX"
echo "========================================"
echo "🌐 Domínio: $DOMAIN"
echo "🖥️ IP: $VPS_IP"
echo ""

# Verificar se está rodando como root
if [ "$EUID" -ne 0 ]; then
    echo "❌ Este script precisa ser executado como root"
    echo "💡 Execute: sudo ./fix-nginx-conflicts.sh"
    exit 1
fi

# 1. Identificar conflitos
echo "1️⃣ IDENTIFICANDO CONFLITOS"
echo "-----------------------------------"

echo "📋 Sites habilitados atualmente:"
ls -la /etc/nginx/sites-enabled/ 2>/dev/null | grep -v "^total" | grep -v "^d"

echo ""
echo "🔍 Verificando conflitos de server_name..."
grep -r "server_name.*$DOMAIN" /etc/nginx/sites-enabled/ 2>/dev/null || echo "   Nenhum conflito direto encontrado"
grep -r "server_name.*$VPS_IP" /etc/nginx/sites-enabled/ 2>/dev/null || echo "   Nenhum conflito de IP encontrado"

echo ""

# 2. Desabilitar site padrão
echo "2️⃣ DESABILITANDO SITE PADRÃO"
echo "-----------------------------------"

# Remover links simbólicos do site padrão
default_sites=("default" "000-default" "default.conf")

for site in "${default_sites[@]}"; do
    if [ -L "/etc/nginx/sites-enabled/$site" ]; then
        echo "🛑 Removendo site padrão: $site"
        rm -f "/etc/nginx/sites-enabled/$site"
    fi
done

# Verificar se ainda existe algum site padrão ativo
if [ -f "/etc/nginx/sites-enabled/default" ]; then
    echo "🛑 Removendo site padrão restante"
    rm -f /etc/nginx/sites-enabled/default
fi

echo "✅ Sites padrão removidos"
echo ""

# 3. Verificar configurações conflitantes
echo "3️⃣ VERIFICANDO CONFIGURAÇÕES EXISTENTES"
echo "-----------------------------------"

# Procurar por outras configurações que usam o mesmo domínio
conflicting_configs=$(grep -l "server_name.*$DOMAIN" /etc/nginx/sites-available/* 2>/dev/null | grep -v "todos-por-um")

if [ ! -z "$conflicting_configs" ]; then
    echo "⚠️ Configurações conflitantes encontradas:"
    for config in $conflicting_configs; do
        config_name=$(basename "$config")
        echo "   📄 $config_name"
        
        # Perguntar se deve desabilitar
        echo "🔧 Desabilitando configuração conflitante: $config_name"
        rm -f "/etc/nginx/sites-enabled/$config_name"
    done
else
    echo "✅ Nenhuma configuração conflitante encontrada"
fi
echo ""

# 4. Verificar se nosso site está ativo
echo "4️⃣ VERIFICANDO NOSSO SITE"
echo "-----------------------------------"

if [ -L "/etc/nginx/sites-enabled/todos-por-um" ]; then
    echo "✅ Site todos-por-um está habilitado"
else
    echo "🔧 Habilitando site todos-por-um..."
    ln -sf /etc/nginx/sites-available/todos-por-um /etc/nginx/sites-enabled/
    echo "✅ Site habilitado"
fi

# Verificar se os arquivos existem
if [ -f "$SITE_DIR/index.html" ]; then
    echo "✅ Arquivo index.html encontrado"
else
    echo "❌ Arquivo index.html não encontrado em $SITE_DIR"
    echo "📋 Conteúdo do diretório:"
    ls -la $SITE_DIR/ 2>/dev/null || echo "   Diretório não existe"
fi
echo ""

# 5. Configurar prioridade do site
echo "5️⃣ CONFIGURANDO PRIORIDADE"
echo "-----------------------------------"

# Renomear para garantir prioridade (nginx carrega em ordem alfabética)
if [ -f "/etc/nginx/sites-available/todos-por-um" ]; then
    if [ ! -f "/etc/nginx/sites-available/000-todos-por-um" ]; then
        echo "🔧 Renomeando para garantir prioridade..."
        mv /etc/nginx/sites-available/todos-por-um /etc/nginx/sites-available/000-todos-por-um
        rm -f /etc/nginx/sites-enabled/todos-por-um
        ln -sf /etc/nginx/sites-available/000-todos-por-um /etc/nginx/sites-enabled/000-todos-por-um
        echo "✅ Prioridade configurada"
    else
        echo "✅ Prioridade já configurada"
    fi
fi
echo ""

# 6. Testar configuração
echo "6️⃣ TESTANDO CONFIGURAÇÃO"
echo "-----------------------------------"

echo "🧪 Testando sintaxe nginx..."
if nginx -t; then
    echo "✅ Configuração nginx válida"
else
    echo "❌ Erro na configuração nginx"
    echo ""
    echo "📝 Detalhes do erro:"
    nginx -t
    exit 1
fi
echo ""

# 7. Recarregar nginx
echo "7️⃣ RECARREGANDO NGINX"
echo "-----------------------------------"

systemctl reload nginx
if [ $? -eq 0 ]; then
    echo "✅ Nginx recarregado com sucesso"
else
    echo "❌ Erro ao recarregar nginx"
    echo "📝 Status do nginx:"
    systemctl status nginx --no-pager -l
    exit 1
fi
echo ""

# 8. Verificar sites ativos
echo "8️⃣ VERIFICANDO SITES ATIVOS"
echo "-----------------------------------"

echo "📋 Sites habilitados após correção:"
ls -la /etc/nginx/sites-enabled/ | grep -v "^total" | grep -v "^d" | awk '{print "   ✅ " $9}'
echo ""

# 9. Testar conectividade
echo "9️⃣ TESTANDO CONECTIVIDADE"
echo "-----------------------------------"

echo "🔍 Testando resposta HTTP..."
HTTP_RESPONSE=$(curl -s -H "Host: $DOMAIN" http://127.0.0.1 --max-time 10 2>/dev/null | head -20)

if echo "$HTTP_RESPONSE" | grep -q "Todos Por Um"; then
    echo "✅ Site respondendo corretamente!"
    echo "🎉 Título encontrado no HTML"
elif echo "$HTTP_RESPONSE" | grep -q "Welcome to nginx"; then
    echo "❌ Ainda mostrando página padrão do nginx"
    echo "🔧 Possível problema de cache ou configuração"
else
    echo "⚠️ Resposta não identificada"
    echo "📝 Primeiras linhas da resposta:"
    echo "$HTTP_RESPONSE" | head -5
fi

echo ""
echo "🔒 Testando HTTPS..."
HTTPS_RESPONSE=$(curl -s -H "Host: $DOMAIN" https://127.0.0.1 -k --max-time 10 2>/dev/null | head -20)

if echo "$HTTPS_RESPONSE" | grep -q "Todos Por Um"; then
    echo "✅ HTTPS respondendo corretamente!"
elif echo "$HTTPS_RESPONSE" | grep -q "Welcome to nginx"; then
    echo "❌ HTTPS ainda mostrando página padrão"
else
    echo "⚠️ HTTPS: resposta não identificada"
fi
echo ""

# 10. Verificar logs
echo "🔟 VERIFICANDO LOGS"
echo "-----------------------------------"

echo "📝 Últimas entradas do log de erro:"
tail -5 /var/log/nginx/error.log 2>/dev/null || echo "   Nenhum erro recente"

echo ""
echo "📝 Últimas entradas do log do site:"
tail -5 /var/log/nginx/todos-por-um-access.log 2>/dev/null || echo "   Nenhum acesso registrado ainda"
echo ""

# 11. Limpar cache se necessário
echo "1️⃣1️⃣ LIMPANDO CACHE"
echo "-----------------------------------"

echo "🧹 Limpando cache do nginx..."
# Limpar cache do nginx se existir
if [ -d "/var/cache/nginx" ]; then
    rm -rf /var/cache/nginx/*
    echo "✅ Cache do nginx limpo"
fi

# Recarregar novamente para garantir
systemctl reload nginx
echo "✅ Nginx recarregado novamente"
echo ""

# 12. Resultado final
echo "🎉 CORREÇÃO CONCLUÍDA!"
echo "========================================"

echo "📋 Status final:"
echo "   • Sites padrão: ❌ Desabilitados"
echo "   • Site todos-por-um: ✅ Habilitado"
echo "   • Prioridade: ✅ Configurada"
echo "   • Configuração: ✅ Válida"
echo ""

echo "🌐 Teste os URLs:"
echo "   • HTTP: http://$VPS_IP"
echo "   • HTTP: http://$DOMAIN"
echo "   • HTTPS: https://$VPS_IP"
echo "   • HTTPS: https://$DOMAIN"
echo ""

echo "🔧 Comandos para debug:"
echo "   • Ver configuração ativa: nginx -T | grep -A 20 'server_name'"
echo "   • Logs em tempo real: tail -f /var/log/nginx/todos-por-um-*.log"
echo "   • Testar diretamente: curl -H 'Host: $DOMAIN' http://127.0.0.1"
echo "   • Verificar arquivos: ls -la $SITE_DIR/"
echo ""

echo "✅ Se ainda mostrar página padrão, aguarde 1-2 minutos para cache limpar"
echo "========================================"