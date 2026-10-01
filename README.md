*This project has been created as part of the 42 curriculum by your_login.*

## Description
Inception is a system administration project where a multi-service web stack is deployed with Docker Compose on a virtual machine.

The mandatory stack includes:
- `nginx` as the only public entrypoint on port 443 with TLSv1.2/TLSv1.3.
- `wordpress` with `php-fpm` only.
- `mariadb` only.
- Two named volumes persisted on the host in `/home/<login>/data`.
- One dedicated Docker bridge network for service communication.

## Instructions
1. Set your login and non-secret values in `srcs/.env`.
2. Update passwords and settings in `srcs/.env`.
3. Ensure your host has the domain mapping for `<login>.42.fr` to your VM/local IP.
4. Launch the project:
   - `make`
5. Useful commands:
   - `make ps`
   - `make logs`
   - `make down`
   - `make clean`

## Project description and design choices
### Docker usage in this project
- Each service has its own Dockerfile and dedicated container.
- Images are built locally from Debian base images (no ready-made service images).
- Service startup logic is handled by entrypoint scripts and foreground processes.

### Main sources in the project
- `srcs/docker-compose.yml`: services, volumes, network, secrets.
- `srcs/requirements/*`: one directory per service with Dockerfile, configs, and tools.
- `Makefile`: build/run lifecycle helpers.
- `srcs/.env`: configuration values used by containers.

### Comparisons
#### Virtual Machines vs Docker
- VM: virtualizes full OS and kernel space, heavier but strong isolation and full machine simulation.
- Docker: shares host kernel, lighter and faster startup, focused on app/service packaging.

#### Secrets vs Environment Variables
- Secrets: stronger separation for sensitive values when enabled in a deployment.
- Environment variables: simpler for local setup, but must never contain real credentials in public repositories.

#### Docker Network vs Host Network
- Docker bridge network: isolated internal communication, explicit topology, safer defaults.
- Host network: bypasses isolation and can create port conflicts and weaker boundaries.

#### Docker Volumes vs Bind Mounts
- Named volumes: managed by Docker, stable lifecycle, portable in compose workflows.
- Bind mounts: direct host path coupling, useful for dev but more host-dependent.

## Resources
- Docker documentation: https://docs.docker.com/
- Docker Compose specification: https://docs.docker.com/compose/
- NGINX docs: https://nginx.org/en/docs/
- MariaDB docs: https://mariadb.com/kb/en/documentation/
- WordPress + WP-CLI docs: https://developer.wordpress.org/cli/commands/

### AI usage disclosure
AI was used for:
- structuring the repository and service layout,
- drafting container bootstrap scripts,
- checking requirement coverage from the subject,
- preparing documentation templates.

All generated material must be reviewed, tested, and understood before defense.
