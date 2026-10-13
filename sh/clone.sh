#!/bin/bash
# =================================================================
# Clone Script - Dynamic Repo & Branch Selector
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"

REPO_URL="https://github.com/${SDK_REPO}/${SDK_REPO}.git"

echo "===> Cloning repository: $REPO_URL"

if [ "$SDK_BRANCH_TYPE" = "main" ]; then
    TARGET_BRANCH="main"
    echo "===> Using Main branch: $TARGET_BRANCH"
    git clone -b "$TARGET_BRANCH" --single-branch "$REPO_URL" openwrt
else
    echo "===> Detecting latest stable branch for $SDK_REPO..."
    git clone "$REPO_URL" openwrt
    cd openwrt
    
    LATEST_STABLE=$(git branch -r | grep -oE 'openwrt-[0-9]+\.[0-9]+' | sort -V | tail -n 1)
    
    if [ -z "$LATEST_STABLE" ]; then
        echo "===> WARNUNG: Konnte keinen Stable-Branch finden, falle auf openwrt-25.12 zurück!"
        LATEST_STABLE="openwrt-25.12"
    fi
    
    echo "===> Checking out latest stable branch: $LATEST_STABLE"
    git checkout "$LATEST_STABLE"
    cd ..
fi

echo "===> Clone completed successfully."
