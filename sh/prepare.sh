#!/bin/bash
# =================================================================
# Prepare Script - Absolute Path Execution (No CD Chaos)
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
echo "===> Running preparation for repository: $SDK_REPO"

# Finde das Quellverzeichnis (entweder openwrt oder immortalwrt)
OPENWRT_DIR=""
if [ -d "openwrt" ]; then
    OPENWRT_DIR="openwrt"
elif [ -d "immortalwrt" ]; then
    OPENWRT_DIR="immortalwrt"
else
    echo "===> FEHLER: Weder 'openwrt' noch 'immortalwrt' Verzeichnis gefunden!"
    exit 1
fi

echo "===> Verwende Quellverzeichnis: $OPENWRT_DIR"

# 1. DTS-Injektion
if [ -d "board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    mkdir -p "$OPENWRT_DIR/target/linux/mediatek/dts"
    cp -rf board/target/linux/mediatek/dts/* "$OPENWRT_DIR/target/linux/mediatek/dts/"
else
    echo "===> FEHLER: DTS-Ordner board/target/linux/mediatek/dts nicht gefunden!"
    exit 1
fi

# 2. filogic.mk injizieren
if [ -f "board/target/linux/mediatek/image/filogic.mk" ]; then
    echo "===> Injecting custom filogic.mk for GL-MT5000 definition..."
    mkdir -p "$OPENWRT_DIR/target/linux/mediatek/image"
    cp -f board/target/linux/mediatek/image/filogic.mk "$OPENWRT_DIR/target/linux/mediatek/image/"
fi

# 3. Config-Datei ermitteln und kopieren
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
    cp "$CONFIG_FILE" "$OPENWRT_DIR/.config"
else
    echo "===> WARNUNG: Keine passende Config-Datei gefunden! Erstelle leere .config"
    touch "$OPENWRT_DIR/.config"
fi

# 4. Feeds aktualisieren und installieren (EXPLIZIT ÜBER PFAD, ohne unvorhersehbares cd)
echo "===> Updating and installing feeds..."
cd "$OPENWRT_DIR" && ./scripts/feeds update -a && ./scripts/feeds install -a
if [ $? -ne 0 ]; then
    echo "===> FEHLER beim Aktualisieren/Installieren der Feeds!"
    exit 1
fi

# 5. Zirkuläre Feeds / Kconfig-Schleifen eliminieren (inkl. Weechat)
echo "===> Removing problematic feed packages causing Kconfig loops..."
rm -rf feeds/video/frameworks/qt5 2>/dev/null || true
rm -rf feeds/packages/sound/squeezelite* 2>/dev/null || true
rm -rf feeds/luci/applications/luci-app-weechat 2>/dev/null || true
rm -rf feeds/packages/utils/weechat 2>/dev/null || true
rm -rf tmp/.config-package.in 2>/dev/null || true

# 6. Basiskonfiguration erzeugen, falls .config leer ist
if [ ! -f .config ] || [ ! -s .config ]; then
    echo "===> .config ist leer. Erzeuge Basiskonfiguration via make defconfig..."
    make defconfig
fi

# Warten, bis .config bereit ist
TIMEOUT=30
while [ ! -s .config ]; do
    sleep 1
    TIMEOUT=$((TIMEOUT - 1))
    if [ $TIMEOUT -le 0 ]; then
        echo "===> FEHLER: Zeitüberschreitung beim Warten auf .config!"
        exit 1
    fi
done

# 7. Target-Konfiguration für GL-MT5000 erzwingen
echo "===> Forcing GL-MT5000 target configuration in .config..."

sed -i '/CONFIG_TARGET_BOARD/d' .config
sed -i '/CONFIG_TARGET_SUBTARGET/d' .config
sed -i '/CONFIG_TARGET_IT/d' .config
sed -i '/CONFIG_TARGET.*_DEVICE_/d' .config
sed -i '/CONFIG_TARGET_DEVICE_/d' .config
sed -i '/CONFIG_TARGET_mediatek/d' .config
sed -i '/CONFIG_TARGET_x86/d' .config
sed -i '/CONFIG_TARGET_armvirt/d' .config

cat << 'EOF' >> .config
CONFIG_TARGET_mediatek=y
CONFIG_TARGET_mediatek_filogic=y
CONFIG_TARGET_BOARD="mediatek"
CONFIG_TARGET_SUBTARGET="filogic"
CONFIG_TARGET_mediatek_filogic_DEVICE_glinet_gl-mt5000=y
EOF

# 7.5 Netzwerkkonfiguration für GL-MT5000 hinterlegen
echo "===> Konfiguriere Netzwerk & Basis für GL-MT5000..."

mkdir -p package/base-files/files/etc/config
cat << 'EOF' > package/base-files/files/etc/config/network
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	option ipaddr '127.0.0.1'
	option netmask '255.0.0.0'

config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ipaddr '192.168.100.1'
	option netmask '255.255.255.0'

config interface 'wan'
	option device 'eth1'
	option proto 'dhcp'
EOF

# 8. Konfiguration abschließen mit olddefconfig
echo "===> Finalizing configuration with olddefconfig..."
yes "" | make olddefconfig

# 9. Kontrolle
echo "===> Verifiziere aktives Device in .config:"
grep "gl-mt5000" .config || echo "ACHTUNG: gl-mt5000 wurde in .config nicht gefunden!"

# Zurück ins Root-Verzeichnis wechseln, damit der Schritt sauber abschließt
cd ..

echo "===> Preparation completed successfully."
