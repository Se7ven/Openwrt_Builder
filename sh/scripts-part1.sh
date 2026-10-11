#!/bin/bash
#
# Dateiname: scripts-part1.sh
# Beschreibung: OpenWrt DIY Skript Teil 1
#

echo "--- DIY Part 1: Skriptausführung gestartet ---"
echo "WORKFLOW_NAME: $WORKFLOW_NAME"
echo "------------------------------------------"

set_default_ip() {
    local ip="$1"
    local label="$2"
    sed -i "s/192.168.1.1/$ip/g" package/base-files/files/bin/config_generate
    echo "$label: Standard-IP geändert auf $ip"
}

# --- Andere Zielgeräte ---
if [[ "$WORKFLOW_NAME" == "AXT-1800" || "$WORKFLOW_NAME" == "JDC-AX6600" ]]; then
    if [[ "$WORKFLOW_NAME" == "AXT-1800" ]]; then
        set_default_ip "192.168.8.1" "AXT-1800"
    elif [[ "$WORKFLOW_NAME" == "JDC-AX6600" ]]; then
        set_default_ip "192.168.100.1" "JDC-AX6600"
    fi
    wget -q https://raw.githubusercontent.com/m0eak/openwrt_patch/refs/heads/main/gl-axt1800/9999-gl-axt1800-dts-change-cooling-level.patch -O target/linux/qualcommax/patches-6.12/9999-gl-axt1800-dts-change-cooling-level.patch || true
    rm -f package/kernel/mac80211/patches/nss/ath11k/999-902-ath11k-fix-WDS-by-disabling-nwds.patch
    rm -f package/kernel/mac80211/patches/nss/subsys/999-775-wifi-mac80211-Changes-for-WDS-MLD.patch

elif [[ "$WORKFLOW_NAME" == "x86_immortalwrt" ]]; then
    set_default_ip "192.168.100.1" "x86"

elif [[ "$WORKFLOW_NAME" == "GL-MT3600BE" ]]; then
    CUSTOM_DTS_URL="https://raw.githubusercontent.com/openwrt/openwrt/cced8d95f3caa9f48eaeb4ef2d15426d20afaf16/target/linux/mediatek/dts/mt7987a-glinet-gl-mt3600be.dts"
    CUSTOM_DTS_TARGET="target/linux/mediatek/dts/mt7987a-glinet-gl-mt3600be.dts"
    curl -fL "$CUSTOM_DTS_URL" -o "$CUSTOM_DTS_TARGET" 2>/dev/null || true
    set_default_ip "192.168.9.1" "mt3600be"

# --- Alle MT5000 Workflows ---
elif [[ "$WORKFLOW_NAME" == "GL-MT5000" || "$WORKFLOW_NAME" == "gl-mt5000_immortalwrt" || "$WORKFLOW_NAME" == "Immortalwrt Brume 3 stable" || "$WORKFLOW_NAME" == "OpenWrt Brume 3 stable" ]]; then
    echo ">>> Nativer GL.iNet MT5000 Quellbaum aktiv: Treiber bereits nativ vorhanden <<<"
    set_default_ip "192.168.100.1" "$WORKFLOW_NAME"
fi

echo "--- DIY Part 1: Skriptausführung beendet ---"
