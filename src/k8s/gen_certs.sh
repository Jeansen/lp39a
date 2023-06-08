#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

_PKI_=../main/jib/pki
# CREATE THE PRIVATE KEY FOR OUR CUSTOM CA
openssl genrsa -out ${_PKI_}/ca.key 2048

# GENERATE A CA CERT WITH THE PRIVATE KEY
openssl req -new -x509 -key ${_PKI_}/ca.key -out ${_PKI_}/ca.crt -config ca.cnf

# CREATE THE PRIVATE KEY FOR OUR SERVER
openssl genrsa -out ${_PKI_}/lp39a-key.pem 2048

# CREATE A CSR FROM THE CONFIGURATION FILE AND OUR PRIVATE KEY
openssl req -new -key ${_PKI_}/lp39a-key.pem -subj "/CN=lp39a.default.svc" -out ${_PKI_}/lp39a.csr -config lp39a.cnf

# CREATE THE CERT SIGNING THE CSR WITH THE CA CREATED BEFORE
openssl x509 -req -in ${_PKI_}/lp39a.csr -CA ${_PKI_}/ca.crt -CAkey ${_PKI_}/ca.key -CAcreateserial  -out ${_PKI_}/lp39a-crt.pem -extensions v3_ca -extfile ssl-x509.cnf

# INJECT CA IN THE WEBHOOK CONFIGURATION
CA_BUNDLE=$(base64 -w0 ${_PKI_}/ca.crt)  envsubst < _manifest_.yaml > manifest.yaml

kubectl delete secret lp39a --ignore-not-found
kubectl create secret generic lp39a -n default  --from-file=key.pem=${_PKI_}/lp39a-key.pem --from-file=cert.pem=${_PKI_}/lp39a-crt.pem

