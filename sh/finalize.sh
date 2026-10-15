#!/bin/bash
# =================================================================
# Finalize Script - Universelles Umbenennen aller Firmware-Artefakte
# =================================================================

echo "--- Finalize: Starte Umbenennung der Firmware-Artefakte ---"

# Übergebenes Argument (Verzeichnis) nutzen, sonst Fallback auf aktuelles Verzeichnis oder Workspace
TARGET_BASE="${1:-.}"

IMAGE_DIR=""

# Mögliche Pfade systematisch durchprobieren, egal aus welchem Workflow das Skript aufgerufen wird
if [ -d "$TARGET_BASE/bin/targets/mediatek/filogic" ]; then
    IMAGE_DIR="$TARGET_BASE/bin/targets/mediatek/filogic"
elif [ -d "bin/targets/mediatek/filogic" ]; then
    IMAGE_DIR="bin/targets/mediatek/filogic"
else
    # Automatische Tiefensuche nach dem Zielordner (deckt /workdir/ und Unterordner ab)
    FOUND_PATH=$(find . "$TARGET_BASE" /workdir -maxdepth 5 -type d -path "*/bin/targets/mediatek/filogic" 2>/dev/null | head -n 1)
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

# 2. Präfix aus der Umgebung (Matrix tag_prefix) oder Fallback generieren
DATE=$(date +'%Y%m%d')
if [ -n "$TAG_PREFIX" ]; then
    PREFIX="${TAG_PREFIX}-${DATE}"
else
    PREFIX="gl-mt5000-${DATE}"
fi

echo "===> Verwende Datei-Präfix: $PREFIX"

# 3. Sysupgrade umbenennen
for f in *sysupgrade*; do
    if [ -f "$f" ]; then
        EXT="${f##*.}"
        TARGET_NAME="${PREFIX}-gl-mt5000-sysupgrade.${EXT}"
        [ "$f" != "$TARGET_NAME" ] && mv "$f" "$TARGET_NAME" && echo "Renamed: $f -> $TARGET_NAME"
    fi
done

# 4. Factory umbenennen
for f in *factory*; do
    if [ -f "$f" ]; then
        EXT="${f##*.}"
        TARGET_NAME="${PREFIX}-gl-mt5000-factory.${EXT}"
        [ "$f" != "$TARGET_NAME" ] && mv "$f" "$TARGET_NAME" && echo "Renamed: $f -> $TARGET_NAME"
    fi
done

# 5. Manifest umbenennen
for f in *.manifest; do
    if [ -f "$f" ]; then
        TARGET_NAME="${PREFIX}-gl-mt5000.manifest"
        [ "$f" != "$TARGET_NAME" ] && mv "$f" "$TARGET_NAME" && echo "Renamed: $f -> $TARGET_NAME"
    fi
done

# 6. sha256sums umbenennen
for f in sha256sums; do
    if [ -f "$f" ]; then
        TARGET_NAME="${PREFIX}-sha256sums"
        [ "$f" != "$TARGET_NAME" ] && mv "$f" "$TARGET_NAME" && echo "Renamed: $f -> $TARGET_NAME"
    fi
done

echo "===> Finalize erfolgreich abgeschlossen."
ls -la
