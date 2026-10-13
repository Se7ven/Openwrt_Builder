#!/bin/bash
# =================================================================
# Custom Part 2.1 Script - Streamlined & Path Fixed
# =================================================================

set -e

TARGET_BRANCH="${BUILD_BRANCH:-openwrt-25.12}"
echo "===> Running Part 2.1 script for branch: $TARGET_BRANCH"

# 1. DTS-Injektion
if [ -d "../board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    cp -rf ../board/target/linux/mediatek/dts/* target/linux/mediatek/dts/
else
    echo "===> FEHLER: DTS-Ordner ../board/target/linux/mediatek/dts nicht gefunden!"
    exit 1
fi

# 2. filogic.mk injizieren
if [ -f "../board/target/linux/mediatek/image/filogic.mk" ]; then
    echo "===> Injecting custom filogic.mk for GL-MT5000 definition..."
    cp -f ../board/target/linux/mediatek/image/filogic.mk target/linux/mediatek/image/
fi

# 3. Zirkuläre Feeds / Kconfig-Schleifen eliminieren
echo "===> Removing problematic feed packages causing Kconfig loops..."
rm -rf feeds/video/frameworks/qt5 2>/dev/null || true
rm -rf feeds/packages/sound/squeezelite* 2>/dev/null || true
rm -rf tmp/.config-package.in 2>/dev/null || true

# 4. Prüfen, ob .config existiert; falls nicht, einmalig erstellen
if [ ! -f .config ]; then
    echo "===> .config existiert noch nicht. Erzeuge Basiskonfiguration via make defconfig..."
    make defconfig
fi

# Warten, bis .config bereit ist
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

# 5. Target-Konfiguration für GL-MT5000 absolut sauber erzwingen
echo "===> Forcing GL-MT5000 target configuration in .config..."

# WICHTIG: Alle bestehenden Targets, Subtargets und Devices restlos entfernen,
# damit es zu keinem "choice state override"-Konflikt kommt
sed -i '/CONFIG_TARGET_BOARD/d' .config
sed -i '/CONFIG_TARGET_SUBTARGET/d' .config
sed -i '/CONFIG_TARGET_IT/d' .config
sed -i '/CONFIG_TARGET.*_DEVICE_/d' .config
sed -i '/CONFIG_TARGET_DEVICE_/d' .config
sed -i '/CONFIG_TARGET_mediatek/d' .config
sed -i '/CONFIG_TARGET_x86/d' .config
sed -i '/CONFIG_TARGET_armvirt/d' .config

# Deine exakte Definition anhängen
cat << 'EOF' >> .config
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_DEVICE_mediatek_filogic_device_gl-mt5000=y
EOF

# 6. Konfiguration final auflösen
make defconfig

# 7. Kontrolle: Prüfen, ob das Target in der .config gelandet ist
echo "===> Verifiziere aktives Device in .config:"
grep "gl-mt5000" .config || echo "ACHTUNG: gl-mt5000 wurde in .config nicht gefunden!"

echo "===> Part 2.1 script completed successfully."
