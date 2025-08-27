#!/data/data/com.termux/files/usr/bin/bash

echo -e "${YELLOW}🔄 Actualizando menú desde GitHub...${NC}"
curl -s -o ~/xray-tunnel/xray-tunnel.sh \
  https://raw.githubusercontent.com/OrtxzJxrdiel/config_termius/refs/heads/main/xray-tunnel/xray-tunnel.sh
chmod +x ~/xray-tunnel/xray-tunnel.sh
echo -e "${GREEN}✅ Menú actualizado correctamente.${NC}"
