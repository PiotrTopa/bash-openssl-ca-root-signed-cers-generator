function generateInternalRootCA() {
    echo "Generating Internal CA private key"
    openssl genrsa \
        -out internalRootCA.key \
        4096

    echo "Generating Internal CA root certificate"
    openssl req \
        -x509 \
        -new \
        -nodes \
        -key internalRootCA.key \
        -sha256 \
        -subj "/C=PL/ST=/L=/O=/CN=internal.net" \
        -days 1825 \
        -out internalRootCA.crt
}

function generateCertificate() {
    echo "Generating $1 service private key"
    openssl genrsa \
        -out $1.key \
        4096

    echo "Generating $1 service CSR"
    openssl req \
        -new \
        -key $1.key \
        -out $1.csr \
        -subj "/C=PL/ST=/L=/CN=$1.internal.net"

    echo "Generating $1 service SAN certificate extension config"
    echo "
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = $1
" > $1.san.ext

    echo "Creating $1 service certificate signed by Internal Root CA"    
    openssl x509 \
        -req \
        -in $1.csr \
        -CA internalRootCA.crt \
        -CAkey internalRootCA.key \
        -CAcreateserial \
        -out $1.crt \
        -days 825 \
        -sha256 \
        -extfile $1.san.ext
}

generateInternalRootCA
generateCertificate "dtr"
