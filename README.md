# OpenWrt & ImmortalWrt Builder (GL-MT5000 / Brume 3)

*[🇩🇪 Deutsche Version unten / German version below](#-deutsche-version-german-version)*

This repository contains two distinct, powerful build architectures tailored for the **GL.iNet GL-MT5000 (Brume 3)** router: a native GL.iNet source-based builder and a vanilla OpenWrt/ImmortalWrt source-patch builder.

## 🚀 The Dual-Builder Architecture

### 1. The GL.iNet Source-Based Builder (`build-gl-mt5000-glinet.yml`)
*   **Purpose:** Universal source code compilation using the official, native GL.iNet source tree (`mt5000` branch) as its kernel and driver foundation[cite: 1].
*   **Workflow:** Controlled via a `workflow_dispatch` dropdown supporting 4 environments (`immortalwrt_master`, `immortalwrt_stable`, `openwrt_main`, `openwrt_stable`) or an `all` parallel matrix mode.
*   **Customization:** Relies exclusively on `sh/scripts-part1.sh` and `sh/scripts-part2.sh` for feeds, package injections, and branding.

### 2. The Vanilla Source & Patch Builder (Custom Workflow / Imagebuilder)
*   **Purpose:** Pulls upstream vanilla OpenWrt or ImmortalWrt source code directly and applies custom kernel patches, device tree sources (DTS), and driver modifications during the build process.
*   **Use Case:** Ideal when experimenting with bleeding-edge upstream kernel developments or applying custom patch sets directly to standard OpenWrt trees.

## 📁 Repository Structure

*   `.github/workflows/`: Contains all automated CI/CD build and release pipelines.
*   `config/`: Firmware-specific configuration profiles (`mt5000.config` and `immortalwrt.config`).
*   `sh/scripts-part1.sh`: Pre-feed script for source code preparations and IP modifications.
*   `sh/scripts-part2.sh`: Post-feed script for cloning custom packages (Passwall, MosDNS, Lucky, themes, etc.) into `package/custom` and resolving Makefile conflicts.
*   `files/`: Rootfs overlay copied directly into the target file system.

## 🙏 Acknowledgments

*   **m0eak** (for the base structure and template design)
*   [GL.iNet Tech](https://github.com/GLiNet-Tech) (for hardware-specific patches and kernel sources)[cite: 1]
*   [OpenWrt Project](https://openwrt.org/)
*   [ImmortalWrt Project](https://immortalwrt.org/)

## 📄 License

[MIT](LICENSE)

---
---

# 🇩🇪 Deutsche Version (German Version)

Dieses Repository enthält zwei unterschiedliche, leistungsstarke Build-Architekturen, die speziell für den **GL.iNet GL-MT5000 (Brume 3)** Router entwickelt wurden: den nativen GL.iNet-Quellbasis-Builder sowie den Vanilla OpenWrt/ImmortalWrt Patch-Builder.

## 🚀 Die Dual-Builder-Architektur

### 1. Der GL.iNet Quellbasis-Builder (`build-gl-mt5000-glinet.yml`)
*   **Zweck:** Universelle Quellcode-Kompilierung auf Basis des offiziellen, nativen GL.iNet-Quellbaums (`mt5000`-Branch) als Kernel- und Treiberfundament[cite: 1].
*   **Workflow:** Gesteuert über ein `workflow_dispatch`-Dropdown für 4 Umgebungen (`immortalwrt_master`, `immortalwrt_stable`, `openwrt_main`, `openwrt_stable`) oder den Parallelmodus `all`.
*   **Anpassung:** Nutzt exklusiv `sh/scripts-part1.sh` und `sh/scripts-part2.sh` für Feeds, Paket-Injektionen und Branding.

### 2. Der Vanilla Source & Patch Builder (Patch-basierter Builder)
*   **Zweck:** Holt direkt den Upstream-Quellcode von Vanilla OpenWrt oder ImmortalWrt ab und wendet während des Build-Prozesses spezifische Kernel-Patches, Device Tree Sources (DTS) und Treiberanpassungen an.
*   **Anwendungsbereich:** Ideal für Experimente mit neuesten Upstream-Kernelversionen oder das gezielte Einpatchen von Änderungen in Standard-OpenWrt-Bäume.

## 📁 Verzeichnisstruktur

*   `.github/workflows/`: Enthält alle automatisierten CI/CD-Pipelines für die Builds und Releases.
*   `config/`: Firmware-spezifische Konfigurationsprofile (`mt5000.config` und `immortalwrt.config`).
*   `sh/scripts-part1.sh`: Pre-Feed-Skript für Quellcode-Vorbereitungen und IP-Anpassungen.
*   `sh/scripts-part2.sh`: Post-Feed-Skript zum Klonen von Zusatzpaketen (Passwall, MosDNS, Lucky, Themes etc.) nach `package/custom` und Bereinigen von Makefile-Konflikten.
*   `files/`: Rootfs-Overlay, das direkt in das Ziel-Dateisystem kopiert wird.

## 🙏 Danksagungen

*   **m0eak** (für die Basisstruktur und das Template-Design)
*   [GL.iNet Tech](https://github.com/GLiNet-Tech) (für hardwarespezifische Patches und Kernel-Quellen)[cite: 1]
*   [OpenWrt Project](https://openwrt.org/)
*   [ImmortalWrt Project](https://immortalwrt.org/)

## 📄 Lizenz

[MIT](LICENSE)
