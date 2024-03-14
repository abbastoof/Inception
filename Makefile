# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: atoof <atoof@student.hive.fi>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/10 15:26:46 by atoof             #+#    #+#              #
#    Updated: 2024/03/10 15:26:46 by atoof            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Variables
DOMAIN = atoof.42.fr

# Default target
all: up

# Prepare environment
prepare:
	@if [ ! -d "/home/atoof/data/wordpress-data" ]; then \
		echo "Creating /home/atoof/data/wordpress-data directory..."; \
		mkdir -p /home/atoof/data/wordpress-data; \
		chmod -R 777 /home/atoof/data/wordpress-data; \
	fi
	@if [ ! -d "/home/atoof/data/mariadb-data" ]; then \
		echo "Creating /home/atoof/data/mariadb-data directory..."; \
		mkdir -p /home/atoof/data/mariadb-data; \
		chmod -R 777 /home/atoof/data/mariadb-data; \
	fi
	@if [ ! grep -q "$(DOMAIN)" /etc/hosts ]; then \
		echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts; \
	fi

# Build and start the services
up: prepare
	@docker-compose -f srcs/docker-compose.yml up --build -d

# Stop and remove containers, networks
down:
	@echo "This will stop and remove all containers, networks. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@docker-compose -f srcs/docker-compose.yml down

# Restart the services by rebuilding them without showing down's message
re: prepare
	@echo "Restarting services. This will stop, remove, and rebuild all containers and networks. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@docker-compose -f srcs/docker-compose.yml down
	@docker-compose -f srcs/docker-compose.yml up --build -d

# Stop services without removing them
stop:
	@docker-compose -f srcs/docker-compose.yml stop

# Start services without rebuilding
start:
	@docker-compose -f srcs/docker-compose.yml start

# Show status of the services
status:
	@docker-compose -f srcs/docker-compose.yml ps

# Remove all Docker containers, images, volumes, and networks
clean:
	@echo "This will remove all containers, images, volumes, and networks. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@docker-compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans
	@docker volume prune -f
	@docker system prune -af --volumes
	# Attempt to remove data directories with sudo to overcome potential permission issues
	@echo "Removing data directories..."
	@sudo rm -rf /home/atoof/data/wordpress-data
	@sudo rm -rf /home/atoof/data/mariadb-data
	@echo "Cleanup completed."

.PHONY: all up down re stop start status clean prepare
