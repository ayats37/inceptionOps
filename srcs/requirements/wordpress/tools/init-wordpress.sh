#!/bin/sh
set -e

require_var() {
    var_name="$1"
    eval var_value="\${$var_name}"
    if [ -z "$var_value" ]; then
        echo "ERROR: Missing required environment variable: ${var_name}" >&2
        exit 1
    fi
}

MYSQL_DATABASE="${MYSQL_DATABASE:-wordpress}"
MYSQL_USER="${MYSQL_USER:-wp_user}"
WP_DB_HOST="${WP_DB_HOST:-mariadb:3306}"
WP_TABLE_PREFIX="${WP_TABLE_PREFIX:-wp_}"

DB_PASSWORD="${MYSQL_PASSWORD}"
WP_ADMIN_PASSWORD="${WP_ADMIN_PASSWORD}"
WP_USER_PASSWORD="${WP_USER_PASSWORD}"
DB_HOST_ONLY="$(echo "${WP_DB_HOST}" | cut -d: -f1)"
WP_PATH="/var/www/html"

require_var MYSQL_PASSWORD
require_var WP_ADMIN_PASSWORD
require_var WP_USER_PASSWORD
require_var DOMAIN_NAME
require_var WP_TITLE
require_var WP_ADMIN_USER
require_var WP_ADMIN_EMAIL
require_var WP_USER
require_var WP_USER_EMAIL

mkdir -p /run/php
mkdir -p "${WP_PATH}"

# Start php-fpm right away so NGINX never gets connection refused
php-fpm8.2 -F &
FPM_PID=$!

echo "Waiting for MariaDB at ${DB_HOST_ONLY}..."
i=0
while ! mariadb-admin ping -h"${DB_HOST_ONLY}" -u"${MYSQL_USER}" -p"${DB_PASSWORD}" --silent 2>/dev/null; do
    i=$((i + 1))
    if [ "$i" -ge 60 ]; then
        echo "ERROR: MariaDB not ready after 120s" >&2
        kill $FPM_PID
        exit 1
    fi
    sleep 2
done
echo "MariaDB is ready."

# Step 1: download core files if missing
if [ ! -f "${WP_PATH}/wp-login.php" ]; then
    wp core download --allow-root --path="${WP_PATH}"
fi

# Step 2: create wp-config.php if missing
if [ ! -f "${WP_PATH}/wp-config.php" ]; then
    wp config create \
        --allow-root \
        --dbname="${MYSQL_DATABASE}" \
        --dbuser="${MYSQL_USER}" \
        --dbpass="${DB_PASSWORD}" \
        --dbhost="${WP_DB_HOST}" \
    --dbprefix="${WP_TABLE_PREFIX}" \
        --path="${WP_PATH}"
fi

# Step 3: run install only if DB tables are not yet present
if ! wp core is-installed --allow-root --path="${WP_PATH}" 2>/dev/null; then
    wp core install \
        --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email \
        --path="${WP_PATH}"
fi

# Step 4: create second user if not already present
if ! wp user get "${WP_USER}" --allow-root --path="${WP_PATH}" 2>/dev/null; then
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --allow-root \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}" \
        --path="${WP_PATH}"
fi

chown -R www-data:www-data "${WP_PATH}"
find "${WP_PATH}" -type d -exec chmod 755 {} \;
find "${WP_PATH}" -type f -exec chmod 644 {} \;

wait $FPM_PID
