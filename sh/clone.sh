#!/bin/bash
# =================================================================
# Clone Script - Robust Dual-Mode (Main & Stable)
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"

REPO_URL="https://github.com/${SDK_REPO}/${SDK_REPO}.git"

echo "===> Cloning repository: $REPO_URL"

if [ "$SDK_BRANCH_TYPE" = "main" ]; then
    if [ "$SDK_REPO" = "immortalwrt" ]; then
        TARGET_BRANCH="master"
    else
        TARGET_BRANCH="main"
    fi
    
    echo "===> Using Main branch: $TARGET_BRANCH for $SDK_REPO"
    git clone -b "$TARGET_BRANCH" --single-branch "$REPO_URL" openwrt
else
    echo "===> Using Stable branch mode for $SDK_REPO..."
    git clone "$REPO_URL" openwrt
    cd openwrt || exit 1
    
    LATEST_STABLE=$(git branch -r | grep -oE 'origin/openwrt-[0-9]+\.[0-9]+' | sed 's|origin/||' | sort -V | tail -n 1)
    
    if [ -z "$LATEST_STABLE" ]; then
        echo "===> WARNUNG: Konnte keinen Stable-Branch finden, verwende Standard-Branch!"
    else
        echo "===> Checking out latest stable branch: $LATEST_STABLE"
        git checkout -b "$LATEST_STABLE" "origin/$LATEST_STABLE"
    fi
    cd ..
fi

echo "===> Clone completed successfully."
