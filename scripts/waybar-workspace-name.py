#!/usr/bin/env python3
"""Emite o nome do workspace ativo para a waybar (modulo custom).

Fica visivel apenas quando o workspace nao tem janela em foco -- quem cuida
disso e o CSS, via a classe .empty que a waybar poe em window#waybar.

Escuta o socket de eventos do Hyprland em vez de fazer polling: sem timer,
so reage a mudanca de workspace ou de monitor.
"""
import json
import os
import socket
import subprocess
import sys

EVENTS = (b"workspace>>", b"focusedmon>>", b"workspacev2>>", b"createworkspace>>")


def active_workspace() -> str:
    try:
        out = subprocess.run(
            ["hyprctl", "activeworkspace", "-j"],
            capture_output=True, text=True, timeout=2,
        ).stdout
        return json.loads(out).get("name", "")
    except Exception:
        return ""


_last = None


def emit() -> None:
    # Hyprland dispara workspace>> e workspacev2>> para a mesma troca; sem este
    # guarda a waybar receberia cada mudanca duas ou tres vezes.
    global _last
    name = active_workspace()
    if name == _last:
        return
    _last = name

    if not name:
        print("", flush=True)
        return
    # Nome puramente numerico ganha o rotulo; nomeado aparece como esta.
    text = f"Workspace {name}" if name.isdigit() else name
    print(json.dumps({"text": text, "tooltip": f"Workspace {name}"}), flush=True)


def socket_path() -> str:
    sig = os.environ.get("HYPRLAND_INSTANCE_SIGNATURE")
    if not sig:
        sys.exit("HYPRLAND_INSTANCE_SIGNATURE nao definida")
    runtime = os.environ.get("XDG_RUNTIME_DIR", f"/run/user/{os.getuid()}")
    return f"{runtime}/hypr/{sig}/.socket2.sock"


def main() -> None:
    emit()

    sock = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
    try:
        sock.connect(socket_path())
    except OSError as exc:
        sys.exit(f"nao consegui abrir o socket de eventos: {exc}")

    buffer = b""
    while True:
        chunk = sock.recv(4096)
        if not chunk:          # Hyprland caiu
            break
        buffer += chunk
        while b"\n" in buffer:
            line, buffer = buffer.split(b"\n", 1)
            if line.startswith(EVENTS):
                emit()


if __name__ == "__main__":
    main()
