#!/bin/bash
set -e

SERVER_ENV="/opt/config/.env_server"
CLIENT_ENV="/opt/config/.env_client"

# check file exists
if [ ! -f "$SERVER_ENV" ]; then

    # check SERVERURL
    if [ -z "${SERVERURL}" ]; then
        echo "Error: SERVERURL is not defined. exit 1"
        exit 1
    fi
    # SERVERURL="${SERVERURL:-$(hostname -I | awk '{print $1}')}"

    echo "Generating WireGuard keys ..."

    # generate key 
    SERVER_PRIVATE=$(wg genkey)
    SERVER_PUBLIC=$(echo "$SERVER_PRIVATE" | wg pubkey)
    CLIENT_PRIVATE=$(wg genkey)
    CLIENT_PUBLIC=$(echo "$CLIENT_PRIVATE" | wg pubkey)
    PSK=$(wg genpsk)

    # URL
    SERVERPORT="${SERVERPORT:-51820}"

    # .env_server
    cat > "$SERVER_ENV" <<EOF
# Auto-generated WireGuard secrets
GEN_SERVERPORT=$SERVERPORT
GEN_SERVER_PRIVATE=$SERVER_PRIVATE
GEN_CLIENT_PUBLIC=$CLIENT_PUBLIC
GEN_PSK=$PSK
EOF

    # .env_client
    cat > "$CLIENT_ENV" <<EOF
# Auto-generated WireGuard secrets
GEN_SERVERURL=$SERVERURL
GEN_SERVERPORT=$SERVERPORT
GEN_CLIENT_PRIVATE=$CLIENT_PRIVATE
GEN_SERVER_PUBLIC=$SERVER_PUBLIC
GEN_PSK=$PSK
EOF

    echo "Generated new keys:"
    echo "  - $SERVER_ENV"
    echo "  - $CLIENT_ENV"
else
    echo "Existing keys found."
fi


set -a
source /opt/config/.env_server
set +a

# install envsubst
apk add --no-cache gettext

mkdir -p /config/wg_confs
envsubst < /opt/wg0.conf.template > /config/wg_confs/wg0.conf
