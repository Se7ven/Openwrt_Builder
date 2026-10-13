#!/bin/bash
# =================================================================
# Custom Part 2.1 Script for GL-MT5000 (Brume 3) Build
# =================================================================

echo "===> Injecting custom board files and DTS for GL-MT5000..."

# Pfad zu deinen benutzerdefinierten Board-Dateien im Repository
CUSTOM_BOARD_DIR="../board/target"

if [ -d "$CUSTOM_BOARD_DIR" ]; then
    echo "===> Found custom board directory: $CUSTOM_BOARD_DIR"
    
    # Kopiere die DTS-Dateien in den Kernel-Quellbaum von ImmortalWrt
    if [ -d "$CUSTOM_BOARD_DIR/linux/mediatek/dts" ]; then
        echo "===> Copying custom DTS files..."
        cp -rf "$CUSTOM_BOARD_DIR/linux/mediatek/dts/"* target/linux/mediatek/dts/
    fi
    
    # Falls weitere Konfigurationen oder Patches im Board-Ordner liegen
    # cp -rf "$CUSTOM_BOARD_DIR/"* target/
else
    echo "===> Warning: Custom board directory '$CUSTOM_BOARD_DIR' not found!"
fi

echo "===> Part 2.1 script completed successfully."
