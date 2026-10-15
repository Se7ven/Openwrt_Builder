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
7.  **Compile:** Generate the `.config` via `make defconfig`, pre-compile toolchains, download dependencies, and execute the final build.
8.  **Release:** Automatically package and upload the finished Sysupgrade/Factory artifacts as a GitHub Release.

## 💻 Local Verification

In a Bash environment, you can perform a syntax check on the shell scripts beforehand to prevent build errors:

```bash
bash -n sh/scripts-part1.sh
bash -n sh/scripts-part2.sh
```

*Note: Due to massive resource and time requirements, actual firmware compilation should always be executed directly within GitHub Actions.*

## 🙏 Acknowledgments

*   **m0eak** (for the excellent base structure and OpenWrt Builder template)
*   [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
*   [OpenWrt Project](https://openwrt.org/)
*   [ImmortalWrt Project](https://immortalwrt.org/)

## 📄 License

[MIT](LICENSE)

---
---

# 🇩🇪 Deutsche Version (German Version)

Dies ist ein auf GitHub Actions basierendes Repository zur Firmware-Erstellung für den GL.iNet GL-MT5000 (Brume 3). Es ist speziell dafür ausgelegt, den Quellcode automatisch abzurufen, benutzerdefinierte Pakete und Optimierungen zu integrieren sowie saubere, voll funktionsfähige Firmware-Images für OpenWrt und ImmortalWrt zu kompilieren.

## 🚀 Unterstützte Firmware-Varianten & Geräte

**Gerät:** GL-MT5000 (Brume 3)  
**Standard-IP:** `192.168.100.1`  
**Basis-System:** Um eine 100%ige Hardware-Kompatibilität (insbesondere für den Realtek RTL8366UB DSA-Switch und den MT7987 SoC) zu gewährleisten, nutzen alle Builds den nativen GL.iNet-Quellbaum als Fundament. Die spezifischen OpenWrt- oder ImmortalWrt-Eigenschaften werden durch das Einbinden der jeweiligen offiziellen Paket- und LuCI-Feeds erreicht.

### Verfügbare Workflows:
*   **ImmortalWrt (Master)** – via `Build immortalwrt.yml`
*   **ImmortalWrt (25.12 Stable)** – via `Immortalwrt Brume 3 stable.yml`
*   **OpenWrt (Master)** – via `Build filogic.yml`
*   **OpenWrt (25.12 Stable)** – via `OpenWrt Brume 3 stable (25.12).yml`

## 📁 Verzeichnisstruktur

*   `.github/workflows/`: Enthält die automatisierten Build- und Release-Pipelines für alle Firmware-Varianten.
*   `.github/actions/`: Lokale Composite-Actions, die während der Release- und Upload-Phasen verwendet werden.
*   `config/`: Enthält die firmware-spezifischen `.config`-Dateien (`mt5000.config` für OpenWrt und `immortalwrt.config` für ImmortalWrt).
*   `sh/scripts-part1.sh`: Quellcode-Modifikationen und Patch-Injektionen, die *vor* den Feed-Updates ausgeführt werden.
*   `sh/scripts-part2.sh`: Benutzerdefinierte Skripte, die *nach* der Feed-Installation ausgeführt werden, um eigene Pakete hinzuzufügen, Kconfig-Abhängigkeitskonflikte (z.B. OpenVSwitch) aufzulösen und Standard-Themes/Netzwerkkonfigurationen zu setzen.
*   `default-settings-m0eak/`: Paket mit benutzerdefinierten Standardeinstellungen für persönliche Konfigurationen.
*   `files/`: Rootfs-Overlay, das direkt in den Build-Tree kopiert wird (`openwrt/files`), um Systemdateien zu überschreiben.

## 🛠️ Build-Ablauf

1.  **Trigger:** Den entsprechenden Workflow über GitHub Actions starten (manuell oder zeitgesteuert).
2.  **Klonen:** Der optimierte GL.iNet OpenWrt-Quellbaum wird geklont, um perfekte Hardware-Unterstützung zu garantieren.
3.  **Teil 1:** `sh/scripts-part1.sh` für Quellcode-Vorbereitungen und Pre-Feed-Patches ausführen.
4.  **Feeds:** Spezifische Paket-Feeds aktualisieren und installieren (ImmortalWrt oder OpenWrt, je nach Workflow).
5.  **Teil 2:** `sh/scripts-part2.sh` ausführen, um zirkuläre Abhängigkeiten (z. B. OpenVSwitch) zu bereinigen und individuelle Pakete (Passwall, Lucky, Footstrap etc.) hinzuzufügen.
6.  **Konfiguration:** `default-settings-m0eak`, das `files/`-Overlay und die jeweilige Konfiguration (`mt5000.config` oder `immortalwrt.config`) einfügen.
7.  **Kompilieren:** Die `.config` über `make defconfig` generieren, Toolchains vorkompilieren, Abhängigkeiten herunterladen und den finalen Build ausführen.
8.  **Release:** Die fertigen Sysupgrade-/Factory-Artefakte automatisch verpacken und als GitHub Release hochladen.

## 💻 Lokale Überprüfung

In einer Bash-Umgebung kannst du vorab eine Syntaxprüfung der Shell-Skripte durchführen, um Build-Fehler zu vermeiden:

```bash
bash -n sh/scripts-part1.sh
bash -n sh/scripts-part2.sh
```

*Hinweis: Aufgrund des enormen Ressourcen- und Zeitbedarfs sollte die eigentliche Firmware-Kompilierung immer direkt innerhalb von GitHub Actions ausgeführt werden.*

## 🙏 Danksagungen

*   **m0eak** (für die exzellente Basisstruktur und das OpenWrt Builder Template)
*   [P3TERX/Actions-OpenWrt](https://github.com/P3TERX/Actions-OpenWrt)
*   [OpenWrt Project](https://openwrt.org/)
*   [ImmortalWrt Project](https://immortalwrt.org/)

## 📄 Lizenz

[MIT](LICENSE)
