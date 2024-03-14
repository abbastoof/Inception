#!/bin/sh

# make sure environment vars are set
if [ -z "$MARIA_DB_ROOT_PASSWORD" ]; then
  echo "Error: MARIADB_ROOT_PASSWORD environment variable is not set."
  exit 1
fi
if [ -z "$MARIA_DB_USER" ] || [ -z "$MARIA_DB_ROOT_PASSWORD" ]; then
  echo "Error: DB_USER and/ or DB_USER_PASSWORD environment variable is not set."
  exit 1
fi

mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld
chown -R mysql:mysql /var/log/mysql
touch /var/log/mysql/error.log

mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql --rpm >/dev/null

mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIA_DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS ${MARIA_DB_DATABASE} CHARACTER SET utf8 COLLATE utf8_general_ci;
CREATE USER '${MARIA_DB_USER}'@'%' IDENTIFIED by '${MARIA_DB_PASSWORD}';
GRANT ALL PRIVILEGES ON ${MARIA_DB_DATABASE}.* TO '${MARIA_DB_USER}'@'%';
GRANT ALL PRIVILEGES ON *.* TO '${MARIA_DB_USER}'@'%';

FLUSH PRIVILEGES;
EOF

exec mysqld_safe "--defaults-file=/etc/mariadb.conf.d/my.cnf"