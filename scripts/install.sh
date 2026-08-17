#!/bin/bash
# ==============================================================================
# Script de Instalação: Num Lock Auto Locker para KDE Plasma 6
# ==============================================================================

set -e

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
echo -e "${BOLD}${BLUE}  Instalador: Num Lock Auto Locker (KDE Plasma 6)   ${NC}"
echo -e "${BOLD}${BLUE}====================================================${NC}\n"

# 1. Garantir permissões de execução dos scripts
echo -e "${BLUE}[1/4] Ajustando permissões dos scripts...${NC}"
chmod +x "$SCRIPT_DIR/numlock_helper.py"
chmod +x "$SCRIPT_DIR/sync_sddm.sh"
chmod +x "$SCRIPT_DIR/uninstall.sh" 2>/dev/null || true
echo -e "${GREEN}[✓] Permissões configuradas.${NC}\n"

# 2. Instalar o Plasmoid no KDE Plasma 6
echo -e "${BLUE}[2/4] Instalando Applet Plasmoid via kpackagetool6...${NC}"
if kpackagetool6 -t Plasma/Applet --list | grep -q "org.kde.plasma.numlocktoggle"; then
    echo -e "${YELLOW}[*] Versão anterior encontrada. Atualizando pacote...${NC}"
    kpackagetool6 -t Plasma/Applet --upgrade "$PACKAGE_DIR"
else
    echo -e "${BLUE}[*] Instalando novo pacote...${NC}"
    kpackagetool6 -t Plasma/Applet --install "$PACKAGE_DIR"
fi
echo -e "${GREEN}[✓] Plasmoid instalado com sucesso!${NC}\n"

# 3. Configurar e Ativar o Serviço de Usuário no systemd
echo -e "${BLUE}[3/4] Configurando serviço em segundo plano (systemd user)...${NC}"
SYSTEMD_USER_DIR="$HOME/.config/systemd/user"
mkdir -p "$SYSTEMD_USER_DIR"

SERVICE_FILE="$SYSTEMD_USER_DIR/numlock-autolock.service"
cp "$SCRIPT_DIR/numlock-autolock.service" "$SERVICE_FILE"

systemctl --user daemon-reload
systemctl --user enable --now numlock-autolock.service
echo -e "${GREEN}[✓] Serviço de monitoramento de bloqueio ativado e em execução!${NC}\n"

# 4. Oferecer configuração do SDDM
echo -e "${BLUE}[4/4] Configuração da Tela de Login Inicial (SDDM)...${NC}"
echo -e "${YELLOW}Deseja configurar o Num Lock para ligar automaticamente na tela de login (SDDM)? (Requer sudo)${NC}"
read -p "Aplicar configuração ao SDDM agora? [S/n]: " choice
choice=${choice:-S}

if [[ "$choice" =~ ^[SsYy]$ ]]; then
    sudo bash "$SCRIPT_DIR/sync_sddm.sh"
else
    echo -e "${YELLOW}[*] Você pode rodar 'sudo bash scripts/sync_sddm.sh' a qualquer momento mais tarde.${NC}"
fi

echo -e "\n${BOLD}${GREEN}====================================================${NC}"
echo -e "${BOLD}${GREEN}  INSTALAÇÃO CONCLUÍDA COM SUCESSO!                 ${NC}"
echo -e "${BOLD}${GREEN}====================================================${NC}"
echo -e "\n${BOLD}Como usar o widget:${NC}"
echo -e " 1. Clique com o botão direito na barra de tarefas (painel) do KDE."
echo -e " 2. Selecione ${BOLD}'Adicionar widgets...'${NC}."
echo -e " 3. Procure por ${BOLD}'Num Lock Auto Locker'${NC} e arraste para a barra."
echo -e " 4. O monitor em segundo plano já está ativo via systemd e forçará o Num Lock sempre ao bloquear a tela!\n"
