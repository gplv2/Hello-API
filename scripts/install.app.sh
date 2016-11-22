#!/usr/bin/env bash
export DEBIAN_FRONTEND=noninteractive

[ -r /etc/lsb-release ] && . /etc/lsb-release

if [ -z "$DISTRIB_RELEASE" ] && [ -x /usr/bin/lsb_release ]; then
    # Fall back to using the very slow lsb_release utility
    DISTRIB_RELEASE=$(lsb_release -s -r)
    DISTRIB_CODENAME=$(lsb_release -s -c)
fi

# If you disable xdebug, you cant use tools like phpspec that depend on
# phpunit dumping coverage data

echo "Disable xdebug"

if [ -L /etc/php/7.0/cli/conf.d/20-xdebug.ini ]; then
    echo "Disabling Xdebug for compilation - cli"
    rm -f /etc/php/7.0/cli/conf.d/20-xdebug.ini
fi

if [ -L /etc/php/7.0/fpm/conf.d/20-xdebug.ini ]; then
    echo "Disabling Xdebug for compilation - fpm"
    rm -f /etc/php/7.0/fpm/conf.d/20-xdebug.ini
fi

echo "Setting up Hello-API"

# Here you could use deploy keys for your non-vagrant private app which you would
# provision remotely with for example terraform.

# echo "Installing SSH deployment keys"
# if [ ! -d "~/.ssh" ]; then 
#    mkdir ~/.ssh
#    chmod 700 ~/.ssh
# fi

# cp /vagrant/scripts/deployment_key.rsa ~/.ssh/deployment_key.rsa
# cp /vagrant/scripts/deployment_key.rsa.pub ~/.ssh/deployment_key.rsa.pub
# cp /vagrant/scripts/ssh_config ~/.ssh/config

# chmod 600 ~/.ssh/deployment_key.rsa
# chmod 644 ~/.ssh/deployment_key.rsa.pub
# chmod 644 ~/.ssh/config


#  Do some cleanup work, I hate that login banner, so silence it
sudo su - vagrant -c "touch ~/.hushlogin"

# Create known_hosts file
sudo su - vagrant -c "touch ~/.ssh/known_hosts"

# Add github key
sudo su - vagrant -c "ssh-keyscan github.com >> ~/.ssh/known_hosts"

# Add bitbuckets key (optional, for private repo use)
# sudo su - vagrant -c "ssh-keyscan bitbucket.org >> ~/.ssh/known_hosts"

echo "Cloning code"

if [ -d "/var/www" ]; then 
    chown vagrant:vagrant /var/www/
fi

sudo su - vagrant -c "cd /var/www && git clone https://github.com/Porto-SAP/Hello-API.git hello-api"

echo "Fixing ownerships and permissions"

chown vagrant:vagrant /var/www
chown -R vagrant:vagrant /var/www/hello-api

echo "Launching composer install"
sudo su - vagrant -c "cd /var/www/hello-api && composer install --no-progress"

# dump autoload 1 time before migrate, it seems to need/want it
sudo su - vagrant -c "cd /var/www/hello-api && composer dump-autoload"

echo "Configuring the application database config"

# Copy .env.example to .env
sudo su - vagrant -c "cp /var/www/hello-api/.env.example /var/www/hello-api/.env"

# In case you need to change port numbers
if [ ! -x "/var/www/hello-api/.env" ]; then 
    echo "Verifying postgres DB port"
    #sed -i 's/DB_PORT=5433/DB_PORT=5432/' /var/www/hello-api/.env
fi

echo "Completing laravel installation ( as vagrant user)"

echo "Create migration table"
sudo su - vagrant -c "cd /var/www/hello-api && php artisan migrate:install"
echo "Perform migrations"
sudo su - vagrant -c "cd /var/www/hello-api && php artisan migrate"
echo "Vendor publish (configs)"
sudo su - vagrant -c "cd /var/www/hello-api && php artisan vendor:publish"
echo "Optimize"
sudo su - vagrant -c "cd /var/www/hello-api && php artisan optimize"
echo "Dump autoload"
sudo su - vagrant -c "cd /var/www/hello-api && composer dump-autoload"

