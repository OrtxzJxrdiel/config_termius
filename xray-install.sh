#!/data/data/com.termux/files/usr/bin/bash

# 📁 Rutas base
BASE=~/xray-tunnel
XRAY=$BASE/xray-xhttp
PROXY=$BASE/proxychains4
BIN=$XRAY/bin
MODULOS=$BASE/modulos
CONF=$XRAY/config.json
LOG=$XRAY/log.txt
PID=$XRAY/xray.pid
MENU=$BASE/xray-tunnel.sh

# 🎨 Colores
GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

# 🔧 Preparar entorno
echo -e "${BLUE}🔧 Preparando entorno Termux...${NC}"
pkg update -y && pkg upgrade -y
pkg install -y curl unzip proot git build-essential toilet ruby python netcat
gem install lolcat

# 📁 Crear estructura
mkdir -p $BIN $PROXY $MODULOS

# ⬇️ Descargar Xray-core
cd $BIN
if [ ! -f "$BIN/xray" ]; then
  echo -e "${YELLOW}⬇️ Descargando Xray-core...${NC}"
  curl -L -o xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-android-arm64-v8a.zip
  unzip xray.zip
  chmod +x xray
  echo -e "${GREEN}✅ Xray-core listo${NC}"
fi

# ⚙️ Configuración cliente XHTTP
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
        "address": "138.197.31.155",
        "port": 80,
        "users": [{
          "id": "cf688aa4-c453-48e6-bb22-4b258ce494b6",
          "encryption": "none"
        }]
      }]
    },
    "streamSettings": {
      "network": "xhttp",
      "xhttpSettings": {
        "path": "/",
        "xhttpMode": "auto",
        "host": "filter-ni.portal-universal.com"
      }
    }
  }]
}
EOF

# 🔗 Instalar proxychains4
cd $PROXY
if [ ! -f "$PROXY/proxychains4" ]; then
  echo -e "${YELLOW}🔗 Instalando proxychains4...${NC}"
  git clone https://github.com/rofl0r/proxychains-ng.git src
  cd src
  ./configure --prefix=$PROXY
  make && make install

  mkdir -p $PROXY/etc
  cat > $PROXY/etc/proxychains.conf <<EOF
strict_chain
proxy_dns
remote_dns_subnet 224
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
socks5 127.0.0.1 10808
EOF
  echo -e "${GREEN}✅ proxychains4 listo${NC}"
fi

# 🛡️ Crear módulo de modo ultra estable
cat > $MODULOS/modo-ultra-estable.sh <<'EOF'
#!/data/data/com.termux/files/usr/bin/bash

PID_FILE=~/xray-tunnel/xray-xhttp/keepalive.pid
PROXY=~/xray-tunnel/proxychains4
CONF=$PROXY/etc/proxychains.conf

activar_modo_ultra_estable() {
  echo -e "\033[1;32m🛡️ Activando modo ultra estable con proxychains4...\033[0m"
  if command -v termux-vibrate >/dev/null 2>&1; then
    termux-vibrate -d 100
  fi

  while true; do
    $PROXY/bin/proxychains4 -f $CONF curl -s --max-time 5 https://api.ipify.org > /dev/null
    sleep 10
  done &
  echo $! > "$PID_FILE"
}

desactivar_modo_ultra_estable() {
  if [ -f "$PID_FILE" ]; then
    kill $(cat "$PID_FILE") 2>/dev/null
    rm "$PID_FILE"
    echo -e "\033[1;31m🛑 Modo ultra estable desactivado\033[0m"
    if command -v termux-vibrate >/dev/null 2>&1; then
      termux-vibrate -d 50
    fi
  fi
}
EOF

chmod +x $MODULOS/modo-ultra-estable.sh

# 📋 Crear menú interactivo
cat > $MENU <<'EOM'
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
  echo "║ 📡 Proxy: 127.0.0.1:10808"
  echo "╚════════════════════════════════════╝"
  echo -e "${NC}"
}

start_xray() {
  banner
  echo -e "${BLUE}🚀 Iniciando conexión Xray...${NC}"
  nohup $BIN/xray run -config $CONF > $LOG 2>&1 &
  echo $! > $PID
  echo -e "${GREEN}✅ Xray corriendo con PID $(cat $PID)${NC}"

  echo -e "${YELLOW}⏳ Esperando a que el proxy esté disponible...${NC}"
  for i in {1..10}; do
    nc -z 127.0.0.1 10808 && break
    sleep 1
  done

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

  desactivar_modo_ultra_estable
}

verificar_ping() {
  banner
  echo -e "${BLUE}🔍 Verificando túnel con curl...${NC}"
  curl --socks5 127.0.0.1:10808 https://api.ipify.org -m 5 && echo -e "${GREEN}✅ Túnel activo${NC}" || echo -e "${RED}❌ Fallo en la conexión${NC}"
}

verificar_proxychains() {
  banner
  echo -e "${BLUE}🔗 Verificando IP con proxychains4...${NC}"
  $PROXY/bin/proxychains4 -f $PROXY/etc/proxychains.conf curl -s https://api.ipify.org && echo -e "${GREEN}✅ IP obtenida con proxychains4${NC}" || echo -e "${RED}❌ Fallo en proxychains4${NC}"
}

# 🆕 Función para cambiar la configuración
change_config() {
    banner
    echo -e "${YELLOW}✏️ Ingresa los nuevos datos del VPS${NC}"
    read -p "   ➡️ Dirección (IP o Dominio): " new_address
    read -p "   ➡️ Puerto: " new_port
    read -p "   ➡️ UUID (ID): " new_id
    read -p "   ➡️ Host (para XHTTP): " new_host

    # Actualiza el archivo de configuración con los nuevos valores
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
    echo -e "${GREEN}✅ Configuración actualizada con éxito.${NC}"
}

actualizar_script() {
  echo -e "${YELLOW}🔄 Actualizando menú desde GitHub...${NC}"
  curl -s -o ~/xray-tunnel/xray-tunnel.sh \
    https://raw.githubusercontent.com/OrtxzJxrdiel/config_termius/refs/heads/main/xray-tunnel/xray-tunnel.sh
  chmod +x ~/xray-tunnel/xray-tunnel.sh
  echo -e "${GREEN}✅ Menú actualizado correctamente.${NC}"
}

menu() {
  banner
  echo -e "\n${BLUE}1️⃣ Iniciar conexión${NC}"
  echo -e "${BLUE}2️⃣ Detener conexión${NC}"
  echo -e "${BLUE}3️⃣ Verificar túnel (curl)${NC}"
  echo -e "${BLUE}4️⃣ Verificar IP con proxychains4${NC}"
  echo -e "${BLUE}5️⃣ Cambiar datos del VPS${NC}"
  echo -e "${BLUE}6️⃣ Salir${NC}"
  echo -e "${BLUE}7️⃣ Actualizar script${NC}"
  read -p $'\n👉 Selección: ' opt

  case $opt in
    1) start_xray ;;
    2) stop_xray ;;
    3) verificar_ping ;;
    4) verificar_proxychains ;;
    5) change_config ;;
    6) exit ;;
    7) actualizar_script ;;
    *) echo -e "${RED}❌ Opción inválida${NC}" ;;
  esac
}

while true; do
  menu
  read -p $'\n🔁 Presiona Enter para volver al menú...'
done
EOM

chmod +x $MENU

# 🎉 Final
echo -e "\n${GREEN}✅ Instalación completa. Creando acceso directo...${NC}"
ln -sf $MENU $PREFIX/bin/menu
echo -e "${GREEN}✅ ¡Listo! Ahora solo escribe 'menu' para iniciar el script.${NC}"
