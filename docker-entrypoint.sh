#! /bin/bash
if [ ! -f "${GHIDRA_CERT_PATH}/keystore.jks" ]; then
    echo "Ghidra server cert generation"
    mkdir -p $GHIDRA_CERT_PATH
    openssl req -newkey rsa:4096 -sha512 -nodes -keyout "${GHIDRA_CERT_PATH}/key.pem" -x509 -days 1460 -subj "/C=/ST=/L=/O=/CN=GhidraServer"  -out "${GHIDRA_CERT_PATH}/certificate.pem" 
    openssl pkcs12 -inkey "${GHIDRA_CERT_PATH}/key.pem" -in "${GHIDRA_CERT_PATH}/certificate.pem" -export -out "${GHIDRA_CERT_PATH}/certificate.p12" -passout "pass:${GHIDRA_CERT_PASSWORD}" 
    keytool -importkeystore -srckeystore "${GHIDRA_CERT_PATH}/certificate.p12" -srcstoretype pkcs12 -destkeystore "${GHIDRA_CERT_PATH}/keystore.jks" -deststoretype JKS  -storepass $GHIDRA_CERT_PASSWORD -srcstorepass $GHIDRA_CERT_PASSWORD
    echo "Keys generated"
fi

if [ ! -f "${GHIDRA_HOME}/server/server.conf" ]; then
    echo "Generating server.conf"
    envsubst '$GHIDRA_HOME,$GHIDRA_REPO_DIR,$GHIDRA_LISTEN_IP,$GHIDRA_CERT_PATH,$GHIDRA_CERT_PASSWORD' < /server.conf.template > "${GHIDRA_HOME}/server/server.conf"
    
    if [ ! -f "${GHIDRA_REPO_DIR}/users" ]; then
        echo 'init server files'
        bash "${GHIDRA_HOME}/server/svrInstall" start
	echo 'install ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
        bash "${GHIDRA_HOME}/server/ghidraSvr" stop
	echo 'stop ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
        bash "${GHIDRA_HOME}/server/ghidraSvr" start
	echo 'start ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
        bash "${GHIDRA_HOME}/server/ghidraSvr" stop
	echo 'stop ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^'
        sleep 5
        echo 'end init server'
    fi
fi

exec "$@"

