#!/usr/bin/env bash
# Liga/desliga o filtro de luz azul (hyprsunset).
set -uo pipefail

TEMP="${1:-4000}"   # Kelvin; menor = mais quente

command -v hyprsunset >/dev/null || {
  notify-send -u critical "hyprsunset nao instalado" "pacman -S hyprsunset"
  exit 1
}

if pgrep -x hyprsunset >/dev/null; then
  pkill -x hyprsunset
  notify-send -a "Luz azul" -t 3000 "Filtro desligado" "Temperatura normal"
else
  setsid nohup hyprsunset -t "$TEMP" >/dev/null 2>&1 </dev/null &
  notify-send -a "Luz azul" -t 3000 "Filtro ligado" "${TEMP}K"
fi
