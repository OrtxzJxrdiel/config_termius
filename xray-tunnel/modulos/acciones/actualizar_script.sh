#!/data/data/com.termux/files/usr/bin/bash

# 🎨 Colores
BLUE='\033[1;34m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
RED='\033[1;31m'
NC='\033[0m'

# 📍 Rutas
BASE=~/xray-tunnel
MENU_DIR=$BASE/modulos/acciones
MENU=$BASE/xray-tunnel.sh
DESTINO=$MENU_DIR/mono.sh
INDEX_FILE=$BASE/modulos/modulos_index.txt

URL_RAW="https://raw.githubusercontent.com/OrtxzJxrdiel/config_termius/refs/heads/main/xray-tunnel/xray-tunnel.sh"

# 🧠 Verificación de nueva versión desde GitHub
REMOTE_HASH=$(curl -s https://api.github.com/repos/OrtxzJxrdiel/config_termius/commits/main | grep sha | head -1 | cut -d '"' -f4)
LOCAL_HASH=$(git rev-parse HEAD 2>/dev/null)

if [ "$REMOTE_HASH" != "$LOCAL_HASH" ]; then
    termux-vibrate -d 150
    echo -e "${BLUE}┌────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│  ⚠️  ¡Nueva versión disponible del script!     │${NC}"
    echo -e "${BLUE}└────────────────────────────────────────────┘${NC}"
    echo -e "${GREEN}¿Deseas actualizar ahora? (s = sí / n = más tarde)${NC}"
    read -r actualizar
    if [ "$actualizar" = "s" ]; then
        echo -e "${GREEN}🔄 Descargando nueva versión...${NC}"
        curl -s -o /tmp/mono_temp.sh "$URL_RAW"

        # ✅ Validación básica del archivo descargado
        if grep -q "#!/bin/bash" /tmp/mono_temp.sh; then
            mv /tmp/mono_temp.sh "$DESTINO"
            echo -e "${GREEN}✅ Mono actualizado correctamente.${NC}"
            echo -e "${GREEN}🔁 Reiniciando menú para aplicar cambios...${NC}"
            exec bash "$MENU_SCRIPT"
        else
            echo -e "${RED}❌ Error: El archivo descargado no es válido.${NC}"
            rm /tmp/mono_temp.sh
        fi
        exit
    else
        echo -e "${BLUE}✔️ Puedes actualizar más tarde desde el menú.${NC}"
    fi
fi

# 📦 Escaneo automático de módulos disponibles
echo -e "${BLUE}┌────────────────────────────────────────────┐${NC}"
echo -e "${BLUE}│        Servicios disponibles detectados     │${NC}"
echo -e "${BLUE}└────────────────────────────────────────────┘${NC}"

# 🧾 Cargar índice anterior
touch "$INDEX_FILE"
mapfile -t anteriores < "$INDEX_FILE"

# 🔍 Detectar nuevos módulos
nuevos=()
for modulo in "$MODULOS_DIR"/*.sh; do
    nombre=$(basename "$modulo")
    echo -e "${GREEN}- $nombre${NC}"
    if ! grep -qx "$nombre" "$INDEX_FILE"; then
        nuevos+=("$nombre")
    fi
done

# 🆕 Mostrar nuevos módulos detectados
if [ "${#nuevos[@]}" -gt 0 ]; then
    termux-vibrate -d 100
    echo -e "${YELLOW}┌────────────────────────────────────────────┐${NC}"
    echo -e "${YELLOW}│ 🆕 Nuevos módulos detectados desde el último uso │${NC}"
    echo -e "${YELLOW}└────────────────────────────────────────────┘${NC}"
    for nuevo in "${nuevos[@]}"; do
        echo -e "${YELLOW}➕ $nuevo${NC}"
    done
fi

# 📝 Actualizar índice
ls "$MODULOS_DIR"/*.sh | xargs -n1 basename > "$INDEX_FILE"
