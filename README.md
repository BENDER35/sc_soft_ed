# sc_soft_ed / SoftEducativo

[![ES](https://img.shields.io/badge/idoma-ES-es?style=flat-square)](README.md)
[![EN](https://img.shields.io/badge/language-EN-en?style=flat-square)](README.md)

Instalador portable de **software educativo básico y juegos didácticos** para **Linux, Windows y macOS**.
Portable installer for **basic educational software and learning games** for **Linux, Windows and macOS**.

---

## Español

### ¿Qué incluye?

- `install.sh` — instalador para Linux. Detecta y usa **todas las tiendas/gestores disponibles**: APT, DNF/YUM, Zypper, Pacman/AUR, APK, Emerge (Portage), XBPS, eopkg, slackpkg/slpkg, PackageKit, Flatpak, Snap, Nix, Guix, Homebrew/Linuxbrew, AppImage (por URL) y `pkcon`.
- `install.ps1` — instalador para Windows con **winget (incluido Microsoft Store), Chocolatey y Scoop**, con búsqueda por nombre como respaldo.
- `install-mac.sh` — instalador para macOS con **Homebrew (fórmulas y casks), MacPorts, Nix, mas (Mac App Store) y descarga directa**.
- `catalog/apps.tsv` — catálogo de aplicaciones (clave, nombre, área, nivel).
- `catalog/packages.tsv` — equivalencias por tienda (`tienda<TAB>clave<TAB>paquete`).
- `docs/` — guía didáctica, historia del software educativo y significado del temario por asignatura, en **español e inglés**.
- `.github/workflows/` y `.gitlab-ci.yml` — **espejo bidireccional automático** GitHub ⇄ GitLab.

### Inicio rápido

```bash
# Linux (Debian/Ubuntu, Fedora, Arch, openSUSE, Alpine, Gentoo, Void, Solus...)
git clone https://github.com/BENDER35/sc_soft_ed.git
cd sc_soft_ed
chmod +x install.sh install-mac.sh
./install.sh --dry-run          # ver qué se instalaría
./install.sh                    # instalar (pregunta antes de cada tienda)
./install.sh --all-stores       # usar todas las tiendas detectadas
./install.sh --stores apt,flatpak,snap --group all
```

```powershell
# Windows (PowerShell)
git clone https://github.com/BENDER35/sc_soft_ed.git
cd sc_soft_ed
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
.\install.ps1 -DryRun
.\install.ps1 -AllStores
.\install.ps1 -Stores winget,choco -Group all
```

```bash
# macOS
./install-mac.sh --dry-run
./install-mac.sh --all-stores
./install-mac.sh --stores brew,cask,macports
```

Opciones comunes: `--dry-run`, `--all-stores`, `--stores LISTA`, `--group core|extra|all`, `--yes`, `--help`.

### Catálogo resumido

| Área | Software |
|---|---|
| Edad temprana / lógica | GCompris, Tux Paint, Tux Math, Tux Typing, Childsplay |
| Matemáticas | GeoGebra, KAlgebra, Kig, Cantor/KStars, Step |
| Lengua y lectura | Kanagram, KHangMan, KWordQuiz, KTouch, Anki |
| Ciencias | Step, KStars, Kiwix, PhET (enlace web) |
| Programación | Scratch, Thonny, Blockly (enlace web) |
| Geografía e historia | KGeography, Marble, Kiwix |
| Arte y música | GIMP, Inkscape, Krita, Audacity, MuseScore, Scribus |
| Productividad | LibreOffice, Xournal++, Freeplane |

> Los nombres de paquetes varían según distro/tienda. El catálogo incluye alternativas y el instalador omite con un aviso lo que no exista; nunca falla por un paquete ausente.

### Documentación

- [Guía didáctica (ES)](docs/GUIA_DIDACTICA_ES.md) · [Didactic guide (EN)](docs/GUIA_DIDACTICA_EN.md)
- [Historia y significado del temario (ES)](docs/HISTORIA_Y_TEMARIO_ES.md) · [History and curriculum (EN)](docs/HISTORY_AND_CURRICULUM_EN.md)

### Espejo y release

- GitHub: `https://github.com/BENDER35/sc_soft_ed`
- GitLab: `https://gitlab.com/BENDER_5000/sc_soft_ed`
- El espejo es **bidireccional**: un push a cualquiera de los dos se replica en el otro mediante GitHub Actions y GitLab CI.
- Detalles de configuración y verificación: [docs/MIRROR.md](docs/MIRROR.md).
- Release `v1.0.0`: ZIP con código y documentación, publicado en GitHub y replicado en GitLab.

### Aviso

Los scripts **instalan software real** y pueden pedir contraseña de administrador. Revisa `--dry-run` antes de ejecutarlos en un equipo de producción o compartido. No se recopilan datos ni se envían telemetría.

---

## English

### What is included?

- `install.sh` — Linux installer. Detects and uses **every available store/package manager**: APT, DNF/YUM, Zypper, Pacman/AUR, APK, Emerge (Portage), XBPS, eopkg, slackpkg/slpkg, PackageKit, Flatpak, Snap, Nix, Guix, Homebrew/Linuxbrew and AppImage (by URL).
- `install.ps1` — Windows installer using **winget (Microsoft Store included), Chocolatey and Scoop**, with name-search fallback.
- `install-mac.sh` — macOS installer using **Homebrew (formulae and casks), MacPorts, Nix, mas (Mac App Store) and direct downloads**.
- `catalog/apps.tsv` — application catalog (key, name, area, tier).
- `catalog/packages.tsv` — per-store package map (`store<TAB>key<TAB>package`).
- `docs/` — didactic guide, history of educational software and meaning of each subject's syllabus, in **Spanish and English**.
- `.github/workflows/` and `.gitlab-ci.yml` — **automatic bidirectional mirror** GitHub ⇄ GitLab.

### Quick start

See the commands above; the flags are identical on the three platforms.

### Documentation

- [Didactic guide (EN)](docs/GUIA_DIDACTICA_EN.md) · [Guía didáctica (ES)](docs/GUIA_DIDACTICA_ES.md)
- [History and curriculum (EN)](docs/HISTORY_AND_CURRICULUM_EN.md) · [Historia y temario (ES)](docs/HISTORIA_Y_TEMARIO_ES.md)

### Mirror and release

- GitHub: `https://github.com/BENDER35/sc_soft_ed`
- GitLab: `https://gitlab.com/BENDER_5000/sc_soft_ed`
- Mirroring is **bidirectional**: a push to either remote is replicated to the other via GitHub Actions and GitLab CI.
- Setup and verification: [docs/MIRROR.md](docs/MIRROR.md).

### Disclaimer

The scripts **install real software** and may ask for administrator credentials. Run `--dry-run` first on shared or production machines. No telemetry or data collection is performed.

## License

MIT — see [LICENSE](LICENSE).
