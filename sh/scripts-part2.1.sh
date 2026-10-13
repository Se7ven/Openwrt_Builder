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
    echo "===> Branch is openwrt-25.12: Injecting custom kernel 6.12 patches..."
    
    # Kernel-Patches in den OpenWrt Patch-Ordner kopieren
    if [ -d "../patches" ]; then
        echo "===> Kopiere 6.12 Kernel-Patches in den Build-Tree..."
        mkdir -p target/linux/mediatek/patches-6.12
        cp -f ../patches/*.patch target/linux/mediatek/patches-6.12/
    else
        echo "===> Keine Patches unter ../patches gefunden."
    fi

elif [ "$TARGET_BRANCH" = "main" ]; then
    echo "===> Branch is 'main': Injecting custom kernel 6.18 patches..."
    
    # Kernel-Patches in den OpenWrt Patch-Ordner kopieren
    if [ -d "../patche618" ]; then
        echo "===> Kopiere 6.18 Kernel-Patches in den Build-Tree..."
        mkdir -p target/linux/mediatek/patches-6.18
        cp -f ../patche618/*.patch target/linux/mediatek/patches-6.18/
    else
        echo "===> Keine Patches unter ../patche618 gefunden."
    fi
fi

echo "===> Part 2.1 script completed successfully."
