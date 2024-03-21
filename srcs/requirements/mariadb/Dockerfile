FROM debian:11

# Set non-interactive to suppress debconf messages
ENV DEBIAN_FRONTEND=noninteractive

# Install MariaDB
RUN apt -y update && \
    apt install -y mariadb-server && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/lib/mysql /run/mysqld /var/log/mysql && \
    chown -R mysql:mysql /var/lib/mysql /run/mysqld /var/log/mysql && \
    chmod 755 /var/log/mysql && \
    touch /var/log/mysql/error.log && \
    chown mysql:mysql /var/log/mysql/error.log

# Configure mariadb to allow remote connections on 0.0.0.0:3306
COPY ./conf/my.cnf /etc/mariadb.conf.d/my.cnf
# 
RUN chmod 440 /etc/mariadb.conf.d/my.cnf

# Copy the entrypoint script to the container
COPY ./tools/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose port 3306
EXPOSE 3306

# Start MariaDB using the custom entrypoint script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
