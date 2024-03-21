FROM debian:11

# Install Nginx and OpenSSL
RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*

# Configure SSL
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
    -out /etc/nginx/ssl/abbas_toof.pem \
    -keyout /etc/nginx/ssl/abbas_toof.key \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Hive Helsinki/OU=Student/CN=abbas toof/"


# Copy the Nginx configuration file to the container image
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Create a directory for the nginx pid file and change the user that runs the nginx server to www-data.
RUN mkdir -p /run/nginx && \
    sed -i 's/user nginx;/user www-data www-data;/' /etc/nginx/nginx.conf && \
	sed -i 's/ssl_protocols TLSv1 TLSv1.1 TLSv1.2 TLSv1.3;/ssl_protocols TLSv1.2 TLSv1.3;/' /etc/nginx/nginx.conf

# Expose is used to expose the port 443 to the host machine. This is used to allow the host machine to access the nginx server running in the container.
EXPOSE 443


# The ENTRYPOINT instruction is used to specify the command that will run when the container starts.
# Start Nginx in the foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]
