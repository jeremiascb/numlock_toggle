#!/bin/bash
# ==============================================================================
# Script de Instalação: Num Lock Auto Locker para KDE Plasma 6
# ==============================================================================

set -e

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/numlock_i18n.sh"
numlock_init_language "$@"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
PACKAGE_DIR="$ROOT_DIR/package"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}====================================================${NC}"
echo -e "${BOLD}${BLUE}$(numlock_message install_title)${NC}"
echo -e "${BOLD}${BLUE}====================================================${NC}\n"

# 1. Garantir permissões de execução dos scripts
echo -e "${BLUE}$(numlock_message permissions_setup)${NC}"
chmod +x "$SCRIPT_DIR/numlock_helper.py"
chmod +x "$SCRIPT_DIR/sync_sddm.sh"
chmod +x "$SCRIPT_DIR/uninstall.sh" 2>/dev/null || true
echo -e "${GREEN}$(numlock_message permissions_done)${NC}\n"

# 2. Instalar o Plasmoid no KDE Plasma 6
echo -e "${BLUE}$(numlock_message applet_install)${NC}"
if kpackagetool6 -t Plasma/Applet --list | grep -q "org.kde.plasma.numlocktoggle"; then
    echo -e "${YELLOW}$(numlock_message applet_upgrade)${NC}"
    kpackagetool6 -t Plasma/Applet --upgrade "$PACKAGE_DIR"
else
    echo -e "${BLUE}$(numlock_message package_install)${NC}"
    kpackagetool6 -t Plasma/Applet --install "$PACKAGE_DIR"
fi
echo -e "${GREEN}$(numlock_message applet_installed)${NC}\n"

# 3. Configurar e Ativar o Serviço de Usuário no systemd
echo -e "${BLUE}$(numlock_message service_setup)${NC}"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"

SERVICE_FILE="$SYSTEMD_USER_DIR/numlock-autolock.service"
cp "$SCRIPT_DIR/numlock-autolock.service" "$SERVICE_FILE"

systemctl --user daemon-reload
systemctl --user enable --now numlock-autolock.service
echo -e "${GREEN}$(numlock_message service_running)${NC}\n"

# 4. Oferecer configuração do SDDM
echo -e "${BLUE}$(numlock_message login_setup)${NC}"
echo -e "${YELLOW}$(numlock_message login_question)${NC}"
read -p "$(numlock_message login_prompt)" choice
choice=${choice:-S}

if [[ "$choice" =~ ^[SsYy]$ ]]; then
    sudo bash "$SCRIPT_DIR/sync_sddm.sh" --language "$NUMLOCK_LANGUAGE"
else
    echo -e "${YELLOW}$(numlock_message login_later)${NC}"
fi

echo -e "\n${BOLD}${GREEN}====================================================${NC}"
echo -e "${BOLD}${GREEN}$(numlock_message install_done)${NC}"
echo -e "${BOLD}${GREEN}====================================================${NC}"
echo -e "\n${BOLD}$(numlock_message widget_usage)${NC}"
echo -e "$(numlock_message widget_step_one)"
echo -e "$(numlock_message widget_step_two)${BOLD}$(numlock_message add_widgets)${NC}."
echo -e "$(numlock_message widget_step_three)${BOLD}'Num Lock Auto Locker'${NC}$(numlock_message widget_drag)"
echo -e "$(numlock_message widget_step_four)\n"
