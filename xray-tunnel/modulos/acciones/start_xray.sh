start_xray() {
  banner
  echo -e "${BLUE}🚀 Iniciando conexión Xray...${NC}"
  nohup $BIN/xray run -config $CONF > $LOG 2>&1 &
  echo $! > $PID
  echo -e "${GREEN}✅ Xray corriendo con PID $(cat $PID)${NC}"
}
