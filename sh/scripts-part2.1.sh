#!/bin/bash
# =================================================================
# Custom Script Part 2.1 (ImmortalWrt GL-MT5000 Injektions-Skript)
# =================================================================

echo "Starte Part 2.1 fuer Kernel 6.12..."

# --- 1. Zusaetzliche Kernel-Patches in patches-6.12 injizieren ---
PATCH_DIR="target/linux/mediatek/patches-6.12"
# Wir suchen direkt im Parent-Verzeichnis, wo das Repo ausgecheckt ist (z.B. ../patches)
SRC_PATCH_DIR="../patches"

if [ -d "$PATCH_DIR" ]; then
    if [ -d "$SRC_PATCH_DIR" ]; then
        cp -f "$SRC_PATCH_DIR"/*.patch "$PATCH_DIR/"
        echo "Zusaetzliche Patches erfolgreich aus $SRC_PATCH_DIR in $PATCH_DIR kopiert."
    else
        echo "Hinweis: Quell-Verzeichnis $SRC_PATCH_DIR nicht gefunden."
    fi
else
    echo "Hinweis: Ziel-Patch-Verzeichnis $PATCH_DIR nicht gefunden."
fi

# --- 2. Board-Definitionen & DTS fuer GL-MT5000 injizieren ---
BOARD_DIR="../board/target"
if [ -d "$BOARD_DIR" ]; then
    cp -rf "$BOARD_DIR"/* target/
    echo "Board-Definitionen und DTS-Dateien erfolgreich in den Quellbaum kopiert."
else
    echo "Hinweis: Kein Board-Verzeichnis unter ../board/target gefunden."
fi

# --- 3. Standard-LAN-IP auf 192.168.100.1 setzen ---
NET_GEN="package/base-files/files/bin/config_generate"
if [ -f "$NET_GEN" ]; then
    sed -i 's/192.168.1.1/192.168.100.1/g' "$NET_GEN"
    echo "LAN-IP erfolgreich angepasst."
else
    find . -path "*/base-files/files/bin/config_generate" -exec sed -i 's/192.168.1.1/192.168.100.1/g' {} +
    echo "LAN-IP ueber alternativen Pfad angepasst."
fi

echo "Part 2.1 erfolgreich abgeschlossen."
