#!/bin/sh
set -eu

ROOT_PASSWORD="${MYSQL_ROOT_PASSWORD}"
DB_PASSWORD="${MYSQL_PASSWORD}"

mkdir -p /run/mysqld
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/lib/mysql

if [ ! -f /var/lib/mysql/.inception_initialized ]; then
    if [ ! -d /var/lib/mysql/mysql ] || [ -z "$(ls -A /var/lib/mysql/mysql 2>/dev/null)" ]; then
        mariadb-install-db --user=mysql --datadir=/var/lib/mysql
    fi

    mysqld_safe --skip-networking &

    for _ in $(seq 1 60); do
        if mariadb-admin ping --silent; then
            break
        fi
        sleep 1
    done

    if mariadb -uroot -e "SELECT 1;" >/dev/null 2>&1; then
        mariadb -uroot <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    else
        mariadb -uroot -p"${ROOT_PASSWORD}" <<EOF
ALTER USER 'root'@'localhost' IDENTIFIED BY '${ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MYSQL_DATABASE};
CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MYSQL_DATABASE}.* TO '${MYSQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF
    fi

    touch /var/lib/mysql/.inception_initialized

    mariadb-admin -uroot -p"${ROOT_PASSWORD}" shutdown
fi

exec mysqld --user=mysql --console
