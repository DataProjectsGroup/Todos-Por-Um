#!/bin/bash

# Script de Instalação - Site Todos Por Um Futuro Melhor
# Para Ubuntu/Debian

echo "🚀 Iniciando instalação das dependências..."
echo "==============================================="

# Atualizar lista de pacotes
echo "📦 Atualizando lista de pacotes..."
sudo apt update

# Instalar dependências básicas
echo "🔧 Instalando dependências básicas..."
sudo apt install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release \
    git \
    wget

# Adicionar chave GPG oficial do Docker
echo "🔑 Adicionando chave GPG do Docker..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Adicionar repositório Docker
echo "📋 Adicionando repositório Docker..."
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Atualizar lista de pacotes novamente
echo "🔄 Atualizando lista de pacotes com repositório Docker..."
sudo apt update

# Instalar Docker
echo "🐳 Instalando Docker..."
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Adicionar usuário atual ao grupo docker
echo "👤 Adicionando usuário ao grupo docker..."
sudo usermod -aG docker $USER

# Iniciar e habilitar Docker
echo "▶️ Iniciando serviço Docker..."
sudo systemctl start docker
sudo systemctl enable docker

# Verificar instalação
echo "✅ Verificando instalação do Docker..."
if docker --version && docker compose version; then
    echo "✅ Docker instalado com sucesso!"
else
    echo "❌ Erro na instalação do Docker"
    exit 1
fi

echo ""
echo "🎉 INSTALAÇÃO CONCLUÍDA COM SUCESSO!"
echo "==============================================="
echo "📋 Próximos passos:"
echo "1. Faça logout e login novamente (ou reinicie) para aplicar as permissões do Docker"
echo "2. Clone este repositório se ainda não fez:"
echo "   git clone <url-do-repositorio>"
echo "3. Execute o script de execução:"
echo "   ./run.sh"
echo ""
echo "⚠️  IMPORTANTE: Você precisa fazer logout/login ou reiniciar para usar o Docker sem sudo!"
echo "===============================================" 