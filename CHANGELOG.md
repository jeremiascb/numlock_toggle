# Changelog

Todas as mudanças notáveis neste projeto serão documentadas aqui.

Formato baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
com versionamento seguindo [Semantic Versioning](https://semver.org/lang/pt-BR/).

---

## [1.0.2] - 2026-08-20

### Corrigido
- **NumLock revertia para "Manter inalterado" após reinicialização**: a função
  `sync_kcminputrc_numlock` usava `configparser.write()` do Python, que gerava
  o arquivo `~/.config/kcminputrc` com a chave `NumLock = 0` (maiúscula e com
  espaços ao redor do `=`). O KDE Plasma não reconhece esse formato e ignorava
  a configuração, revertendo para o padrão "Manter inalterado" a cada boot.
- **Formato da chave corrigido**: a chave agora é escrita como `numlock=1`
  (minúscula, sem espaços), exatamente como o KDE espera.
- **Valores corrigidos**: os valores estavam invertidos na lógica interna do
  script (`0=ligar / 1=desligar`). Agora seguem a convenção correta do KDE
  Plasma (`0=desligar / 1=ligar / 2=manter inalterado`).
- **Preservação do arquivo**: a reescrita agora é feita linha a linha,
  preservando o formato e as demais seções do `kcminputrc` (ex.: configurações
  de touchpad, libinput), sem reprocessar o arquivo inteiro via configparser.

### Alterado
- `scripts/numlock_helper.py`: função `sync_kcminputrc_numlock` reescrita
- `scripts/package_release.sh`: versão atualizada para `1.0.2`
- `package/metadata.json`: versão atualizada para `1.0.2`

---

## [1.0.1] - 2026-08-17

### Corrigido
- Correção da ativação idempotente do Num Lock: quando o NumLock já estava
  ativo antes do bloqueio de tela, o daemon injetava um segundo evento de
  tecla desnecessariamente, o que acabava **desligando** o NumLock ao invés
  de mantê-lo ligado.
- A leitura do estado do hardware (`get_led_state`) agora ocorre **antes** da
  chamada a `sync_kcminputrc_numlock`, evitando a leitura de um estado
  desatualizado após a reconfiguração assíncrona do KWin.

### Alterado
- Função `enable_numlock`: injeção de tecla só ocorre se o NumLock estiver
  realmente desligado no momento do bloqueio.

---

## [1.0.0] - 2026-08-17

### Adicionado
- Publicação inicial do **Num Lock Auto Locker** para KDE Plasma 6.
- Widget de bandeja do sistema mostrando o estado do Num Lock, Caps Lock e
  Scroll Lock em tempo real via leitura de `/sys/class/leds/`.
- Daemon (`--daemon`) que monitora eventos de bloqueio de tela via DBus
  (`org.freedesktop.ScreenSaver` e `org.kde.screensaver`) e força o NumLock
  ativo automaticamente ao bloquear.
- Injeção de eventos de teclado via `/dev/uinput` (com fallbacks para
  `ydotool`, `wtype` e `numlockx` em X11).
- Notificação de área de trabalho opcional ao ativar o NumLock
  automaticamente (`--notify`).
- Scripts de instalação (`install.sh`) e desinstalação (`uninstall.sh`).
- Serviço systemd de usuário (`numlock-autolock.service`) ativado
  automaticamente com a sessão gráfica.
- Script de sincronização do SDDM (`sync_sddm.sh`) para manter o NumLock
  ativo também na tela de login.
- Suporte a Wayland e X11.
- Pacotes de distribuição: `.plasmoid` (KDE Store) e `.tar.gz`.
