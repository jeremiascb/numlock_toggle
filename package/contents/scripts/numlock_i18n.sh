#!/bin/bash
# Shared translations for user-facing shell scripts. Safe to source without side effects.
numlock_init_language() {
    NUMLOCK_LANGUAGE=${NUMLOCK_LANGUAGE:-en}
    while [ "$#" -gt 0 ]; do
        case "$1" in
            --language)
                if [ "$#" -lt 2 ]; then
                    printf '%s\n' 'Missing value for --language (en, pt_PT, pt_BR, es).' >&2
                    exit 2
                fi
                NUMLOCK_LANGUAGE=$2
                shift 2
                ;;
            --language=*) NUMLOCK_LANGUAGE=${1#*=}; shift ;;
            --help|-h)
                printf 'Usage: bash %s [--language en|pt_PT|pt_BR|es]\n' "${0##*/}"
                exit 0
                ;;
            *) printf 'Unknown argument: %s\n' "$1" >&2; exit 2 ;;
        esac
    done
    case "$NUMLOCK_LANGUAGE" in
        en|pt_PT|pt_BR|es) ;;
        *) printf 'Unsupported language: %s\n' "$NUMLOCK_LANGUAGE" >&2; exit 2 ;;
    esac
    export NUMLOCK_LANGUAGE
}

