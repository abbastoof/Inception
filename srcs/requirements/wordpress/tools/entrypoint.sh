#!/bin/sh

# Proceed with WordPress setup if not already installed
if [ -f "wp-config.php" ]; then
    echo "WordPress is already installed."
else
    echo "Installing WordPress..."
    wp core download --allow-root \
    && wp config create --path=/var/www/html --dbname="${MARIA_DB_DATABASE}" --dbuser="${MARIA_DB_USER}" --dbpass="${MARIA_DB_PASSWORD}" --dbhost="${MARIA_DB_HOST}" --force --allow-root \
    && wp core install --path=/var/www/html --url="${DOMAIN_NAME}" --title="${WORDPRESS_TITLE}" --admin_user="${WORDPRESS_ADMIN_USER}" --admin_password="${WORDPRESS_ADMIN_PASSWORD}" --admin_email="${WORDPRESS_ADMIN_EMAIL}" --allow-root \
    && wp user create "${WORDPRESS_USER}" "${WORDPRESS_USER_EMAIL}" --role=author --user_pass="${WORDPRESS_USER_PASSWORD}" --path=/var/www/html --allow-root \
    && wp option update siteurl "https://${DOMAIN_NAME}" --allow-root \
    && wp option update home "https://${DOMAIN_NAME}" --allow-root \
    && wp theme install inspiro --activate --path=/var/www/html --allow-root \
    && echo "WordPress installation complete."
    touch /var/www/html/.wordpress_installed
fi


# Set permissions after installation
chown -R www-data:www-data /var/www/html
chmod -R 775 /var/www/html

# Start PHP-FPM in the foreground, PHP-FPM will handle the process management
echo "Starting PHP-FPM..."
exec /usr/sbin/php-fpm7.4 -R -F
