# USER_DOC

## Provided services
- `nginx` (HTTPS reverse proxy, public entrypoint on port 443)
- `wordpress` (PHP-FPM application)
- `mariadb` (database backend)

## Start and stop
- Start (build + run): `make`
- Stop containers: `make down`
- Stop and remove volumes: `make clean`

## Access website and administration panel
1. Ensure your host resolves `<login>.42.fr` to your VM/local IP.
2. Open: `https://<login>.42.fr`
3. WordPress admin panel: `https://<login>.42.fr/wp-admin`

## Locate and manage credentials
- Non-sensitive config is in `srcs/.env`.
- Passwords are configured through environment variables in `srcs/.env`.
- Keep real credentials out of version control.

## Check service health
- List container states: `make ps`
- View logs: `make logs`
- Verify HTTPS endpoint: open browser on `https://<login>.42.fr`
