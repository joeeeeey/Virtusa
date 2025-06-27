#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "=== user-data start ==="

# Update package index and upgrade
apt-get update -y
apt-get upgrade -y

# Install base packages
apt-get install -y curl git jq build-essential

# Install Node.js 20 from NodeSource
curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
apt-get install -y nodejs

# Verify versions
echo "Node: $(node -v)  NPM: $(npm -v)"

# Install PM2
npm install -g pm2

# Switch to ubuntu user home
sudo -u ubuntu bash <<'EOSU'
set -xe
cd /home/ubuntu

# Clone app if not exists
if [ ! -d app ]; then
  git clone https://github.com/chapagain/nodejs-mysql-crud.git app
fi
cd app

# Create runtime config with RDS credentials
cat > config.js <<CFG
module.exports = {
  database: {
    host: '${db_host}',
    user: 'admin',
    password: '${db_password}',
    port: 3306,
    db: '${db_name}'
  },
  server: {
    host: '0.0.0.0',
    port: '3000'
  }
}
CFG

# Install dependencies
npm install

# Start app with PM2 using env vars
cat > ecosystem.config.js <<EOF
module.exports = {
  apps : [{
    name   : 'nodejs-crud',
    script : 'app.js',
    env: {
      DB_HOST: '${db_host}',
      DB_USER: 'admin',
      DB_PASSWORD: '${db_password}',
      DB_NAME: '${db_name}',
      PORT: 3000
    }
  }]
};
EOF

pm2 start ecosystem.config.js
pm2 save
pm2 startup systemd -u ubuntu --hp /home/ubuntu
EOSU

echo "=== user-data end ===" 