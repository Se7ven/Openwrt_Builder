#!/bin/bash
# =================================================================
# Custom Part 2.1 Script with Branch-Aware Patch Injection
# =================================================================

TARGET_BRANCH="${BUILD_BRANCH:-openwrt-25.12}"
echo "===> Running Part 2.1 script for branch: $TARGET_BRANCH"

# 1. DTS-Injektion (wird IMMER ausgeführt)
if [ -d "../board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    cp -rf ../board/target/linux/mediatek/dts/* target/linux/mediatek/dts/
else
    echo "===> FEHLER: DTS-Ordner ../board/target/linux/mediatek/dts nicht gefunden!"
fi

# 2. Branch-spezifische Patch-Anwendung
if [ "$TARGET_BRANCH" = "openwrt-25.12" ]; then
    echo "===> Branch is openwrt-25.12: Applying custom kernel 6.12 patches..."
    
    # Wendet Patches aus dem Standard-Patchordner an (für 6.12)
    if [ -d "../patches" ]; then
        for patch in ../patches/*.patch; do
            if [ -f "$patch" ]; then
                echo "Applying $patch ..."
                patch -p1 < "$patch"
            fi
        done
    else
        echo "===> Keine Patches unter ../patches gefunden."
    fi

elif [ "$TARGET_BRANCH" = "main" ]; then
    echo "===> Branch is 'main': Applying custom kernel 6.18 patches..."
    
    # Wendet Patches aus deinem speziellen 6.18-Ordner an (Achtung Schreibweise: patche618)
    if [ -d "../patche618" ]; then
        for patch in ../patche618/*.patch; do
            if [ -f "$patch" ]; then
                echo "Applying $patch ..."
                patch -p1 < "$patch"
            fi
        done
    else
        echo "===> Keine Patches unter ../patche618 gefunden."
    fi
fi

echo "===> Part 2.1 script completed successfully."
