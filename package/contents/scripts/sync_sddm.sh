#!/bin/bash
# ==============================================================================
# Script: sync_sddm.sh
# Descrição: Sincroniza e força a ativação do Num Lock na Tela de Login (SDDM)
#            e configura permissões uinput para alternância via software
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

echo -e "${BOLD}${BLUE}$(numlock_message sddm_title)${NC}\n"

if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}$(numlock_message admin_required)${NC}"
    echo -e "$(numlock_message sudo_retry)\n"
    exec sudo bash "$0" --language "$NUMLOCK_LANGUAGE"
fi

# 1. Configurar /etc/sddm.conf.d/numlock.conf
SDDM_CONF_DIR="/etc/sddm.conf.d"
mkdir -p "$SDDM_CONF_DIR"

SDDM_NUMLOCK_FILE="$SDDM_CONF_DIR/numlock.conf"
echo -e "${BLUE}$(numlock_message sddm_create)${SDDM_NUMLOCK_FILE}${NC}"

cat << 'EOF' > "$SDDM_NUMLOCK_FILE"
# Configuração gerada pelo Num Lock Auto Locker
[General]
Numlock=on
EOF

chmod 644 "$SDDM_NUMLOCK_FILE"
echo -e "${GREEN}$(numlock_message file_prefix)${SDDM_NUMLOCK_FILE}$(numlock_message file_configured)${NC}\n"

# 2. Configurar kcminputrc do usuário sddm
SDDM_VAR_CONFIG="/var/lib/sddm/.config"
if [ -d "/var/lib/sddm" ]; then
    echo -e "${BLUE}$(numlock_message sddm_profile_update)${NC}"
    mkdir -p "$SDDM_VAR_CONFIG"
    cat << 'EOF' > "$SDDM_VAR_CONFIG/kcminputrc"
[Keyboard]
NumLock=0
EOF
    if id "sddm" &>/dev/null; then
        chown -R sddm:sddm "/var/lib/sddm" 2>/dev/null || true
    fi
    echo -e "${GREEN}$(numlock_message sddm_profile_done)${NC}\n"
fi

# 3. Criar regra udev para /dev/uinput (Permite que o usuário do desktop alterne teclas via software)
UINPUT_RULE_FILE="/etc/udev/rules.d/99-uinput.rules"
echo -e "${BLUE}$(numlock_message uinput_setup)${NC}"
cat << 'EOF' > "$UINPUT_RULE_FILE"
# Permite ao usuário ativo da sessão gráfica e aplicativos locais acessar /dev/uinput
KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0666", TAG+="uaccess", GROUP="input"
EOF
chmod 644 "$UINPUT_RULE_FILE"
chmod 666 /dev/uinput 2>/dev/null || true
echo -e "${GREEN}$(numlock_message rule_prefix)${UINPUT_RULE_FILE}$(numlock_message rule_configured)${NC}\n"

# 4. Criar regra udev para LEDs de teclado
LEDS_RULE_FILE="/etc/udev/rules.d/99-numlock-leds.rules"
echo -e "${BLUE}$(numlock_message leds_setup)${NC}"
cat << 'EOF' > "$LEDS_RULE_FILE"
ACTION=="add", SUBSYSTEM=="leds", KERNEL=="*::numlock", ATTR{brightness}="1", GROUP="input", MODE="0664"
EOF
chmod 644 "$LEDS_RULE_FILE"

# Recarregar udev e aplicar
udevadm control --reload-rules 2>/dev/null || true
udevadm trigger 2>/dev/null || true

# Adicionar usuário ao grupo input se existir
if [ -n "$SUDO_USER" ] && id "$SUDO_USER" &>/dev/null; then
    usermod -aG input "$SUDO_USER" 2>/dev/null || true
fi

echo -e "\n${BOLD}${GREEN}======================================================${NC}"
echo -e "${BOLD}${GREEN}$(numlock_message system_done)${NC}"
echo -e "${BOLD}${GREEN}$(numlock_message sddm_enabled)${NC}"
echo -e "${BOLD}${GREEN}$(numlock_message uinput_enabled)${NC}"
echo -e "${BOLD}${GREEN}======================================================${NC}\n"
