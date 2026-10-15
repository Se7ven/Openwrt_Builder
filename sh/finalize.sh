#!/bin/bash
# =================================================================
# Finalize Script - Firmware Renaming (Erkennt .bin und .itb)
# Universell angepasst für Matrix-Builds und Patch-Builder
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"

# 1. Versuche den Ordner über WORKFLOW_NAME oder Matrix-Variablen zu finden
TARGET_DIR=""
if [ -n "$WORKFLOW_NAME" ] && [ -d "$WORKFLOW_NAME" ]; then
    TARGET_DIR="$WORKFLOW_NAME"
elif [ -n "$SDK_REPO" ] && [ -n "$SDK_BRANCH_TYPE" ]; then
    if [ "$SDK_REPO" = "immortalwrt" ] && [ "$SDK_BRANCH_TYPE" = "main" ]; then
        POSSIBLE_DIR="immortalwrt_master"
    else
        POSSIBLE_DIR="${SDK_REPO}_${SDK_BRANCH_TYPE}"
    fi
    [ -d "$POSSIBLE_DIR" ] && TARGET_DIR="$POSSIBLE_DIR"
fi

# 2. Falls immer noch nicht gefunden, automatisches Fallback durch bekannte Ordner
if [ -z "$TARGET_DIR" ]; then
    for dir in immortalwrt_master immortalwrt_stable openwrt_main openwrt_stable openwrt immortalwrt; do
        if [ -d "$dir" ]; then
            TARGET_DIR="$dir"
            break
        fi
    done
fi

# 3. Wenn ein Verzeichnis mit bin/targets direkt im Root existiert
if [ -z "$TARGET_DIR" ] && [ -d "bin/targets/mediatek/filogic" ]; then
    IMAGE_DIR="bin/targets/mediatek/filogic"
elif [ -n "$TARGET_DIR" ] && [ -d "${TARGET_DIR}/bin/targets/mediatek/filogic" ]; then
    IMAGE_DIR="${TARGET_DIR}/bin/targets/mediatek/filogic"
else
    # Letzte Rettung: Suche dynamisch nach dem Pfad im Workspace
    FOUND_PATH=$(find . -maxdepth 4 -type d -path "*/bin/targets/mediatek/filogic" | head -n 1)
    if [ -n "$FOUND_PATH" ]; then
        IMAGE_DIR="$FOUND_PATH"
    else
        echo "===> FEHLER: Konnte kein gültiges Firmware-Verzeichnis (bin/targets/mediatek/filogic) finden!"
        exit 1
    fi
fi

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
ls -la *-gl-mt5000-* 2>/dev/null || ls -la
