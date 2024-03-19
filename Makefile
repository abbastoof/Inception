# **************************************************************************** #
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: atoof <atoof@student.hive.fi>              +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2024/03/15 14:48:25 by atoof             #+#    #+#              #
#    Updated: 2024/03/15 14:48:25 by atoof            ###   ########.fr        #
#                                                                              #
# **************************************************************************** #

# Variables
DOMAIN = atoof.42.fr


all: up
	@echo "Waiting for WordPress to become available at https://atoof.42.fr:443..."
	@success_count=0; \
	while true; do \
		response=$$(curl -s -k -o /dev/null -w "%{http_code}" https://atoof.42.fr:443); \
		if [ "$$response" = "200" ]; then \
			success_count=$$((success_count + 1)); \
			if [ $$success_count -ge 2 ]; then \
				echo "WordPress is available at https://atoof.42.fr:443"; \
				break; \
			fi; \
		elif [ "$$response" = "502" ] && [ $$success_count -ge 2 ]; then \
			success_count=1;  # Reset to require one more 200 OK after seeing a 502, but keep the progress towards availability. \
		else \
			success_count=0;  # Reset if the response is not 200 and we haven't reached our success criteria yet. \
		fi; \
		sleep 5; \
	done

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

	@if ! grep -q "$(DOMAIN)" /etc/hosts; then \
    	echo "127.0.0.1 $(DOMAIN)" | sudo tee -a /etc/hosts; \
	fi

# Build and start the services
up: prepare
	@docker compose -f srcs/docker-compose.yml up --build -d

# Stop and remove containers, networks
down:
	@echo "This will stop and remove all containers, networks. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@docker compose -f srcs/docker-compose.yml down

# Restart the services by rebuilding them without showing down's message
re: prepare
	@echo "Restarting services. This will stop, remove, and rebuild all containers and networks. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@docker compose -f srcs/docker-compose.yml down
	@docker compose -f srcs/docker-compose.yml up --build -d

# Stop services without removing them
stop:
	@docker compose -f srcs/docker-compose.yml stop

# Start services without rebuilding
start:
	@docker compose -f srcs/docker-compose.yml start

# Show status of the services
status:
	@docker compose -f srcs/docker-compose.yml ps

# Remove all Docker containers, images, volumes, and networks
clean:
	@if [ -z "$$SKIP_CLEAN_PROMPT" ]; then \
		echo "This will remove all containers, images, volumes, and networks. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]; \
	fi
	@docker compose -f srcs/docker-compose.yml down --rmi all --volumes --remove-orphans
	@docker volume prune -f
	@docker system prune -af --volumes
	@echo "Waiting for Docker resources to be fully released..."
	@sleep 5
	@echo "Checking for active processes that might be using the data directories...";
# We will list all processes using the data directories and check if there are any active processes
	@if sudo lsof +D /home/atoof/data/ 2>/dev/null; then \
		echo "Warning: Active processes are using the data directories. Please ensure all processes are stopped before attempting cleanup again."; \
	else \
		echo "No active process detected. Proceeding with data directories removal..."; \
		if sudo rm -rf /home/atoof/data/; then \
			echo "Data directories successfully removed."; \
		else \
			echo "Failed to remove data directories. Please check permissions and try again."; \
		fi \
	fi
	@echo "Cleanup completed."

fclean:
	@echo "This will remove the domain $(DOMAIN) from /etc/hosts and clean up Docker resources. Are you sure? [y/N]" && read ans && [ $${ans:-N} = y ]
	@sudo sed -i'' "/$(DOMAIN)/d" /etc/hosts
	@echo "Domain removed from /etc/hosts."
	@echo "Cleaning up Docker resources..."
	@echo "Docker resources cleaned up."
	@SKIP_CLEAN_PROMPT=1 $(MAKE) clean --no-print-directory

.PHONY: all up down re stop start status clean fclean prepare
