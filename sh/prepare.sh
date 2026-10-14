#!/bin/bash
# =================================================================
# Prepare Script - Mit dediziertem package/custom Ordner & Konfliktbereinigung
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"
echo "===> Running preparation for repository: $SDK_REPO (Branch-Type: $SDK_BRANCH_TYPE)"

# Finde das Quellverzeichnis (entweder openwrt oder immortalwrt)
OPENWRT_DIR=""
if [ -d "openwrt" ]; then
    OPENWRT_DIR="openwrt"
elif [ -d "immortalwrt" ]; then
    OPENWRT_DIR="immortalwrt"
else
    echo "===> FEHLER: Weder 'openwrt' nor 'immortalwrt' Verzeichnis gefunden!"
    exit 1
fi

echo "===> Verwende Quellverzeichnis: $OPENWRT_DIR"
cd "$OPENWRT_DIR"

# 1. DTS-Injektion
if [ -d "../board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    mkdir -p "target/linux/mediatek/dts"
    cp -rf ../board/target/linux/mediatek/dts/* "target/linux/mediatek/dts/"
fi

# 2. filogic.mk injizieren
if [ -f "../board/target/linux/mediatek/image/filogic.mk" ]; then
    echo "===> Injecting custom filogic.mk for GL-MT5000 definition..."
    mkdir -p "target/linux/mediatek/image"
    cp -f ../board/target/linux/mediatek/image/filogic.mk "target/linux/mediatek/image/"
fi

# =================================================================
# NEU: CUSTOM PACKAGES ORDNER EINBINDEN
# =================================================================
CUSTOM_DIR="package/custom"
echo "===> Prepare custom packages directory: $CUSTOM_DIR"
rm -rf "$CUSTOM_DIR"
mkdir -p "$CUSTOM_DIR"

# Hier kannst du deine gewünschten Repositories eintragen, die nach package/custom geladen werden sollen:
# Beispiel:
# git clone --depth 1 https://github.com/pymumu/luci-app-smartdns "$CUSTOM_DIR/luci-app-smartdns"
# git clone --depth 1 https://github.com/pymumu/smartdns "$CUSTOM_DIR/smartdns"

# Konfligierende Makefiles im gesamten Baum (außerhalb von custom) bereinigen
CONFLICTING_KEYWORDS=("weechat" "squeezelite" "qt5" "openvswitch")
for keyword in "${CONFLICTING_KEYWORDS[@]}"; do
    find . -type f -name "Makefile" ! -path "$CUSTOM_DIR/*" -print0 | while IFS= read -r -d $'\0' file; do
        if [[ "${file,,}" == *"$keyword"* ]]; then
            rm -f "$file"
        fi
    done
done
rm -rf tmp/.config-package.in 2>/dev/null || true
# =================================================================

# 3. Feeds aktualisieren und installieren
echo "===> Updating and installing feeds..."
./scripts/feeds update -a && ./scripts/feeds install -a
if [ $? -ne 0 ]; then
    echo "===> FEHLER beim Aktualisieren/Installieren der Feeds!"
    exit 1
fi

# 4. Config-Datei ermitteln und kopieren
CONFIG_FILE=""
if [ "$SDK_REPO" = "openwrt" ]; then
    if [ -f "../config/mt5000.config" ]; then
        CONFIG_FILE="../config/mt5000.config"
    elif [ -f "../mt5000.config" ]; then
        CONFIG_FILE="../mt5000.config"
    fi
else
    if [ -f "../config/immortalwrt.config" ]; then
        CONFIG_FILE="../config/immortalwrt.config"
    elif [ -f "../immortalwrt.config" ]; then
        CONFIG_FILE="../immortalwrt.config"
    fi
fi

if [ -n "$CONFIG_FILE" ]; then
    echo "===> Applying configuration: $CONFIG_FILE"
    cp "$CONFIG_FILE" .config
else
    echo "===> WARNUNG: Keine passende Config-Datei gefunden! Erstelle leere .config"
    touch .config
fi

# 5. Basiskonfiguration erzeugen, falls .config leer ist
if [ ! -s .config ]; then
    echo "===> .config ist leer. Erzeuge Basiskonfiguration via make defconfig..."
    make defconfig
fi

# 6. Target-Konfiguration für GL-MT5000 bereinigen und erzwingen
echo "===> Sanitizing and forcing GL-MT5000 target configuration in .config..."

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

# 7. Netzwerkkonfiguration für GL-MT5000 hinterlegen
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

# 8. Konfigurationsabgleich non-interaktiv durchführen
echo "===> Running automated configuration sync..."
sed -i '/^#.*is not set$/!{/=/!d}' .config 2>/dev/null || true

export TERM=dumb
make olddefconfig

# 9. Kontrolle
echo "===> Verifiziere aktives Device in .config:"
grep "gl-mt5000" .config || echo "ACHTUNG: gl-mt5000 wurde in .config nicht gefunden!"

# Zurück ins Root-Verzeichnis wechseln
cd ..

echo "===> Preparation completed successfully."
