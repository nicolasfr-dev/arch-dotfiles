# arch-dotfiles

Configuração pessoal de Arch Linux + Hyprland, tema **Tokyo Night**.

![paleta](https://img.shields.io/badge/tema-Tokyo%20Night-7aa2f7?style=flat-square)

## Hardware alvo

- Notebook Intel Alder Lake-UP3 / Iris Xe
- `eDP-1` 1366x768 · `HDMI-A-1` 1920x1080 (à esquerda)
- Teclado `br` / `abnt2`

## Instalação

```bash
git clone git@github.com:nicolasfr-dev/arch-dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 1. pacotes
./packages.sh

# 2. symlinks + wallpaper + tema GTK  (--dry-run para simular)
./install.sh

# 3. recarregar
hyprctl reload
```

`install.sh` faz backup de qualquer config existente em `~/.config-backup-<timestamp>/` antes de sobrescrever.

## Estrutura

```
colors/tokyonight.md      paleta de referência (fonte única de verdade)
config/hypr/              hyprland.lua, hyprlock, hypridle, hyprpaper
config/waybar/            barra de status
config/foot/              terminal
config/swaync/            notificações + central
config/wofi/              seletor (usado pelo histórico de clipboard)
config/wlogout/           menu de energia
config/qt5ct/ qt6ct/      tema Qt (Fusion + paleta Tokyo Night)
config/gtk-3.0/ gtk-4.0/  tema GTK
home/                     dotfiles da raiz do $HOME
scripts/gen-wallpaper.py  gera o wallpaper (PNG puro, sem dependências)
```

## Atalhos

| Tecla | Ação |
|---|---|
| `SUPER` + `Q` | terminal (foot) |
| `SUPER` + `C` | fechar janela |
| `SUPER` + `Space` / `R` | launcher (vicinae) |
| `SUPER` + `E` | arquivos (nautilus) |
| `SUPER` + `B` | navegador (zen) |
| `SUPER` + `Z` | editor (zed) |
| `SUPER` + `V` | flutuar janela |
| `SUPER` + `F` | tela cheia |
| `SUPER` + `J` | alternar direção do split (dwindle) |
| `SUPER` + `P` | pseudo-tile |
| `SUPER` + `L` | bloquear tela |
| `SUPER` + `M` | menu de energia (wlogout) |
| `SUPER` + `N` | central de notificações |
| `SUPER` + `SHIFT` + `N` | não perturbe |
| `SUPER` + `SHIFT` + `V` | histórico de clipboard |
| `SUPER` + `SHIFT` + `C` | conta-gotas de cor (copia o hex) |
| `SUPER` + `SHIFT` + `T` | filtro de luz azul (4000K) |
| `SUPER` + `1..0` | ir para workspace |
| `SUPER` + `SHIFT` + `1..0` | mover janela para workspace |
| `SUPER` + `setas` | mover foco |
| `SUPER` + `SHIFT` + `setas` | mover janela |
| `SUPER` + `CTRL` + `setas` | redimensionar janela |
| `SUPER` + `S` | scratchpad |
| `Print` | screenshot de área (satty) |
| `SHIFT` + `Print` | screenshot da tela toda |

## Inatividade

Definido em `config/hypr/hypridle.conf`:

| Tempo | Ação |
|---|---|
| 2min30 | escurece a tela |
| 5min30 | desliga a tela |
| 30min | suspende |

**Não há bloqueio automático.** O login no TTY durante o boot já autentica a
sessão (sem display manager, sem autologin), então travar de novo por
inatividade pediria a senha duas vezes no mesmo uso. Bloqueio manual: `SUPER+L`.

Se o hyprlock morrer e a sessão ficar travada, `misc:allow_session_lock_restore`
está ligado: vá para um TTY (`Ctrl+Alt+F2`), logue e rode `hyprlock` — ele
reassume o lock órfão. Nunca mate o hyprlock por sinal: ele morre antes de
enviar o unlock e a sessão fica presa.

## Wallpaper

Gerado por `scripts/gen-wallpaper.py` (Python puro, sem PIL/ImageMagick) em
`~/.local/share/wallpapers/tokyonight.png`. Para regerar em outra resolução:

```bash
python3 scripts/gen-wallpaper.py ~/.local/share/wallpapers/tokyonight.png 2560 1440
```

## Notas

- Apps **Qt5** precisam de `QT_QPA_PLATFORMTHEME=qt5ct`; o padrão global está em `qt6ct`
  (definido em `hyprland.lua`). Os dois configs existem e usam a mesma paleta.
- `nwg-look` sobrescreve `gtk-3.0/settings.ini` e `.gtkrc-2.0` — se usá-lo, confira
  o `git diff` do repo depois.
