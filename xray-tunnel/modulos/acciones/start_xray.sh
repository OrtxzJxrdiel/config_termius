#!/data/data/com.termux/files/usr/bin/bash
bash "$(dirname "$0")/animacion_start.sh"

# Este script inicia Xray
BASE=~/xray-tunnel
XRAY=$BASE/xray-xhttp
BIN=$XRAY/bin
CONF=$XRAY/config.json
LOG=$XRAY/log.txt
PID=$XRAY/xray.pid

GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

if [ -f "$PID" ]; then
  echo -e "${YELLOW}🚨 Xray ya está en ejecución. Por favor, deténlo primero.${NC}"
  exit 1
fi

echo -e "${BLUE}🚀 Iniciando conexión Xray...${NC}"
nohup $BIN/xray run -c $CONF > $LOG 2>&1 &
echo $! > $PID

sleep 2

if pgrep -F $PID > /dev/null; then
  echo -e "${GREEN}✅ Xray iniciado con éxito (PID: $(cat $PID))${NC}"
  echo -e "${YELLOW}Túnel Xray activado. Ahora puedes usarlo.${NC}"
else
  echo -e "${RED}❌ Fallo al iniciar Xray.${NC}"
  exit 1
fi
