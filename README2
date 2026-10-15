# OpenWrt & ImmortalWrt Builder (GL-MT5000 / Brume 3)

*[🇩🇪 Deutsche Version unten / German version below](#-deutsche-version-german-version)*

This is a specialized GitHub Actions-based firmware build repository tailored specifically for the **GL.iNet GL-MT5000 (Brume 3)** router. It utilizes a powerful dual-workflow architecture to support both full source compilation and rapid image building while strictly guaranteeing native hardware and kernel compatibility.

## 🚀 Core Architecture & Source Basis

*   **Device:** GL.iNet GL-MT5000 (Brume 3)  
*   **Default IP:** `192.168.100.1`  
*   **Kernel & Hardware Basis:** To ensure 100% hardware stability (including proper operation of the Realtek switch, MT7987 SoC, and native Wi-Fi/NSS drivers), all workflows exclusively pull the official, native GL.iNet source tree (`mt5000` branch from `GLiNet-Tech/openwrt`) as their kernel foundation.
*   **Software Feeds ("The Roof"):** The specific OpenWrt or ImmortalWrt user interfaces, LuCI dashboards, and package feeds (Master or Stable 25.12) are dynamically injected on top of this native GL.iNet foundation.

## 🛠️ Available Workflows

1.  **`build-gl-mt5000-glinet.yml` (Universal Source Builder)**
    *   **Purpose:** Full source code compilation with a flexible GitHub Actions `workflow_dispatch` dropdown menu allowing you to choose between 4 distinct environments:
        *   `immortalwrt_master`
        *   `immortalwrt_stable` (25.12)
        *   `openwrt_main`
        *   `openwrt_stable` (25.12)
        *   `all` (Runs all four variants in parallel matrix jobs)
    *   **Features:** Optional Docker support, automated custom package integration via Part 1 & Part 2 scripts, and automatic release publishing.

2.  **`Imagebuilder gl-mt5000.yml` (Fast Image Builder)**
    *   **Purpose:** Rapid image generation utilizing pre-compiled SDK/Imagebuilder components for quick, lightweight rebuilds when only minor package adjustments or configuration updates are needed.

## 📁 Repository Structure

*   `.github/workflows/`: Contains the automated CI/CD pipelines (`build-gl-mt5000-glinet.yml` and `imagebuilder`).
*   `config/`: Firmware-specific configuration profiles (`mt5000.config` and `immortalwrt.config`).
*   `sh/scripts-part1.sh`: Pre-feed modification script (sets default IPs, handles core feed branch assignments).
*   `sh/scripts-part2.sh`: Post-feed customization script (clones custom packages into `package/custom`, resolves Kconfig/Makefile conflicts, configures network layouts, and handles branding).
*   `default-settings-m0eak/`: Custom default settings package.
*   `files/`: Rootfs overlay copied directly into the target file system.

## ⚙️ Build Workflow (Source Builder)

1.  **Trigger:** Launch the workflow manually via GitHub Actions and select your desired target environment.
2.  **Clone Native Base:** Clones the official GL.iNet MT5000 source tree (`-b mt5000`) into an isolated workspace directory.
3.  **Part 1 (`scripts-part1.sh`):** Configures feeds based on the chosen branch and applies pre-feed adjustments (such as setting the default IP to `192.168.100.1`).
4.  **Feeds Update:** Pulls and installs all package and LuCI feeds.
5.  **Part 2 (`scripts-part2.sh`):** Clones third-party repositories (Passwall, MosDNS, Lucky, custom themes, etc.) into `package/custom`, cleans up conflicting system makefiles, injects network bridge configurations (`br-lan` / `eth1`), and sets up branding.
6.  **Compile & Release:** Applies configurations via `make defconfig`, compiles the firmware, and publishes the resulting artifacts as a GitHub Release.

## 🙏 Acknowledgments

*   **m0eak** (for the base structure and template design)
*   [GL.iNet Tech](https://github.com/GLiNet-Tech) (for providing the official hardware source and kernel patches)
*   [OpenWrt Project](https://openwrt.org/)
*   [ImmortalWrt Project](https://immortalwrt.org/)

## 📄 License

[MIT](LICENSE)

---
---

# 🇩🇪 Deutsche Version (German Version)

Dies ist ein spezialisiertes GitHub Actions-basiertes Firmware-Build-Repository, das exklusiv für den **GL.iNet GL-MT5000 (Brume 3)** Router entwickelt wurde. Es nutzt eine leistungsstarke Dual-Workflow-Architektur, um sowohl vollständige Quellcode-Kompilierungen als auch blitzschnelle Imagebuilder-Durchläufe zu ermöglichen, wobei stets eine native Kernel- und Hardware-Kompatibilität garantiert wird.

## 🚀 Kernarchitektur & Quell-Basis

*   **Gerät:** GL.iNet GL-MT5000 (Brume 3)  
*   **Standard-IP:** `192.168.100.1`  
*   **Kernel- & Hardware-Basis:** Um eine 100%ige Hardware-Stabilität (inklusive des Realtek-Switches, des MT7987 SoC und der nativen WLAN-/NSS-Treiber) sicherzustellen, ziehen alle Workflows ausschließlich den offiziellen, nativen GL.iNet-Quellbaum (`mt5000`-Branch von `GLiNet-Tech/openwrt`) als Kernel-Fundament heran.
*   **Software-Feeds („Das Dach“):** Die jeweiligen OpenWrt- oder ImmortalWrt-Oberflächen, LuCI-Dashboards und Paket-Feeds (Master oder Stable 25.12) werden dynamisch auf dieses native GL.iNet-Fundament aufgesetzt.

## 🛠️ Verfügbare Workflows

1.  **`build-gl-mt5000-glinet.yml` (Universal Source Builder)**
    *   **Zweck:** Vollständige Quellcode-Kompilierung mit einem flexiblen GitHub Actions `workflow_dispatch`-Dropdown-Menü, über das du zwischen 4 Umgebungen wählen kannst:
        *   `immortalwrt_master`
        *   `immortalwrt_stable` (25.12)
        *   `openwrt_main`
        *   `openwrt_stable` (25.12)
        *   `all` (Führt alle vier Varianten parallel in einer Matrix aus)
    *   **Features:** Optionaler Docker-Support, automatisierte Einbindung eigener Zusatzpakete über Part 1 & Part 2 Skripte sowie automatisierter Release-Upload.

2.  **`Imagebuilder gl-mt5000.yml` (Fast Image Builder)**
    *   **Zweck:** Schnelle Image-Erstellung auf Basis vorkompilierter SDK-/Imagebuilder-Komponenten für schlanke, zügige Rebuilds bei kleineren Paket- oder Konfigurationsänderungen.

## 📁 Verzeichnisstruktur

*   `.github/workflows/`: Enthält die automatisierten CI/CD-Pipelines (`build-gl-mt5000-glinet.yml` und `imagebuilder`).
*   `config/`: Firmware-spezifische Konfigurationsprofile (`mt5000.config` und `immortalwrt.config`).
*   `sh/scripts-part1.sh`: Pre-Feed-Skript (setzt Standard-IPs und steuert Feed-Zuweisungen).
*   `sh/scripts-part2.sh`: Post-Feed-Skript (klont Custom Packages nach `package/custom`, bereinigt Kconfig-/Makefile-Konflikte, konfiguriert das Netzwerk-Layout und setzt das Branding).
*   `default-settings-m0eak/`: Paket mit persönlichen Standardeinstellungen.
*   `files/`: Rootfs-Overlay, das direkt in das Ziel-Dateisystem kopiert wird.

## ⚙️ Build-Ablauf (Source Builder)

1.  **Trigger:** Workflow manuell über GitHub Actions starten und die gewünschte Zielumgebung auswählen.
2.  **Natives Klonen:** Der offizielle GL.iNet MT5000 Quellbaum (`-b mt5000`) wird in ein isoliertes Arbeitsverzeichnis geklont.
3.  **Teil 1 (`scripts-part1.sh`):** Konfiguriert die Feeds passend zum gewählten Zweig und führt Vorbereitungen (wie das Setzen der IP auf `192.168.100.1`) durch.
4.  **Feeds aktualisieren:** Lädt und installiert alle Paket- und LuCI-Feeds.
5.  **Teil 2 (`scripts-part2.sh`):** Klont Drittanbieter-Repositories (Passwall, MosDNS, Lucky, Custom Themes etc.) nach `package/custom`, entfernt kollidierende Makefiles, injiziert die Netzwerkkonfiguration (`br-lan` / `eth1`) und setzt das Branding.
6.  **Kompilieren & Release:** Generiert die `.config` via `make defconfig`, kompiliert die Firmware und veröffentlicht die fertigen Artefakte als GitHub Release.

## 🙏 Danksagungen

*   **m0eak** (für die exzellente Basisstruktur und das Template-Design)
*   [GL.iNet Tech](https://github.com/GLiNet-Tech) (für die Bereitstellung der offiziellen Hardware-Quellen und Kernel-Patches)
*   [OpenWrt Project](https://openwrt.org/)
*   [ImmortalWrt Project](https://immortalwrt.org/)

## 📄 Lizenz

[MIT](LICENSE)
