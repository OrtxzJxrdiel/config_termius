#!/data/data/com.termux/files/usr/bin/bash

BASE=~/xray-tunnel
XRAY=$BASE/xray-xhttp
MODULOS=$BASE/modulos
source $MODULOS/modo-ultra-estable.sh
PROXY=$BASE/proxychains4
BIN=$XRAY/bin
CONF=$XRAY/config.json
LOG=$XRAY/log.txt
PID=$XRAY/xray.pid

GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

banner() {
  clear
  toilet -f pagga "NANASHI" | lolcat
  echo -e "${GREEN}"
  echo "╔════════════════════════════════════╗"
  echo "║ 🌀 Xray XHTTP - 🔥 Flow Nica 🔥     ║"
  echo "╠════════════════════════════════════╣"
  echo "║ 📁 Config: $CONF"
  echo "║ 📡 Proxy: 127.00.1:10808"
  echo "╚════════════════════════════════════╝"
  echo -e "${NC}"
}

start_xray() {
  banner
  echo -e "${BLUE}🚀 Iniciando conexión Xray...${NC}"
  nohup $BIN/xray run -config $CONF > $LOG 2>&1 &
  echo $! > $PID
  echo -e "${GREEN}✅ Xray corriendo con PID $(cat $P>

  # Activar modo ultra estable
  activar_modo_ultra_estable
}

stop_xray() {
  banner
  if [ -f "$PID" ]; then
    kill -9 $(cat $PID) && rm -f $PID
    echo -e "${RED}🛑 Xray detenido${NC}"
  else
    echo -e "${YELLOW}⚠️ No hay proceso activo${NC}"
  fi

  # Desactivar modo ultra estable
  desactivar_modo_ultra_estable
}

verificar_ping() {
  banner
  echo -e "${BLUE}🔍 Verificando túnel con curl...${N>
  curl --socks5 127.0.0.1:10808 https://api.ipify.org>
}

verificar_proxychains() {
  banner
  echo -e "${BLUE}🔗 Verificando IP con proxychains4.>
  $PROXY/bin/proxychains4 -f $PROXY/etc/proxychains.c>
}

# 🆕 Función para cambiar la configuración
change_config() {
    banner
    echo -e "${YELLOW}✏️ Ingresa los nuevos datos del >
    read -p "   ➡️ Dirección (IP o Dominio): " new_add>
    read -p "   ➡️ Puerto: " new_port
    read -p "   ➡️ UUID (ID): " new_id
    read -p "   ➡️ Host (para XHTTP): " new_host

    # Actualiza el archivo de configuración con los n>
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
        "address": "$new_address",
        "port": $new_port,
        "users": [{
          "id": "$new_id",
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
    echo -e "${GREEN}✅ Configuración actualizada con>
}

menu() {
  banner
  echo -e "\n${BLUE}1️⃣ Iniciar conexión${NC}"
  echo -e "${BLUE}2️⃣ Detener conexión${NC}"
  echo -e "${BLUE}3️⃣ Verificar túnel (curl)${NC}"
  echo -e "${BLUE}4️⃣ Verificar IP con proxychains4${NC>
  echo -e "${BLUE}5️⃣ Cambiar datos del VPS${NC}"
  echo -e "${BLUE}6️⃣ Salir${NC}"
  read -p $'\n👉 Selección: ' opt

  case $opt in
    1) start_xray ;;
    2) stop_xray ;;
    3) verificar_ping ;;
    4) verificar_proxychains ;;
    5) change_config ;; # 🆕 Llamada a la nueva funci>
    6) exit ;;
    *) echo -e "${RED}❌ Opción inválida${NC}" ;;
  esac
}

while true; do
  menu
  read -p $'\n🔁 Presiona Enter para volver al menú..>
done
