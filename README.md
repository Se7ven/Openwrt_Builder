# OpenWrt & ImmortalWrt Builder (GL-MT5000 / Brume 3)

*[🇩🇪 Deutsche Version unten / German version below](#-deutsche-version-german-version)*

This repository contains two distinct build architectures tailored for the **GL.iNet GL-MT5000 (Brume 3)** router: the universal GL.iNet source-based builder and the vanilla OpenWrt/ImmortalWrt source-patch builder.

## 🚀 The Dual-Builder Architecture & Script Allocation

### 1. The GL.iNet Source-Based Builder (`build-gl-mt5000-glinet.yml`)
*   **Purpose:** Universal source code compilation using the official, native GL.iNet source tree (`mt5000` branch) as its kernel and driver foundation.
*   **Workflow:** Controlled via a `workflow_dispatch` dropdown supporting 4 environments (`immortalwrt_master`, `immortalwrt_stable`, `openwrt_main`, `openwrt_stable`) or an `all` parallel matrix mode.
*   **Assigned Scripts:**
    *   `sh/scripts-part1.sh`: Pre-feed script executed right after cloning the native GL.iNet tree; sets default IPs (e.g., `192.168.100.1`) and configures branch feeds.
    *   `sh/scripts-part2.sh`: Post-feed customization script that clones third-party packages (Passwall, MosDNS, Lucky, themes, etc.) into `package/custom`, resolves Makefile conflicts, and handles network layout and branding.
    *   `sh/finalize.sh`: Post-build script for organizing, renaming, and packaging final firmware artifacts with timestamps.

### 2. The Vanilla Source & Patch Builder (Patch-Based Builder)
*   **Purpose:** Pulls upstream vanilla OpenWrt or ImmortalWrt source code directly and applies custom kernel patches, device tree sources (DTS), and driver modifications during the build process using dedicated helper scripts and patch directories.
*   **Assigned Scripts & Folders:**
    *   `sh/clone.sh`: Helper script for cloning specific upstream repositories and setting up isolated target directories.
    *   `sh/prepare.sh`: Prepares the source tree, injects custom device tree sources (DTS), and applies necessary kernel patches.
    *   `sh/finalize.sh`: Finalizes and packages the build artifacts.

## 📁 Repository & Folder Structure

*   `.github/workflows/`: Contains all automated CI/CD build and release pipelines (including the universal builder and imagebuilder).
*   `board/`: Contains hardware-specific board definitions, device configurations, or device tree assets.
*   `config/`: Firmware-specific configuration profiles (`mt5000.config` and `immortalwrt.config`).
*   `default-settings-m0eak/`: Custom default settings package for personal configurations.
*   `files/`: Rootfs overlay copied directly into the target file system during the build.
*   `patches/`: General kernel and source code patches applied during vanilla builds.
*   `patches-25.12/`: Version-specific patch sets tailored for the 25.12 stable release branches.
*   `sh/`: Beherbergt alle modularen Hilfs- und Anpassungsskripte (`clone.sh`, `prepare.sh`, `scripts-part1.sh`, `scripts-part2.sh`, `finalize.sh`).

## 🙏 Acknowledgments

*   **m0eak** (for the base structure and template design)
*   **Kitsune2077** (for `Kitsune2077/mt5000-immortalwrt` repository contributions and references)
*   [GL.iNet Tech](https://github.com/GLiNet-Tech) (for hardware-specific patches and kernel sources)
*   [OpenWrt Project](https://openwrt.org/)
*   [ImmortalWrt Project](https://immortalwrt.org/)

## 📄 License

[MIT](LICENSE)

---
---

# 🇩🇪 Deutsche Version (German Version)

Dieses Repository enthält zwei unterschiedliche Build-Architekturen, die speziell für den **GL.iNet GL-MT5000 (Brume 3)** Router entwickelt wurden: den universellen GL.iNet-Quellbasis-Builder sowie den Vanilla OpenWrt/ImmortalWrt Patch-Builder.

## 🚀 Die Dual-Builder-Architektur & Skript-Zuordnung

### 1. Der GL.iNet Quellbasis-Builder (`build-gl-mt5000-glinet.yml`)
*   **Zweck:** Universelle Quellcode-Kompilierung auf Basis des offiziellen, nativen GL.iNet-Quellbaums (`mt5000`-Branch) als Kernel- und Treiberfundament.
*   **Workflow:** Gesteuert über ein `workflow_dispatch`-Dropdown für 4 Umgebungen (`immortalwrt_master`, `immortalwrt_stable`, `openwrt_main`, `openwrt_stable`) oder den Parallelmodus `all`.
*   **Zuordnete Skripte:**
    *   `sh/scripts-part1.sh`: Pre-Feed-Skript, das direkt nach dem Klonen des nativen GL.iNet-Baums ausgeführt wird; setzt Standard-IPs (z. B. `192.168.100.1`) und steuert Feed-Zuweisungen.
    *   `sh/scripts-part2.sh`: Post-Feed-Skript zum Klonen von Zusatzpaketen (Passwall, MosDNS, Lucky, Themes etc.) nach `package/custom`, Bereinigen von Makefile-Konflikten sowie Konfigurieren von Netzwerk-Layout und Branding.
    *   `sh/finalize.sh`: Post-Build-Skript zum Umbenennen, Organisieren und Verpacken der finalen Firmware-Artefakte mit Zeitstempel.

### 2. Der Vanilla Source & Patch Builder (Patch-basierter Builder)
*   **Zweck:** Holt direkt den Upstream-Quellcode von Vanilla OpenWrt oder ImmortalWrt ab und wendet spezifische Kernel-Patches, Device Tree Sources (DTS) und Treiberanpassungen während des Build-Prozesses über dedizierte Hilfsskripte und Patch-Ordner an.
*   **Zuordnete Skripte & Ordner:**
    *   `sh/clone.sh`: Hilfsskript zum Klonen spezifischer Upstream-Repositories und Einrichten isolierter Zielverzeichnisse.
    *   `sh/prepare.sh`: Bereitet den Quellbaum vor, injiziert benutzerdefinierte Device Tree Sources (DTS) und wendet Kernel-Patches an.
    *   `sh/finalize.sh`: Verpackt und bereitet die Artefakte für den Release vor.

## 📁 Verzeichnis- & Ordnerstruktur

*   `.github/workflows/`: Enthält alle automatisierten CI/CD-Pipelines für die Builds und Releases (inkl. Universal-Builder und Imagebuilder).
*   `board/`: Beinhaltet hardwarespezifische Board-Definitionen, Gerätekonfigurationen oder Device-Tree-Assets.
*   `config/`: Firmware-spezifische Konfigurationsprofile (`mt5000.config` und `immortalwrt.config`).
*   `default-settings-m0eak/`: Paket mit benutzerdefinierten Standardeinstellungen für persönliche Konfigurationen.
*   `files/`: Rootfs-Overlay, das während des Build-Vorgangs direkt in das Ziel-Dateisystem kopiert wird.
*   `patches/`: Allgemeine Kernel- und Quellcode-Patches, die bei Vanilla-Builds angewendet werden.
*   `patches-25.12/`: Versionsspezifische Patch-Sammlungen, die für die stabilen 25.12-Zweige ausgelegt sind.
*   `sh/`: Beherbergt alle modularen Hilfs- und Anpassungsskripte (`clone.sh`, `prepare.sh`, `scripts-part1.sh`, `scripts-part2.sh`, `finalize.sh`).

## 🙏 Danksagungen

*   **m0eak** (for the base structure and template design)
*   **Kitsune2077** (for `Kitsune2077/mt5000-immortalwrt` repository contributions and references)
*   [GL.iNet Tech](https://github.com/GLiNet-Tech) (for hardware-specific patches and kernel sources)
*   [OpenWrt Project](https://openwrt.org/)
*   [ImmortalWrt Project](https://immortalwrt.org/)

## 📄 Lizenz

[MIT](LICENSE)
