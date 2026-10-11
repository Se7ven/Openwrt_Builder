# OpenWrt & ImmortalWrt Builder

*[🇩🇪 Deutsche Version unten / German version below](#-deutsche-version-german-version)*

This is a GitHub Actions-based firmware build repository for the GL.iNet GL-MT5000 (Brume 3). It is specifically designed to automatically pull source code, integrate custom packages and optimizations, and build clean, fully functional firmware images for both OpenWrt and ImmortalWrt.

## 🚀 Supported Firmware Variants & Devices

**Device:** GL-MT5000 (Brume 3)  
**Default IP:** `192.168.100.1`  
**Base System:** To guarantee 100% hardware compatibility (especially for the Realtek RTL8366UB DSA switch and MT7987 SoC), all builds utilize the native GL.iNet source tree as their foundation. The distinct OpenWrt or ImmortalWrt experiences are achieved by injecting the respective official package and LuCI feeds.

### Available Workflows:
*   **ImmortalWrt (Master)** – via `Build immortalwrt.yml`
*   **ImmortalWrt (25.12 Stable)** – via `Immortalwrt Brume 3 stable.yml`
*   **OpenWrt (Master)** – via `Build filogic.yml`
*   **OpenWrt (25.12 Stable)** – via `OpenWrt Brume 3 stable (25.12).yml`

## 📁 Directory Structure

*   `.github/workflows/`: Contains the automated build and release pipelines for all firmware variants.
*   `.github/actions/`: Local composite actions used during the release and upload phases.
*   `config/`: Contains the firmware-specific `.config` files (`mt5000.config` for OpenWrt and `immortalwrt.config` for ImmortalWrt).
*   `sh/scripts-part1.sh`: Source code modifications and patch injections executed *before* feed updates.
*   `sh/scripts-part2.sh`: Custom scripts executed *after* feed installation to inject custom packages, handle conflicting Kconfig dependencies, and set default themes/network configurations.
*   `default-settings-m0eak/`: Custom default settings package for personal configurations.
*   `files/`: Rootfs overlay copied directly into the build tree (`openwrt/files`) to override system files.

## 🛠️ Build Workflow

1.  **Trigger:** Start the respective workflow via GitHub Actions (manually or scheduled).
2.  **Clone:** The optimized GL.iNet OpenWrt source code base is cloned to ensure perfect hardware compatibility.
3.  **Part 1:** Execute `sh/scripts-part1.sh` for source code preparations and pre-feed patches.
4.  **Feeds:** Update and install specific package feeds (ImmortalWrt or OpenWrt, depending on the workflow).
5.  **Part 2:** Execute `sh/scripts-part2.sh` to clean up circular dependencies (e.g., OpenVSwitch) and add individual packages (Passwall, Lucky, Footstrap, etc.).
6.  **Config:** Inject `default-settings-m0eak`, the `files/` overlay, and the respective configuration (`mt5000.config` or `immortalwrt.config`).
7.  **Compile:**
