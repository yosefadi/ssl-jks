#!/bin/bash

# Exit on any error
set -e

# Configuration
SSL_BASE_PATH="./out" # current dir
SSL_PASSWORD="your_secure_password"
VALIDITY_DAYS=365
RSA_KEY_SIZE=2048

# Create directories if they don't exist
mkdir -p "${SSL_BASE_PATH}"

echo "=== Generating CA certificate and key ==="
openssl req -new -nodes \
    -x509 \
    -days ${VALIDITY_DAYS} \
    -newkey rsa:${RSA_KEY_SIZE} \
    -keyout "${SSL_BASE_PATH}/ca.key" \
    -out "${SSL_BASE_PATH}/ca.crt" \
    -config "ca.cnf"

# Verify CA certificate
openssl x509 -in "${SSL_BASE_PATH}/ca.crt" -text -noout

echo "=== Generating server key and CSR ==="
openssl req -new \
    -newkey rsa:${RSA_KEY_SIZE} \
    -keyout "${SSL_BASE_PATH}/cert.key" \
    -out "${SSL_BASE_PATH}/cert.csr" \
    -config "cert.cnf" \
    -nodes

echo "=== Signing server certificate with CA ==="
openssl x509 -req \
    -days ${VALIDITY_DAYS} \
    -in "${SSL_BASE_PATH}/cert.csr" \
    -CA "${SSL_BASE_PATH}/ca.crt" \
    -CAkey "${SSL_BASE_PATH}/ca.key" \
    -CAcreateserial \
    -out "${SSL_BASE_PATH}/cert.crt" \
    -extfile "cert.cnf" \
    -extensions v3_req

# Verify server certificate
openssl x509 -in "${SSL_BASE_PATH}/cert.crt" -text -noout
