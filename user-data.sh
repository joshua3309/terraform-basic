#!/bin/bash
set -e

echo "Updating system..."
sudo apt update && sudo apt upgrade -y

echo "Installing core utilities..."
sudo apt install -y \
  software-properties-common \
  language-pack-en-base \
  dialog \
  apt-utils \
  ca-certificates \
  curl \
  unzip

echo "Setting locale and timezone..."
sudo update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8
sudo ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime

echo "Adding PHP repository..."
sudo add-apt-repository -y ppa:ondrej/php
sudo apt update

echo "Installing Apache, PHP 8.2, MySQL..."
sudo apt install -y \
  apache2 \
  mysql-server \
  php8.2 \
  php8.2-cli \
  php8.2-common \
  php8.2-mysql \
  php8.2-xml \
  php8.2-curl \
  php8.2-mbstring \
  php8.2-zip \
  php8.2-gd \
  php8.2-intl \
  libapache2-mod-php8.2

echo "Enabling Apache modules..."
sudo a2enmod php8.2 rewrite headers
sudo systemctl restart apache2

echo "Deploying application..."
sudo rm -rf /var/www/html/*
cd /tmp
curl -LO https://github.com/devopsdemoapps/devops-demo/raw/master/devops-demo.tar.gz
sudo tar -xzf devops-demo.tar.gz -C /var/www/html

echo "Fixing permissions..."
sudo chown -R www-data:www-data /var/www/html
sudo find /var/www/html -type d -exec chmod 755 {} \;
sudo find /var/www/html -type f -exec chmod 644 {} \;

echo "Downloading database schema..."
curl -LO https://raw.githubusercontent.com/devopsdemoapps/devops-demo/master/devops-demo.sql

echo "MySQL secure setup reminder:"
echo "Run: sudo mysql_secure_installation"

echo "Setup complete!"
