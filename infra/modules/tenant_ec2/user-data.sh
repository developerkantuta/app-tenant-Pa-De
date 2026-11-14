
#!/bin/bash
apt-get update -y
apt-get install -y curl git build-essential unzip

# Instalar Node.js 20 LTS
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Instalar OpenTofu
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
rm install-opentofu.sh

# Clonar el repositorio
mkdir -p /app
cd /app
git clone https://github.com/developerkantuta/app-tenant-Pa-De.git .
cd backend

npm install
node data/init_db.js
nohup node server.js > app.log 2>&1 &