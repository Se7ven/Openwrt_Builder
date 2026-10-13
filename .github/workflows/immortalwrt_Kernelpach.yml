#!/bin/bash
# =================================================================
# Custom Script Part 2.1 (ImmortalWrt GL-MT5000 Injektions-Skript)
# =================================================================

echo "Starte Part 2.1 fuer Kernel 6.12..."

# --- 1. Zusaetzliche Kernel-Patches in patches-6.12 injizieren ---
PATCH_DIR="target/linux/mediatek/patches-6.12"
if [ -d "$PATCH_DIR" ] && [ -d "../patches" ]; then
    cp -f ../patches/*.patch "$PATCH_DIR/"
    echo "Patches erfolgreich in patches-6.12 kopiert."
else
    echo "Hinweis: Patch-Verzeichnis oder ../patches nicht gefunden."
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
