verificar_proxychains() {
  banner
  echo -e "${BLUE}🔗 Verificando IP con proxychains4...${NC}"
  $PROXY/bin/proxychains4 -f $PROXY/etc/proxychains.conf curl -s https://api.ipify.org && echo -e "${GREEN}✅ IP obtenida con proxychains4${NC}" || echo -e "${RED}❌ Fallo en proxychains4${NC}"
}
