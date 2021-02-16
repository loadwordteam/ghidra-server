#! /bin/bash

# Let's start to check if the server has been configured
if [ ! -f "${GHIDRA_HOME}/server/server.conf" ]; then
    
    echo "====== GHIDRA CONF FILE ======" #
    # Usually, ghidra server creates a self-signed certificate with a very
    # weak algorithm, some gnu/Linux distribution like Fedora implements
    # some security policies for preventing you to connect to such
    # "unsafe" environments. Alas the default algorithm used by ghidra is
    # a hardcoded SHA1withRSA and we cannot change it by the
    # configuration, but we can generate a new certificate with stronger
    # encryption and configure the server to use that.

    # We need two environment variables:

    # $GHIDRA_CERT_PATH the directory for holding our certificates. I
    # strongly suggest you mount this as a volume to not create a new
    # certificate for every startup.

    # $GHIDRA_CERT_PASSWORD a secret for ghidra to unlock the
    # keystore.jks, the only file it needs for the encryption.

    # You might want to create the certificate yourself and just mount the
    # volume, feel free to do so, I wrote this piece of code for
    # convenience and also to make sure the keytool is the one from the
    # current JDK distribution.
    
    if [ ! -f "${GHIDRA_CERT_PATH}/keystore.jks" ]; then
	if [ -n "$GHIDRA_CERT_PATH" -a -n "$GHIDRA_CERT_PASSWORD" ]; then
	    echo "------ Ghidra server cert generation ------"
	    mkdir -p $GHIDRA_CERT_PATH
	    openssl req -newkey rsa:4096 -sha512 -nodes -keyout "${GHIDRA_CERT_PATH}/key.pem" -x509 -days 1460 -subj "/C=US/ST=/L=/O=/CN=GhidraServer"  -out "${GHIDRA_CERT_PATH}/certificate.pem" 
	    openssl pkcs12 -inkey "${GHIDRA_CERT_PATH}/key.pem" -in "${GHIDRA_CERT_PATH}/certificate.pem" -export -out "${GHIDRA_CERT_PATH}/certificate.p12" -passout "pass:${GHIDRA_CERT_PASSWORD}" 
	    keytool -importkeystore -srckeystore "${GHIDRA_CERT_PATH}/certificate.p12" -srcstoretype pkcs12 -destkeystore "${GHIDRA_CERT_PATH}/keystore.jks" -deststoretype JKS  -storepass $GHIDRA_CERT_PASSWORD -srcstorepass $GHIDRA_CERT_PASSWORD
	    echo "------ Keys generated ------"
	else
	    echo "!!!!!! ERROR password and/or cert path empty"
	    exit -1
	fi
    fi
    # Manually define the envirioment variables for the server.conf
    # generation, this template is full of bash-like variables!
    #
    # Beware about the $HOSTNAME variable is used for the -ip argument
    # in our server.
    envsubst '$GHIDRA_HOME,$GHIDRA_REPO_DIR,$HOSTNAME,$GHIDRA_CERT_PATH,$GHIDRA_CERT_PASSWORD' < /server.conf.tmpl > "${GHIDRA_HOME}/server/server.conf"

    # We run svrInstall for making the ghidra server happy and it will
    # also initialize our repository files. We cannot directly start
    # the server in "console" mode.
    if [ ! -f "${GHIDRA_REPO_DIR}/users" ]; then
	echo '====== GHIDRA FIRST START UP ======'
	# will not work on a centos or fedora, we need a debian based
	# distro
	bash "${GHIDRA_HOME}/server/svrInstall" start 
	bash "${GHIDRA_HOME}/server/ghidraSvr" stop
	echo '====== GHIDRA END FIRST START UP ======'
    fi
fi

exec "$@"
