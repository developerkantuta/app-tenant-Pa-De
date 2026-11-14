#!/bin/bash
# Nos aseguramos de estar en una carpeta con permisos
cd /tmp

# Actualizar e instalar dependencias
apt-get update -y
apt-get install -y curl git build-essential unzip

# Instalar Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Instalar OpenTofu de forma segura
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
sudo ./install-opentofu.sh --install-method deb
rm install-opentofu.sh

# Clonar el repositorio en /app (usando sudo para evitar problemas de permisos)
mkdir -p /app
cd /app
git clone https://github.com/developerkantuta/app-tenant-Pa-De.git .
cd backend

# Instalar dependencias de Node
npm install

# Inicializar la base de datos (por si acaso)
node data/init_db.js

# Levantar el servidor
nohup node server.js > app.log 2>&1 &