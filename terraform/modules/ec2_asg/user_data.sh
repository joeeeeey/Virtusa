#!/bin/bash -xe
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

# Install Node.js 18
yum update -y
yum install -y gcc-c++ make
curl -sL https://rpm.nodesource.com/setup_18.x | sudo -E bash -
yum install -y nodejs

# Install Git
yum install -y git
yum install -y jq

# Install PM2
npm install pm2 -g

# Get app code
cd /home/ec2-user
git clone https://github.com/chapagain/nodejs-mysql-crud.git app
cd app

# Get DB credentials from Secrets Manager
SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id ${db_secret_arn} --region ${region} --query SecretString --output text)

# Set environment variables for the app
export DB_HOST=$(echo $SECRET_JSON | jq -r .host)
export DB_USER=$(echo $SECRET_JSON | jq -r .username)
export DB_PASSWORD=$(echo $SECRET_JSON | jq -r .password)
export DB_NAME=$(echo $SECRET_JSON | jq -r .dbname)

# Install app dependencies
npm install

# Start the app with PM2
pm2 start app.js --name "nodejs-crud"
pm2 startup
pm2 save

# Ensure the permissions are correct for ec2-user
chown -R ec2-user:ec2-user /home/ec2-user/app 