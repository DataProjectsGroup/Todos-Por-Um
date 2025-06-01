#!/bin/bash

# Script de Debug - Site Todos Por Um Futuro Melhor
# Para diagnosticar problemas na VPS

VPS_IP="144.91.122.53"
CONTAINER_NAME="donation-site"
PORT="80"

echo "🔧 DIAGNÓSTICO DO SITE - VPS CONTABO"
echo "==============================================="
echo "🖥️ VPS IP: $VPS_IP"
echo "📅 Data/Hora: $(date)"
echo ""

# 1. Verificar Docker
echo "1️⃣ VERIFICANDO DOCKER"
echo "-----------------------------------"
if command -v docker &> /dev/null; then
    echo "✅ Docker instalado"
    if docker info &> /dev/null; then
        echo "✅ Docker está rodando"
        echo "📊 Versão: $(docker --version)"
    else
        echo "❌ Docker não está rodando"
        echo "💡 Execute: sudo systemctl start docker"
    fi
else
    echo "❌ Docker não está instalado"
    echo "💡 Execute: ./install.sh"
fi
echo ""

# 2. Verificar Container
echo "2️⃣ VERIFICANDO CONTAINER"
echo "-----------------------------------"
if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
    echo "✅ Container está rodando"
    echo "📊 Status detalhado:"
    docker ps --filter name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
    echo ""
    echo "💾 Uso de recursos:"
    docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}" $CONTAINER_NAME
else
    if docker ps -a -q -f name=$CONTAINER_NAME | grep -q .; then
        echo "⚠️ Container existe mas não está rodando"
        echo "📊 Status:"
        docker ps -a --filter name=$CONTAINER_NAME --format "table {{.Names}}\t{{.Status}}"
        echo ""
        echo "📝 Últimos logs:"
        docker logs --tail 10 $CONTAINER_NAME
    else
        echo "❌ Container não existe"
        echo "💡 Execute: ./run.sh"
    fi
fi
echo ""

# 3. Verificar Rede
echo "3️⃣ VERIFICANDO REDE"
echo "-----------------------------------"
if netstat -tlnp 2>/dev/null | grep -q ":$PORT"; then
    echo "✅ Porta $PORT está sendo usada"
    echo "📊 Detalhes da porta:"
    netstat -tlnp | grep ":$PORT"
else
    echo "❌ Porta $PORT não está sendo usada"
    echo "💡 Container pode estar parado"
fi

echo ""
echo "📡 Teste de conectividade local:"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$PORT 2>/dev/null || echo "000")
echo "   Localhost HTTP: $HTTP_CODE"

if command -v nc &> /dev/null; then
    if nc -z 127.0.0.1 $PORT 2>/dev/null; then
        echo "   ✅ Porta $PORT acessível localmente"
    else
        echo "   ❌ Porta $PORT não acessível localmente"
    fi
fi
echo ""

# 4. Verificar Firewall
echo "4️⃣ VERIFICANDO FIREWALL"
echo "-----------------------------------"
if command -v ufw &> /dev/null; then
    echo "🔥 Status UFW:"
    ufw status
    echo ""
    if ufw status | grep -q "Status: active"; then
        if ufw status | grep -q "$PORT/tcp"; then
            echo "✅ Porta $PORT liberada no UFW"
        else
            echo "⚠️ Porta $PORT pode não estar liberada"
            echo "💡 Execute: sudo ufw allow $PORT/tcp"
        fi
    fi
else
    echo "ℹ️ UFW não está instalado"
fi

if command -v iptables &> /dev/null; then
    echo "🔥 Regras iptables relevantes:"
    iptables -L INPUT -n | grep $PORT || echo "   Nenhuma regra específica para porta $PORT"
fi
echo ""

# 5. Verificar Logs
echo "5️⃣ LOGS DO SISTEMA"
echo "-----------------------------------"
if docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
    echo "📝 Últimos logs do container:"
    docker logs --tail 15 $CONTAINER_NAME
    echo ""
    echo "📊 Logs de erro do nginx:"
    docker exec $CONTAINER_NAME cat /var/log/nginx/error.log 2>/dev/null | tail -10 || echo "   Sem logs de erro do nginx"
else
    echo "❌ Container não está rodando - sem logs disponíveis"
fi
echo ""

# 6. Verificar Arquivos
echo "6️⃣ VERIFICANDO ARQUIVOS"
echo "-----------------------------------"
if [ -f "index.html" ]; then
    echo "✅ index.html existe"
else
    echo "❌ index.html não encontrado"
fi

if [ -f "Dockerfile" ]; then
    echo "✅ Dockerfile existe"
else
    echo "❌ Dockerfile não encontrado"
fi

if [ -f "nginx-security.conf" ]; then
    echo "✅ nginx-security.conf existe"
else
    echo "❌ nginx-security.conf não encontrado"
fi
echo ""

# 7. Sugestões
echo "7️⃣ SUGESTÕES DE CORREÇÃO"
echo "-----------------------------------"
if ! docker ps -q -f name=$CONTAINER_NAME | grep -q .; then
    echo "🔧 Container não está rodando:"
    echo "   1. Execute: ./run.sh"
    echo "   2. Se der erro, verifique: docker logs $CONTAINER_NAME"
    echo "   3. Reconstrua se necessário: docker build -t donation-daniel ."
fi

if ! netstat -tlnp 2>/dev/null | grep -q ":$PORT"; then
    echo "🔧 Porta $PORT não está ativa:"
    echo "   1. Verifique se o container está rodando"
    echo "   2. Verifique mapeamento de porta no docker run"
fi

if [ "$HTTP_CODE" = "000" ] || [ "$HTTP_CODE" = "403" ]; then
    echo "🔧 Site não está respondendo:"
    echo "   1. Verifique logs: docker logs $CONTAINER_NAME"
    echo "   2. Entre no container: docker exec -it $CONTAINER_NAME sh"
    echo "   3. Teste nginx: docker exec $CONTAINER_NAME nginx -t"
fi

echo ""
echo "📞 COMANDOS ÚTEIS"
echo "-----------------------------------"
echo "• Reiniciar tudo: ./run.sh"
echo "• Parar container: docker stop $CONTAINER_NAME"
echo "• Ver logs em tempo real: docker logs -f $CONTAINER_NAME"
echo "• Entrar no container: docker exec -it $CONTAINER_NAME sh"
echo "• Testar nginx: docker exec $CONTAINER_NAME nginx -t"
echo "• Recarregar nginx: docker exec $CONTAINER_NAME nginx -s reload"
echo "• Verificar arquivos: docker exec $CONTAINER_NAME ls -la /usr/share/nginx/html/"
echo "==============================================="