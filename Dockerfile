# Use a imagem oficial do Krayin como base
# Certifique-se que esta imagem (2.1.0) é compatível com os pacotes apt que vamos instalar (Ubuntu Focal)
FROM webkul/krayin:2.1.0

# Define variáveis de ambiente para garantir instalações não interativas e fuso horário
ENV DEBIAN_FRONTEND=noninteractive
ENV TZ=America/Sao_Paulo

# Passo 1: Remove o arquivo de lista de fontes do PPA problemático que causa o erro de Label
# O nome do arquivo para ppa:ondrej/php em focal é geralmente ondrej-ubuntu-php-focal.list
# Usamos 'rm -f' para não dar erro se o arquivo já foi removido ou não existir
RUN rm -f /etc/apt/sources.list.d/ondrej-ubuntu-php-focal.list

# Passo 2: Agora atualiza o apt (não deve mais dar o erro do PPA removido) e instala pré-requisitos
RUN apt-get update \
    && apt-get install -y --no-install-recommends apt-transport-https ca-certificates curl gnupg software-properties-common \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Passo 3: Adiciona o repositório oficial do NodeSource para Node.js v18 LTS
# Adiciona a chave GPG e o arquivo .list
RUN apt-get update \ 
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource.gpg.key | apt-key add - \
    && echo "deb https://deb.nodesource.com/node_18.x focal main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Passo 4: Roda apt-get update mais uma vez para incluir o novo repositório NodeSource e instala o Node.js
RUN apt-get update \
    && apt-get install -y --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# O WORKDIR já deve estar definido na imagem base, mas é bom garantir explicitamente
# Verifique qual é a pasta raiz do projeto na imagem base (geralmente /var/www/html ou /app)
WORKDIR /var/www/html

# Copia o código da sua aplicação local para dentro do container
# Certifique-se de ter um arquivo .dockerignore para excluir arquivos desnecessários (node_modules, vendor)
COPY . /var/www/html

# --- ADICIONE ESTA LINHA PARA CORRIGIR O DOCUMENTROOT DO APACHE ---
# Usa sed para editar o arquivo de configuração habilitado do Apache
# Substitui o DocumentRoot incorreto pelo correto
RUN sed -i 's|DocumentRoot /var/www/html/laravel-crm/public|DocumentRoot /var/www/html/public|g' /etc/apache2/sites-enabled/000-default.conf
# --- FIM DA LINHA ADICIONADA ---

# Instala dependências do Composer (modo desenvolvimento)
# Assume que composer está instalado na imagem base
RUN composer install --no-interaction --no-plugins --no-scripts --prefer-dist --dev --optimize-autoloader

# Instala dependências do NPM
# Assume que npm está instalado agora (Passo 4)
RUN npm install

# Constrói os assets de frontend (para desenvolvimento)
# Para desenvolvimento local rápido, 'npm run dev' é rodado SEPARADAMENTE no terminal do container
# Deixe este passo comentado para o build da imagem
# RUN npm run build

# O comando principal que inicia a aplicação já deve estar definido na imagem base (CMD ou ENTRYPOINT)
# Ex: CMD ["/usr/bin/supervisord"] # ou similar para rodar PHP-FPM e Webserver

# A porta que o webserver Krayin escuta já deve estar definida na imagem base
# EXPOSE 80 # Exemplo da porta padrão

# A configuração da conexão DB e APP_KEY virá do .env montado via docker-compose