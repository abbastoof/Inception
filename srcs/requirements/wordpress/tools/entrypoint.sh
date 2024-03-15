#!/bin/bash

# Wait for MariaDB to be ready
while mariadb -h"${MARIA_DB_HOST}" -u"${MARIA_DB_USER}" -p"${MARIA_DB_PASSWORD}" -e "SELECT 1" "${MARIA_DB_DATABASE}" 2>/dev/null; [ $? -ne 0 ]; do
	echo "MariaDB is not ready. Waiting..."
	sleep 30
done

# Check if wordpress is already installed
if [ -f "wp-config.php" ]; then
    echo "WordPress is already installed"
else
    wp core download --allow-root \
    && wp config create --path=/var/www/html --dbname=${MARIA_DB_DATABASE} --dbuser=${MARIA_DB_USER} --dbpass=${MARIA_DB_PASSWORD} --dbhost=${MARIA_DB_HOST} --force --allow-root \
    && wp core install --path=/var/www/html --url=${DOMAIN_NAME} --title=${WORDPRESS_TITLE} --admin_user=${WORDPRESS_ADMIN_USER} --admin_password=${WORDPRESS_ADMIN_PASSWORD} --admin_email=${WORDPRESS_ADMIN_EMAIL} --allow-root \
    && wp user create ${WORDPRESS_USER} ${WORDPRESS_USER_EMAIL} --role=author --user_pass=${WORDPRESS_USER_PASSWORD} --path=/var/www/html --allow-root \
    && wp theme install twentynineteen --activate --path=/var/www/html --allow-root \
    && wp option update siteurl "https://${DOMAIN_NAME}" --allow-root \
    && wp option update home "https://${DOMAIN_NAME}" --allow-root \
    && touch /var/www/html/.wordpress_installed
    echo "WordPress is installed"
fi

# Set permissions
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html


# Start services and keep them running in the foreground
/usr/sbin/php-fpm7.4 -R -F
