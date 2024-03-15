#!/bin/sh

# Initialize retry count
RETRY_COUNT=0
MAX_RETRIES=24
RETRY_INTERVAL=5

# Wait for MariaDB to be ready
while ! mariadb -h"${MARIA_DB_HOST}" -u"${MARIA_DB_USER}" -p"${MARIA_DB_PASSWORD}" -e "SELECT 1" "${MARIA_DB_DATABASE}" > /dev/null 2>&1; do
    RETRY_COUNT=$((RETRY_COUNT+1))
    if [ "$RETRY_COUNT" -le "$MAX_RETRIES" ]; then
        echo "MariaDB is not ready. Attempt ${RETRY_COUNT}/${MAX_RETRIES}. Waiting ${RETRY_INTERVAL} seconds..."
        sleep $RETRY_INTERVAL
    else
        echo "Failed to connect to MariaDB after ${MAX_RETRIES} attempts. Exiting."
        exit 1
    fi
done

echo "MariaDB is ready!"

# Proceed with WordPress setup if not already installed
if [ -f "wp-config.php" ]; then
    echo "WordPress is already installed."
else
    echo "Installing WordPress..."
    wp core download --allow-root \
    && wp config create --path=/var/www/html --dbname="${MARIA_DB_DATABASE}" --dbuser="${MARIA_DB_USER}" --dbpass="${MARIA_DB_PASSWORD}" --dbhost="${MARIA_DB_HOST}" --force --allow-root \
    && wp core install --path=/var/www/html --url="${DOMAIN_NAME}" --title="${WORDPRESS_TITLE}" --admin_user="${WORDPRESS_ADMIN_USER}" --admin_password="${WORDPRESS_ADMIN_PASSWORD}" --admin_email="${WORDPRESS_ADMIN_EMAIL}" --allow-root \
    && wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" --role=author --user_pass="${WORDPRESS_USER_PASSWORD}" --path=/var/www/html --allow-root \
    && wp theme install twentynineteen --activate --path=/var/www/html --allow-root \
    && wp option update siteurl "https://${DOMAIN_NAME}" --allow-root \
    && wp option update home "https://${DOMAIN_NAME}" --allow-root \
    && echo "WordPress installation complete."
    touch /var/www/html/.wordpress_installed
fi

# Set permissions after installation
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

# Start PHP-FPM in the foreground
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -R -F
