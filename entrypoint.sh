#! /bin/bash

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
