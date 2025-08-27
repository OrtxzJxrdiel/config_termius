#!/data/data/com.termux/files/usr/bin/bash

BASE=~/xray-tunnel
XRAY=$BASE/xray-xhttp
CONF=$XRAY/config.json
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

clear
echo -e "${YELLOW}⚙️ Cambiar configuración de Xray${NC}"
echo ""

read -p "Ingrese la nueva IP del servidor: " new_ip
read -p "Ingrese el nuevo puerto: " new_port
read -p "Ingrese el nuevo UUID: " new_uuid
read -p "Ingrese el nuevo host: " new_host

if [ -z "$new_ip" ] || [ -z "$new_port" ] || [ -z "$new_uuid" ] || [ -z "$new_host" ]; then
  echo -e "${RED}❌ Error: No se pueden dejar campos vacíos.${NC}"
  exit 1
fi

cat > $CONF <<EOF
{
  "log": {
    "loglevel": "warning"
  },
  "inbounds": [{
    "port": 10808,
    "listen": "127.0.0.1",
    "protocol": "socks",
    "settings": {
      "udp": true
    }
  }],
  "outbounds": [{
    "protocol": "vless",
    "settings": {
      "vnext": [{
        "address": "$new_ip",
        "port": $new_port,
        "users": [{
          "id": "$new_uuid",
          "encryption": "none"
        }]
      }]
    },
    "streamSettings": {
      "network": "xhttp",
      "xhttpSettings": {
        "path": "/",
        "xhttpMode": "auto",
        "host": "$new_host"
      }
    }
  }]
}
EOF

echo -e "${GREEN}✅ Configuración actualizada con éxito.${NC}"
