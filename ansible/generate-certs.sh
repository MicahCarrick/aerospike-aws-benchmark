#!/usr/bin/env bash

# Generate self-signed certificates for testing Aerospike with TLS enabled.

PREFIX='aerospike'
PASSWORD='changeit'
ORG='Aerospike, Inc.'
VALID_DAYS=360
CERT_DIR='files'
KEYSTORE_PASSWORD='changeit'

# create CA cert
echo "Creating CA certificate"
openssl req -new -x509 -days ${VALID_DAYS} -extensions v3_ca -passout pass:"$PASSWORD" -keyout ${CERT_DIR}/${PREFIX}.ca.key -out ${CERT_DIR}/${PREFIX}.ca.crt -subj "/CN=${PREFIX}.ca/O=$ORG/C=US"

# create ECDSA certs
# TODO: remove "ECDSA" from common name
CERTS=( "${PREFIX}.client_ECDSA" "${PREFIX}.server_ECDSA" )
for CERT in "${CERTS[@]}"
do
    echo "Creating ${CERT} ECDSA certificate"
    CN=${CERT:0:${#CERT}-6}
    openssl ecparam -genkey -out ${CERT_DIR}/ecparam.pem -name prime256v1
    openssl genpkey -paramfile ${CERT_DIR}/ecparam.pem -out ${CERT_DIR}/${CERT}.key
    openssl req -new -key ${CERT_DIR}/${CERT}.key -out ${CERT_DIR}/${CERT}.csr -subj "/CN=$CN/O=$ORG/C=US"
    openssl x509 -req -days ${VALID_DAYS} -passin pass:"$PASSWORD" -in ${CERT_DIR}/${CERT}.csr -CA ${CERT_DIR}/${PREFIX}.ca.crt -CAkey ${CERT_DIR}/${PREFIX}.ca.key -CAcreateserial -out ${CERT_DIR}/${CERT}.crt
    rm ${CERT_DIR}/ecparam.pem ${CERT_DIR}/${CERT}.csr ${CERT_DIR}/${PREFIX}.ca.srl
done

# create RSA certs
CERTS=( "${PREFIX}.client_RSA" "${PREFIX}.server_RSA" )
for CERT in "${CERTS[@]}"
do
    echo "Creating ${CERT} RSA certificate"
    CN=${CERT:0:${#CERT}-4}
    openssl req -new -nodes -keyout ${CERT_DIR}/${CERT}.key -out ${CERT_DIR}/${CERT}.csr -subj "/CN=$CN/O=$ORG/C=US"
    openssl x509 -req -passin pass:"$PASSWORD" -in ${CERT_DIR}/${CERT}.csr -CA ${CERT_DIR}/${PREFIX}.ca.crt -CAkey ${CERT_DIR}/${PREFIX}.ca.key -CAcreateserial -out ${CERT_DIR}/${CERT}.crt
    rm ${CERT_DIR}/${CERT}.csr ${CERT_DIR}/${PREFIX}.ca.srl
done

echo "Creating $CERT_DIR/${PREFIX}.client_ECDSA.p12"
cat $CERT_DIR/${PREFIX}.ca.crt $CERT_DIR/${PREFIX}.client_ECDSA.crt $CERT_DIR/${PREFIX}.client_ECDSA.key > $CERT_DIR/${PREFIX}.client_ECDSA.chain.crt
openssl pkcs12 -export -in $CERT_DIR/${PREFIX}.client_ECDSA.chain.crt -out $CERT_DIR/${PREFIX}.client_ECDSA.chain.p12 -password pass:"$KEYSTORE_PASSWORD" -name ${PREFIX}.client -noiter -nomaciter

# create pkcs12 client certificate
echo "Creating $CERT_DIR/${PREFIX}.client_RSA.p12"
cat $CERT_DIR/${PREFIX}.ca.crt $CERT_DIR/${PREFIX}.client_RSA.crt $CERT_DIR/${PREFIX}.client_RSA.key > $CERT_DIR/${PREFIX}.client_RSA.chain.crt
openssl pkcs12 -export -in $CERT_DIR/${PREFIX}.client_RSA.chain.crt -out $CERT_DIR/${PREFIX}.client_RSA.chain.p12 -password pass:"$KEYSTORE_PASSWORD" -name ${PREFIX}.client -noiter -nomaciter
