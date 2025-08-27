verificar_ping() {
  banner
  echo -e "${BLUE}🔍 Verificando túnel con curl...${NC}"
  curl --socks5 127.0.0.1:10808 https://api.ipify.org -m 5 && echo -e "${GREEN}✅ Túnel activo${NC}" || echo -e "${RED}❌ Fallo en la conexión${NC}"
}
