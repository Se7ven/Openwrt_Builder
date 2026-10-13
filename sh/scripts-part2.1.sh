#!/bin/bash
# =================================================================
# Custom Part 2.1 Script - Fully Streamlined for GL-MT5000
# =================================================================

TARGET_BRANCH="${BUILD_BRANCH:-openwrt-25.12}"
echo "===> Running Part 2.1 script for branch: $TARGET_BRANCH"

# Einziger Job des Skripts: Den fehlenden DTS-Hardware-Bauplan injizieren.
# Alle Treiber-Patches werden für alle Branches (6.12 & 6.18) nativ von Upstream geladen.
if [ -d "custom_files/board/target/linux/mediatek/dts" ]; then
    echo "===> Injecting custom DTS files for GL-MT5000..."
    cp -rf custom_files/board/target/linux/mediatek/dts/* target/linux/mediatek/dts/
else
    echo "===> FEHLER: DTS-Ordner custom_files/board/target/linux/mediatek/dts nicht gefunden!"
    exit 1
fi

echo "===> Part 2.1 script completed successfully."
