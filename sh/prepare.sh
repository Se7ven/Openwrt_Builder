#!/bin/bash
# =================================================================
# Prepare Script - DTS Injection, Config & Target Force
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
echo "===> Running preparation for repository: $SDK_REPO"

# 1. DTS-Injektion aus dem lokalen board-Ordner
if [ -d "board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    cp -rf board/target/linux/mediatek/dts/* openwrt/target/linux/mediatek/dts/
else
    echo "===> FEHLER: DTS-Ordner board/target/linux/mediatek/dts nicht gefunden!"
    exit 1
fi

# Optional: filogic.mk, falls vorhanden
if [ -f "board/target/linux/mediatek/image/filogic.mk" ]; then
    echo "===> Injecting custom filogic.mk..."
    cp -f board/target/linux/mediatek/image/filogic.mk openwrt/target/linux/mediatek/image/
fi

# 2. Richtige Config-Datei anhand der Auswahl kopieren
if [ "$SDK_REPO" = "openwrt" ] && [ -f "board/mt5000.config" ]; then
    echo "===> Applying OpenWrt configuration (mt5000.config)..."
    cp board/mt5000.config openwrt/.config
elif [ -f "board/immortalwrt.config" ]; then
    echo "===> Applying ImmortalWrt configuration (immortalwrt.config)..."
    cp board/immortalwrt.config openwrt/.config
else
    echo "===> WARNUNG: Keine passende Config-Datei gefunden, verwende Standard!"
fi

cd openwrt || exit 1

# 3. Target für GL-MT5000 erzwingen
echo "===> Forcing GL-MT5000 target configuration in .config..."
sed -i '/CONFIG_TARGET_BOARD/d' .config
sed -i '/CONFIG_TARGET_SUBTARGET/d' .config
sed -i '/CONFIG_TARGET_IT/d' .config
sed -i '/CONFIG_TARGET.*_DEVICE_/d' .config

cat << 'EOF' >> .config
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_DEVICE_mediatek_filogic_device_gl-mt5000=y
EOF

make defconfig

echo "===> Preparation completed successfully."
