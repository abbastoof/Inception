FROM debian:11

# Install Nginx and OpenSSL
RUN apt -y update && \
    apt install -y nginx openssl && \
    rm -rf /var/lib/apt/lists/*  # Cleanup to reduce image size

# Configure SSL
RUN mkdir -p /etc/nginx/ssl && \
    openssl req -newkey rsa:4096 -x509 -sha256 -days 365 -nodes \
    -out /etc/nginx/ssl/abbas_toof.pem \
    -keyout /etc/nginx/ssl/abbas_toof.key \
    -subj "/C=FI/ST=Uusimaa/L=Helsinki/O=Hive Helsinki/OU=Student/CN=abbas toof/"

# Add Nginx configuration
# Ensure your Nginx configuration is ready at `conf/nginx.conf` on your host
COPY conf/nginx.conf /etc/nginx/conf.d/default.conf

# Prepare Nginx and system user
# mkdir -p /run/nginx is used to create the directory for the nginx.pid file. The nginx.pid file is used to store the process id of the nginx server.
# -p is used to create the directory and its parent directories if they do not exist.
# --system is used to create a system user and group. A system user is a user that is created for running a service and it is not meant to be used for login.
# --no-create-home is used to not create a home directory for the user.
# --ingroup is used to add the user to a group.
# -i is used to edit the file in place.
# -i 's/user nginx;/user www www;/' is used to replace the user directive in the nginx.conf file with the www user and group that we created.
RUN mkdir -p /run/nginx && \
    addgroup --system www && \
    adduser --system --no-create-home --ingroup www www && \
    sed -i 's/user nginx;/user www www;/' /etc/nginx/nginx.conf

# Expose is used to expose the port 443 to the host machine. This is used to allow the host machine to access the nginx server running in the container.
EXPOSE 443


# Entrypoint is the last command to run in the Dockerfile and it is the command that will be run when the container starts up.
# This command job is to start the nginx server. -g "daemon off;" is used to keep the container running and not to exit after starting the server.
# -g means global configuration directive and it is used to set a global configuration option.
# daemon off; is used to run the server in the foreground. when deamin is on, the server runs in the background.
# why we dont want to run the server in the background? because when the server runs in the background, the container will exit after starting the server.

# Start Nginx in the foreground
ENTRYPOINT ["nginx", "-g", "daemon off;"]
