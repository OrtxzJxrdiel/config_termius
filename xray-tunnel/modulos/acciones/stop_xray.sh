#!/data/data/com.termux/files/usr/bin/bash

PID=~/xray-tunnel/xray-xhttp/xray.pid
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

if [ -f "$PID" ]; then
  echo -e "${YELLOW}⏳ Deteniendo Xray...${NC}"
  kill $(cat $PID)
  rm $PID
  echo -e "${GREEN}✅ Xray se ha detenido con éxito.$>
else
  echo -e "${RED}❌ Xray no está en ejecución.${NC}"
fi
