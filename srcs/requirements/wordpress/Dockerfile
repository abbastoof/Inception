FROM debian:11

# Set non-interactive to suppress debconf messages
ENV DEBIAN_FRONTEND=noninteractive

WORKDIR /

# Check if the www-data group exists, if not, create it
RUN getent group www-data || addgroup --system www-data

# Check if the www-data user exists, if not, create it and add to the www-data group
RUN id -u www-data &>/dev/null || adduser --system --ingroup www-data --disabled-password --no-create-home www-data


RUN apt-get update && \
	apt-get -y install php php-fpm mariadb-client sendmail wordpress wget

RUN mkdir -p /run/php && mkdir -p /var/www/html

COPY ./conf/www.conf /etc/php/7.4/fpm/pool.d/www.conf

# Install wp-cli
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp

WORKDIR /var/www/html



COPY ./tools/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000

CMD ["sh",  "/usr/local/bin/entrypoint.sh"]
