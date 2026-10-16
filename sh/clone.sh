#!/bin/bash
# =================================================================
# Clone Script - Exact 4-folder separation with branch assignment
# Supports both branch-based and tag-based (release) cloning.
# =================================================================

SDK_REPO="${INPUT_SDK_REPO:-immortalwrt}"
SDK_BRANCH_TYPE="${INPUT_SDK_BRANCH:-main}"
SDK_TAG="${INPUT_SDK_TAG:-}"

# Determines the exact target directory (immortalwrt_master, openwrt_main, etc.)
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
    echo "===> Directory $TARGET_DIR already exists, cleaning up..."
    rm -rf "$TARGET_DIR"
fi

# --- Tag-based clone: checkout a specific release tag (e.g. v25.12.5) ---
# NOTE: Tag-based cloning is only valid for stable/frozen builds.
# When INPUT_SDK_TAG is set at workflow level it applies to ALL matrix entries
# (including master/main via 'all' mode), so we must guard against it.
if [ -n "$SDK_TAG" ] && [ "$SDK_BRANCH_TYPE" != "main" ]; then
    echo "===> Using release tag: $SDK_TAG for $SDK_REPO"
    git clone --depth 1 --branch "$SDK_TAG" --single-branch "$REPO_URL" "$TARGET_DIR" || {
        echo "===> ERROR: Failed to clone tag $SDK_TAG from $REPO_URL!"
        exit 1
    }
    echo "===> Checked out release tag '$SDK_TAG' (stable, Kernel 6.12)."
# --- Main/master clone ---
elif [ "$SDK_BRANCH_TYPE" = "main" ]; then
    echo "===> Using Main/Master branch: $TARGET_BRANCH for $SDK_REPO"
    git clone -b "$TARGET_BRANCH" --single-branch "$REPO_URL" "$TARGET_DIR" || {
        echo "===> ERROR during cloning!"
        exit 1
    }
# --- Stable branch clone: find latest openwrt-XX.YY branch ---
else
    echo "===> Using Stable branch mode for $SDK_REPO..."
    git clone "$REPO_URL" "$TARGET_DIR" || {
        echo "===> ERROR cloning repository!"
        exit 1
    }

    cd "$TARGET_DIR" || exit 1

    LATEST_STABLE=$(git branch -r | grep -oE 'origin/openwrt-[0-9]+\.[0-9]+' | sed 's|origin/||' | sort -V | tail -n 1)

    if [ -z "$LATEST_STABLE" ]; then
        echo "===> WARNING: Could not find a stable branch, using default branch!"
    else
        echo "===> Checking out latest stable branch: $LATEST_STABLE"
        git checkout -b "$LATEST_STABLE" "origin/$LATEST_STABLE" || {
            echo "===> ERROR during checkout of stable branch!"
            exit 1
        }
    fi
    cd ..
fi

if [ ! -d "$TARGET_DIR" ]; then
    echo "===> CRITICAL ERROR: Target directory '$TARGET_DIR' was not found after cloning!"
    exit 1
fi

echo "===> Clone into '$TARGET_DIR' completed successfully."
