#!/bin/bash
#
# Dateiname: scripts-part2.sh
# Beschreibung: OpenWrt DIY Skript Teil 2
#

TARGET_DIR="${PWD}/package/custom"

declare -A REPOS=(
    ["https://github.com/sbwml/luci-app-mosdns"]=""
    ["https://github.com/chenmozhijin/turboacc"]=""
    ["https://github.com/gdy666/luci-app-lucky"]=""
    ["https://github.com/m0eak/fancontrol"]=""
    ["https://github.com/animegasan/luci-app-wolplus"]=""
    ["https://github.com/0x676e67/luci-theme-design"]="js"
    ["https://github.com/0x676e67/luci-app-design-config.git"]=""
    ["https://github.com/nikkinikki-org/OpenWrt-nikki"]=""
    ["https://github.com/sirpdboy/luci-app-partexp"]=""
    ["https://github.com/pymumu/luci-app-smartdns"]=""
    ["https://github.com/pymumu/smartdns"]=""
    ["https://github.com/sbwml/v2ray-geodata"]=""
    ["https://github.com/vernesong/OpenClash.git"]=""
    ["https://github.com/eamonxg/luci-theme-aurora"]=""
    ["https://github.com/eamonxg/luci-theme-shadcn.git"]=""
    ["https://github.com/eamonxg/luci-app-aurora-config"]=""
    ["https://github.com/NONGFAH/luci-app-athena-led.git"]=""
    ["https://github.com/Tokisaki-Galaxy/luci-app-tailscale-community.git"]=""
    ["https://github.com/m0eak/openwrt-gecoosac.git"]=""
    ["https://github.com/miaoermua/luci-app-leigod-acc.git"]=""
    ["https://github.com/EasyTier/luci-app-easytier"]="v2.6.4"
    ["https://github.com/Openwrt-Passwall/openwrt-passwall2"]=""
    ["https://github.com/Openwrt-Passwall/openwrt-passwall"]=""
    ["https://github.com/Openwrt-Passwall/openwrt-passwall-packages"]=""
    ["https://github.com/10000ge10000/luci-app-openclaw"]=""
    ["https://github.com/Slava-Shchipunov/awg-openwrt"]=""
    ["https://github.com/QiuSimons/luci-app-daed"]=""
    ["https://github.com/sirpdboy/luci-app-ddns-go.git"]=""
    ["https://github.com/gaoderby/luci-app-kms.git"]=""
    ["https://github.com/sbwml/luci-app-ramfree.git"]=""
    ["https://github.com/lisaac/luci-app-diskman"]=""
    ["https://github.com/tty228/luci-app-wechatpush.git"]=""
)

CONFLICTING_MAKEFILE_KEYWORDS=(
    "mosdns"
    "openclash"
    "luci-app-lucky"
    "smartdns"
    "v2ray-geodata"
    "xray-core"
    "daed"
    "ddns-go"
)

patch_rust_makefile() {
    if [ -e "feeds/packages/lang/rust/Makefile" ]; then
        sed -i 's/--set=llvm\.download-ci-llvm=true/--set=llvm.download-ci-llvm=false/' feeds/packages/lang/rust/Makefile
    fi
}

reset_custom_package_dir() {
    [ -n "$TARGET_DIR" ] && [ "$TARGET_DIR" != "/" ] && rm -rf "$TARGET_DIR" && mkdir -p "$TARGET_DIR"
}

remove_conflicting_makefiles() {
    find . -type f -name "Makefile" ! -path "$TARGET_DIR/*" -print0 | while IFS= read -r -d $'\0' file; do
        file_lower="${file,,}"
        for keyword in "${CONFLICTING_MAKEFILE_KEYWORDS[@]}"; do
            if [[ "$file_lower" == *"$keyword"* ]]; then
                rm -f "$file"
                break
            fi
        done
    done
}

clone_repo() {
    local repo_url="$1"
    local repo_branch="${REPOS[$repo_url]}"
    local repo_name="$(basename -s .git "$repo_url")"
    local repo_dir="$TARGET_DIR/$repo_name"

    [ -d "$repo_dir" ] && return 0
    if [ -z "$repo_branch" ]; then
        git clone --single-branch --depth 1 "$repo_url" "$repo_dir"
    else
        git clone --single-branch --depth 1 -b "$repo_branch" "$repo_url" "$repo_dir"
    fi
}

clone_custom_repos() {
    for repo in "${!REPOS[@]}"; do
        clone_repo "$repo"
    done
}

echo "--- DIY Part 2: Skriptausführung gestartet ---"
echo "WORKFLOW_NAME: $WORKFLOW_NAME"

# 1. ZUERST ALLE PAKETE LADEN UND ABHÄNGIGKEITEN KLÄREN
patch_rust_makefile
reset_custom_package_dir
remove_conflicting_makefiles
clone_custom_repos

# Kollidierende Standard-Pakete entfernen
rm -rf feeds/packages/net/openvswitch package/feeds/packages/openvswitch 2>/dev/null || true
rm -rf package/feeds/packages/net/weechat feeds/packages/net/weechat package/custom/luci-app-wechatpush 2>/dev/null || true

# 2. MT5000 SPEZIFISCHE KONFIGURATIONEN & BRANDING
if [[ "${WORKFLOW_NAME,,}" == *"mt5000"* || "${WORKFLOW_NAME,,}" == *"brume 3"* ]]; then
    echo ">>> Konfiguriere Netzwerk & Basis für GL-MT5000 <<<"

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

    mkdir -p package/base-files/files/etc/uci-defaults/
    cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-default-theme-footstrap
uci set luci.main.mediaurlbase='/luci-static/footstrap'
uci commit luci
exit 0
EOF
    chmod +x package/base-files/files/etc/uci-defaults/99-default-theme-footstrap

    # --- BRANDING NUR FÜR IMMORTALWRT WORKFLOWS ---
    if [[ "${WORKFLOW_NAME,,}" == *"immortalwrt"* || "${WORKFLOW_NAME,,}" == *"immortal"* ]]; then
        echo ">>> Setze ImmortalWrt Identität & Banner <<<"
        
        cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-set-hostname
uci set system.@system[0].hostname='ImmortalWrt'
uci commit system
exit 0
EOF
        chmod +x package/base-files/files/etc/uci-defaults/99-set-hostname

        sed -i 's/VERSION_DIST:=OpenWrt/VERSION_DIST:=ImmortalWrt/g' include/version.mk 2>/dev/null || true
        
        cat << 'EOF' > package/base-files/files/etc/banner
 _____                                _         _  __          __      _   
|_   _|                              | |       | | \ \        / /     | |  
  | |  _ __ ___  _ __ ___   ___  _ __| |_  __ _| |  \ \  /\  / /_ __  | |_ 
  | | | '_ ` _ \| '_ ` _ \ / _ \| '__| __|/ _` | |   \ \/  \/ /| '__| | __|
 _| |_| | | | | | | | | | | (_) | |  | |_| (_| | |    \  /\  / | |    | |_ 
|_____|_| |_| |_|_| |_| |_|\___/|_|   \__|\__,_|_|     \/  \/  |_|     \__|
 --------------------------------------------------------------------------
 ImmortalWrt GL-MT5000 (Brume 3)
 --------------------------------------------------------------------------
EOF
    fi
fi

echo "--- DIY Part 2: Skriptausführung beendet ---"
