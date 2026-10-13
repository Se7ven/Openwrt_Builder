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

# 2. Richtige Config-Datei anhand der Auswahl in das openwrt-Verzeichnis kopieren
if [ "$SDK_REPO" = "openwrt" ] && [ -f "board/mt5000.config" ]; then
    echo "===> Applying OpenWrt configuration (mt5000.config)..."
    cp board/mt5000.config openwrt/.config
elif [ -f "board/immortalwrt.config" ]; then
    echo "===> Applying ImmortalWrt configuration (immortalwrt.config)..."
    cp board/immortalwrt.config openwrt/.config
else
    echo "===> WARNUNG: Keine passende Config-Datei im board/-Ordner gefunden!"
    touch openwrt/.config
fi

# 3. Ins openwrt-Verzeichnis wechseln, da ab hier dort gearbeitet wird
cd openwrt || exit 1

# 4. Zirkuläre Feeds / Kconfig-Schleifen eliminieren (falls vorhanden)
echo "===> Removing problematic feed packages causing Kconfig loops..."
rm -rf feeds/video/frameworks/qt5 2>/dev/null || true
rm -rf feeds/packages/sound/squeezelite* 2>/dev/null || true
rm -rf tmp/.config-package.in 2>/dev/null || true

# 5. Warten, bis .config bereit ist
if [ ! -f .config ]; then
    echo "===> .config existiert noch nicht. Erzeuge Basiskonfiguration via make defconfig..."
    make defconfig
fi

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

# 6. Target-Konfiguration für GL-MT5000 absolut sauber erzwingen
echo "===> Forcing GL-MT5000 target configuration in .config..."

sed -i '/CONFIG_TARGET_BOARD/d' .config
sed -i '/CONFIG_TARGET_SUBTARGET/d' .config
sed -i '/CONFIG_TARGET_IT/d' .config
sed -i '/CONFIG_TARGET.*_DEVICE_/d' .config
sed -i '/CONFIG_TARGET_DEVICE_/d' .config
sed -i '/CONFIG_TARGET_mediatek/d' .config
sed -i '/CONFIG_TARGET_x86/d' .config
sed -i '/CONFIG_TARGET_armvirt/d' .config

# Korrekte Key-Definition für den GL-MT5000 anhängen
cat << 'EOF' >> .config
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_mediatek_filogic_DEVICE_glinet_gl-mt5000=y
EOF

# 7. Konfiguration final auflösen
make defconfig

# 8. Kontrolle: Prüfen, ob das Target in der .config gelandet ist
echo "===> Verifiziere aktives Device in .config:"
grep "gl-mt5000" .config || echo "ACHTUNG: gl-mt5000 wurde in .config nicht gefunden!"

echo "===> Preparation completed successfully."
