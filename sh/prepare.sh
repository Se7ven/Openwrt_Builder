#!/bin/bash
# =================================================================
# Prepare Script - Universell mit exakter 4-Ordner-Trennung, Patch-Schutz & Bereinigung
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"
echo "===> Running preparation for repository: $SDK_REPO (Branch-Type: $SDK_BRANCH_TYPE)"

# Exakte Ordner-Zuordnung passend zum Clone-Script und Workflow
if [ "$SDK_REPO" = "immortalwrt" ] && [ "$SDK_BRANCH_TYPE" = "main" ]; then
    OPENWRT_DIR="immortalwrt_master"
else
    OPENWRT_DIR="${SDK_REPO}_${SDK_BRANCH_TYPE}"
fi

# Fallback-Prüfung, falls das Verzeichnis anders heißen sollte
if [ ! -d "$OPENWRT_DIR" ]; then
    if [ -d "immortalwrt_master" ]; then
        OPENWRT_DIR="immortalwrt_master"
    elif [ -d "immortalwrt_stable" ]; then
        OPENWRT_DIR="immortalwrt_stable"
    elif [ -d "openwrt_main" ]; then
        OPENWRT_DIR="openwrt_main"
    elif [ -d "openwrt_stable" ]; then
        OPENWRT_DIR="openwrt_stable"
    else
        echo "===> FEHLER: Kein passendes Zielverzeichnis für $SDK_REPO ($SDK_BRANCH_TYPE) gefunden!"
        exit 1
    fi
fi

echo "===> Verwende Quellverzeichnis: $OPENWRT_DIR"
cd "$OPENWRT_DIR"

# =================================================================
# 1. MT5000 Patches mit Schutz vor Mehrfach-Ausführung anwenden
# =================================================================
echo "===> Prüfe und wende MT5000-Patches an..."

if [ "$SDK_BRANCH_TYPE" = "stable" ] || [[ "$SDK_BRANCH_TYPE" =~ 25\.12 ]]; then
    PATCH_DIR="../patches-25.12"
    echo "Verwende Patch-Ordner für Stable/25.12 (Kernel 6.12): $PATCH_DIR"
else
    PATCH_DIR="../patches"
    echo "Verwende Patch-Ordner für Master/Main (Kernel 6.18): $PATCH_DIR"
fi

# Schutzprüfung: Wenn die MT5000 DTS bereits existiert, wurden die Patches schon angewendet
if [ -f "target/linux/mediatek/dts/mt7987a-gl-mt5000.dts" ]; then
    echo "===> HINWEIS: MT5000 Patches wurden in diesem Verzeichnis bereits angewendet. Überspringe Patch-Durchlauf."
else
    if [ -d "$PATCH_DIR" ]; then
        for patch in "$PATCH_DIR"/*.patch; do
            [ -e "$patch" ] || continue
            echo "Wende Patch an: $(basename "$patch")"
            
            # Versucht es zuerst mit git apply (-3), und weicht bei Versatz auf patch mit --fuzz=3 aus
            git apply -3 "$patch" || patch -p1 --fuzz=3 < "$patch" || {
                echo "FEHLER: Patch $(basename "$patch") konnte nicht angewendet werden!"
                exit 1
            }
        done
        echo "===> Alle MT5000-Patches erfolgreich angewendet."
    else
        echo "===> WARNUNG: Patch-Ordner '$PATCH_DIR' nicht im Hauptverzeichnis gefunden!"
    fi
fi

# Unabhängig davon: 795-12 Störenfried immer restlos entfernen, falls er aufgetaucht ist
echo "===> Räume inkompatiblen Kernel-Patch 795-12 endgültig auf..."
rm -f target/linux/generic/pending-6.18/795-12-net-mediatek-init-dummy-napi-before-netdev-registration.patch
rm -f target/linux/generic/pending-6.12/795-12-net-mediatek-init-dummy-napi-before-netdev-registration.patch
# =================================================================

# 2. filogic.mk injizieren (falls vorhanden)
if [ -f "../board/target/linux/mediatek/image/filogic.mk" ]; then
    echo "===> Injecting custom filogic.mk for GL-MT5000 definition..."
    mkdir -p "target/linux/mediatek/image"
    cp -f ../board/target/linux/mediatek/image/filogic.mk "target/linux/mediatek/image/"
fi

# 2b. mt7987a-gl-mt5000.dts direkt aus dem board-Ordner injizieren[cite: 1]
if [ -f "../board/target/linux/mediatek/dts/mt7987a-gl-mt5000.dts" ]; then
    echo "===> Injecting custom mt7987a-gl-mt5000.dts for GL-MT5000..."[cite: 1]
    mkdir -p "target/linux/mediatek/dts"
    cp -f ../board/target/linux/mediatek/dts/mt7987a-gl-mt5000.dts "target/linux/mediatek/dts/"[cite: 1]
fi

# 3. CUSTOM PACKAGES ORDNER EINBINDEN & KONFLIKTE BEREINIGEN
CUSTOM_DIR="package/custom"
echo "===> Prepare custom packages directory: $CUSTOM_DIR"
rm -rf "$CUSTOM_DIR"
mkdir -p "$CUSTOM_DIR"

CONFLICTING_KEYWORDS=("weechat" "squeezelite" "qt5" "openvswitch")
for keyword in "${CONFLICTING_KEYWORDS[@]}"; do
    find . -type f -name "Makefile" ! -path "$CUSTOM_DIR/*" -print0 | while IFS= read -r -d $'\0' file; do
        if [[ "${file,,}" == *"$keyword"* ]]; then
            rm -f "$file"
        fi
    done
done
rm -rf tmp/.config-package.in 2>/dev/null || true

# 4. Feeds aktualisieren und installieren
echo "===> Updating and installing feeds..."
./scripts/feeds update -a && ./scripts/feeds install -a
if [ $? -ne 0 ]; then
    echo "===> FEHLER beim Aktualisieren/Installieren der Feeds!"
    exit 1
fi

# 5. Radikales Löschen der Kconfig-Störenfriede nach Feed-Install
echo "===> Deleting recursive dependency packages completely..."
rm -rf feeds/video/frameworks/qt5 2>/dev/null || true
rm -rf feeds/packages/sound/squeezelite* 2>/dev/null || true
rm -rf feeds/luci/applications/luci-app-weechat 2>/dev/null || true
rm -rf feeds/packages/utils/weechat 2>/dev/null || true
rm -rf package/feeds/*/qt5 2>/dev/null || true
rm -rf package/feeds/*/weechat 2>/dev/null || true
rm -rf package/feeds/*/squeezelite* 2>/dev/null || true
rm -rf tmp/ 2>/dev/null || true

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
    elif [ -f "../config/mt500.config" ]; then
        CONFIG_FILE="../config/mt500.config"
    elif [ -f "../mt500.config" ]; then
        CONFIG_FILE="../mt500.config"
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

# 8. Netzwerkkonfiguration für GL-MT5000 hinterlegen (LAN 192.168.100.1 / WAN eth1 192.168.10.1)
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
	option proto 'static'
	option ipaddr '192.168.10.1'
	option netmask '255.255.255.0'
EOF

# 9. Konfigurationsabgleich
echo "===> Running clean non-interactive config sync..."
export TERM=dumb
export DEBIAN_FRONTEND=noninteractive
make defconfig

echo "===> Verifiziere aktives Device in .config:"
grep "gl-mt5000" .config || echo "ACHTUNG: gl-mt5000 wurde in .config nicht gefunden!"

cd ..
echo "===> Preparation completed successfully."
