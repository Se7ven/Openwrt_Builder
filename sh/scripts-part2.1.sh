#!/bin/bash
# =================================================================
# Custom Part 2.1 Script - Cleaned, DTS & filogic.mk Injection
# =================================================================

TARGET_BRANCH="${BUILD_BRANCH:-openwrt-25.12}"
echo "===> Running Part 2.1 script for branch: $TARGET_BRANCH"

# 1. DTS-Injektion für den GL-MT5000
if [ -d "../board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    cp -rf ../board/target/linux/mediatek/dts/* target/linux/mediatek/dts/
else
    echo "===> FEHLER: DTS-Ordner ../board/target/linux/mediatek/dts nicht gefunden!"
    exit 1
fi

# 1.1 filogic.mk Injektion für die GL-MT5000 Device-Definition
if [ -f "../board/target/linux/mediatek/image/filogic.mk" ]; then
    echo "===> Injecting custom filogic.mk for GL-MT5000 definition..."
    cp -f ../board/target/linux/mediatek/image/filogic.mk target/linux/mediatek/image/filogic.mk
else
    echo "===> FEHLER: filogic.mk unter ../board/target/linux/mediatek/image/ nicht gefunden!"
    exit 1
fi

# 2. Wir lassen erst die Basis-Konfiguration generieren/laden
echo "===> Running initial defconfig..."
make defconfig

# 3. JETZT überschreiben / erzwingen wir unsere GL-MT5000 Ziel-Parameter in der fertigen .config
echo "===> Forcing GL-MT5000 target configuration in .config..."
if [ -f ".config" ]; then
    sed -i '/CONFIG_TARGET_BOARD/d' .config
    sed -i '/CONFIG_TARGET_SUBTARGET/d' .config
    sed -i '/CONFIG_TARGET_DEVICE_mediatek_filogic/d' .config

    echo 'CONFIG_TARGET_mediatek=y' >> .config
    echo 'CONFIG_TARGET_mediatek_filogic=y' >> .config
    echo 'CONFIG_TARGET_DEVICE_mediatek_filogic_device_gl-mt5000=y' >> .config
else
    echo "===> FEHLER: .config wurde nicht erstellt!"
    exit 1
fi

# 4. Abschließendes defconfig, damit das Buildsystem die erzwungenen Werte sauber verarbeitet
make defconfig

echo "===> Part 2.1 script completed successfully."
