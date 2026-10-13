#!/bin/bash
# =================================================================
# Custom Part 2.1 Script with Branch-Aware Patch Injection
# =================================================================

TARGET_BRANCH="${BUILD_BRANCH:-openwrt-25.12}"
echo "===> Running Part 2.1 script for branch: $TARGET_BRANCH"

# 1. DTS-Injektion (wird für beide Branches benötigt)
CUSTOM_BOARD_DIR="../board/target" # Passe den Pfad an, falls er bei dir anders liegt (oder custom_files)
if [ -d "custom_files/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    cp -rf custom_files/target/linux/mediatek/dts/* target/linux/mediatek/dts/
fi

# 2. Bedingte Patch-Anwendung (nur für den stabilen 25.12 / Kernel 6.12 Zweig)
if [ "$TARGET_BRANCH" = "openwrt-25.12" ]; then
    echo "===> Branch is openwrt-25.12: Applying custom kernel patches..."
    
    # Beispiel für das Anwenden von Patches (Passe den Pfad an, je nachdem wo deine Patches liegen)
    if [ -d "custom_files/patches" ]; then
        for patch in custom_files/patches/*.patch; do
            [ -f "$patch" ] && patch -p1 < "$patch"
        done
    fi
else
    echo "===> Branch is '$TARGET_BRANCH' (Mainstream/Newer Kernel): Skipping legacy kernel patches, using native drivers + custom DTS."
fi

echo "===> Part 2.1 script completed successfully."
