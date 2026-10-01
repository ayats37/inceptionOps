include srcs/.env

COMPOSE_FILE = srcs/docker-compose.yml
ENV_FILE = srcs/.env
COMPOSE = docker compose -f $(COMPOSE_FILE) --env-file $(ENV_FILE)

DATA_ROOT = /home/$(LOGIN)/data
MARIADB_DATA = $(DATA_ROOT)/mariadb
WORDPRESS_DATA = $(DATA_ROOT)/wordpress

.PHONY: all up down build ps logs clean fclean re init-data check-env

all: up

up: init-data check-env
	$(COMPOSE) up -d --build

build: init-data check-env
	$(COMPOSE) build

down:
	$(COMPOSE) down

ps:
	$(COMPOSE) ps

logs:
	$(COMPOSE) logs -f

clean:
	$(COMPOSE) down -v --remove-orphans

fclean: clean
	docker image rm -f mariadb wordpress nginx 2>/dev/null || true
	docker volume rm -f mariadb_data wordpress_data 2>/dev/null || true

re: fclean up

init-data:
	mkdir -p $(MARIADB_DATA) $(WORDPRESS_DATA)

check-env:
	@test -n "$(MYSQL_PASSWORD)" || (echo "Missing MYSQL_PASSWORD in srcs/.env" && exit 1)
	@test -n "$(MYSQL_ROOT_PASSWORD)" || (echo "Missing MYSQL_ROOT_PASSWORD in srcs/.env" && exit 1)
	@test -n "$(WP_ADMIN_PASSWORD)" || (echo "Missing WP_ADMIN_PASSWORD in srcs/.env" && exit 1)
	@test -n "$(WP_USER_PASSWORD)" || (echo "Missing WP_USER_PASSWORD in srcs/.env" && exit 1)
