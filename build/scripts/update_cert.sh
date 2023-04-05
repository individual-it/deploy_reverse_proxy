#!/usr/bin/env bash

acme_domains=""

find /etc/nginx/conf.d/ -type f -delete

for prefix in ${DOMAIN_NAME_PREFIXES[@]}
do
    domain=""
    http_port=""
    https_port=""
    eval "domain=\$${prefix}_DOMAIN"
    eval "http_port=\$${prefix}_HTTP_PORT"
    eval "https_port=\$${prefix}_HTTPS_PORT"

    if [[ ( "$http_port" == 80 ) && ( "$https_port" == 443 ) ]]
    then
        conf_name="${prefix}_${domain}.conf"

        cp /templates/encrypt.conf "/etc/nginx/conf.d/$conf_name"
        sed -i \
            -e "s|_SERVERNAME_|$domain|g" \
            "/etc/nginx/conf.d/$conf_name"
        acme_domains="$acme_domains -d $domain"
    fi
done

service nginx force-reload

if [ "$1" = "update" ]; then
    ACTION="--renew-all"
else
    ACTION="--issue"
fi

if [ "${CERT_TESTING}" != "no" ]; then
    STAGING="--test"
else
    STAGING=""
fi

/root/.acme.sh/acme.sh \
    ${ACTION} ${STAGING} \
    $acme_domains \
    --nginx \
    --cert-file       /etc/ssl/certs/cert.pem  \
    --key-file       /etc/ssl/private/key.pem  \
    --reloadcmd     "service nginx force-reload"

/scripts/create_configs.sh

service nginx force-reload
