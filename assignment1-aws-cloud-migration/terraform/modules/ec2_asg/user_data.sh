#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

export DEBIAN_FRONTEND=noninteractive

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

# Install MySQL client for schema bootstrap
apt-get install -y mysql-client

# Wait for RDS to accept connections
until mysql -h "${db_host}" -u admin -p"${db_password}" -e "SELECT 1" >/dev/null 2>&1; do
  echo "Waiting for MySQL to be available..."; sleep 10;
done

# Initialise database and table if they do not exist
mysql -h "${db_host}" -u admin -p"${db_password}" <<SQL
CREATE DATABASE IF NOT EXISTS ${db_name};
USE ${db_name};
DROP TABLE IF EXISTS users;
CREATE TABLE IF NOT EXISTS users (
  id INT PRIMARY KEY AUTO_INCREMENT,
  name VARCHAR(50),
  email VARCHAR(50),
  age VARCHAR(25)
);
SQL

# Switch to ubuntu user for application tasks
sudo -u ubuntu bash <<'EOSU'
set -e
DB_HOST="${db_host}"
DB_PASSWORD="${db_password}"
DB_NAME="${db_name}"
cd /home/ubuntu

# Clone app if not exists
[ ! -d app ] && git clone https://github.com/chapagain/nodejs-mysql-crud.git app
cd app

# Write runtime config.js so Express-MyConnection picks up correct creds
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

# PM2 ecosystem with env vars
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