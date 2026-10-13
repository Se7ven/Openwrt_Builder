#!/bin/bash
# =================================================================
# Prepare Script - DTS Injection, Config & Target Force
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
echo "===> Running preparation for repository: $SDK_REPO"

# 1. DTS-Injektion (aus board/ oder target/)
if [ -d "board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files from board/..."
    cp -rf board/target/linux/mediatek/dts/* openwrt/target/linux/mediatek/dts/
elif [ -d "target/linux/mediatek/dts" ]; then
    echo "===> DTS files already in place."
fi

# 2. Richtige Config-Datei aus dem config/-Ordner (oder Root) anhand der Auswahl kopieren
CONFIG_FILE=""
if [ "$SDK_REPO" = "openwrt" ]; then
    if [ -f "config/mt5000.config" ]; then
        CONFIG_FILE="config/mt5000.config"
    elif [ -f "mt5000.config" ]; then
        CONFIG_FILE="mt5000.config"
    fi
else
    if [ -f "config/immortalwrt.config" ]; then
        CONFIG_FILE="config/immortalwrt.config"
    elif [ -f "immortalwrt.config" ]; then
        CONFIG_FILE="immortalwrt.config"
    fi
fi

if [ -n "$CONFIG_FILE" ]; then
    echo "===> Applying configuration: $CONFIG_FILE"
    cp "$CONFIG_FILE" openwrt/.config
else
    echo "===> WARNUNG: Keine passende Config-Datei gefunden! Erstelle leere .config"
    touch openwrt/.config
fi

# 3. Ins openwrt-Verzeichnis wechseln
cd openwrt || exit 1

# 4. Zirkuläre Feeds / Kconfig-Schleifen eliminieren
echo "===> Removing problematic feed packages causing Kconfig loops..."
rm -rf feeds/video/frameworks/qt5 2>/dev/null || true
rm -rf feeds/packages/sound/squeezelite* 2>/dev/null || true
rm -rf tmp/.config-package.in 2>/dev/null || true

# 5. Prüfen, ob .config existiert; falls nicht, einmalig erstellen
if [ ! -f .config ]; then
    echo "===> .config existiert noch nicht. Erzeuge Basiskonfiguration via make defconfig..."
    make defconfig
fi

# 6. Warten, bis .config bereit ist
echo "===> Stelle sicher, dass .config bereit ist..."
TIMEOUT=30
while [ ! -s .config ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ $TIMEOUT -le 0 ]; then
        echo "===> FEHLER: Zeitüberschreitung beim Warten auf .config!"
        exit 1
    fi
done

# 7. Target-Konfiguration für GL-MT5000 absolut sauber erzwingen
echo "===> Forcing GL-MT5000 target configuration in .config..."

# 8. WICHTIG: Alle bestehenden Targets, Subtargets und Devices restlos entfernen,
# damit es zu keinem "choice state override"-Konflikt kommt
sed -i '/CONFIG_TARGET_BOARD/d' .config
sed -i '/CONFIG_TARGET_SUBTARGET/d' .config
sed -i '/CONFIG_TARGET_IT/d' .config
sed -i '/CONFIG_TARGET.*_DEVICE_/d' .config
sed -i '/CONFIG_TARGET_DEVICE_/d' .config
sed -i '/CONFIG_TARGET_mediatek/d' .config
sed -i '/CONFIG_TARGET_x86/d' .config
sed -i '/CONFIG_TARGET_armvirt/d' .config

# 9. Korrekte Key-Definition mit Großbuchstaben anhängen
cat << 'EOF' >> .config
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_glinet_gl-mt5000=y
EOF

# 6. Konfiguration final auflösen
make defconfig

# 7. Kontrolle: Prüfen, ob das Target in der .config gelandet ist
echo "===> Verifiziere aktives Device in .config:"
grep "gl-mt5000" .config || echo "ACHTUNG: gl-mt5000 wurde in .config nicht gefunden!"

echo "===> Preparation completed successfully."
