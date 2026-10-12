#!/bin/bash
# =================================================================
# Custom Script Part 2.1 (Wird vor der Konfiguration ausgeführt)
# =================================================================

echo "Starte Part 2.1: Kopiere benutzerdefinierte Kernel-Patches..."

# Zielverzeichnis im GL.iNet / OpenWrt Quellbaum für MediaTek Kernel-Patches (Version 6.18)
TARGET_PATCH_DIR="target/linux/mediatek/patches-6.18"

if [ -d "$TARGET_PATCH_DIR" ]; then
    echo "Zielverzeichnis gefunden: $TARGET_PATCH_DIR"
    
    # Kopiere die Patches aus dem Repository-Ordner 'patches/' in den Quellbaum
    if [ -f "patches/750-net-ethernet-mtk_eth_soc-add-mt7987-support.patch" ]; then
        cp -f patches/750-net-ethernet-mtk_eth_soc-add-mt7987-support.patch "$TARGET_PATCH_DIR/"
        echo "Patch 750 erfolgreich kopiert."
    else
        echo "Warnung: Patch 750 nicht im patches/-Ordner gefunden!"
    fi

    if [ -f "patches/751-net-ethernet-mtk_eth_soc-revise-hardware-configuration-for-mt7987.patch" ]; then
        cp -f patches/751-net-ethernet-mtk_eth_soc-revise-hardware-configuration-for-mt7987.patch "$TARGET_PATCH_DIR/"
        echo "Patch 751 erfolgreich kopiert."
    else
        echo "Warnung: Patch 751 nicht im patches/-Ordner gefunden!"
    fi
else
    echo "Fehler: Ziel-Patch-Verzeichnis $TARGET_PATCH_DIR existiert im Quellbaum nicht!"
fi
