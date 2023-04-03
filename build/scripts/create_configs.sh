#!/usr/bin/env bash

find /etc/nginx/conf.d/ -type f -delete

for prefix in "${DOMAIN_NAME_PREFIXES[@]}"
do
    domain=""
    http_port=""
    https_port=""
    redirect=""
    proxy=""
    eval "domain=\$${prefix}_DOMAIN"
    eval "http_port=\$${prefix}_HTTP_PORT"
    eval "https_port=\$${prefix}_HTTPS_PORT"
    eval "redirect=\$${prefix}_REDIRECT"
    eval "proxy=\$${prefix}_PROXY"

    conf_name="${prefix}_${domain}.conf"

    if [[ "$https_port" == 443 ]]
    then
	https_url_port=
    else
	https_url_port=":$https_port"
    fi

    if [[ -n $proxy ]]
    then
	# proxy to host
	cp /templates/proxy.conf "/etc/nginx/conf.d/${conf_name}"
	sed -i \
	    -e "s|_SERVERNAME_|$domain|g" \
	    -e "s|_HTTP_PORT_|$http_port|g" \
	    -e "s|_HTTPS_PORT_|$https_port|g" \
	    -e "s|_HTTPS_URL_PORT_|$https_url_port|g" \
	    -e "s|_REDIRECT_TO_|$proxy|g" \
	    "/etc/nginx/conf.d/${conf_name}"
    elif [[ -n $redirect ]]
    then
	# redirect
	cp /templates/redirect.conf "/etc/nginx/conf.d/${conf_name}"
	sed -i \
	    -e "s|_SERVERNAME_|$domain|g" \
	    -e "s|_HTTP_PORT_|$http_port|g" \
	    -e "s|_HTTPS_PORT_|$https_port|g" \
	    -e "s|_REDIRECT_|$redirect|g" \
	    "/etc/nginx/conf.d/${conf_name}"
    else
	# serve page
	cp /templates/serve.conf "/etc/nginx/conf.d/${conf_name}"
	sed -i \
	    -e "s|_SERVERNAME_|$domain|g" \
	    -e "s|_HTTP_PORT_|$http_port|g" \
	    -e "s|_HTTPS_PORT_|$https_port|g" \
	    -e "s|_HTTPS_URL_PORT_|$https_url_port|g" \
	    "/etc/nginx/conf.d/${conf_name}"
    fi
done
