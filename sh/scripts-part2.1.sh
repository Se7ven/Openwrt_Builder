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

# --- NEU: Standard-LAN-IP auf 192.168.100.1 setzen ---
echo "Passe Standard-LAN-IP auf 192.168.100.1 an..."
NETWORK_GEN="package/base-files/files/bin/config_generate"
if [ -f "$NETWORK_GEN" ]; then
    sed -i 's/192.168.1.1/192.168.100.1/g' "$NETWORK_GEN"
    echo "LAN-IP erfolgreich in config_generate angepasst."
else
    find . -path "*/base-files/files/bin/config_generate" -exec sed -i 's/192.168.1.1/192.168.100.1/g' {} +
    echo "LAN-IP über Alternatives-Pfad-Finden angepasst."
fi
