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
sudo apt-get install -y php5 apache2 libapache2-mod-php5 php5-curl php5-gd php5-mcrypt mysql-server-5.5 php5-mysql php5-sqlite git-core

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

# Set to "blinks" theme which
# uses Solarized and shows user/host
sudo sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="blinks"/' /home/vagrant/.zshrc
# Add /sbin to PATH
sudo sed -i 's=:/bin:=:/bin:/sbin:=' /home/vagrant/.zshrc

# Change vagrant user's default shell
chsh vagrant -s $(which zsh);

echo "--- Editing PATH ---"
echo 'PATH=vendor/bin:$PATH' >> /home/vagrant/.zshrc

echo "--- Setting up local and testing database with external access ---"
sudo sed -i 's/#skip-external-locking/skip-external-locking/' /etc/mysql/my.cnf
sudo sed -i 's/#bind-address/bind-address/' /etc/mysql/my.cnf
sudo sed -i 's/127.0.0.1/0.0.0.0/' /etc/mysql/my.cnf

echo "CREATE DATABASE testdb" | mysql -uroot -proot
echo "CREATE DATABASE develdb" | mysql -uroot -proot
echo "create user 'root'@'10.0.2.2' identified by 'root';" | mysql -uroot -proot
echo "grant all privileges on *.* to 'root'@'10.0.2.2' with grant option;" | mysql -uroot -proot
echo "flush privileges;" | mysql -uroot -proot

echo "--- Restarting mysql ---"
sudo service mysql restart

echo "--- Creating Aliases ---"
cat << EOF | tee -a /home/vagrant/.zshrc
alias ls="ls -lhF ${colorflag}"
alias lsd="ls -lhF ${colorflag}  | grep \"^d\""
alias la="ls -lahF ${colorflag}"
alias cs=". /usr/bin/cdls.hr"

export LS_COLORS='no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:ex=01;32:*.tar=01;31:*.tgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.gz=01;31:*.bz2=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.ogg=01;35:*.mp3=01;35:*.wav=01;35:'


# Easier navigation: .., ..., ...., ....., ~ and -
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."

#Git aliases
alias gs="git status"
alias ga="git add"
alias gaa="git add ."
alias gc="git commit"

#Artisan aliases
alias g:c="php artisan generate:controller"
alias g:m="php artisan generate:model"
alias g:v="php artisan generate:view"
alias g:mig="php artisan generate:migration"
alias g:a="php artisan generate:assets"
alias g:t="php artisan generate:test"
alias g:r="php artisan generate:resource"

#Codeception aliases
alias cr="codecept run"
alias cra="codecept run acceptance"
alias crf="codecept run functional"
alias cru="codecept run unit"

#Disable autocorrect
unsetopt correct_all

# Create a new directory and enter it
function mkd() {
        mkdir -p "$@" && cd "$@"
}

# Determine size of a file or total size of a directory
function fs() {
        if du -b /dev/null > /dev/null 2>&1; then
                local arg=-sbh
        else
                local arg=-sh
        fi
        if [[ -n "$@" ]]; then
                du $arg -- "$@"
        else
                du $arg .[^.]* *
        fi
}
EOF

# Laravel stuff
# Load Composer packages
# cd /var/www
# composer install --dev
# php artisan migrate --seed --env="development"
# php artisan migrate --seed --env="testing"


echo "--- All set to go! Would you like to play a game? ---"
