#!/bin/sh

# Ensure all required environment variables are set
if [ -z "$MARIA_DB_ROOT_PASSWORD" ]; then
  echo "Error: MARIA_DB_ROOT_PASSWORD environment variable is not set."
  exit 1
fi

if [ -z "$MARIA_DB_USER" ] || [ -z "$MARIA_DB_PASSWORD" ]; then
  echo "Error: MARIA_DB_USER and/or MARIA_DB_PASSWORD environment variables are not set."
  exit 1
fi

# Initialize MariaDB data directory
mysql_install_db --user=mysql --basedir=/usr --datadir=/var/lib/mysql --rpm >/dev/null

# Secure the installation and set up initial database and user
mysqld --user=mysql --bootstrap << EOF
USE mysql;
FLUSH PRIVILEGES;

ALTER USER 'root'@'localhost' IDENTIFIED BY '${MARIA_DB_ROOT_PASSWORD}';
CREATE DATABASE IF NOT EXISTS \`${MARIA_DB_DATABASE}\` CHARACTER SET utf8 COLLATE utf8_general_ci;
GRANT ALL PRIVILEGES ON \`${MARIA_DB_DATABASE}\`.* TO '${MARIA_DB_USER}'@'%' IDENTIFIED BY '${MARIA_DB_PASSWORD}' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Start MariaDB
exec mysqld --defaults-file=/etc/mariadb.conf.d/my.cnf
