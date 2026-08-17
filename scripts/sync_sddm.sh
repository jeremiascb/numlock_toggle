#!/bin/bash
# ==============================================================================
# Script: sync_sddm.sh
# Descrição: Sincroniza e força a ativação do Num Lock na Tela de Login (SDDM)
#            e configura permissões uinput para alternância via software
# ==============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
BOLD='\033[1m'
NC='\033[0m'

echo -e "${BOLD}${BLUE}=== Configurando Num Lock para SDDM e Permissões do Sistema ===${NC}\n"

if [ "$EUID" -ne 0 ]; then
    echo -e "${YELLOW}[!] Este script precisa de permissões de administrador (sudo).${NC}"
    echo -e "Executando novamente com sudo...\n"
    exec sudo bash "$0" "$@"
fi

# 1. Configurar /etc/sddm.conf.d/numlock.conf
SDDM_CONF_DIR="/etc/sddm.conf.d"
mkdir -p "$SDDM_CONF_DIR"

SDDM_NUMLOCK_FILE="$SDDM_CONF_DIR/numlock.conf"
echo -e "${BLUE}[1/4] Criando configuração do SDDM: ${SDDM_NUMLOCK_FILE}${NC}"

cat << 'EOF' > "$SDDM_NUMLOCK_FILE"
# Configuração gerada pelo Num Lock Auto Locker
[General]
Numlock=on
EOF

chmod 644 "$SDDM_NUMLOCK_FILE"
echo -e "${GREEN}[✓] Arquivo ${SDDM_NUMLOCK_FILE} configurado com sucesso!${NC}\n"

# 2. Configurar kcminputrc do usuário sddm
SDDM_VAR_CONFIG="/var/lib/sddm/.config"
if [ -d "/var/lib/sddm" ]; then
    echo -e "${BLUE}[2/4] Atualizando perfil do usuário SDDM...${NC}"
    mkdir -p "$SDDM_VAR_CONFIG"
    cat << 'EOF' > "$SDDM_VAR_CONFIG/kcminputrc"
[Keyboard]
NumLock=0
EOF
    if id "sddm" &>/dev/null; then
        chown -R sddm:sddm "/var/lib/sddm" 2>/dev/null || true
    fi
    echo -e "${GREEN}[✓] Perfil do SDDM atualizado.${NC}\n"
fi

# 3. Criar regra udev para /dev/uinput (Permite que o usuário do desktop alterne teclas via software)
UINPUT_RULE_FILE="/etc/udev/rules.d/99-uinput.rules"
echo -e "${BLUE}[3/4] Configurando regra udev para injeção de teclas virtuais (/dev/uinput)...${NC}"
cat << 'EOF' > "$UINPUT_RULE_FILE"
# Permite ao usuário ativo da sessão gráfica e aplicativos locais acessar /dev/uinput
KERNEL=="uinput", SUBSYSTEM=="misc", MODE="0666", TAG+="uaccess", GROUP="input"
EOF
chmod 644 "$UINPUT_RULE_FILE"
chmod 666 /dev/uinput 2>/dev/null || true
echo -e "${GREEN}[✓] Regra ${UINPUT_RULE_FILE} configurada.${NC}\n"

# 4. Criar regra udev para LEDs de teclado
LEDS_RULE_FILE="/etc/udev/rules.d/99-numlock-leds.rules"
echo -e "${BLUE}[4/4] Configurando regra udev para leds de teclado...${NC}"
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
echo -e "${BOLD}${GREEN}✓ Sistema configurado com sucesso!                    ${NC}"
echo -e "${BOLD}${GREEN}  - Num Lock no SDDM: ATIVADO                         ${NC}"
echo -e "${BOLD}${GREEN}  - Controle por software (/dev/uinput): HABILITADO   ${NC}"
echo -e "${BOLD}${GREEN}======================================================${NC}\n"
