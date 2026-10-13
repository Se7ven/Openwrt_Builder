#!/bin/bash
# =================================================================
# Custom Part 2.1 Script - Streamlined & Path Fixed
# =================================================================

set -e

TARGET_BRANCH="${BUILD_BRANCH:-openwrt-25.12}"
echo "===> Running Part 2.1 script for branch: $TARGET_BRANCH"

# 1. DTS-Injektion mit dem korrekten relativen Pfad (../board/...)
if [ -d "../board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    cp -rf ../board/target/linux/mediatek/dts/* target/linux/mediatek/dts/
else
    echo "===> FEHLER: DTS-Ordner ../board/target/linux/mediatek/dts nicht gefunden!"
    exit 1
fi

# Optional: Falls du auch eine angepasste filogic.mk injizierst (wie im Log erwähnt)
if [ -f "../board/target/linux/mediatek/image/filogic.mk" ]; then
    echo "===> Injecting custom filogic.mk for GL-MT5000 definition..."
    cp -f ../board/target/linux/mediatek/image/filogic.mk target/linux/mediatek/image/
fi

# 2. Prüfen, ob die .config existiert; falls nicht, initial erzeugen lassen
if [ ! -f .config ]; then
    echo "===> .config existiert noch nicht. Erzeuge Basiskonfiguration via make defconfig..."
    make defconfig
fi

# Warten/Sicherstellen, dass .config vorhanden und nicht leer ist
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

# 3. Target-Konfiguration für GL-MT5000 sauber erzwingen
echo "===> Forcing GL-MT5000 target configuration in .config..."

# Alte Target- und Device-Einträge komplett bereinigen, um Choice-Konflikte zu vermeiden
sed -i '/CONFIG_TARGET_BOARD/d' .config
sed -i '/CONFIG_TARGET_SUBTARGET/d' .config
sed -i '/CONFIG_TARGET_IT/d' .config
sed -i '/CONFIG_TARGET.*_DEVICE_/d' .config

# Sauber setzen (Choice-konform für mediatek/filogic und das konkrete Device)
cat << 'EOF' >> .config
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_DEVICE_mediatek_filogic_device_gl-mt5000=y
EOF

# Konfiguration final aktualisieren, damit Kconfig die Abhängigkeiten sauber auflöst
make defconfig

echo "===> Part 2.1 script completed successfully."
