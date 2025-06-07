#!/bin/bash

# Script de Execução - Site Todos Por Um Futuro Melhor
# Para Ubuntu/Debian - VPS Contabo

# --------------------------------------------------
# CONFIGURAÇÕES
# --------------------------------------------------
IMAGE_NAME="todospor1"
CONTAINER_NAME="todospor1-container"
HOST_PORT=8080          # porta livre no host
CONTAINER_PORT=80       # porta que o app usa dentro do container

# --------------------------------------------------
# FUNÇÕES
# --------------------------------------------------
log() {
    echo "[$(date +'%Y-%m-%d %H:%M:%S')] $1"
}

# --------------------------------------------------
# EXECUÇÃO
# --------------------------------------------------
log "🌐 Iniciando Site Todos Por Um Futuro Melhor..."
echo "==============================================="
echo "🖥️ VPS IP: 144.91.122.53"

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

log "🛑 Limpando container antigo (se existir) ..."
docker rm -f $CONTAINER_NAME 2>/dev/null || true

log "🏗️ Construindo imagem $IMAGE_NAME ..."
docker build -t $IMAGE_NAME . || { log "❌ build falhou"; exit 1; }

log "▶️  Subindo container em 127.0.0.1:$HOST_PORT ..."
docker run -d \
    -p 127.0.0.1:$HOST_PORT:$CONTAINER_PORT \
    --name $CONTAINER_NAME \
    --restart unless-stopped \
    $IMAGE_NAME || { log "❌ falhou ao iniciar"; exit 1; }

# Teste de saúde
log "⏳ Aguardando app ..."
sleep 5
curl -fsI http://127.0.0.1:$HOST_PORT || {
    log "⚠️  App não respondeu — veja logs:"
    docker logs --tail 20 $CONTAINER_NAME
    exit 1
}

log "✅ Container iniciado com sucesso!"
log "📝 Logs disponíveis com: docker logs $CONTAINER_NAME"

# Aguardar alguns segundos para o servidor inicializar
echo "⏳ Aguardando servidor inicializar..."
sleep 8

# Verificar se está funcionando
echo "🔍 Verificando se o servidor está respondendo..."
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1:$HOST_PORT 2>/dev/null || echo "000")

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
echo "🌐 Acesse o site em: http://144.91.122.53"
echo "📋 Páginas disponíveis:"
echo "   • Página inicial: http://144.91.122.53"
echo "   • Cartilha: http://144.91.122.53/cartilha.html"
echo "   • Estatuto: http://144.91.122.53/estatuto.html"
echo "   • Doação: http://144.91.122.53/donate.html"
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
echo "   • Verificar porta: netstat -tlnp | grep :$HOST_PORT"
echo "   • Testar local: curl -I http://127.0.0.1:$HOST_PORT"
echo "   • Verificar firewall: ufw status"
echo ""
echo "💡 Para parar o site use: docker stop $CONTAINER_NAME"
echo "==============================================="