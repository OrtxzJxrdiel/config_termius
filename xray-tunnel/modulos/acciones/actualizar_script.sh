#!/data/data/com.termux/files/usr/bin/bash

ROOT_DIR="$(cd "$(dirname "$0")"/../.. && pwd)"
TMP_DIR="$ROOT_DIR/tmp_update"
REPO_URL="https://github.com/OrtxzJxrdiel/config_termius.git"

echo -e "\n[INFO] [LOW] => Clonando repositorio desde GitHub...\n"

# Limpiar carpeta temporal
rm -rf "$TMP_DIR"

# Clonar repo
git clone --depth=1 "$REPO_URL" "$TMP_DIR" || {
    echo "❌ Error al clonar el repositorio"
    exit 1
}

# Copiar solo archivos nuevos o modificados
echo -e "\n[INFO] [LOW] => Actualizando archivos...\n"
cp -ru "$TMP_DIR/xray-tunnel/"* "$ROOT_DIR/" && \
echo "✅ Archivos actualizados correctamente" || \
echo "⚠️ Error al copiar archivos"

# Limpiar
rm -rf "$TMP_DIR"

# Vibración y banner
echo -e "\n🎉 ¡Menú y módulos actualizados con flow nica! 🎉\n"
