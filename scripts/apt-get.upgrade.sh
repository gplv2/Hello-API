#!/usr/bin/env bash
DEBIAN_FRONTEND=noninteractive
export $DEBIAN_FRONTEND

DBTYPE=$1

echo "Finishing off standard install"

printf "Fixing locales warnings"
echo "LC_ALL=en_US.UTF-8" >> /etc/environment

# fix locales
locale-gen "en_US.UTF-8"
# locale-gen "nl_BE.UTF-8"

echo "nl_BE.UTF-8 UTF-8" >> /etc/locale.gen

locale-gen

# Generating locales...
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure locales

# since all services run on localhost, set those in the vagrant hostfile 
echo "127.0.0.1 redis" >> /etc/hosts

# create a log dir that affects the server

if [ ! -d "/var/log/provision" ]; then
    mkdir /var/log/provision 2>/dev/null
    chown vagrant:vagrant /var/www/provision
fi

# Fix package problems & upgrade dist immediately
DEBIAN_FRONTEND=noninteractive apt-get update

DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -f
DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -f

[ -r /etc/lsb-release ] && . /etc/lsb-release
if [ -z "$DISTRIB_RELEASE" ] && [ -x /usr/bin/lsb_release ]; then
    # Fall back to using the very slow lsb_release utility
    DISTRIB_RELEASE=$(lsb_release -s -r)
    DISTRIB_CODENAME=$(lsb_release -s -c)
fi

printf "Preparing for ubuntu %s - %s\n" "$DISTRIB_RELEASE" "$DISTRIB_CODENAME"

# common general packages for all ubuntu versions
DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" zip unzip
DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -f

echo "Setting up for ubuntu %s - %s\n" "$DISTRIB_RELEASE" "$DISTRIB_CODENAME"

echo "Provisioning virtual machine"

echo "Install packages ..."
# DISTRIB_RELEASE=14.04
if [ "$DISTRIB_RELEASE" = "14.04" ]; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Progress-Fancy="0" phpunit php7.0 php7.0-fpm php-dev php-pear php-config pkg-config pkgconf pkg-php-tools g++ make memcached libmemcached-dev build-essential python-software-properties php-memcached memcached php-memcache curl php-redis redis-server php5-cli git ccze 2> /dev/null
    if [ "$DBTYPE" = "pgsql" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Progress-Fancy="0" postgresql 2> /dev/null
    fi
    if [ "$DBTYPE" = "mysql" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Progress-Fancy="0" mariadb-server mariadb-client php-mysql 2> /dev/null
    fi
fi

if [ "$DISTRIB_RELEASE" = "16.04" ]; then
    echo "Install $DISTRIB_RELEASE packages ..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Progress-Fancy="0" phpunit php7.0 php7.0-fpm php-dev php-pear pkg-config pkgconf pkg-php-tools g++ make memcached libmemcached-dev build-essential python-software-properties php-memcached memcached php-memcache php-redis redis-server curl php-cli git ccze 2> /dev/null
    if [ "$DBTYPE" = "pgsql" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Progress-Fancy="0" postgresql 2> /dev/null
    fi
    if [ "$DBTYPE" = "mysql" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -o Dpkg::Progress-Fancy="0" mariadb-server mariadb-client php-mysql 2> /dev/null
    fi
fi

echo "Install Composer in /usr/local/bin ..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
