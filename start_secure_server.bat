@echo off
title Servidor HTTP Seguro - Todos Por Um
color 0A

echo.
echo ================================================================
echo                    SERVIDOR HTTP SEGURO
echo                   Todos Por Um Futuro Melhor
echo ================================================================
echo.

cd /d "%~dp0"

echo 🔍 Verificando Python...
python --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Python não encontrado!
    echo 💡 Instale Python em: https://www.python.org/downloads/
    pause
    exit /b 1
)

echo ✅ Python encontrado!
echo.

:choose_option
echo Escolha uma opção:
echo.
echo [1] Servidor SEGURO (recomendado)
echo [2] Servidor padrão Python (sem segurança)
echo [3] Sair
echo.
set /p choice="Digite sua escolha (1-3): "

if "%choice%"=="1" goto secure_server
if "%choice%"=="2" goto standard_server
if "%choice%"=="3" goto exit
goto choose_option

:secure_server
echo.
echo 🔒 Iniciando servidor SEGURO...
echo 📂 Diretório: %CD%
echo.
echo ⚠️  IMPORTANTE: Use este servidor com ngrok!
echo 💡 Em outro terminal execute: ngrok http 8000
echo.
python secure_server.py
goto end

:standard_server
echo.
echo ⚠️  ATENÇÃO: Servidor SEM proteções de segurança!
echo 📂 Diretório: %CD%
echo.
echo 💡 Para usar com ngrok: ngrok http 8000
echo.
python -m http.server 8000
goto end

:exit
echo.
echo 👋 Saindo...
exit /b 0

:end
echo.
echo 🛑 Servidor parado.
pause 