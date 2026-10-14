#!/bin/bash
# =================================================================
# Finalize Script - Firmware Renaming (Erkennt .bin und .itb)
# =================================================================

cd openwrt/bin/targets/mediatek/filogic/ || exit 1

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"
DATE=$(date +'%Y%m%d')

PREFIX="${SDK_REPO}-${SDK_BRANCH_TYPE}-${DATE}"
echo "===> Renaming firmware images with prefix: $PREFIX"

# 1. Sysupgrade-Image umbenennen (egal ob .bin oder .itb)
for f in *sysupgrade*; do
    if [ -f "$f" ]; then
        # Ermittle Dateiendung (.bin oder .itb)
        EXT="${f##*.}"
        TARGET_NAME="${PREFIX}-gl-mt5000-sysupgrade.${EXT}"
        
        # Nur umbenennen, wenn der Name nicht schon passt
        if [ "$f" != "$TARGET_NAME" ]; then
            mv "$f" "$TARGET_NAME"
            echo "Renamed: $f -> $TARGET_NAME"
        fi
    fi
done

# 2. Factory-Image umbenennen (falls vorhanden)
for f in *factory*; do
    if [ -f "$f" ]; then
        EXT="${f##*.}"
        TARGET_NAME="${PREFIX}-gl-mt5000-factory.${EXT}"
        
        if [ "$f" != "$TARGET_NAME" ]; then
            mv "$f" "$TARGET_NAME"
            echo "Renamed: $f -> $TARGET_NAME"
        fi
    fi
done

echo "===> Finalize completed successfully."
ls -la *-gl-mt5000-*
