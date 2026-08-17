# Num Lock Auto Locker & Toggle (KDE Plasma 6)

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
│           ├── configGeneral.qml
│           └── main.qml
├── scripts/
│   ├── install.sh               # Script de instalação completa
│   ├── uninstall.sh             # Script de desinstalação
│   ├── sync_sddm.sh             # Script de configuração do SDDM (root)
│   ├── numlock_helper.py        # Utilitário CLI e daemon DBus
│   └── numlock-autolock.service # Serviço de usuário do systemd
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

# Alternar Num Lock
./scripts/numlock_helper.py --toggle

# Executar como daemon DBus em background
./scripts/numlock_helper.py --daemon
```

---

## 🗑️ Desinstalação

Para remover completamente a extensão e os serviços:

```bash
bash scripts/uninstall.sh
```

---

## 📄 Licença

GPL-3.0-or-later.
