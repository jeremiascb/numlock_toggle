#!/bin/bash
# ==============================================================================
# Script de Desinstalação: Num Lock Auto Locker para KDE Plasma 6
# ==============================================================================

set -e

source "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/numlock_i18n.sh"
numlock_init_language "$@"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${RED}====================================================${NC}"
echo -e "${BOLD}${RED}$(numlock_message uninstall_title)${NC}"
echo -e "${BOLD}${RED}====================================================${NC}\n"

# 1. Parar e desabilitar o serviço systemd de usuário
echo -e "${BLUE}$(numlock_message service_remove)${NC}"
systemctl --user stop numlock-autolock.service 2>/dev/null || true
systemctl --user disable numlock-autolock.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/numlock-autolock.service"
systemctl --user daemon-reload
echo -e "${GREEN}$(numlock_message service_removed)${NC}\n"

# 2. Desinstalar o Plasmoid
echo -e "${BLUE}$(numlock_message applet_remove)${NC}"
if kpackagetool6 -t Plasma/Applet --list | grep -q "org.kde.plasma.numlocktoggle"; then
    kpackagetool6 -t Plasma/Applet --remove "org.kde.plasma.numlocktoggle"
    echo -e "${GREEN}$(numlock_message applet_removed)${NC}\n"
else
    echo -e "${YELLOW}$(numlock_message applet_absent)${NC}\n"
fi

# 3. Remover arquivos do SDDM se existirem
if [ -f "/etc/sddm.conf.d/numlock.conf" ]; then
    read -p "$(numlock_message sddm_remove_prompt)" rem_sddm
    if [[ "$rem_sddm" =~ ^[SsYy]$ ]]; then
        sudo rm -f "/etc/sddm.conf.d/numlock.conf" "/etc/udev/rules.d/99-numlock.rules"
        sudo udevadm control --reload-rules 2>/dev/null || true
        echo -e "${GREEN}$(numlock_message sddm_removed)${NC}\n"
    fi
fi

echo -e "${BOLD}${GREEN}$(numlock_message uninstall_done)${NC}\n"
