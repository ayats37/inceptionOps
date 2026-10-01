FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    mariadb-server \
    tini \
    && rm -rf /var/lib/apt/lists/*

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/init-mariadb.sh /usr/local/bin/init-mariadb.sh
RUN chmod +x /usr/local/bin/init-mariadb.sh

EXPOSE 3306

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/init-mariadb.sh"]
