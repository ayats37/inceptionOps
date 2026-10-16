NAME = inception

# Chemin vers le dossier srcs où se trouve ton docker-compose.yml
SRCS = ./srcs/docker-compose.yml

# Dossiers pour les volumes (Chemins absolus recommandés pour Docker)
DATA_PATH = /home/taya/data
MARIADB_DATA = $(DATA_PATH)/mariadb
WORDPRESS_DATA = $(DATA_PATH)/wordpress

all:
	@printf "Création des dossiers de données...\n"
	@mkdir -p $(MARIADB_DATA)
	@mkdir -p $(WORDPRESS_DATA)
	@printf "Lancement de la configuration Docker...\n"
	@docker-compose -f $(SRCS) up --build -d

down:
	@printf "Arrêt des conteneurs...\n"
	@docker-compose -f $(SRCS) down

clean: down
	@printf "Nettoyage des conteneurs, réseaux et images...\n"
	@docker-compose -f $(SRCS) down --rmi all --volumes

fclean: clean
	@printf "Suppression définitive des volumes de données...\n"
	@sudo rm -rf $(DATA_PATH)

re: fclean all

.PHONY: all down clean fclean re