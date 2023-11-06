#!/bin/bash
ROOTDIR=$(git rev-parse --show-toplevel)
if [[ $# -eq 0 ]] ; then
    echo 'ERROR: You must provide a number of clients.'
    exit 1
fi
NUM_CLIENTS=$1
CA_PATH="${ROOTDIR}/scripts/sts-wire/conf/cacerts"
mkdir -p $CA_PATH
openssl genrsa -out $CA_PATH/clientsCA.key 4096
openssl req -x509 -new -nodes -key $CA_PATH/clientsCA.key \
 -sha256 -days 1024 -out $CA_PATH/clientsCA.crt \
 -subj "/CN=clientsCA"

for index in $(seq 1 $NUM_CLIENTS)
do
  CERTS_PATH="${ROOTDIR}/scripts/sts-wire/conf/certs/client${index}"
  mkdir -p $CERTS_PATH
  openssl genrsa -out $CERTS_PATH/private.key 4096
  openssl req -new -sha256 -key $CERTS_PATH/private.key \
   -subj "/CN=client${index}" \
   -out $CERTS_PATH/public.csr
  openssl x509 -req -in $CERTS_PATH/public.csr \
   -CA $CA_PATH/clientsCA.crt -CAkey $CA_PATH/clientsCA.key -CAcreateserial \
   -out $CERTS_PATH/public.crt -days 365 -sha256
done