numlock_message() {
    local message
    case "${NUMLOCK_LANGUAGE:-en}:$1" in
        en:sddm_title) message='=== Configuring Num Lock for SDDM and system permissions ===' ;;
        pt_PT:sddm_title) message='=== A configurar o Num Lock para o SDDM e permissões do sistema ===' ;;
        pt_BR:sddm_title) message='=== Configurando Num Lock para SDDM e Permissões do Sistema ===' ;;
        es:sddm_title) message='=== Configurando Num Lock para SDDM y permisos del sistema ===' ;;
        en:admin_required) message='[!] This script requires administrator privileges (sudo).' ;;
        pt_PT:admin_required) message='[!] Este script requer permissões de administrador (sudo).' ;;
        pt_BR:admin_required) message='[!] Este script precisa de permissões de administrador (sudo).' ;;
        es:admin_required) message='[!] Este script requiere permisos de administrador (sudo).' ;;
        en:sudo_retry) message='Running again with sudo...' ;;
        pt_PT:sudo_retry) message='A executar novamente com sudo...' ;;
        pt_BR:sudo_retry) message='Executando novamente com sudo...' ;;
        es:sudo_retry) message='Ejecutando de nuevo con sudo...' ;;
        en:sddm_create) message='[1/4] Creating SDDM configuration: ' ;;
        pt_PT:sddm_create) message='[1/4] A criar a configuração do SDDM: ' ;;
        pt_BR:sddm_create) message='[1/4] Criando configuração do SDDM: ' ;;
        es:sddm_create) message='[1/4] Creando la configuración de SDDM: ' ;;
        en:file_prefix) message='[✓] File ' ;;
        pt_PT:file_prefix) message='[✓] Ficheiro ' ;;
        pt_BR:file_prefix) message='[✓] Arquivo ' ;;
        es:file_prefix) message='[✓] Archivo ' ;;
        en:file_configured) message=' configured successfully!' ;;
        pt_PT:file_configured) message=' configurado com sucesso!' ;;
        pt_BR:file_configured) message=' configurado com sucesso!' ;;
        es:file_configured) message=' configurado correctamente!' ;;
        en:sddm_profile_update) message='[2/4] Updating the SDDM user profile...' ;;
        pt_PT:sddm_profile_update) message='[2/4] A atualizar o perfil do utilizador SDDM...' ;;
        pt_BR:sddm_profile_update) message='[2/4] Atualizando perfil do usuário SDDM...' ;;
        es:sddm_profile_update) message='[2/4] Actualizando el perfil del usuario SDDM...' ;;
        en:sddm_profile_done) message='[✓] SDDM profile updated.' ;;
        pt_PT:sddm_profile_done) message='[✓] Perfil do SDDM atualizado.' ;;
        pt_BR:sddm_profile_done) message='[✓] Perfil do SDDM atualizado.' ;;
        es:sddm_profile_done) message='[✓] Perfil de SDDM actualizado.' ;;
        en:uinput_setup) message='[3/4] Configuring the udev rule for virtual key injection (/dev/uinput)...' ;;
        pt_PT:uinput_setup) message='[3/4] A configurar a regra udev para injeção de teclas virtuais (/dev/uinput)...' ;;
        pt_BR:uinput_setup) message='[3/4] Configurando regra udev para injeção de teclas virtuais (/dev/uinput)...' ;;
        es:uinput_setup) message='[3/4] Configurando la regla udev para inyección de teclas virtuales (/dev/uinput)...' ;;
        en:rule_prefix) message='[✓] Rule ' ;;
        pt_PT:rule_prefix) message='[✓] Regra ' ;;
        pt_BR:rule_prefix) message='[✓] Regra ' ;;
        es:rule_prefix) message='[✓] Regla ' ;;
        en:rule_configured) message=' configured.' ;;
        pt_PT:rule_configured) message=' configurada.' ;;
        pt_BR:rule_configured) message=' configurada.' ;;
        es:rule_configured) message=' configurada.' ;;
        en:leds_setup) message='[4/4] Configuring the udev rule for keyboard LEDs...' ;;
        pt_PT:leds_setup) message='[4/4] A configurar a regra udev para os LEDs do teclado...' ;;
        pt_BR:leds_setup) message='[4/4] Configurando regra udev para leds de teclado...' ;;
        es:leds_setup) message='[4/4] Configurando la regla udev para los LED del teclado...' ;;
        en:system_done) message='✓ System configured successfully!                    ' ;;
        pt_PT:system_done) message='✓ Sistema configurado com sucesso!                    ' ;;
        pt_BR:system_done) message='✓ Sistema configurado com sucesso!                    ' ;;
        es:system_done) message='✓ Sistema configurado correctamente!                  ' ;;
        en:sddm_enabled) message='  - Num Lock in SDDM: ENABLED                         ' ;;
        pt_PT:sddm_enabled) message='  - Num Lock no SDDM: ATIVADO                         ' ;;
        pt_BR:sddm_enabled) message='  - Num Lock no SDDM: ATIVADO                         ' ;;
        es:sddm_enabled) message='  - Num Lock en SDDM: ACTIVADO                        ' ;;
        en:uinput_enabled) message='  - Software control (/dev/uinput): ENABLED           ' ;;
        pt_PT:uinput_enabled) message='  - Controlo por software (/dev/uinput): ATIVADO       ' ;;
        pt_BR:uinput_enabled) message='  - Controle por software (/dev/uinput): HABILITADO   ' ;;
        es:uinput_enabled) message='  - Control por software (/dev/uinput): ACTIVADO       ' ;;
        en:install_title) message='  Installer: Num Lock Auto Locker (KDE Plasma 6)    ' ;;
        pt_PT:install_title) message='  Instalador: Num Lock Auto Locker (KDE Plasma 6)   ' ;;
        pt_BR:install_title) message='  Instalador: Num Lock Auto Locker (KDE Plasma 6)   ' ;;
        es:install_title) message='  Instalador: Num Lock Auto Locker (KDE Plasma 6)   ' ;;
        en:permissions_setup) message='[1/4] Setting script permissions...' ;;
        pt_PT:permissions_setup) message='[1/4] A ajustar as permissões dos scripts...' ;;
        pt_BR:permissions_setup) message='[1/4] Ajustando permissões dos scripts...' ;;
        es:permissions_setup) message='[1/4] Ajustando los permisos de los scripts...' ;;
        en:permissions_done) message='[✓] Permissions configured.' ;;
        pt_PT:permissions_done) message='[✓] Permissões configuradas.' ;;
        pt_BR:permissions_done) message='[✓] Permissões configuradas.' ;;
        es:permissions_done) message='[✓] Permisos configurados.' ;;
        en:applet_install) message='[2/4] Installing the Plasmoid applet with kpackagetool6...' ;;
        pt_PT:applet_install) message='[2/4] A instalar o applet Plasmoid através do kpackagetool6...' ;;
        pt_BR:applet_install) message='[2/4] Instalando Applet Plasmoid via kpackagetool6...' ;;
        es:applet_install) message='[2/4] Instalando el applet Plasmoid con kpackagetool6...' ;;
        en:applet_upgrade) message='[*] Previous version found. Updating package...' ;;
        pt_PT:applet_upgrade) message='[*] Versão anterior encontrada. A atualizar o pacote...' ;;
        pt_BR:applet_upgrade) message='[*] Versão anterior encontrada. Atualizando pacote...' ;;
        es:applet_upgrade) message='[*] Versión anterior encontrada. Actualizando el paquete...' ;;
        en:package_install) message='[*] Installing new package...' ;;
        pt_PT:package_install) message='[*] A instalar o novo pacote...' ;;
        pt_BR:package_install) message='[*] Instalando novo pacote...' ;;
        es:package_install) message='[*] Instalando un paquete nuevo...' ;;
        en:applet_installed) message='[✓] Plasmoid installed successfully!' ;;
        pt_PT:applet_installed) message='[✓] Plasmoid instalado com sucesso!' ;;
        pt_BR:applet_installed) message='[✓] Plasmoid instalado com sucesso!' ;;
        es:applet_installed) message='[✓] Plasmoid instalado correctamente!' ;;
        en:service_setup) message='[3/4] Configuring the background service (systemd user)...' ;;
        pt_PT:service_setup) message='[3/4] A configurar o serviço em segundo plano (systemd user)...' ;;
        pt_BR:service_setup) message='[3/4] Configurando serviço em segundo plano (systemd user)...' ;;
        es:service_setup) message='[3/4] Configurando el servicio en segundo plano (systemd user)...' ;;
        en:service_running) message='[✓] Lock monitoring service enabled and running!' ;;
        pt_PT:service_running) message='[✓] Serviço de monitorização do bloqueio ativado e em execução!' ;;
        pt_BR:service_running) message='[✓] Serviço de monitoramento de bloqueio ativado e em execução!' ;;
        es:service_running) message='[✓] Servicio de supervisión del bloqueo activado y en ejecución!' ;;
        en:login_setup) message='[4/4] Configuring the login screen (SDDM)...' ;;
        pt_PT:login_setup) message='[4/4] Configuração do ecrã de início de sessão (SDDM)...' ;;
        pt_BR:login_setup) message='[4/4] Configuração da Tela de Login Inicial (SDDM)...' ;;
        es:login_setup) message='[4/4] Configurando la pantalla de inicio de sesión (SDDM)...' ;;
        en:login_question) message='Enable Num Lock automatically on the login screen (SDDM)? (Requires sudo)' ;;
        pt_PT:login_question) message='Deseja ativar automaticamente o Num Lock no ecrã de início de sessão (SDDM)? (Requer sudo)' ;;
        pt_BR:login_question) message='Deseja configurar o Num Lock para ligar automaticamente na tela de login (SDDM)? (Requer sudo)' ;;
        es:login_question) message='¿Desea activar Num Lock automáticamente en la pantalla de inicio de sesión (SDDM)? (Requiere sudo)' ;;
        en:login_prompt) message='Apply SDDM configuration now? [Y/n]: ' ;;
        pt_PT:login_prompt) message='Aplicar a configuração ao SDDM agora? [S/n]: ' ;;
        pt_BR:login_prompt) message='Aplicar configuração ao SDDM agora? [S/n]: ' ;;
        es:login_prompt) message='¿Aplicar la configuración de SDDM ahora? [S/n]: ' ;;
        en:login_later) message='[*] You can run '"'"'sudo bash scripts/sync_sddm.sh'"'"' later.' ;;
        pt_PT:login_later) message='[*] Pode executar '"'"'sudo bash scripts/sync_sddm.sh'"'"' mais tarde.' ;;
        pt_BR:login_later) message='[*] Você pode rodar '"'"'sudo bash scripts/sync_sddm.sh'"'"' a qualquer momento mais tarde.' ;;
        es:login_later) message='[*] Puede ejecutar '"'"'sudo bash scripts/sync_sddm.sh'"'"' más tarde.' ;;
        en:install_done) message='  INSTALLATION COMPLETED SUCCESSFULLY!              ' ;;
        pt_PT:install_done) message='  INSTALAÇÃO CONCLUÍDA COM SUCESSO!                 ' ;;
        pt_BR:install_done) message='  INSTALAÇÃO CONCLUÍDA COM SUCESSO!                 ' ;;
        es:install_done) message='  INSTALACIÓN COMPLETADA CORRECTAMENTE!             ' ;;
        en:widget_usage) message='How to use the widget:' ;;
        pt_PT:widget_usage) message='Como utilizar o widget:' ;;
        pt_BR:widget_usage) message='Como usar o widget:' ;;
        es:widget_usage) message='Cómo usar el widget:' ;;
        en:widget_step_one) message=' 1. Right-click the KDE taskbar (panel).' ;;
        pt_PT:widget_step_one) message=' 1. Clique com o botão direito na barra de tarefas (painel) do KDE.' ;;
        pt_BR:widget_step_one) message=' 1. Clique com o botão direito na barra de tarefas (painel) do KDE.' ;;
        es:widget_step_one) message=' 1. Haga clic derecho en la barra de tareas (panel) de KDE.' ;;
        en:widget_step_two) message=' 2. Select ' ;;
        pt_PT:widget_step_two) message=' 2. Selecione ' ;;
        pt_BR:widget_step_two) message=' 2. Selecione ' ;;
        es:widget_step_two) message=' 2. Seleccione ' ;;
        en:add_widgets) message=''"'"'Add Widgets...'"'"'' ;;
        pt_PT:add_widgets) message=''"'"'Adicionar elementos gráficos...'"'"'' ;;
        pt_BR:add_widgets) message=''"'"'Adicionar widgets...'"'"'' ;;
        es:add_widgets) message=''"'"'Añadir elementos gráficos...'"'"'' ;;
        en:widget_step_three) message=' 3. Search for ' ;;
        pt_PT:widget_step_three) message=' 3. Procure ' ;;
        pt_BR:widget_step_three) message=' 3. Procure por ' ;;
        es:widget_step_three) message=' 3. Busque ' ;;
        en:widget_drag) message=' and drag it to the panel.' ;;
        pt_PT:widget_drag) message=' e arraste para o painel.' ;;
        pt_BR:widget_drag) message=' e arraste para a barra.' ;;
        es:widget_drag) message=' y arrástrelo al panel.' ;;
        en:widget_step_four) message=' 4. The systemd background monitor is active and enables Num Lock when the screen locks!' ;;
        pt_PT:widget_step_four) message=' 4. O monitor em segundo plano está ativo via systemd e ativa o Num Lock ao bloquear o ecrã!' ;;
        pt_BR:widget_step_four) message=' 4. O monitor em segundo plano já está ativo via systemd e forçará o Num Lock sempre ao bloquear a tela!' ;;
        es:widget_step_four) message=' 4. El monitor de systemd está activo y activa Num Lock al bloquear la pantalla!' ;;
        en:uninstall_title) message='  Uninstaller: Num Lock Auto Locker                 ' ;;
        pt_PT:uninstall_title) message='  Desinstalador: Num Lock Auto Locker               ' ;;
        pt_BR:uninstall_title) message='  Desinstalador: Num Lock Auto Locker               ' ;;
        es:uninstall_title) message='  Desinstalador: Num Lock Auto Locker               ' ;;
        en:service_remove) message='[*] Stopping and removing the user service...' ;;
        pt_PT:service_remove) message='[*] A parar e remover o serviço de utilizador...' ;;
        pt_BR:service_remove) message='[*] Parando e removendo serviço de usuário...' ;;
        es:service_remove) message='[*] Deteniendo y eliminando el servicio de usuario...' ;;
        en:service_removed) message='[✓] systemd service removed.' ;;
        pt_PT:service_removed) message='[✓] Serviço systemd removido.' ;;
        pt_BR:service_removed) message='[✓] Serviço systemd removido.' ;;
        es:service_removed) message='[✓] Servicio de systemd eliminado.' ;;
        en:applet_remove) message='[*] Removing the Plasma 6 applet...' ;;
        pt_PT:applet_remove) message='[*] A remover o applet do Plasma 6...' ;;
        pt_BR:applet_remove) message='[*] Removendo Applet do Plasma 6...' ;;
        es:applet_remove) message='[*] Eliminando el applet de Plasma 6...' ;;
        en:applet_removed) message='[✓] Plasmoid removed from KDE Plasma.' ;;
        pt_PT:applet_removed) message='[✓] Plasmoid removido do KDE Plasma.' ;;
        pt_BR:applet_removed) message='[✓] Plasmoid removido do KDE Plasma.' ;;
        es:applet_removed) message='[✓] Plasmoid eliminado de KDE Plasma.' ;;
        en:applet_absent) message='[*] Plasmoid was not installed.' ;;
        pt_PT:applet_absent) message='[*] O Plasmoid não estava instalado.' ;;
        pt_BR:applet_absent) message='[*] Plasmoid não estava instalado.' ;;
        es:applet_absent) message='[*] Plasmoid no estaba instalado.' ;;
        en:sddm_remove_prompt) message='Remove SDDM settings (/etc/sddm.conf.d/numlock.conf)? (Requires sudo) [y/N]: ' ;;
        pt_PT:sddm_remove_prompt) message='Deseja remover as definições do SDDM (/etc/sddm.conf.d/numlock.conf)? (Requer sudo) [s/N]: ' ;;
        pt_BR:sddm_remove_prompt) message='Deseja remover as configurações do SDDM (/etc/sddm.conf.d/numlock.conf)? (Requer sudo) [s/N]: ' ;;
        es:sddm_remove_prompt) message='¿Eliminar la configuración de SDDM (/etc/sddm.conf.d/numlock.conf)? (Requiere sudo) [s/N]: ' ;;
        en:sddm_removed) message='[✓] SDDM settings removed.' ;;
        pt_PT:sddm_removed) message='[✓] Definições do SDDM removidas.' ;;
        pt_BR:sddm_removed) message='[✓] Configurações do SDDM removidas.' ;;
        es:sddm_removed) message='[✓] Configuración de SDDM eliminada.' ;;
        en:uninstall_done) message='Uninstallation completed successfully.' ;;
        pt_PT:uninstall_done) message='Desinstalação concluída com sucesso.' ;;
        pt_BR:uninstall_done) message='Desinstalação concluída com sucesso.' ;;
        es:uninstall_done) message='Desinstalación completada correctamente.' ;;
        *) printf 'Unknown message: %s\n' "$1" >&2; return 2 ;;
    esac
    printf '%s' "$message"
}
