#!/data/data/com.termux/files/usr/bin/bash

BASE=~/xray-tunnel
PROXY=$BASE/proxychains4
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${BLUE}🔗 Verificando IP con proxychains4...${NC}"
$PROXY/bin/proxychains4 -f $PROXY/etc/proxychains.conf curl -s https://api.ipify.org && echo -e "${GREEN}✅ IP obtenida con proxychains4${NC}" || echo -e "${RED}❌ Fallo en proxychains4${NC}"
