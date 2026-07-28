#!/usr/bin/env bash
# Instala tudo que estes dotfiles assumem que existe.
set -euo pipefail

# --- repos oficiais ---
REPO=(
  # ja instalados no setup original, listados para reprodutibilidade
  hyprland hyprpaper waybar wofi foot nautilus
  grim slurp satty wl-clipboard brightnessctl playerctl
  pipewire pipewire-pulse wireplumber polkit-gnome
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk
  papirus-icon-theme nwg-look ttf-input-nerd noto-fonts-emoji

  # adicionados
  swaync              # daemon + central de notificacoes
  hyprlock            # tela de bloqueio
  hypridle            # regras de inatividade
  cliphist            # historico de clipboard
  wl-clip-persist     # mantem o clipboard apos fechar a janela de origem
  pavucontrol         # mixer de audio
  blueman             # bluetooth
  qt5ct qt6ct         # tema para apps Qt
  noto-fonts          # cobertura de glifos
  ttf-jetbrains-mono-nerd
)

# --- AUR ---
QOL_REPO=(
  # desktop
  hyprpicker            # conta-gotas de cor (SUPER+SHIFT+C)
  hyprsunset            # filtro de luz azul (SUPER+SHIFT+T)
  hyprpolkitagent       # agente polkit nativo (nome SEM hifens, e repo oficial)
  power-profiles-daemon # perfis de energia + modulo na waybar
  ffmpegthumbnailer     # miniaturas de video no nautilus
  noto-fonts-cjk        # cobertura de glifos

  # terminal
  fzf ripgrep fd bat eza zoxide
  lazygit github-cli btop jq

  # gravacao de tela com aceleracao por hardware (ver nota no bloco AUR)
  gpu-screen-recorder
)

AUR=(
  wlogout                  # menu de energia
  tokyonight-gtk-theme-git # tema GTK
)

# NAO usar wl-screenrec: a crate ffmpeg-next 8.0.0 que ele fixa nao cobre os
# enums novos do ffmpeg 8.1 do Arch (AV_CODEC_ID_JPEGXS, AV_FRAME_DATA_EXIF,
# AVCOL_PRI_EXT_BASE...) e o match exaustivo do Rust quebra o build.
# gpu-screen-recorder faz o mesmo (VAAPI na Iris Xe) e vem pronto do repo.

# Sem `set -e` daqui pra baixo de proposito: um nome de pacote errado faz o
# pacman/yay abortar a transacao inteira, e com -e o script morreria antes das
# etapas seguintes (foi o que aconteceu: um nome errado no AUR deixou o
# power-profiles-daemon sem habilitar, sem nenhum aviso).
FALHAS=()

echo "==> repos oficiais"
sudo pacman -S --needed "${REPO[@]}" "${QOL_REPO[@]}" || FALHAS+=("pacman")

echo "==> AUR"
yay -S --needed "${AUR[@]}" || FALHAS+=("yay/AUR")

echo "==> habilitando o power-profiles-daemon"
sudo systemctl enable --now power-profiles-daemon.service || FALHAS+=("power-profiles-daemon")

if (( ${#FALHAS[@]} )); then
  printf '\n\e[33m!\e[0m etapas com falha: %s\n' "${FALHAS[*]}"
  printf '  reveja a saida acima antes de rodar o install.sh\n'
  exit 1
fi

echo "==> pronto. Agora rode: ./install.sh"
