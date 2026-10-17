# Num Lock Auto Locker & Toggle (KDE Plasma 6)

**Versão atual: 1.0.4** · [Histórico de alterações](CHANGELOG.md)

Extensão e Applet para o **KDE Plasma 6** (Wayland e X11) que força automaticamente o **Num Lock** a ficar ativo na **tela de bloqueio (*kscreenlocker*)** e na **tela de login (*SDDM*)**, além de fornecer um indicador visual moderno para o painel / bandeja do sistema.

---

## 🚀 Funcionalidades

- 🔒 **Num Lock Automático na Tela de Bloqueio**: Detecta instantaneamente via DBus (`org.freedesktop.ScreenSaver` / `AboutToLock`) quando a tela é bloqueada e garante que o teclado numérico esteja ativado para digitar PINs e senhas.
- 🖥️ **Sincronização com SDDM (Login Inicial)**: Script de configuração do SDDM para que o Num Lock já venha ligado no boot antes do login.
- 📊 **Indicador Visual no Painel**:
  - Exibe o estado em tempo real do **Num Lock** (com badge dinâmico).
  - Suporte opcional para exibir **Caps Lock** e **Scroll Lock**.
- 🎛️ **Painel de Controle Interativo**:
  - Botões para alternar ou forçar estado do Num Lock.
  - Cartão de status das travas de teclado.
  - Acesso direto às preferências e ao assistente de sincronização.
- 🌐 **Idioma da interface**: English (padrão), Português (Portugal), Português (Brasil) e Español. Escolha em **Configurações → General → Language** e clique em **Aplicar**.
- ⚙️ **Serviço de Fundo (systemd --user)**: Mantém o monitoramento mesmo se o widget não for adicionado à barra de tarefas.

---

## 📁 Estrutura do Projeto

```
numlock_toggle/
├── package/                     # Pacote do Applet Plasmoid (Plasma 6)
│   ├── metadata.json            # Metadados e identificação do KPackage
│   └── contents/
│       ├── config/              # Esquema de configuração KConfigXT
│       │   ├── config.qml
│       │   └── main.xml
│       └── ui/                  # Componentes de interface QML
│           ├── CompactRepresentation.qml
│           ├── FullRepresentation.qml
│           ├── Translations.js   # Textos nos quatro idiomas
│           ├── configGeneral.qml
│           └── main.qml
├── scripts/
│   ├── install.sh               # Script de instalação completa
│   ├── uninstall.sh             # Script de desinstalação
│   ├── sync_sddm.sh             # Script de configuração do SDDM (root)
│   ├── numlock_helper.py        # Utilitário CLI e daemon DBus
│   ├── numlock-autolock.service # Serviço de usuário do systemd
│   └── package_release.sh      # Geração dos pacotes de distribuição
└── README.md
```

---

## 🛠️ Instalação

Abra o terminal na pasta do projeto e execute:

```bash
bash scripts/install.sh
```

O instalador irá:
1. Instalar o applet no KDE Plasma 6 (`kpackagetool6`).
2. Configurar e iniciar o serviço de usuário (`systemctl --user enable --now numlock-autolock.service`).
3. Opcionalmente configurar o SDDM (`sync_sddm.sh`).

---

## 🌐 Escolhendo o idioma

A versão 1.0.4 usa **English** como padrão. Para mudar:

1. Abra as configurações do widget pelo botão de engrenagem.
2. Na página **General**, escolha uma opção em **Language**: English,
   Português (Portugal), Português (Brasil) ou Español.
3. Clique em **Aplicar** para salvar a preferência.

A escolha é salva por instância do widget e aplicada ao painel, às dicas, à
página de configurações e às notificações de ativação iniciadas pelo widget.
O serviço em segundo plano é independente: para escolher o idioma das suas
notificações ao executá-lo manualmente, use `--notify --language`.
Os scripts de instalação e sincronização do SDDM continuam em português.

---

## 📌 Adicionando o Widget ao Painel

1. Clique com o botão direito em uma área vazia da barra de tarefas / painel do KDE Plasma.
2. Selecione **"Adicionar widgets..."**.
3. Pesquise por **"Num Lock Auto Locker"**.
4. Arraste-o para o painel ou bandeja do sistema.

---

## ⌨️ Uso pela Linha de Comando (CLI)

O script `numlock_helper.py` pode ser executado diretamente no terminal:

```bash
# Ver status atual em texto
./scripts/numlock_helper.py --status

# Ver status em formato JSON
./scripts/numlock_helper.py --json

# Forçar Num Lock LIGADO
./scripts/numlock_helper.py --enable

# Forçar ativação com notificação em português do Brasil
./scripts/numlock_helper.py --enable --notify --language pt_BR

# Alternar Num Lock
./scripts/numlock_helper.py --toggle

# Executar como daemon DBus em background
./scripts/numlock_helper.py --daemon

# Executar o daemon com notificações em espanhol
./scripts/numlock_helper.py --daemon --notify --language es
```

A opção `--language` aceita `en` (padrão), `pt_PT`, `pt_BR` e `es` e define
somente o idioma das notificações.

---

## 📦 Pacotes da versão 1.0.4

Para gerar os pacotes de distribuição a partir do código-fonte:

```bash
bash scripts/package_release.sh
```

O comando recria a pasta `build/` e gera:

- `build/org.kde.plasma.numlocktoggle-v1.0.4.plasmoid`
- `build/org.kde.plasma.numlocktoggle-v1.0.4.tar.gz`

Para instalar somente o widget a partir do pacote:

```bash
kpackagetool6 -t Plasma/Applet --install build/org.kde.plasma.numlocktoggle-v1.0.4.plasmoid
```

Se o widget já estiver instalado, use `--upgrade` no lugar de `--install`.
Para instalar também o serviço de monitoramento, siga a instalação completa
com `bash scripts/install.sh` descrita acima.

---

## 🗑️ Desinstalação

Para remover completamente a extensão e os serviços:

```bash
bash scripts/uninstall.sh
```

---

## 📄 Licença

GPL-3.0-or-later.
