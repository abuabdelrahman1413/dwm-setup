# 🧱 dwm-setup by Mohamed Said

![Made for Debian](https://img.shields.io/badge/Made%20for-Debian-A81D33?style=for-the-badge&logo=debian&logoColor=white)

A minimal suckless DWM setup for Debian-based systems, personalized for my workflow.
Following the suckless philosophy with carefully selected patches — simple, efficient, and hackable.

## 📜 Suckless Philosophy

This setup adheres to the [suckless philosophy](https://suckless.org/philosophy/):
- **Simplicity** - Minimal code, maximum functionality
- **Clarity** - Configuration through clean C header files and shell scripts
- **Hackability** - Easy to understand, modify, and extend

All configuration is done by editing `config.h` files and recompiling — no bloated config systems.

![2025-03-27_03-24](https://github.com/user-attachments/assets/e3f8481a-8eb4-420c-bf84-77218c29a679)

---

## 🚀 Installation

This installer is designed to be run on a fresh Debian installation. It sets up the entire desktop environment, including drivers, applications, and links the configuration files from this repository.

### Quick Install
```bash
git clone https://github.com/abuabdelrahman1413/dwm-setup.git
cd dwm-setup
chmod +x install.sh
sudo ./install.sh
```

**Note:** The script is interactive and will prompt for optional software like NVIDIA drivers, Flatpak, and Obsidian.

### What Gets Installed

The installer is comprehensive and sets up a complete, minimal desktop:

1.  **System Setup** - Updates packages, sets up the Sid repository with APT pinning for specific apps.
2.  **Core Packages** - Essential X11, build tools (`build-essential`, `libx11-dev`), and dependencies.
3.  **NVIDIA Drivers** - (Optional) Installs proprietary NVIDIA drivers with a choice of auto-detection or direct installation.
4.  **Suckless Tools** - Compiles and installs `dwm`, `slstatus`, and `st` from the source in this repository.
5.  **Dotfile Management** - Creates symbolic links from this repository to `~/.config/`, so any change is immediately reflected in your source files.
6.  **Shell & Fonts** - Installs `fish` as the default shell and fetches required Nerd Fonts (`FiraCode`, `JetBrainsMono`).
7.  **Optional Software** - Prompts to install:
    -   **Flatpak** with Flathub and **Joplin**.
    -   **Obsidian** note-taking app.

---

## 📦 Core Applications

This setup uses a curated list of lightweight and powerful applications.

### Suckless & Core Components
| Component         | Purpose                          |
|-------------------|----------------------------------|
| `dwm`             | Tiling window manager (patched)  |
| `st`              | Simple terminal                  |
| `slstatus`        | Status bar for DWM               |
| `sxhkd`           | Keybinding daemon                |
| `xorg` & tools    | Display server and utilities     |
| `build-essential` | Compilation tools                |
| `picom`           | Compositor for effects           |

### UI & System Tools
| Component         | Purpose                          |
|-------------------|----------------------------------|
| `rofi`            | App launcher                     |
| `dunst`           | Lightweight notifications        |
| `feh`             | Wallpaper setter & image viewer  |
| `lxappearance`    | GTK theme manager                |
| `thunar`          | File Manager (+plugins)          |
| `pipewire`        | Audio server (managed via CLI)   |
| `maim` / `slop`   | Screenshot tools                 |
| `Brave`           | Default web browser              |
| `fish`            | Default interactive shell        |
| `nala`            | Better `apt` frontend            |
| `policykit-1-gnome`| Authentication agent for GUI apps|

### Optional Software (prompted)
| Component         | Purpose                          |
|-------------------|----------------------------------|
| Flatpak & Joplin  | App sandboxing and note-taking   |
| Obsidian          | Note-taking and knowledge base   |
| Telegram          | Secure messaging app (from Sid)  |

---

## 🔑 Keybindings Overview

Keybindings are managed by `sxhkd` and are stored in:
`~/.config/sxhkd/sxhkdrc`

DWM's internal window-management keybindings are in:
`~/.config/dwm/config.h`

| Shortcut            | Action                          |
|---------------------|---------------------------------|
| `Super + Enter`     | Launch terminal (`st`)          |
| `Super + d`         | Launch rofi application menu    |
| `Super + q`         | Close focused window            |
| `Super + Shift + c` | Restart DWM in-place            |
| `Super + Shift + q` | Quit DWM session (log out)      |
| `Super + z / v / s` | Cycle through layouts           |
| `Super + 1-0`       | Switch to tag                   |
| `Super + Shift + 1-0`| Move window to tag              |
| `Print`             | Take a region screenshot        |

---

## 🧱 Layouts

These are the layouts included in this build. You can switch between them using the keybindings defined in `config.h` (`Super + z/v/s`).

<details>
<summary>Click to expand layout descriptions</summary>

- **`tile`** (`[]=`) — Classic master-stack (Default)
- **`bstack`** (`TTT`) — Master on top, stack below
- **`monocle`** (`[M]`) — Fullscreen stacked windows
- **Floating** (`><>`) — Free window placement

*(Additional layouts may be present in the source but are not bound to keys by default in this configuration).*

</details>

---

## 📂 Configuration Files

This setup is managed entirely through symbolic links. The `install.sh` script links the directories from the `suckless/` subdirectory of this repository into your `~/.config/` folder. This means any edit you make in `~/.config/` is an edit on your source files, ready to be pushed to Git.

```
~/.config/
├── dwm/         -> (linked from repo's suckless/dwm)
├── st/          -> (linked from repo's suckless/st)
├── slstatus/    -> (linked from repo's suckless/slstatus)
├── sxhkd/       -> (linked from repo's suckless/sxhkd)
├── dunst/       -> (linked from repo's suckless/dunst)
├── picom/       -> (linked from repo's suckless/picom)
├── rofi/        -> (linked from repo's suckless/rofi)
├── fish/        -> (linked from repo's suckless/fish)
└── scripts/     -> (linked from repo's suckless/scripts)
