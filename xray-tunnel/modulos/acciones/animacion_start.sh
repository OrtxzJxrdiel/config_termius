#!/data/data/com.termux/files/usr/bin/bash

# 🎨 Banner visual
toilet -f pagga "Xray Tunnel" | lolcat
echo -e "\n${YELLOW}🔐 Estableciendo conexión segura...${NC}"
sleep 0.5

# 🔄 Barra progresiva
echo -ne "${BLUE}Progreso: ["
for i in $(seq 1 30); do
  echo -ne "\033[1;31m▇\033[0m"  # Rojo
  sleep 0.05
done
echo -e "] ${GREEN}100%${NC}\n"
sleep 0.3

# 📳 Vibración (solo si termux-api está instalado)
command -v termux-vibrate >/dev/null && termux-vibrate -d 150

# 🎉 Mensaje final
echo -e "\n${GREEN}✅ XRAY activado. Ahora puedes usarlo con flow nica.${NC}"
