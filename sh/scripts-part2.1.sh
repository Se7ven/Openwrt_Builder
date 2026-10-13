#!/bin/bash
# =================================================================
# Custom Part 2.1 Script - Streamlined & Path Fixed
# =================================================================

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

# 2. Target-Konfiguration für GL-MT5000 erzwingen (Sicherheitsprüfung für .config)
echo "===> Forcing GL-MT5000 target configuration in .config..."
if [ -f ".config" ]; then
    sed -i '/CONFIG_TARGET_BOARD/d' .config
    sed -i '/CONFIG_TARGET_SUBTARGET/d' .config
    sed -i '/CONFIG_TARGET_DEVICE_mediatek_filogic/d' .config
else
    echo "===> Hinweis: .config existiert noch nicht, wird neu erstellt."
    touch .config
fi

echo 'CONFIG_TARGET_mediatek=y' >> .config
echo 'CONFIG_TARGET_mediatek_filogic=y' >> .config
echo 'CONFIG_TARGET_DEVICE_mediatek_filogic_device_gl-mt5000=y' >> .config

# Konfiguration final aktualisieren, damit das Target greift
make defconfig

echo "===> Part 2.1 script completed successfully."
