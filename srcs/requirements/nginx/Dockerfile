FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    nginx \
    openssl \
    tini \
    && rm -rf /var/lib/apt/lists/*

COPY conf/default.conf /etc/nginx/conf.d/default.conf
COPY tools/init-nginx.sh /usr/local/bin/init-nginx.sh
RUN chmod +x /usr/local/bin/init-nginx.sh

EXPOSE 443

ENTRYPOINT ["/usr/bin/tini", "--", "/usr/local/bin/init-nginx.sh"]
