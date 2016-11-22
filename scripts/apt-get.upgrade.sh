#!/usr/bin/env bash
DEBIAN_FRONTEND=noninteractive
export $DEBIAN_FRONTEND

DBTYPE=$1

echo "Finishing off install"

DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" -f

[ -r /etc/lsb-release ] && . /etc/lsb-release

if [ -z "$DISTRIB_RELEASE" ] && [ -x /usr/bin/lsb_release ]; then
    # Fall back to using the very slow lsb_release utility
    DISTRIB_RELEASE=$(lsb_release -s -r)
    DISTRIB_CODENAME=$(lsb_release -s -c)
fi

echo "Setting up for ubuntu %s - %s\n" "$DISTRIB_RELEASE" "$DISTRIB_CODENAME"

echo "Provisioning virtual machine"

echo "Install packages ..."
# DISTRIB_RELEASE=14.04
if [ "$DISTRIB_RELEASE" = "14.04" ]; then
    DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" phpunit php7.0 php7.0-fpm php-dev php-pear php-config pkg-config pkgconf pkg-php-tools g++ make memcached libmemcached-dev build-essential python-software-properties php-memcached memcached php-memcache curl php-redis redis-server php5-cli git ccze 2> /dev/null
    if [ "$DBTYPE" = "pgsql" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" postgresql 2> /dev/null
    fi
    if [ "$DBTYPE" = "mysql" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" mariadb-server mariadb-client php-mysql 2> /dev/null
    fi
fi

if [ "$DISTRIB_RELEASE" = "16.04" ]; then
    echo "Install $DISTRIB_RELEASE packages ..."
    DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" phpunit php7.0 php7.0-fpm php-dev php-pear pkg-config pkgconf pkg-php-tools g++ make memcached libmemcached-dev build-essential python-software-properties php-memcached memcached php-memcache php-redis redis-server curl php-cli git ccze 2> /dev/null
    if [ "$DBTYPE" = "pgsql" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" postgresql 2> /dev/null
    fi
    if [ "$DBTYPE" = "mysql" ]; then
        DEBIAN_FRONTEND=noninteractive apt-get install -y -o Dpkg::Options::="--force-confdef" -o Dpkg::Options::="--force-confnew" mariadb-server mariadb-client php-mysql 2> /dev/null
    fi
fi

echo "Install Composer in /usr/local/bin ..."
curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer
