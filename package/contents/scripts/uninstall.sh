#!/bin/bash
# ==============================================================================
# Script de Desinstalação: Num Lock Auto Locker para KDE Plasma 6
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${RED}====================================================${NC}"
echo -e "${BOLD}${RED}  Desinstalador: Num Lock Auto Locker               ${NC}"
echo -e "${BOLD}${RED}====================================================${NC}\n"

# 1. Parar e desabilitar o serviço systemd de usuário
echo -e "${BLUE}[*] Parando e removendo serviço de usuário...${NC}"
systemctl --user stop numlock-autolock.service 2>/dev/null || true
systemctl --user disable numlock-autolock.service 2>/dev/null || true
rm -f "$HOME/.config/systemd/user/numlock-autolock.service"
systemctl --user daemon-reload
echo -e "${GREEN}[✓] Serviço systemd removido.${NC}\n"

# 2. Desinstalar o Plasmoid
echo -e "${BLUE}[*] Removendo Applet do Plasma 6...${NC}"
if kpackagetool6 -t Plasma/Applet --list | grep -q "org.kde.plasma.numlocktoggle"; then
    kpackagetool6 -t Plasma/Applet --remove "org.kde.plasma.numlocktoggle"
    echo -e "${GREEN}[✓] Plasmoid removido do KDE Plasma.${NC}\n"
else
    echo -e "${YELLOW}[*] Plasmoid não estava instalado.${NC}\n"
fi

# 3. Remover arquivos do SDDM se existirem
if [ -f "/etc/sddm.conf.d/numlock.conf" ]; then
    read -p "Deseja remover as configurações do SDDM (/etc/sddm.conf.d/numlock.conf)? (Requer sudo) [s/N]: " rem_sddm
    if [[ "$rem_sddm" =~ ^[SsYy]$ ]]; then
        sudo rm -f "/etc/sddm.conf.d/numlock.conf" "/etc/udev/rules.d/99-numlock.rules"
        sudo udevadm control --reload-rules 2>/dev/null || true
        echo -e "${GREEN}[✓] Configurações do SDDM removidas.${NC}\n"
    fi
fi

echo -e "${BOLD}${GREEN}Desinstalação concluída com sucesso.${NC}\n"
