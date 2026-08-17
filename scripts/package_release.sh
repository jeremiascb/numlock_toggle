#!/bin/bash
# ==============================================================================
# Script: package_release.sh
# Descrição: Gera os pacotes .plasmoid e .tar.gz prontos para publicação na KDE Store
# ==============================================================================

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGE_DIR="$ROOT_DIR/package"
BUILD_DIR="$ROOT_DIR/build"
VERSION="1.0.0"
PLUGIN_ID="org.kde.plasma.numlocktoggle"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}=== Empacotador para KDE Store: Num Lock Auto Locker ===${NC}\n"

# 1. Sincronizar scripts dentro de package/contents/scripts
mkdir -p "$PACKAGE_DIR/contents/scripts"
cp -f "$ROOT_DIR/scripts/numlock_helper.py" "$PACKAGE_DIR/contents/scripts/"
cp -f "$ROOT_DIR/scripts/sync_sddm.sh" "$PACKAGE_DIR/contents/scripts/"
cp -f "$ROOT_DIR/scripts/numlock-autolock.service" "$PACKAGE_DIR/contents/scripts/"
cp -f "$ROOT_DIR/scripts/install.sh" "$PACKAGE_DIR/contents/scripts/"
cp -f "$ROOT_DIR/scripts/uninstall.sh" "$PACKAGE_DIR/contents/scripts/"
chmod +x "$PACKAGE_DIR/contents/scripts/"*.sh "$PACKAGE_DIR/contents/scripts/"*.py 2>/dev/null || true

# 2. Criar diretório de build
rm -rf "$BUILD_DIR"
mkdir -p "$BUILD_DIR"

PLASMOID_FILE="$BUILD_DIR/${PLUGIN_ID}-v${VERSION}.plasmoid"
TARGZ_FILE="$BUILD_DIR/${PLUGIN_ID}-v${VERSION}.tar.gz"

# 3. Gerar arquivo .plasmoid (formato zip oficial do Plasma 6)
echo -e "${BLUE}[*] Gerando pacote .plasmoid...${NC}"
cd "$PACKAGE_DIR"
zip -r -9 "$PLASMOID_FILE" . -x "*.git*" "*~" "*.DS_Store"

# 4. Gerar arquivo .tar.gz (com o diretório raiz org.kde.plasma.numlocktoggle)
echo -e "${BLUE}[*] Gerando pacote .tar.gz...${NC}"
TMP_DIR=$(mktemp -d)
cp -r "$PACKAGE_DIR" "$TMP_DIR/$PLUGIN_ID"
cd "$TMP_DIR"
tar -czf "$TARGZ_FILE" "$PLUGIN_ID"
rm -rf "$TMP_DIR"

echo -e "\n${BOLD}${GREEN}======================================================${NC}"
echo -e "${BOLD}${GREEN}  PACOTES GERADOS COM SUCESSO!                        ${NC}"
echo -e "${BOLD}${GREEN}======================================================${NC}"
echo -e " 📦 ${BOLD}${PLASMOID_FILE}${NC} ($(du -h "$PLASMOID_FILE" | cut -f1))"
echo -e " 📦 ${BOLD}${TARGZ_FILE}${NC} ($(du -h "$TARGZ_FILE" | cut -f1))\n"
