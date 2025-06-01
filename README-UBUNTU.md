# 🌐 Site Todos Por Um Futuro Melhor - Instalação Ubuntu

Este guia mostra como instalar e executar o site no Ubuntu/Debian.

## 📋 Pré-requisitos

- Ubuntu 18.04+ ou Debian 10+
- Conexão com internet
- Usuário com privilégios sudo

## 🚀 Instalação Rápida

### 1️⃣ Dar Permissão aos Scripts

```bash
chmod +x install.sh run.sh
```

### 2️⃣ Instalar Dependências

```bash
./install.sh
```

Este script irá instalar:
- Docker
- Docker Compose
- Git
- Outras dependências necessárias

### 3️⃣ Reiniciar (IMPORTANTE!)

Após a instalação, **faça logout e login novamente** ou reinicie o sistema:

```bash
# Opção 1: Logout/Login
exit

# Opção 2: Reiniciar
sudo reboot
```

### 4️⃣ Executar o Site

```bash
./run.sh
```

## 🌐 Acessar o Site

Após a execução, acesse:

- **Site principal**: http://localhost:8080
- **Cartilha**: http://localhost:8080/cartilha.html
- **Estatuto**: http://localhost:8080/estatuto.html

## 📊 Comandos Úteis

```bash
# Ver status dos containers
docker ps

# Ver logs do site
docker logs donation-site

# Parar o site
docker stop donation-site

# Reiniciar o site
docker restart donation-site

# Remover container
docker rm donation-site

# Reconstruir e executar
./run.sh
```

## 🛠️ Troubleshooting

### Problema: "Permission denied" no Docker

**Solução**: Você precisa fazer logout/login após a instalação
```bash
# Verificar se seu usuário está no grupo docker
groups $USER

# Se não mostrar "docker", execute:
sudo usermod -aG docker $USER
# Depois faça logout/login
```

### Problema: "Docker daemon not running"

**Solução**: Iniciar o serviço Docker
```bash
sudo systemctl start docker
sudo systemctl enable docker
```

### Problema: Porta 8080 em uso

**Solução**: Alterar porta no run.sh ou parar o serviço que está usando
```bash
# Ver o que está usando a porta 8080
sudo netstat -tulpn | grep 8080

# Ou alterar a porta no arquivo run.sh
# Linha: docker run -d -p 8080:80 --name donation-site donation-daniel
# Para: docker run -d -p 8081:80 --name donation-site donation-daniel
```

### Problema: "Build failed"

**Solução**: Verificar se todos os arquivos estão presentes
```bash
# Listar arquivos necessários
ls -la

# Devem existir:
# - Dockerfile
# - nginx-simple.conf
# - index.html
# - css/, js/, assets/
```

## 📁 Estrutura de Arquivos

```
Donation-Daniel/
├── install.sh          # Script de instalação
├── run.sh              # Script de execução
├── Dockerfile          # Configuração Docker
├── nginx-simple.conf   # Configuração Nginx
├── index.html          # Página principal
├── cartilha.html       # Página da cartilha
├── estatuto.html       # Página do estatuto
├── css/                # Estilos CSS
├── js/                 # Scripts JavaScript
└── assets/             # Imagens e arquivos
```

## 🔧 Personalização

### Alterar Porta

Edite o arquivo `run.sh` na linha:
```bash
docker run -d -p 8080:80 --name donation-site donation-daniel
```

Altere `8080` para sua porta desejada.

### Alterar Configurações Nginx

Edite o arquivo `nginx-simple.conf` conforme necessário.

## 🆘 Suporte

Em caso de problemas:

1. Verifique os logs: `docker logs donation-site`
2. Verifique se o Docker está rodando: `docker info`
3. Verifique a porta: `netstat -tulpn | grep 8080`
4. Reconstrua tudo: `./run.sh`

---

**Todos Por Um Futuro Melhor** - Erradicar a vulnerabilidade infanto-juvenil 