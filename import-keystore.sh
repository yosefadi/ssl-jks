#!/bin/bash

# Exit on any error
set -e

# Configuration
SSL_BASE_PATH="./out" # current dir
SSL_PASSWORD="your_secure_password"
VALIDITY_DAYS=365
RSA_KEY_SIZE=2048

echo "=== Converting server certificate to PKCS12 format ==="
openssl pkcs12 -export \
    -in "${SSL_BASE_PATH}/cert.crt" \
    -inkey "${SSL_BASE_PATH}/cert.key" \
    -chain \
    -CAfile "${SSL_BASE_PATH}/ca.crt" \
    -name cert \
    -out "${SSL_BASE_PATH}/cert.p12" \
    -password pass:${SSL_PASSWORD}

echo "=== Generating broker keystore and importing the certificate ==="
keytool -importkeystore \
    -deststorepass ${SSL_PASSWORD} \
    -destkeystore "${SSL_BASE_PATH}/cert.keystore.pkcs12" \
    -srckeystore "${SSL_BASE_PATH}/cert.p12" \
    -deststoretype PKCS12 \
    -srcstoretype PKCS12 \
    -noprompt \
    -srcstorepass ${SSL_PASSWORD}

echo "=== Verifying the keystore ==="
keytool -list -v \
    -keystore "${SSL_BASE_PATH}/cert.keystore.pkcs12" \
    -storepass ${SSL_PASSWORD}
