#!/bin/bash

# Script de Execução - Site Todos Por Um Futuro Melhor
# Para Ubuntu/Debian - VPS Contabo

VPS_IP="144.91.122.53"
CONTAINER_NAME="donation-site"
IMAGE_NAME="donation-daniel"
PORT="80"

echo "🌐 Iniciando Site Todos Por Um Futuro Melhor..."
echo "==============================================="
echo "🖥️ VPS IP: $VPS_IP"

# Verificar se Docker está instalado
if ! command -v docker &> /dev/null; then
    echo "❌ Docker não está instalado!"
    echo "Execute primeiro: ./install.sh"
    exit 1
fi

# Verificar se Docker está rodando
if ! docker info &> /dev/null; then
    echo "❌ Docker não está rodando!"
    echo "Iniciando Docker..."
    sudo systemctl start docker
    sleep 3
fi

# Parar container anterior se existir
echo "🛑 Parando container anterior..."
docker stop $CONTAINER_NAME 2>/dev/null || true
docker rm $CONTAINER_NAME 2>/dev/null || true

# Construir a imagem
echo "🏗️ Construindo imagem Docker..."
if docker build -t $IMAGE_NAME .; then
    echo "✅ Imagem construída com sucesso!"
else
    echo "❌ Erro ao construir imagem!"
    docker logs $CONTAINER_NAME 2>/dev/null || true
    exit 1
fi

# Executar o container
echo "🚀 Iniciando container..."
if docker run -d \
    -p $PORT:80 \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    $IMAGE_NAME; then
    echo "✅ Container iniciado com sucesso!"
else
    echo "❌ Erro ao iniciar container!"
    docker logs $CONTAINER_NAME 2>/dev/null || true
    exit 1
fi

# Aguardar alguns segundos para o servidor inicializar
echo "⏳ Aguardando servidor inicializar..."
sleep 8

# Verificar se está funcionando
echo "🔍 Verificando se o servidor está respondendo..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$PORT 2>/dev/null || echo "000")

if [[ "$HTTP_CODE" =~ ^(200|301|302)$ ]]; then
    echo "✅ Servidor está funcionando! (HTTP $HTTP_CODE)"
else
    echo "⚠️ Problemas detectados (HTTP $HTTP_CODE)"
    echo "📝 Verificando logs do container..."
    docker logs --tail 10 $CONTAINER_NAME
    echo ""
    echo "🔧 Status do container:"
    docker ps -a --filter name=$CONTAINER_NAME
fi

echo ""
echo "🎉 SITE CONFIGURADO PARA VPS!"
echo "==============================================="
echo "🌐 Acesse o site em: http://$VPS_IP"
echo "📋 Páginas disponíveis:"
echo "   • Página inicial: http://$VPS_IP"
echo "   • Cartilha: http://$VPS_IP/cartilha.html"
echo "   • Estatuto: http://$VPS_IP/estatuto.html"
echo "   • Doação: http://$VPS_IP/donate.html"
echo ""
echo "📊 Comandos úteis:"
echo "   • Ver logs: docker logs $CONTAINER_NAME"
echo "   • Ver logs em tempo real: docker logs -f $CONTAINER_NAME"
echo "   • Parar site: docker stop $CONTAINER_NAME"
echo "   • Reiniciar: docker restart $CONTAINER_NAME"
echo "   • Status: docker ps"
echo "   • Entrar no container: docker exec -it $CONTAINER_NAME sh"
echo ""
echo "🔧 Debug:"
echo "   • Verificar porta: netstat -tlnp | grep :$PORT"
echo "   • Testar local: curl -I http://127.0.0.1:$PORT"
echo "   • Verificar firewall: ufw status"
echo ""
echo "💡 Para parar o site use: docker stop $CONTAINER_NAME"
echo "==============================================="