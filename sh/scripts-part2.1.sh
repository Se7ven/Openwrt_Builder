#!/bin/bash
# =================================================================
# Custom Script Part 2.1 (ImmortalWrt GL-MT5000 Injektions-Skript)
# =================================================================

echo "Starte Part 2.1: Injiziere Kernel-Patches und Board-Definitionen für GL-MT5000..."

# --- 1. Kernel-Patches für MT7987/MT7988 injizieren ---
TARGET_PATCH_DIR="target/linux/mediatek/patches-6.18"

if [ -d "$TARGET_PATCH_DIR" ]; then
    echo "Zielverzeichnis für Patches gefunden: $TARGET_PATCH_DIR"
    
    if [ -f "patches/750-net-ethernet-mtk_eth_soc-add-mt7987-support.patch" ]; then
        cp -f patches/750-net-ethernet-mtk_eth_soc-add-mt7987-support.patch "$TARGET_PATCH_DIR/"
        echo "Patch 750 erfolgreich injiziert."
    else
        echo "Warnung: Patch 750 nicht im patches/-Ordner gefunden!"
    fi

    if [ -f "patches/751-net-ethernet-mtk_eth_soc-revise-hardware-configuration-for-mt7987.patch" ]; then
        cp -f patches/751-net-ethernet-mtk_eth_soc-revise-hardware-configuration-for-mt7987.patch "$TARGET_PATCH_DIR/"
        echo "Patch 751 erfolgreich injiziert."
    else
        echo "Warnung: Patch 751 nicht im patches/-Ordner gefunden!"
    fi
else
    echo "Fehler: Patch-Verzeichnis $TARGET_PATCH_DIR existiert nicht im Quellbaum!"
fi


# --- 2. Board-Definitionen & DTS für GL-MT5000 injizieren ---
# (Vorausgesetzt, du hast die angepassten Board-Dateien im Repo unter 'board/' abgelegt)
BOARD_TARGET_DIR="target/linux/mediatek/image"

if [ -d "$BOARD_TARGET_DIR" ] && [ -d "board" ]; then
    echo "Injiziere Board-Konfigurationen und Device-Trees..."
    cp -rf board/* "$BOARD_TARGET_DIR/"
    echo "Board-Dateien erfolgreich kopiert."
fi


# --- 3. Standard-LAN-IP auf 192.168.100.1 setzen ---
echo "Passe Standard-LAN-IP auf 192.168.100.1 an..."
NETWORK_GEN="package/base-files/files/bin/config_generate"

if [ -f "$NETWORK_GEN" ]; then
    sed -i 's/192.168.1.1/192.168.100.1/g' "$NETWORK_GEN"
    echo "LAN-IP erfolgreich in config_generate angepasst."
else
    find . -path "*/base-files/files/bin/config_generate" -exec sed -i 's/192.168.1.1/192.168.100.1/g' {} +
    echo "LAN-IP über alternativen Pfad angepasst."
fi
