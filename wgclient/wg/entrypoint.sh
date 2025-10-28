#!/bin/bash

CLIENT_ENV="/opt/config/.env_client"

if [ ! -f $CLIENT_ENV ]; then
  echo "Error: $CLIENT_ENV not found. exit 1"
  exit 1
fi

set -a
source $CLIENT_ENV
set +a

# install envsubst
apk add --no-cache gettext

mkdir -p /config/wg_confs
envsubst < /opt/wg0.conf.template > /config/wg_confs/wg0.conf
