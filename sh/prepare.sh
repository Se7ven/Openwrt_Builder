#!/bin/bash
# =================================================================
# Prepare Script - Universal with exact 4-folder separation, patch protection & cleanup
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"
echo "===> Running preparation for repository: $SDK_REPO (Branch-Type: $SDK_BRANCH_TYPE)"

# Exact directory assignment matching the clone script and workflow
if [ "$SDK_REPO" = "immortalwrt" ] && [ "$SDK_BRANCH_TYPE" = "main" ]; then
    OPENWRT_DIR="immortalwrt_master"
else
    OPENWRT_DIR="${SDK_REPO}_${SDK_BRANCH_TYPE}"
fi

# Fallback check in case the directory has a different name
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
        echo "===> ERROR: No matching target directory found for $SDK_REPO ($SDK_BRANCH_TYPE)!"
        exit 1
    fi
fi

echo "===> Using source directory: $OPENWRT_DIR"
cd "$OPENWRT_DIR"

# =================================================================
# 1. Apply MT5000 patches with protection against multiple execution
# =================================================================
echo "===> Checking and applying MT5000 patches..."

if [ "$SDK_BRANCH_TYPE" = "stable" ] || [[ "$SDK_BRANCH_TYPE" =~ 25\.12 ]]; then
    PATCH_DIR="../patches-25.12"
    echo "Using patch directory for Stable/25.12 (Kernel 6.12): $PATCH_DIR"
else
    PATCH_DIR="../patches"
    echo "Using patch directory for Master/Main (Kernel 6.18): $PATCH_DIR"
fi

# Safety check: If the MT5000 DTS already exists, the patches have already been applied
if [ -f "target/linux/mediatek/dts/mt7987a-gl-mt5000.dts" ]; then
    echo "===> NOTE: MT5000 patches have already been applied in this directory. Skipping patch pass."
else
    if [ -d "$PATCH_DIR" ]; then
        for patch in "$PATCH_DIR"/*.patch; do
            [ -e "$patch" ] || continue
            echo "Applying patch: $(basename "$patch")"
            
            # Try with git apply (-3) first, fall back to patch with --fuzz=3 if it fails
            git apply -3 "$patch" || patch -p1 --fuzz=3 < "$patch" || {
                echo "ERROR: Patch $(basename "$patch") could not be applied!"
                exit 1
            }
        done
        echo "===> All MT5000 patches successfully applied."
    else
        echo "===> WARNING: Patch directory '$PATCH_DIR' not found in main directory!"
    fi
fi

# Regardless: always completely remove the 795-12 nuisance package, if present
echo "===> Cleaning up incompatible kernel patch 795-12 permanently..."
rm -f target/linux/generic/pending-6.18/795-12-net-mediatek-init-dummy-napi-before-netdev-registration.patch
rm -f target/linux/generic/pending-6.12/795-12-net-mediatek-init-dummy-napi-before-netdev-registration.patch
# =================================================================

# 2. Inject filologie.mk (if available)
if [ -f "../board/target/linux/mediatek/image/filogic.mk" ]; then
    echo "===> Injecting custom filogic.mk for GL-MT5000 definition..."
    mkdir -p "target/linux/mediatek/image"
    cp -f ../board/target/linux/mediatek/image/filogic.mk "target/linux/mediatek/image/"
fi

# 2b. Inject mt7987a-gl-mt5000.dts into all relevant paths so relative compiler include paths resolve
if [ -f "../board/target/linux/mediatek/dts/mt7987a-gl-mt5000.dts" ]; then
    echo "===> Injecting custom mt7987a-gl-mt5000.dts into all required paths..."
    
    # Standard path in the kernel DTS tree
    mkdir -p "target/linux/mediatek/dts"
    cp -f ../board/target/linux/mediatek/dts/mt7987a-gl-mt5000.dts "target/linux/mediatek/dts/"
    
    # Additionally in the image folder as dts/, so that ../dts/ resolves
    mkdir -p "target/linux/mediatek/image/dts"
    cp -f ../board/target/linux/mediatek/dts/mt7987a-gl-mt5000.dts "target/linux/mediatek/image/dts/"
fi

# 3. Include custom packages directory (Including Footstrap Theme) & clean up conflicts
CUSTOM_DIR="package/custom"
echo "===> Prepare custom packages directory: $CUSTOM_DIR"
rm -rf "$CUSTOM_DIR"
mkdir -p "$CUSTOM_DIR"

# Download Footstrap Theme so it resides directly in the custom directory
echo "===> Cloning luci-theme-footstrap..."
git clone --depth 1 https://github.com/VizzleTF/luci-theme-footstrap.git "$CUSTOM_DIR/luci-theme-footstrap"

CONFLICTING_KEYWORDS=("weechat" "squeezelite" "qt5" "openvswitch")
for keyword in "${CONFLICTING_KEYWORDS[@]}"; do
    find . -type f -name "Makefile" ! -path "$CUSTOM_DIR/*" -print0 | while IFS= read -r -d $'\0' file; do
        if [[ "${file,,}" == *"$keyword"* ]]; then
            rm -f "$file"
        fi
    done
done
rm -rf tmp/.config-package.in 2>/dev/null || true

# 4. Update and install feeds
echo "===> Updating and installing feeds..."
./scripts/feeds update -a && ./scripts/feeds install -a
if [ $? -ne 0 ]; then
    echo "===> ERROR while updating/installing feeds!"
    exit 1
fi

# 5. Radically delete problematic Kconfig packages after feed install
echo "===> Deleting recursive dependency packages completely..."
rm -rf feeds/video/frameworks/qt5 2>/dev/null || true
rm -rf feeds/packages/sound/squeezelite* 2>/dev/null || true
rm -rf feeds/luci/applications/luci-app-weechat 2>/dev/null || true
rm -rf feeds/packages/utils/weechat 2>/dev/null || true
rm -rf package/feeds/*/qt5 2>/dev/null || true
rm -rf package/feeds/*/weechat 2>/dev/null || true
rm -rf package/feeds/*/squeezelite* 2>/dev/null || true
rm -rf tmp/ 2>/dev/null || true

# 6. Determine and copy config file
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
    echo "===> WARNING: No matching config file found! Creating empty .config"
    touch .config
fi

# 7. Sanitize, force GL-MT5000 target configuration in .config & enable Footstrap
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
CONFIG_PACKAGE_luci-theme-footstrap=y
EOF

# 8. Store network configuration for GL-MT5000 & set Footstrap as default theme
echo "===> Configure network, base & Footstrap Theme for GL-MT5000..."
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

# Set Footstrap UCI defaults
mkdir -p package/base-files/files/etc/uci-defaults/
cat << 'EOF' > package/base-files/files/etc/uci-defaults/99-default-theme-footstrap
uci set luci.main.mediaurlbase='/luci-static/footstrap'
uci commit luci
exit 0
EOF
chmod +x package/base-files/files/etc/uci-defaults/99-default-theme-footstrap

# 9. Configuration sync
echo "===> Running clean non-interactive config sync..."
export TERM=dumb
export DEBIAN_FRONTEND=noninteractive
make defconfig

echo "===> Verifying active device in .config:"
grep "gl-mt5000" .config || echo "WARNING: gl-mt5000 was not found in .config!"

cd ..
echo "===> Preparation completed successfully."
