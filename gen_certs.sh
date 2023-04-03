#!/usr/bin/env bash

set -e

DAYS=3650
SUBJ='/C=RU/ST=MSK/L=MSK/O=CMP/OU=CNO/CN=cert'

BASEDIR=$(dirname $(realpath $0))
CERT=$BASEDIR/certs/cert.pem
KEY=$BASEDIR/certs/key.pem

if [[ -f $CERT || -f $KEY ]]
then
    1>&2 echo Certificates exist! Not overwriting!
    exit 1
fi

openssl req -newkey rsa:4096 -x509 -sha256 -nodes \
	-days $DAYS \
	-subj $SUBJ \
	-out $CERT \
	-keyout $KEY
