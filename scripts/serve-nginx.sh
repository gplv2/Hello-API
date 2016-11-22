#!/usr/bin/env bash

DOMAIN=$1
WEBROOT=$2

if [ -z "${DOMAIN}" ]; then
    printf "Can't be called without arguments"
    exit 1;
fi

if [ ! -d "/etc/nginx/ssl" ]; then
    mkdir /etc/nginx/ssl 2>/dev/null
fi

# Self signing SSL
printf "Generating SSL files"
openssl genrsa -out "/etc/nginx/ssl/$DOMAIN.key" 1024 2>/dev/null
openssl req -new -key /etc/nginx/ssl/$DOMAIN.key -out /etc/nginx/ssl/$DOMAIN.csr -subj "/CN=$DOMAIN/O=Vagrant/C=UK" 2>/dev/null
openssl x509 -req -days 365 -in /etc/nginx/ssl/$DOMAIN.csr -signkey /etc/nginx/ssl/$DOMAIN.key -out /etc/nginx/ssl/$DOMAIN.crt 2>/dev/null

block="server {
    listen ${3:-80};
    listen ${4:-443} ssl;
    server_name $DOMAIN;
    root \"$WEBROOT\";

    index index.html index.php app.php;

    charset utf-8;

    location / {
        try_files \$uri \$uri/ /index.php?\$query_string;
    }

    location = /favicon.ico { access_log off; log_not_found off; }
    location = /robots.txt  { access_log off; log_not_found off; }

    access_log off;
    error_log  /var/log/nginx/$DOMAIN-ssl-error.log error;

    sendfile off;

    client_max_body_size 100m;

    # DEV
    location ~ ^/(app_dev|config)\.php(/|\$) {
        fastcgi_split_path_info ^(.+\.php)(/.+)\$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
    }

    # PROD
    location ~ ^/index\.php(/|$) {
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php7.0-fpm.sock;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_intercept_errors off;
        fastcgi_buffer_size 16k;
        fastcgi_buffers 4 16k;
        # Prevents URIs that include the front controller. This will 404:
        # http://domain.tld/app.php/some-path
        # Remove the internal directive to allow URIs like this
        internal;
    }

    location ~ /\.ht {
        deny all;
    }

    ssl_certificate     /etc/nginx/ssl/$DOMAIN.crt;
    ssl_certificate_key /etc/nginx/ssl/$DOMAIN.key;
}
"

printf "Generating config file"

echo "$block" > "/etc/nginx/sites-available/$DOMAIN"
ln -fs "/etc/nginx/sites-available/$DOMAIN" "/etc/nginx/sites-enabled/$DOMAIN"
