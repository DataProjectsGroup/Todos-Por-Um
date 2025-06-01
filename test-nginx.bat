@echo off
echo =========================================
echo    TESTE DO SITE COM NGINX
echo =========================================
echo.

echo Verificando se Docker esta instalado...
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Docker nao encontrado!
    echo Instale o Docker Desktop primeiro.
    pause
    exit /b 1
)

echo Docker encontrado! ✓
echo.

echo Verificando se Docker Desktop esta rodando...
docker info >nul 2>&1
if %errorlevel% neq 0 (
    echo [ERRO] Docker Desktop nao esta rodando!
    echo Abra o Docker Desktop e aguarde ele inicializar.
    echo Depois execute este script novamente.
    pause
    exit /b 1
)

echo Docker Desktop esta rodando! ✓
echo.

echo Construindo a imagem com nginx...
docker-compose build

echo.
echo Iniciando o servidor nginx...
docker-compose up -d

echo.
echo =========================================
echo  SITE RODANDO COM NGINX!
echo =========================================
echo.
echo 🌐 Acesse: http://localhost:8080
echo.
echo Comandos uteis:
echo   Ver logs:    docker-compose logs -f
echo   Parar:       docker-compose down
echo   Reiniciar:   docker-compose restart
echo.
echo Pressione qualquer tecla para abrir o site...
pause >nul

start http://localhost:8080 