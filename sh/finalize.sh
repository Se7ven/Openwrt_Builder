#!/bin/bash
# =================================================================
# Finalize Script - Universal renaming of all firmware artifacts
# =================================================================

echo "--- Finalize: Starting firmware artifact renaming ---"

# Use passed argument (directory), otherwise fall back to current directory or workspace
TARGET_BASE="${1:-.}"

IMAGE_DIR=""

# Systematically try possible paths, regardless of which workflow called the script
if [ -d "$TARGET_BASE/bin/targets/mediatek/filogic" ]; then
    IMAGE_DIR="$TARGET_BASE/bin/targets/mediatek/filogic"
elif [ -d "bin/targets/mediatek/filogic" ]; then
    IMAGE_DIR="bin/targets/mediatek/filogic"
else
    # Automatic deep search for the target directory (covers /workdir/ and subdirectories)
    FOUND_PATH=$(find . "$TARGET_BASE" /workdir -maxdepth 5 -type d -path "*/bin/targets/mediatek/filogic" 2>/dev/null | head -n 1)
    if [ -n "$FOUND_PATH" ]; then
        IMAGE_DIR="$FOUND_PATH"
    else
        echo "===> ERROR: Could not find a valid firmware directory (bin/targets/mediatek/filogic)!"
        exit 1
    fi
fi

echo "===> Switching to firmware directory: $IMAGE_DIR"
cd "$IMAGE_DIR" || {
    echo "===> ERROR: Could not switch to directory $IMAGE_DIR!"
    exit 1
}

# 2. Generate prefix from environment (matrix tag_prefix) or fallback
DATE=$(date +'%Y%m%d')
if [ -n "$TAG_PREFIX" ]; then
    PREFIX="${TAG_PREFIX}-${DATE}"
else
    PREFIX="gl-mt5000-${DATE}"
fi

echo "===> Using file prefix: $PREFIX"

# 3. Rename sysupgrade
for f in *sysupgrade*; do
    if [ -f "$f" ]; then
        EXT="${f##*.}"
        TARGET_NAME="${PREFIX}-gl-mt5000-sysupgrade.${EXT}"
        [ "$f" != "$TARGET_NAME" ] && mv "$f" "$TARGET_NAME" && echo "Renamed: $f -> $TARGET_NAME"
    fi
done

# 4. Rename factory
for f in *factory*; do
    if [ -f "$f" ]; then
        EXT="${f##*.}"
        TARGET_NAME="${PREFIX}-gl-mt5000-factory.${EXT}"
        [ "$f" != "$TARGET_NAME" ] && mv "$f" "$TARGET_NAME" && echo "Renamed: $f -> $TARGET_NAME"
    fi
done

# 5. Rename manifest
for f in *.manifest; do
    if [ -f "$f" ]; then
        TARGET_NAME="${PREFIX}-gl-mt5000.manifest"
        [ "$f" != "$TARGET_NAME" ] && mv "$f" "$TARGET_NAME" && echo "Renamed: $f -> $TARGET_NAME"
    fi
done

# 6. Rename sha256sums
for f in sha256sums; do
    if [ -f "$f" ]; then
        TARGET_NAME="${PREFIX}-sha256sums"
        [ "$f" != "$TARGET_NAME" ] && mv "$f" "$TARGET_NAME" && echo "Renamed: $f -> $TARGET_NAME"
    fi
done

echo "===> Finalize completed successfully."
ls -la
