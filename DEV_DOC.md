# DEV_DOC

## Environment setup from scratch
1. Install Docker Engine + Docker Compose plugin.
2. Clone repository.
3. Edit `srcs/.env` (`LOGIN`, `DOMAIN_NAME`, and credential variables).
4. Ensure host directories are available (Makefile also creates them):
   - `/home/<login>/data/mariadb`
   - `/home/<login>/data/wordpress`

## Build and launch with Makefile + Compose
- Build and run: `make`
- Build only: `make build`
- Stop stack: `make down`
- Full cleanup: `make fclean`
- Rebuild from scratch: `make re`

## Container and volume management commands
- `make ps` for status
- `make logs` for logs
- `docker volume ls` to inspect volumes
- `docker network ls` to inspect networks

## Data location and persistence
- Volume `mariadb_data` persists at `/home/<login>/data/mariadb`
- Volume `wordpress_data` persists at `/home/<login>/data/wordpress`
- Data survives container recreation unless removed with cleanup that deletes volumes
