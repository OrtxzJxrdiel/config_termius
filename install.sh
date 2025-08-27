#!/data/data/com.termux/files/usr/bin/bash

# 📁 Rutas base
BASE=~/xray-tunnel
XRAY=$BASE/xray-xhttp
PROXY=$BASE/proxychains4
BIN=$XRAY/bin
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
pkg install -y curl unzip proot git build-essential toilet ruby python
gem install lolcat

# 📁 Crear estructura
echo -e "${BLUE}📁 Creando estructura de archivos...${NC}"
mkdir -p $BIN $PROXY
mkdir -p $BASE/modulos/acciones
echo -e "${GREEN}✅ Estructura de carpetas lista${NC}"

# ⬇️ Descargar Xray-core
cd $BIN
if [ ! -f "$BIN/xray" ]; then
  echo -e "${YELLOW}⬇️ Descargando Xray-core...${NC}"
  curl -L -o xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-android-arm64-v8a.zip
  unzip xray.zip
  chmod +x xray
  rm xray.zip
  echo -e "${GREEN}✅ Xray-core listo${NC}"
fi

# ⚙️ Configuración cliente XHTTP (configuración por defecto)
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
[ProxyList]
socks5 127.0.0.1 10808
EOF
  rm -rf src
  echo -e "${GREEN}✅ proxychains4 listo${NC}"
fi

# 📋 Crear scripts de acción en la carpeta 'modulos/acciones'
echo -e "${BLUE}📝 Creando scripts de acción...${NC}"

# Script de inicio
cat > $BASE/modulos/acciones/start_xray.sh <<'EOM'
#!/data/data/com.termux/files/usr/bin/bash

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
EOM
chmod +x $BASE/modulos/acciones/start_xray.sh

# Script de detención
cat > $BASE/modulos/acciones/stop_xray.sh <<'EOM'
#!/data/data/com.termux/files/usr/bin/bash

PID=~/xray-tunnel/xray-xhttp/xray.pid
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

if [ -f "$PID" ]; then
  echo -e "${YELLOW}⏳ Deteniendo Xray...${NC}"
  kill $(cat $PID)
  rm $PID
  echo -e "${GREEN}✅ Xray se ha detenido con éxito.${NC}"
else
  echo -e "${RED}❌ Xray no está en ejecución.${NC}"
fi
EOM
chmod +x $BASE/modulos/acciones/stop_xray.sh

# Script de detención
cat > $BASE/modulos/acciones/verificar_ping.sh <<'EOM'
#!/data/data/com.termux/files/usr/bin/bash

echo -e "${BLUE}🔍 Verificando túnel con curl...${NC}"
  curl --socks5 127.0.0.1:10808 https://api.ipify.org -m 5 && echo -e "${GREEN}✅ Túnel activo${NC}" || echo -e "${RED}❌ Fallo en la conexión${NC}"
EOM
chmod +x $BASE/modulos/acciones/verificar_ping.sh

# Script para cambiar la configuración
cat > $BASE/modulos/acciones/change_config.sh <<'EOM'
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
EOM
chmod +x $BASE/modulos/acciones/change_config.sh

# Script para verificar proxychains
cat > $BASE/modulos/acciones/verificar_proxychains.sh <<'EOM'
#!/data/data/com.termux/files/usr/bin/bash

BASE=~/xray-tunnel
PROXY=$BASE/proxychains4
GREEN='\033[1;32m'
RED='\033[1;31m'
BLUE='\033[1;34m'
NC='\033[0m'

echo -e "${BLUE}🔗 Verificando IP con proxychains4...${NC}"
$PROXY/bin/proxychains4 -f $PROXY/etc/proxychains.conf curl -s https://api.ipify.org && echo -e "${GREEN}✅ IP obtenida con proxychains4${NC}" || echo -e "${RED}❌ Fallo en proxychains4${NC}"
EOM
chmod +x $BASE/modulos/acciones/verificar_proxychains.sh

