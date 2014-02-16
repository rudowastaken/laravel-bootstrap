#!/usr/bin/env bash

echo "--- Good morning, master. Let's get to work. Installing now. ---"

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- MySQL time ---"
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password password root'
sudo debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password root'

echo "--- Installing base packages ---"
sudo apt-get install -y vim mc curl python-software-properties

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- We want the bleeding edge of PHP, right master? ---"
sudo add-apt-repository -y ppa:ondrej/php5

echo "--- Updating packages list ---"
sudo apt-get update

echo "--- Installing PHP-specific packages ---"
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt mysql-server-5.5 php5-mysql git-core

echo "--- Installing and configuring Xdebug ---"
sudo apt-get install -y php5-xdebug

cat << EOF | sudo tee -a /etc/php5/mods-available/xdebug.ini
xdebug.scream=1
xdebug.cli_color=1
xdebug.show_local_vars=1
EOF

echo "--- Enabling mod-rewrite ---"
sudo a2enmod rewrite

echo "--- Setting document root ---"
sudo rm -rf /var/www
sudo ln -fs /vagrant/public /var/www
sudo sed -i "s/DocumentRoot \/var\/www.*/DocumentRoot \/var\/www/" /etc/apache2/sites-available/000-default.conf


echo "--- What developer codes without errors turned on? Not you, master. ---"
sed -i "s/error_reporting = .*/error_reporting = E_ALL/" /etc/php5/apache2/php.ini
sed -i "s/display_errors = .*/display_errors = On/" /etc/php5/apache2/php.ini

sed -i 's/AllowOverride None/AllowOverride All/' /etc/apache2/apache2.conf

echo "--- Restarting Apache ---"
sudo service apache2 restart

echo "--- Composer is the future. But you knew that, did you master? Nice job. ---"
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

echo "--- Adding oh-my-zsh ---"
# Install zsh
sudo apt-get install -y zsh

# Install oh-my-zsh
sudo su - vagrant -c 'wget https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh -O - | zsh'

# Set to "amuse" theme which
# uses Solarized and shows user/host
sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="amuse"/' /home/vagrant/.zshrc
# Add /sbin to PATH
sudo sed -i 's=:/bin:=:/bin:/sbin:=' /home/vagrant/.zshrc

# Change vagrant user's default shell
chsh vagrant -s $(which zsh);

# Laravel stuff
# Load Composer packages
cd /var/www
composer install --dev


echo "--- All set to go! Would you like to play a game? ---"
