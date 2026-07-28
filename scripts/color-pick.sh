#!/usr/bin/env bash
# Conta-gotas: copia o hex da cor sob o cursor e notifica.
set -uo pipefail

command -v hyprpicker >/dev/null || {
  notify-send -u critical "hyprpicker nao instalado" "pacman -S hyprpicker"
  exit 1
}

# -a ja copia para o clipboard; a saida e o hex
color="$(hyprpicker -a -f hex 2>/dev/null)" || exit 1
[[ -z "$color" ]] && exit 0   # cancelado com Esc

notify-send -a "Conta-gotas" -t 4000 "Cor copiada" "$color"
