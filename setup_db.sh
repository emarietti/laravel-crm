#!/bin/bash

# Este script espera o banco de dados estar acessível e depois roda as migrações

echo "Aguardando o banco de dados 'mysql' estar acessível na porta 3306..."

# Comando de espera usando netcat (nc). Espera até 30 segundos.
# -z: modo zero-I/O, apenas escaneia
# -w 1: timeout de 1 segundo por tentativa
# mysql: o hostname do serviço de banco de dados (conforme no .env)
# 3306: a porta do banco de dados
# Redireciona a saída de erro (2) para /dev/null para não poluir o terminal
timeout 30 bash -c 'until nc -z mysql 3306; do echo -n "."; sleep 1; done' 2>/dev/null

# Captura o código de saída do comando timeout
WAIT_EXIT_CODE=$?

echo "" # Adiciona uma nova linha após os pontos

# Verifica o resultado do comando de espera
if [ $WAIT_EXIT_CODE -eq 0 ]; then
    echo "Banco de dados 'mysql' acessível. Prosseguindo com as migrações..."
    # *** SEU COMANDO DE MIGRAÇÃO ***
    php artisan migrate:fresh --seed -v
else
    echo "Timeout: Banco de dados 'mysql' na porta 3306 não acessível após 30 segundos."
    echo "Por favor, verifique se o container MySQL está rodando e acessível na rede GenialityNet."
    exit 1 # Sai com erro
fi