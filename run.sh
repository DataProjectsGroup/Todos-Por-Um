#!/bin/bash

# Script de Execução - Site Todos Por Um Futuro Melhor
# Para Ubuntu/Debian

echo "🌐 Iniciando Site Todos Por Um Futuro Melhor..."
echo "==============================================="

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
docker stop donation-site 2>/dev/null || true
docker rm donation-site 2>/dev/null || true

# Construir a imagem
echo "🏗️ Construindo imagem Docker..."
if docker build -t donation-daniel .; then
    echo "✅ Imagem construída com sucesso!"
else
    echo "❌ Erro ao construir imagem!"
    exit 1
fi

# Executar o container
echo "🚀 Iniciando container..."
if docker run -d -p 80:80 --name donation-site donation-daniel; then
    echo "✅ Container iniciado com sucesso!"
else
    echo "❌ Erro ao iniciar container!"
    exit 1
fi

# Aguardar alguns segundos para o servidor inicializar
echo "⏳ Aguardando servidor inicializar..."
sleep 5

# Verificar se está funcionando
echo "🔍 Verificando se o servidor está respondendo..."
if curl -s -o /dev/null -w "%{http_code}" http://127.0.0.1 | grep -q "200\|301\|302"; then
    echo "✅ Servidor está funcionando!"
else
    echo "⚠️ Servidor pode estar iniciando ainda..."
fi

echo ""
echo "🎉 SITE INICIADO COM SUCESSO!"
echo "==============================================="
echo "🌐 Acesse o site em: http://localhost:8080"
echo "📋 Páginas disponíveis:"
echo "   • Página inicial: http://localhost:8080"
echo "   • Cartilha: http://localhost:8080/cartilha.html"
echo "   • Estatuto: http://localhost:8080/estatuto.html"
echo ""
echo "📊 Comandos úteis:"
echo "   • Ver logs: docker logs donation-site"
echo "   • Parar site: docker stop donation-site"
echo "   • Reiniciar: docker restart donation-site"
echo "   • Status: docker ps"
echo ""
echo "💡 Para parar o site use: docker stop donation-site"
echo "===============================================" 
