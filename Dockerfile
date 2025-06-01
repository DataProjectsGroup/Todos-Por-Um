# Use nginx oficial
FROM nginx:alpine

# Copie os arquivos do site para o diretório padrão do nginx
COPY . /usr/share/nginx/html

# Copie a configuração principal do nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copie a configuração de segurança do nginx
COPY nginx-security.conf /etc/nginx/conf.d/default.conf

# Exponha a porta 80
EXPOSE 80

# Comando padrão do nginx
CMD ["nginx", "-g", "daemon off;"]