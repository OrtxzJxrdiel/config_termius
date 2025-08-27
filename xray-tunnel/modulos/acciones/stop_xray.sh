stop_xray() {
  banner
  if [ -f "$PID" ]; then
    kill -9 $(cat $PID) && rm -f $PID
    echo -e "${RED}🛑 Xray detenido${NC}"
  else
    echo -e "${YELLOW}⚠️ No hay proceso activo${NC}"
  fi
}
