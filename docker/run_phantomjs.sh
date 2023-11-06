#!/bin/bash -x

X509_USER_CERT=$1
X509_USER_KEY=$2
IAM_SERVER=$3

OPENSSL_CONF=/etc/ssl phantomjs \
  --ignore-ssl-errors=true \
  --ssl-protocol=any \
  --ssl-client-certificate-file=$X509_USER_CERT \
  --ssl-client-key-file=$X509_USER_KEY \
  $HOME/login.js $IAM_SERVER

OPENSSL_CONF=/etc/ssl phantomjs \
  --ignore-ssl-errors=true \
  --ssl-protocol=any \
  --ssl-client-certificate-file=$X509_USER_CERT \
  --ssl-client-key-file=$X509_USER_KEY \
  $HOME/authorize.js $IAM_SERVER

rm -f cookies.txt
