#!/bin/bash

service nginx stop

if [[ -f /certs/cert.pem && -f /certs/key.pem ]]
then
    # self signed
    mkdir -p /etc/ssl/certs
    mkdir -p /etc/ssl/private

    ln -sf /certs/cert.pem /etc/ssl/certs/cert.pem
    ln -sf /certs/key.pem /etc/ssl/private/key.pem

    /scripts/create_configs.sh

    nginx -g "daemon off;"
else
    # let's encrypt
    service nginx start

    /scripts/update_cert.sh issue

    service nginx stop

    crontab -r
    echo '24 2 1 * * /update_cert.sh update' | crontab -

    nginx -g "daemon off;"
fi