# Script para actualizar el menú
cat > $BASE/modulos/acciones/actualizar_script.sh <<'EOM'
#!/data/data/com.termux/files/usr/bin/bash

YELLOW='\033[1;33m'
GREEN='\033[1;32m'
NC='\033[0m'

echo -e "${YELLOW}🔄 Actualizando menú desde GitHub...${NC}"
curl -s -o ~/xray-tunnel/xray-tunnel.sh \
  https://raw.githubusercontent.com/OrtxzJxrdiel/config_termius/refs/heads/main/xray-tunnel/xray-tunnel.sh
chmod +x ~/xray-tunnel/xray-tunnel.sh
echo -e "${GREEN}✅ Menú actualizado correctamente.${NC}"
EOM
chmod +x $BASE/modulos/acciones/actualizar_script.sh

echo -e "${GREEN}✅ Scripts de acción creados${NC}"

# 📋 Crear script de menú principal
echo -e "${BLUE}📝 Creando script de menú principal...${NC}"
cat > $MENU <<'EOM'
#!/data/data/com.termux/files/usr/bin/bash

BASE=~/xray-tunnel
MENU_DIR=$BASE/modulos/acciones

GREEN='\033[1;32m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
NC='\033[0m'

banner() {
  clear
  toilet -f pagga "NANASHI" | lolcat
  echo -e "${GREEN}"
}

menu() {
  banner
  echo -e "   ${YELLOW}Menú Principal${NC}"
  echo "=========================="
  echo -e "${BLUE}[01]${NC} = ${GREEN}Iniciar Conexión${NC}"
  echo -e "${BLUE}[02]${NC} = ${YELLOW}Detener Conexión${NC} ${RED}${NC}"
  echo -e "${BLUE}[03]${NC} = ${GREEN}Verificar Túnel (curl)${NC} ${RED}${NC}"
  echo -e "${BLUE}[04]${NC} = ${GREEN}Verificar IP con Proxychains4${NC} ${YELLOW}${NC}"
  echo -e "${BLUE}[05]${NC} = ${GREEN}Editar Datos del VPS${NC}"
  echo -e "${BLUE}[06]${NC} = ${YELLOW}Actualizar${NC}"
  echo -e "${BLUE}[0]${NC} = ${RED}Salir${NC}"
  echo "=========================="
  read -p "Elige una opción: " opcion
  echo ""

  case $opcion in
    1) $MENU_DIR/start_xray.sh ;;
    2) $MENU_DIR/stop_xray.sh ;;
    3) $MENU_DIR/verificar_ping.sh ;;
    4) $MENU_DIR/verificar_proxychains.sh ;;
    5) $MENU_DIR/change_config.sh ;;
    6) $MENU_DIR/actualizar_script.sh ;;
    0) echo -e "${BLUE}Saliendo...${NC}"; exit 0 ;;
    *) echo -e "${RED}Opción inválida.${NC}";;
  esac
  read -p "Presione [Enter] para continuar..."
  menu
}

menu
EOM
chmod +x $MENU

# 🚀 NUEVO PASO: Crear enlaces simbólicos para ejecutar el menú fácilmente
echo -e "${BLUE}🚀 Creando accesos directos para el menú...${NC}"
ln -s $MENU /data/data/com.termux/files/usr/bin/menu
ln -s $MENU /data/data/com.termux/files/usr/bin/MENU
ln -s $MENU /data/data/com.termux/files/usr/bin/adm
ln -s $MENU /data/data/com.termux/files/usr/bin/xray-menu
echo -e "${GREEN}✅ Accesos directos creados en /usr/bin/${NC}"

echo -e "${GREEN}🎉 ¡Instalación completa!${NC}"
echo ""
echo -e "${YELLOW}Ahora puedes ejecutar el menú desde cualquier lugar con los siguientes comandos:${NC}"
echo -e "   -> menu"
echo -e "   -> MENU"
echo -e "   -> adm"
echo -e "   -> xray-menu"
