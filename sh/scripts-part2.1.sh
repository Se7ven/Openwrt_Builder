#!/bin/bash
# =================================================================
# Custom Script Part 2.1 (ImmortalWrt GL-MT5000 Injektions-Skript)
# =================================================================

echo "Starte Part 2.1: Kernel-Version auf 6.18.25 festnageln, Patches und Board-Dateien injizieren..."

# --- 0a. Kernel-Patch-Version im Mediatk-Target auf 6.18 setzen ---
MEDIATEK_MAKEFILE="target/linux/mediatek/Makefile"
if [ -f "$MEDIATEK_MAKEFILE" ]; then
    echo "Passe KERNEL_PATCHVER in $MEDIATEK_MAKEFILE auf 6.18 an..."
    sed -i 's/KERNEL_PATCHVER:=.*/KERNEL_PATCHVER:=6.18/g' "$MEDIATEK_MAKEFILE"
else
    echo "Warnung: $MEDIATEK_MAKEFILE nicht gefunden!"
fi

# --- 0b. Exakte Kernel-Version 6.18.25 in include/kernel-6.18 erzwingen ---
KERNEL_INCLUDE="include/kernel-6.18"
if [ -f "$KERNEL_INCLUDE" ]; then
    echo "Passe LINUX_VERSION in $KERNEL_INCLUDE auf 6.18.25 an..."
    sed -i 's/LINUX_VERSION:=.*/LINUX_VERSION:=6.18.25/g' "$KERNEL_INCLUDE"
else
    echo "Hinweis: $KERNEL_INCLUDE nicht direkt gefunden, suche in include/..."
    FOUND_KERNEL_INC=$(find include -maxdepth 1 -name "kernel-6.18*")
    if [ -n "$FOUND_KERNEL_INC" ]; then
        echo "Passe LINUX_VERSION in $FOUND_KERNEL_INC auf 6.18.25 an..."
        sed -i 's/LINUX_VERSION:=.*/LINUX_VERSION:=6.18.25/g' "$FOUND_KERNEL_INC"
    fi
fi


# --- 1. Kernel-Patches für MT7987/MT7988 injizieren ---
TARGET_PATCH_DIR="target/linux/mediatek/patches-6.18"

if [ -d "$TARGET_PATCH_DIR" ]; then
    echo "Zielverzeichnis für Patches gefunden: $TARGET_PATCH_DIR"
    if [ -d "../patches" ]; then
        cp -f ../patches/*.patch "$TARGET_PATCH_DIR/"
        echo "Alle Kernel-Patches aus dem patches/-Ordner erfolgreich injiziert."
    else
        echo "Warnung: ../patches/-Ordner nicht gefunden!"
    fi
else
    echo "Fehler: Patch-Verzeichnis $TARGET_PATCH_DIR existiert nicht im Quellbaum!"
fi


# --- 2. Board-Definitionen & DTS für GL-MT5000 injizieren ---
if [ -d "../board/target" ]; then
    echo "Injiziere Board-Konfigurationen und DTS-Dateien..."
    cp -rf ../board/target/* target/
    echo "Board-Dateien erfolgreich in den Quellbaum kopiert."
else
    echo "Hinweis: Kein '../board/target'-Ordner gefunden, überspringe Board-Injektion."
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
