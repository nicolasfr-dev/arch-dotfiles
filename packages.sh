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
AUR=(
  wlogout                  # menu de energia
  tokyonight-gtk-theme-git # tema GTK
)

echo "==> repos oficiais"
sudo pacman -S --needed "${REPO[@]}"

echo "==> AUR"
yay -S --needed "${AUR[@]}"

echo "==> pronto. Agora rode: ./install.sh"
