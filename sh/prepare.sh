#!/bin/bash
# =================================================================
# Prepare Script - Dynamische Kernel-Patch-Injektion & globalem files/ Ordner
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
    echo "===> FEHLER: Weder 'openwrt' noch 'immortalwrt' Verzeichnis gefunden!"
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
# 2.1 DYNAMISCHE KERNEL-PATCH-INJEKTION & BEREINIGUNG
# =================================================================
PATCH_SOURCE_DIR=""
if [[ "$SDK_BRANCH_TYPE" == *"main"* ]] || [[ "$SDK_BRANCH_TYPE" == *"master"* ]] || [ -d "../patche618" ]; then
    if [ -d "../patche618" ]; then
        PATCH_SOURCE_DIR="../patche618"
        echo "===> Verwende Kernel-Patches für MAIN / KERNEL 6.18 (aus patche618)"
    fi
fi

# Fallback auf den Standard-Stable-Ordner
if [ -z "$PATCH_SOURCE_DIR" ] && [ -d "../patches" ]; then
    PATCH_SOURCE_DIR="../patches"
    echo "===> Verwende Kernel-Patches für STABLE (aus patches)"
fi

if [ -n "$PATCH_SOURCE_DIR" ]; then
    PATCH_TARGET_DIR=$(find target/linux/mediatek -type d -name "patches-*" | head -n 1)
    if [ -n "$PATCH_TARGET_DIR" ]; then
        mkdir -p "$PATCH_TARGET_DIR"
        echo "===> Bereinige konkurrierende Ethernet- und PHY-Patches in $PATCH_TARGET_DIR ..."
        rm -f "$PATCH_TARGET_DIR"/*mtk_eth_soc* 2>/dev/null || true
        rm -f "$PATCH_TARGET_DIR"/*mtk-2p5ge* 2>/dev/null || true
        rm -f "$PATCH_TARGET_DIR"/*i2p5g* 2>/dev/null || true
        
        echo "===> Injiziere Patches aus $PATCH_SOURCE_DIR nach $PATCH_TARGET_DIR ..."
        cp -f "$PATCH_SOURCE_DIR"/*.patch "$PATCH_TARGET_DIR/"
        ls -l "$PATCH_TARGET_DIR"
    else
        echo "===> WARNUNG: Kein Kernel-Patch-Verzeichnis unter target/linux/mediatek gefunden!"
    fi
else
    echo "===> HINWEIS: Kein passender Patch-Quellordner gefunden."
fi

# =================================================================
# 3. CUSTOM PACKAGES ORDNER EINBINDEN
# =================================================================
CUSTOM_DIR="package/custom"
echo "===> Prepare custom packages directory: $CUSTOM_DIR"
rm -rf "$CUSTOM_DIR"
mkdir -p "$CUSTOM_DIR"

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

# 4. Feeds aktualisieren und installieren
echo "===> Updating and installing feeds..."
./scripts/feeds update -a && ./scripts/feeds install -a
if [ $? -ne 0 ]; then
    echo "===> FEHLER beim Aktualisieren/Installieren der Feeds!"
    exit 1
fi

# =================================================================
# 5. Radikales Löschen der Kconfig-Störenfriede nach Feed-Install
# =================================================================
echo "===> Deleting recursive dependency packages completely..."
rm -rf feeds/video/frameworks/qt5 2>/dev/null || true
rm -rf feeds/packages/sound/squeezelite* 2>/dev/null || true
rm -rf feeds/luci/applications/luci-app-weechat 2>/dev/null || true
rm -rf feeds/packages/utils/weechat 2>/dev/null || true
rm -rf package/feeds/*/qt5 2>/dev/null || true
rm -rf package/feeds/*/weechat 2>/dev/null || true
rm -rf package/feeds/*/squeezelite* 2>/dev/null || true
rm -rf tmp/ 2>/dev/null || true
# =================================================================

# 6. Config-Datei ermitteln und kopieren
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

# 7. Target-Konfiguration für GL-MT5000 bereinigen und erzwingen
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

# 8. Vollständige Netzwerkkonfiguration im globalen files/-Ordner hinterlegen
# (WICHTIG: Ausserhalb des Quellverzeichnisses, damit es korrekt ins Image gebacken wird)
cd ..
echo "===> Konfiguriere vollständiges Netzwerk im globalen files/-Ordner..."
mkdir -p files/etc/config
cat << 'EOF' > files/etc/config/network
config interface 'loopback'
	option device 'lo'
	option proto 'static'
	list ipaddr '127.0.0.1/8'

config globals 'globals'
	option dhcp_default_duid '0004f31c8204880e56098d4a3884ce4ecbf2'
	option ula_prefix 'fdc4:8d08:2f12::/48'

config device
	option name 'br-lan'
	option type 'bridge'
	list ports 'lan1'
	list ports 'lan2'

config interface 'lan'
	option device 'br-lan'
	option proto 'static'
	option ip6assign '64'
	list ipaddr '192.168.178.4/24'
	option ip6hint '1'

config interface 'wan'
	option device 'eth1.7'
	option proto 'pppoe'
	option username 'vodafone-vdsl.komplett/vb3986354996'
	option password 'geqclvmq'
	option norelease '1'
	option mtu '1492'
	option peerdns '0'
	list dns '1.1.1.1'
	list dns '8.8.8.8'
	option ip6assign '64'
	list ip6class 'WAN_6'

config interface 'Modem'
	option proto 'static'
	option device 'eth1'
	option ipaddr '192.168.1.2'
	option netmask '255.255.255.0'

config interface 'wg0'
	option proto 'wireguard'
	option private_key 'YNjZSoBKWk5MrWu1BSOmC/mb6dNM9EcCpic4dSQgDFI='
	option listen_port '51820'
	list addresses '10.9.0.1/24'
	option mtu '1412'

config wireguard_wg0
	option public_key 'vGZl57B6NQdAz3PrNVTkZxczoEsJKYnFngmN2B51DSA='
	list allowed_ips '10.9.0.2/32'
	option route_allowed_ips '1'

config device
	option name 'wg0'
	option mtu6 '1412'
	option mtu '1412'

config device
	option name 'eth1.7'
	option type '8021q'
	option ifname 'eth1'
	option vid '7'
	option mtu '1500'
	option mtu6 '1500'

config device
	option name 'lan1'
	option mtu '1504'
EOF

# Zurück ins Quellverzeichnis für make defconfig
cd "$OPENWRT_DIR"

# 9. Sauberen, non-interaktiven Konfigurationsabgleich durchführen
echo "===> Running clean non-interactive config sync..."

export TERM=dumb
export DEBIAN_FRONTEND=noninteractive

make defconfig

# 10. Kontrolle
echo "===> Verifiziere aktives Device in .config:"
grep "gl-mt5000" .config || echo "ACHTUNG: gl-mt5000 wurde in .config nicht gefunden!"

# Zurück ins Root-Verzeichnis wechseln
cd ..

echo "===> Preparation completed successfully."
