arg NGINX_VERSION
from nginx:${NGINX_VERSION}

arg DEBIAN_FRONTEND=noninteractive
arg EMAIL=admin@example.com

RUN apt-get update \
	&& apt-get install -y --no-install-recommends \
	cron \
	&& apt-get autoremove \
	&& apt-get autoclean \
	&& rm -rf /var/lib/apt/lists/*

RUN rm /etc/nginx/conf.d/default.conf

RUN curl https://get.acme.sh | sh -s email=${EMAIL} \
	&& /root/.acme.sh/acme.sh --set-default-ca --server letsencrypt

COPY templates /templates
COPY scripts /scripts
