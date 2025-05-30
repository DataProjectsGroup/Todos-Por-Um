#!/usr/bin/env python3
"""
Servidor HTTP seguro para desenvolvimento
Impede directory listing e adiciona headers de segurança
"""

import os
import sys
import socket
from http.server import HTTPServer, SimpleHTTPRequestHandler
from urllib.parse import unquote

class SecureHTTPRequestHandler(SimpleHTTPRequestHandler):
    
    # Desabilitar directory listing
    def list_directory(self, path):
        """Impede listagem de diretórios retornando 403 Forbidden"""
        self.send_error(403, "Directory listing not allowed")
        return None
    
    def end_headers(self):
        """Adiciona headers de segurança"""
        # Headers de segurança
        self.send_header('X-Content-Type-Options', 'nosniff')
        self.send_header('X-Frame-Options', 'DENY') 
        self.send_header('X-XSS-Protection', '1; mode=block')
        self.send_header('Referrer-Policy', 'strict-origin-when-cross-origin')
        self.send_header('Permissions-Policy', 'camera=(), microphone=(), geolocation=()')
        
        # Content Security Policy
        csp = ("default-src 'self'; "
               "script-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://www.youtube.com; "
               "style-src 'self' 'unsafe-inline' https://cdnjs.cloudflare.com https://fonts.googleapis.com; "
               "font-src 'self' https://fonts.gstatic.com https://cdnjs.cloudflare.com; "
               "img-src 'self' data:; "
               "frame-src 'self' https://www.youtube.com; "
               "connect-src 'self'")
        self.send_header('Content-Security-Policy', csp)
        
        # HSTS (apenas se usando HTTPS)
        if self.headers.get('X-Forwarded-Proto') == 'https':
            self.send_header('Strict-Transport-Security', 'max-age=63072000; includeSubDomains; preload')
        
        super().end_headers()
    
    def do_GET(self):
        """Override GET para adicionar validações de segurança"""
        # Bloquear acesso a arquivos sensíveis
        blocked_files = ['.htaccess', '.env', '.git', '.gitignore', 'secure_server.py', 'nginx-security.conf']
        blocked_extensions = ['.log', '.bak', '.tmp', '.ini', '.conf', '.py']
        
        path = unquote(self.path.split('?')[0])
        
        # Verificar arquivos bloqueados
        for blocked in blocked_files:
            if blocked in path.lower():
                self.send_error(403, "Access denied")
                return
        
        # Verificar extensões bloqueadas
        for ext in blocked_extensions:
            if path.lower().endswith(ext):
                self.send_error(403, "Access denied")
                return
        
        # Verificar tentativas de directory traversal
        if '..' in path or path.startswith('/assets/'):
            if not path.endswith(('.html', '.css', '.js', '.png', '.jpg', '.jpeg', '.gif', '.pdf', '.ico')):
                self.send_error(403, "Access denied")
                return
        
        # Verificar User-Agent malicioso
        user_agent = self.headers.get('User-Agent', '').lower()
        blocked_agents = ['httrack', 'wget', 'curl', 'python-requests', 'scrapy', 'bot', 'crawler']
        
        for agent in blocked_agents:
            if agent in user_agent:
                self.send_error(403, "Bot access denied")
                return
        
        # Prosseguir com request normal
        super().do_GET()
    
    def log_message(self, format, *args):
        """Override para log mais detalhado"""
        client_ip = self.client_address[0]
        user_agent = self.headers.get('User-Agent', 'Unknown')
        print(f"{client_ip} - {args[0]} - {user_agent}")

def get_local_ip():
    """Obtém o IP local da máquina"""
    try:
        # Conecta a um endereço externo para descobrir IP local
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(("8.8.8.8", 80))
        local_ip = s.getsockname()[0]
        s.close()
        return local_ip
    except:
        return "127.0.0.1"

def run_server(port=8000):
    """Inicia o servidor HTTP seguro"""
    
    # Mudar para o diretório do script
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    
    local_ip = get_local_ip()
    server_address = ('', port)
    
    try:
        httpd = HTTPServer(server_address, SecureHTTPRequestHandler)
        
        print("=" * 60)
        print("🔒 SERVIDOR HTTP SEGURO INICIADO")
        print("=" * 60)
        print(f"📂 Diretório: {os.getcwd()}")
        print(f"🌐 Endereços:")
        print(f"   Local:    http://127.0.0.1:{port}")
        print(f"   Rede:     http://{local_ip}:{port}")
        print("=" * 60)
        print("🛡️  Recursos de Segurança Ativos:")
        print("   ❌ Directory listing DESABILITADO")
        print("   🔒 Headers de segurança aplicados")
        print("   🚫 Arquivos sensíveis bloqueados")
        print("   🤖 Bots maliciosos bloqueados")
        print("   🛡️  Directory traversal bloqueado")
        print("=" * 60)
        print("Para parar o servidor: Ctrl+C")
        print("=" * 60)
        
        httpd.serve_forever()
        
    except KeyboardInterrupt:
        print("\n🛑 Servidor parado pelo usuário")
        httpd.shutdown()
    except OSError as e:
        if e.errno == 10048:  # Windows - porta em uso
            print(f"❌ Erro: Porta {port} já está em uso")
            print(f"💡 Tente: python secure_server.py {port + 1}")
        else:
            print(f"❌ Erro: {e}")

if __name__ == "__main__":
    port = 8000
    
    # Permitir especificar porta como argumento
    if len(sys.argv) > 1:
        try:
            port = int(sys.argv[1])
        except ValueError:
            print("❌ Porta inválida. Usando porta padrão 8000")
    
    run_server(port) 