# OpenWrt & ImmortalWrt Builder (GL-MT5000 / Brume 3)

*🇩🇪 [Deutsche Version unten / German version below](#-deutsche-version-german-version)*

This repository contains two distinct build architectures tailored for the **GL.iNet GL-MT5000 (Brume 3)** router: the universal GL.iNet source-based builder and the vanilla OpenWrt/ImmortalWrt source-patch builder.

---

## 🚀 The Dual-Builder Architecture & Script Allocation

### 1. The GL.iNet Source-Based Builder (`build-gl-mt5000-glinet.yml`)
* **Purpose:** Universal source code compilation using the official, native GL.iNet source tree (`mt5000` branch) as its kernel and driver foundation.
* **Workflow & Selection:** Controlled via a `workflow_dispatch` dropdown (`target_env`) supporting 4 environments (`immortalwrt_master` [default], `immortalwrt_stable`, `openwrt_main`, `openwrt_stable`) for targeted single builds, or `all` to trigger a parallel matrix build of all 4 variants simultaneously.
* **Assigned Scripts:**
  * `sh/scripts-part1.sh`: Pre-feed script executed right after cloning the native GL.iNet tree; sets default IPs (e.g., `192.168.100.1`) and configures branch feeds.
  * `sh/scripts-part2.sh`: Post-feed customization script that clones third-party packages (Passwall, MosDNS, Lucky, themes, etc.) into `package/custom`, resolves Makefile conflicts, and handles network layout and branding.
  * `sh/finalize.sh`: Post-build script for organizing, renaming, and packaging final firmware artifacts with timestamps.

### 2. The Vanilla Source & Patch Builder (`Imagebuilder gl-mt5000.yml`)
* **Purpose:** Pulls upstream vanilla OpenWrt or ImmortalWrt source code directly and applies custom kernel patches, device tree sources (DTS), and driver modifications during a full compilation process using dedicated helper scripts and patch directories.
* **Workflow & Selection:** Controlled via a `workflow_dispatch` dropdown (`target_env`) with `immortalwrt_master` set as default. Allows building a single specific environment (`immortalwrt_master`, `immortalwrt_stable`, `openwrt_main`, `openwrt_stable`) or selecting `all` to compile all 4 environments in parallel via a dynamic JSON matrix.
* **Assigned Scripts & Folders:**
  * `sh/clone.sh`: Helper script for cloning specific upstream repositories and setting up isolated target directories.
  * `sh/prepare.sh`: Prepares the source tree, injects custom device tree sources (DTS) from `board/`, and applies necessary kernel patches.
  * `sh/finalize.sh`: Renames, finalizes, and packages the compiled firmware images for release.

---

## 📁 Repository & Folder Structure

* `.github/workflows/`: Contains all automated CI/CD build and release pipelines (including `build-gl-mt5000-glinet.yml` and `Imagebuilder gl-mt5000.yml`).
* `board/`: Contains hardware-specific board definitions, Makefile targets (`filogic.mk`), device configurations, and device tree assets.
* `config/`: Firmware-specific configuration profiles (e.g., `mt5000.config` and `immortalwrt.config`).
* `default-settings-m0eak/`: Custom default settings package for personal configurations.
* `files/`: Rootfs overlay copied directly into the target file system during the build.
* `patches/`: General kernel and source code patches applied during vanilla builds.
* `patches-25.12/`: Version-specific patch sets tailored for the 25.12 stable release branches.
* `patche618/`: Kernel 6.18 specific patches and driver adjustments.
* `sh/`: Houses all modular helper and customization scripts (`clone.sh`, `prepare.sh`, `scripts-part1.sh`, `scripts-part2.sh`, `finalize.sh`).

---

## 🙏 Acknowledgments

* **m0eak** (for the base structure and template design)
* **Kitsune2077** (for `Kitsune2077/mt5000-immortalwrt` repository contributions and references)
* **GL.iNet Tech** (for hardware-specific patches and kernel sources)
* **OpenWrt Project**
* **ImmortalWrt Project**

## 📄 License

MIT

---
---

# 🇩🇪 Deutsche Version (German Version)

Dieses Repository enthält zwei unterschiedliche Build-Architekturen, die speziell für den **GL.iNet GL-MT5000 (Brume 3)** Router entwickelt wurden: den universellen GL.iNet-Quellbasis-Builder sowie den Vanilla OpenWrt/ImmortalWrt Patch-Builder.

---

## 🚀 Die Dual-Builder-Architektur & Skript-Zuordnung

### 1. Der GL.iNet Quellbasis-Builder (`build-gl-mt5000-glinet.yml`)
* **Zweck:** Universelle Quellcode-Kompilierung auf Basis des offiziellen, nativen GL.iNet-Quellbaums (`mt5000`-Branch) als Kernel- und Treiberfundament.
* **Workflow & Auswahl:** Gesteuert über ein `workflow_dispatch`-Dropdown (`target_env`) für 4 Umgebungen (`immortalwrt_master` [Standard], `immortalwrt_stable`, `openwrt_main`, `openwrt_stable`) für gezielte Einzel-Builds oder die Option `all`, um alle 4 Varianten parallel in einer Matrix zu bauen.
* **Zugeordnete Skripte:**
  * `sh/scripts-part1.sh`: Pre-Feed-Skript, das direkt nach dem Klonen des nativen GL.iNet-Baums ausgeführt wird; setzt Standard-IPs (z. B. `192.168.100.1`) und steuert Feed-Zuweisungen.
  * `sh/scripts-part2.sh`: Post-Feed-Skript zum Klonen von Zusatzpaketen (Passwall, MosDNS, Lucky, Themes etc.) nach `package/custom`, Bereinigen von Makefile-Konflikten sowie Konfigurieren von Netzwerk-Layout und Branding.
  * `sh/finalize.sh`: Post-Build-Skript zum Umbenennen, Organisieren und Verpacken der finalen Firmware-Artefakte mit Zeitstempel.

### 2. Der Vanilla Source & Patch Builder (`Imagebuilder gl-mt5000.yml`)
* **Zweck:** Holt direkt den Upstream-Quellcode von Vanilla OpenWrt oder ImmortalWrt ab und wendet spezifische Kernel-Patches, Device Tree Sources (DTS) und Treiberanpassungen während eines vollständigen Kompiliervorgangs über dedizierte Hilfsskripte und Patch-Ordner an.
* **Workflow & Auswahl:** Ebenfalls gesteuert über ein `workflow_dispatch`-Dropdown (`target_env`), wobei `immortalwrt_master` als Standardauswahl vorbelegt ist. Ermöglicht wahlweise den gezielten Bau einer einzelnen Umgebung (`immortalwrt_master`, `immortalwrt_stable`, `openwrt_main`, `openwrt_stable`) oder über die Auswahl `all` den parallelen Matrix-Build aller 4 Umgebungen gleichzeitig.
* **Zugeordnete Skripte & Ordner:**
  * `sh/clone.sh`: Hilfsskript zum Klonen spezifischer Upstream-Repositories und Einrichten isolierter Zielverzeichnisse.
  * `sh/prepare.sh`: Bereitet den Quellbaum vor, injiziert benutzerdefinierte Device Tree Sources (DTS) aus `board/` und wendet die Kernel-Patches an.
  * `sh/finalize.sh`: Benennt die fertigen Images um und bereitet die Artefakte für den GitHub-Release vor.

---

## 📁 Verzeichnis- & Ordnerstruktur

* `.github/workflows/`: Enthält alle automatisierten CI/CD-Pipelines für die Builds und Releases (inkl. `build-gl-mt5000-glinet.yml` und `Imagebuilder gl-mt5000.yml`).
* `board/`: Beinhaltet hardwarespezifische Board-Definitionen, Makefile-Definitionen (`filogic.mk`), Gerätekonfigurationen und Device-Tree-Assets.
* `config/`: Firmware-spezifische Konfigurationsprofile (z. B. `mt5000.config` und `immortalwrt.config`).
* `default-settings-m0eak/`: Paket mit benutzerdefinierten Standardeinstellungen für persönliche Konfigurationen.
* `files/`: Rootfs-Overlay, das während des Build-Vorgangs direkt in das Ziel-Dateisystem kopiert wird.
* `patches/`: Allgemeine Kernel- und Quellcode-Patches, die bei Vanilla-Builds angewendet werden.
* `patches-25.12/`: Versionsspezifische Patch-Sammlungen, die für die stabilen 25.12-Zweige ausgelegt sind.
* `patche618/`: Spezifische Patches und Treiberanpassungen für Kernel 6.18.
* `sh/`: Beherbergt alle modularen Hilfs- und Anpassungsskripte (`clone.sh`, `prepare.sh`, `scripts-part1.sh`, `scripts-part2.sh`, `finalize.sh`).

---

## 🙏 Danksagungen

* **m0eak** (für die Basisstruktur und das Template-Design)
* **Kitsune2077** (für Beiträge und Referenzen aus dem `Kitsune2077/mt5000-immortalwrt` Repository)
* **GL.iNet Tech** (für hardwarespezifische Patches und Kernel-Quellen)
* **OpenWrt Project**
* **ImmortalWrt Project**

## 📄 Lizenz

MIT
