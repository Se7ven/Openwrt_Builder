#!/bin/bash
# =================================================================
# Clone Script - Exakte 4-Ordner-Trennung mit Branch-Zuordnung
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"

# Bestimmt den exakten Zielordner (immortalwrt_master, openwrt_main, etc.)
if [ "$SDK_REPO" = "immortalwrt" ] && [ "$SDK_BRANCH_TYPE" = "main" ]; then
    TARGET_DIR="immortalwrt_master"
    TARGET_BRANCH="master"
else
    TARGET_DIR="${SDK_REPO}_${SDK_BRANCH_TYPE}"
    if [ "$SDK_BRANCH_TYPE" = "main" ]; then
        TARGET_BRANCH="main"
    fi
fi

REPO_URL="https://github.com/${SDK_REPO}/${SDK_REPO}.git"

echo "===> Cloning repository: $REPO_URL into target directory: $TARGET_DIR"

if [ -d "$TARGET_DIR" ]; then
    echo "===> Verzeichnis $TARGET_DIR existiert bereits, räume auf..."
    rm -rf "$TARGET_DIR"
fi

if [ "$SDK_BRANCH_TYPE" = "main" ]; then
    echo "===> Using Main/Master branch: $TARGET_BRANCH for $SDK_REPO"
    git clone -b "$TARGET_BRANCH" --single-branch "$REPO_URL" "$TARGET_DIR" || {
        echo "===> FEHLER beim Klonen!"
        exit 1
    }
else
    echo "===> Using Stable branch mode for $SDK_REPO..."
    git clone "$REPO_URL" "$TARGET_DIR" || {
        echo "===> FEHLER beim Klonen des Repositories!"
        exit 1
    }
    
    cd "$TARGET_DIR" || exit 1
    
    LATEST_STABLE=$(git branch -r | grep -oE 'origin/openwrt-[0-9]+\.[0-9]+' | sed 's|origin/||' | sort -V | tail -n 1)
    
    if [ -z "$LATEST_STABLE" ]; then
        echo "===> WARNUNG: Konnte keinen Stable-Branch finden, verwende Standard-Branch!"
    else
        echo "===> Checking out latest stable branch: $LATEST_STABLE"
        git checkout -b "$LATEST_STABLE" "origin/$LATEST_STABLE" || {
            echo "===> FEHLER beim Checkout des Stable-Branches!"
            exit 1
        }
    fi
    cd ..
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "===> KRITISCHER FEHLER: Zielverzeichnis '$TARGET_DIR' wurde nach dem Klonen nicht gefunden!"
    exit 1
fi

echo "===> Clone into '$TARGET_DIR' completed successfully."
