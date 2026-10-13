#!/bin/bash
# =================================================================
# Finalize Script - Firmware Renaming
# =================================================================

cd openwrt/bin/targets/mediatek/filogic/ || exit 1

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"
DATE=$(date +'%Y%m%d')

PREFIX="${SDK_REPO}-${SDK_BRANCH_TYPE}-${DATE}"
echo "===> Renaming firmware images with prefix: $PREFIX"

# Sysupgrade-Image umbenennen
for f in *sysupgrade.itb; do
    if [ -f "$f" ]; then
        mv "$f" "${PREFIX}-gl-mt5000-sysupgrade.itb"
        echo "Renamed: $f -> ${PREFIX}-gl-mt5000-sysupgrade.itb"
    fi
done

# Factory-Image umbenennen (falls vorhanden)
for f in *-factory.bin; do
    if [ -f "$f" ]; then
        mv "$f" "${PREFIX}-gl-mt5000-factory.bin"
        echo "Renamed: $f -> ${PREFIX}-gl-mt5000-factory.bin"
    fi
done

echo "===> Finalize completed successfully."
