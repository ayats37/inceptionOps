#!/bin/sh
set -eu

mkdir -p /etc/nginx/certs

if [ ! -f /etc/nginx/certs/inception.crt ] || [ ! -f /etc/nginx/certs/inception.key ]; then
    openssl req -x509 -nodes -newkey rsa:2048 -days 365 \
        -keyout /etc/nginx/certs/inception.key \
        -out /etc/nginx/certs/inception.crt \
        -subj "/CN=${DOMAIN_NAME}"
fi

exec nginx -g "daemon off;"
