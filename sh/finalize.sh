#!/bin/bash
# =================================================================
# Finalize Script - Firmware Renaming (Erkennt .bin und .itb)
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"

# Exakte Ordner-Zuordnung passend zum Workflow
if [ "$SDK_REPO" = "immortalwrt" ] && [ "$SDK_BRANCH_TYPE" = "main" ]; then
    TARGET_DIR="immortalwrt_master"
else
    TARGET_DIR="${SDK_REPO}_${SDK_BRANCH_TYPE}"
fi

# Fallback-Prüfung
if [ ! -d "$TARGET_DIR" ]; then
    if [ -d "immortalwrt_master" ]; then
        TARGET_DIR="immortalwrt_master"
    elif [ -d "immortalwrt_stable" ]; then
        TARGET_DIR="immortalwrt_stable"
    elif [ -d "openwrt_main" ]; then
        TARGET_DIR="openwrt_main"
    elif [ -d "openwrt_stable" ]; then
        TARGET_DIR="openwrt_stable"
    else
        echo "===> FEHLER: Kein passendes Firmware-Verzeichnis für $SDK_REPO ($SDK_BRANCH_TYPE) gefunden!"
        exit 1
    fi
fi

IMAGE_DIR="${TARGET_DIR}/bin/targets/mediatek/filogic"

echo "===> Wechsle in das Firmware-Verzeichnis: $IMAGE_DIR"
cd "$IMAGE_DIR" || {
    echo "===> FEHLER: Konnte nicht in das Verzeichnis $IMAGE_DIR wechseln!"
    exit 1
}

DATE=$(date +'%Y%m%d')
PREFIX="${SDK_REPO}-${SDK_BRANCH_TYPE}-${DATE}"
echo "===> Renaming firmware images with prefix: $PREFIX"

for f in *sysupgrade*; do
    if [ -f "$f" ]; then
        EXT="${f##*.}"
        TARGET_NAME="${PREFIX}-gl-mt5000-sysupgrade.${EXT}"
        
        if [ "$f" != "$TARGET_NAME" ]; then
            mv "$f" "$TARGET_NAME"
            echo "Renamed: $f -> $TARGET_NAME"
        fi
    fi
done

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
