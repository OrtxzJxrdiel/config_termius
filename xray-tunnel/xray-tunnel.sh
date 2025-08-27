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
  echo -e "${RED}[0]${NC}  = ${RED}Salir${NC}"
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
