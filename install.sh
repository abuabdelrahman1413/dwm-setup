#!/bin/bash

# Mohamed Said - DWM Setup (Dotfiles Management Version)
# Target: Debian, with Sid pinning, selectable options, startx, and fish shell
# NOTE: This script assumes 'contrib' and 'non-free' for the main release are already enabled by the user.

set -e

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="$HOME/dwm-install.log"
TEMP_DIR="/tmp/dwm-setup-$$"

# Logging and cleanup
exec > >(tee -a "$LOG_FILE") 2>&1
trap "rm -rf $TEMP_DIR" EXIT


# Colors for output messages
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

die() { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }
msg() { echo -e "${CYAN}$*${NC}"; }

# --- Repository Setup Function ---
setup_sid_repository() {
    msg "--- Setting up Debian Sid (Unstable) Repository with Pinning ---"
    msg "Creating /etc/apt/sources.list.d/sid.sources..."
    cat <<EOF | sudo tee /etc/apt/sources.list.d/sid.sources
Types: deb deb-src
URIs: http://deb.debian.org/debian/
Suites: sid
Components: main contrib non-free non-free-firmware
Signed-By: /usr/share/keyrings/debian-archive-keyring.gpg
EOF
    msg "Creating APT pinning preferences to prioritize the main release..."
    sudo mkdir -p /etc/apt/preferences.d
    cat <<EOF | sudo tee /etc/apt/preferences.d/99-sid-priority
Package: *
Pin: release n=sid
Pin-Priority: 100
EOF
    msg "Sid repository setup complete. Updating package lists..."; sudo apt-get update
}


# --- NVIDIA Driver Installation Functions ---
install_nvidia_auto() {
    msg "--- Installing NVIDIA driver using Auto-Detect method ---"
    if ! command -v nvidia-detect &> /dev/null; then msg "'nvidia-detect' not found. Skipping."; return; fi
    NVIDIA_DRIVER_PACKAGE=$(nvidia-detect | grep -o 'nvidia-driver[a-zA-Z0-9-]*')
    if [ -z "$NVIDIA_DRIVER_PACKAGE" ]; then msg "No compatible NVIDIA card detected. Skipping."; return; fi
    msg "Detected NVIDIA driver package: $NVIDIA_DRIVER_PACKAGE"
    sudo apt-get install -y --no-install-recommends --no-install-suggests "$NVIDIA_DRIVER_PACKAGE" nvidia-settings || die "Failed to install NVIDIA drivers."
    create_xorg_conf
}
install_nvidia_direct() {
    msg "--- Installing NVIDIA driver using Direct method ---"
    sudo apt-get install -y --no-install-recommends --no-install-suggests nvidia-driver nvidia-settings || die "Failed to install NVIDIA drivers."
    create_xorg_conf
}
create_xorg_conf() {
    msg "Creating Xorg configuration to load the NVIDIA driver..."
    sudo mkdir -p /etc/X11/xorg.conf.d
    cat <<EOF | sudo tee /etc/X11/xorg.conf.d/20-nvidia.conf
Section "Device"
    Identifier "Nvidia Card"
    Driver     "nvidia"
    VendorName "NVIDIA Corporation"
EndSection
EOF
    msg "NVIDIA driver configuration complete."
}
prompt_and_install_nvidia() {
    clear
    msg "NVIDIA Driver Installation"; echo "Please choose a method:"; echo "  1) Auto-Detect (Recommended)"; echo "  2) Direct (Modern cards)"; echo "  3) Skip"; echo
    read -p "Enter your choice [1-3]: " choice
    case $choice in 1) install_nvidia_auto ;; 2) install_nvidia_direct ;; *) msg "Skipping NVIDIA installation." ;; esac
}

# --- Optional Software Functions ---
prompt_and_install_flatpak() {
    clear
    msg "Optional: Install Flatpak and Joplin?"
    read -p "This will install Flatpak, add the Flathub remote, and install Joplin. (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        msg "Installing Flatpak..."
        sudo apt-get install -y --no-install-recommends --no-install-suggests flatpak gnome-software-plugin-flatpak || die "Failed to install flatpak."
        msg "Adding the Flathub repository..."
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || die "Failed to add Flathub remote."
        msg "Installing Joplin from Flathub..."
        sudo flatpak install -y flathub net.cozic.joplin_desktop || die "Failed to install Joplin."
        msg "Granting Flatpak apps home directory access..."
        sudo flatpak override --filesystem=home
    else
        msg "Skipping Flatpak installation."
    fi
}

prompt_and_install_obsidian() {
    clear
    msg "Optional: Install Obsidian Note-Taking App?"
    read -p "This will download and install the latest .deb package from the official source. (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        local OBSIDIAN_VER="1.5.12"
        local OBSIDIAN_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VER}/obsidian_${OBSIDIAN_VER}_amd64.deb"
        msg "Downloading Obsidian v${OBSIDIAN_VER}..."
        wget -q --show-progress -O "$TEMP_DIR/obsidian.deb" "$OBSIDIAN_URL" || die "Failed to download Obsidian."
        msg "Installing Obsidian..."
        sudo apt-get install -y --no-install-recommends --no-install-suggests "$TEMP_DIR/obsidian.deb" || die "Failed to install Obsidian."
    else
        msg "Skipping Obsidian installation."
    fi
}

# --- Main Script Start ---
clear
echo -e "${CYAN}"; echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "; echo " |m|o|h|a|m|e|d| |s|a|i|d| "; echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "; echo " |d|w|m| |s|e|t|u|p|   | "; echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "; echo -e "${NC}\n"
msg "Starting Dotfiles-Managed DWM setup for Debian."

# Initial System Update & Sid Repo Setup
msg "Performing initial system update and setting up repositories..."
sudo apt-get update && sudo apt-get upgrade -y
setup_sid_repository

# --- Package Installation ---
PACKAGES_CORE=(xorg xorg-dev libx11-dev libxinerama-dev xvkbd xinput build-essential sxhkd xdotool libnotify-bin libnotify-dev)
# ADDED picom and policykit-1-gnome
PACKAGES_UI=(rofi dunst feh lxappearance picom policykit-1-gnome)
PACKAGES_FILE_MANAGER=(thunar thunar-archive-plugin thunar-volman gvfs-backends dialog mtools unzip)
PACKAGES_AUDIO=(pamixer pipewire-audio wireplumber)
PACKAGES_UTILITIES=(acpi acpid maim slop xclip nala xdg-user-dirs-gtk eza fish nvidia-detect)
PACKAGES_TERMINAL=(suckless-tools)
PACKAGES_FONTS=(fonts-dejavu-core fonts-noto-naskh-arabic fonts-noto-color-emoji fonts-font-awesome fonts-terminus)
PACKAGES_BUILD=(cmake meson ninja-build curl pkg-config)

msg "Installing selected packages with minimal dependencies..."
sudo apt-get install -y --no-install-recommends --no-install-suggests "${PACKAGES_CORE[@]}" "${PACKAGES_UI[@]}" "${PACKAGES_FILE_MANAGER[@]}" "${PACKAGES_AUDIO[@]}" "${PACKAGES_UTILITIES[@]}" "${PACKAGES_TERMINAL[@]}" "${PACKAGES_FONTS[@]}" "${PACKAGES_BUILD[@]}" || die "Failed to install packages"

# --- Special Package Installations ---
prompt_and_install_nvidia
msg "Installing Telegram Desktop from Sid repository..."
sudo apt-get install -y -t sid --no-install-recommends --no-install-suggests telegram-desktop || die "Failed to install telegram-desktop from sid."
msg "Installing Brave Browser..."
sudo apt-get install -y --no-install-recommends --no-install-suggests curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt-get update
sudo apt-get install -y --no-install-recommends --no-install-suggests brave-browser || die "Failed to install Brave Browser"

# --- Optional Software Installation ---
prompt_and_install_flatpak
prompt_and_install_obsidian

# --- Nerd Font Installation ---
msg "Installing Nerd Fonts (FiraCode, JetBrainsMono)..."
mkdir -p "$TEMP_DIR"
declare -a nerd_fonts=("FiraCode" "JetBrainsMono")
for font in "${nerd_fonts[@]}"; do
    wget -q --show-progress -O "$TEMP_DIR/$font.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip" || die "Failed to download $font."
    mkdir -p "$HOME/.local/share/fonts/$font" && unzip -q -o "$TEMP_DIR/$font.zip" -d "$HOME/.local/share/fonts/$font" && msg "Installed $font."
done
msg "Creating custom fontconfig file..."; mkdir -p "$HOME/.config/fontconfig"
cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><match target="font"><edit name="autohint" mode="assign"><bool>false</bool></edit><edit name="hinting" mode="assign"><bool>true</bool></edit><edit name="hintstyle" mode="assign"><const>hintslight</const></edit><edit name="rgba" mode="assign"><const>rgb</const></edit><edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit></match><alias><family>sans-serif</family><prefer><family>Noto Sans</family><family>Noto Naskh Arabic</family><family>FiraCode Nerd Font</family><family>Noto Color Emoji</family></prefer></alias><alias><family>serif</family><prefer><family>Noto Serif</family><family>Noto Naskh Arabic</family><family>FiraCode Nerd Font</family><family>Noto Color Emoji</family></prefer></alias><alias><family>monospace</family><prefer><family>FiraCode Nerd Font</family><family>Noto Naskh Arabic</family><family>Noto Color Emoji</family></prefer></alias><match target="pattern"><test qual="any" name="family"><string>emoji</string></test><edit name="family" mode="assign" binding="strong"><string>Noto Color Emoji</string></edit></match></fontconfig>
EOF
msg "Updating font cache..."; fc-cache -fv

# --- System Configuration ---
msg "Enabling system services (acpid)..."; sudo systemctl enable acpid

# --- Configuration Linking ---
msg "Setting up configuration files using symbolic links..."
config_dirs=("dunst" "dwm" "fish" "i3" "picom" "rofi" "scripts" "slstatus" "st" "sxhkd")
mkdir -p "$HOME/.config"
for dir in "${config_dirs[@]}"; do
    SOURCE_PATH="$SCRIPT_DIR/suckless/$dir"
    DEST_PATH="$HOME/.config/$dir"
    if [ ! -d "$SOURCE_PATH" ]; then msg "WARNING: Source directory '$SOURCE_PATH' not found. Skipping link for '$dir'."; continue; fi
    if [ -e "$DEST_PATH" ] || [ -L "$DEST_PATH" ]; then msg "Backing up existing config at '$DEST_PATH'..."; mv "$DEST_PATH" "$DEST_PATH.bak.$(date +%s)"; fi
    msg "Linking '$SOURCE_PATH' to '$DEST_PATH'..."; ln -s "$SOURCE_PATH" "$DEST_PATH" || die "Failed to create symbolic link for '$dir'."
done

# --- Build Suckless Tools ---
msg "Building and installing suckless tools...";
for tool in dwm slstatus st; do
    if [ -d "$HOME/.config/$tool" ]; then cd "$HOME/.config/$tool" && make && sudo make clean install || die "Failed to build $tool"; fi
done

# --- Final Setup ---
# UPDATED: .xinitrc now only calls the autostart script
msg "Creating a simplified .xinitrc file..."
cat > "$HOME/.xinitrc" << EOF
#!/bin/sh

# Launch the autostart script in the background.
# Make sure your autostart script is executable: chmod +x ~/.config/scripts/autostart.sh
[ -x "\$HOME/.config/scripts/autostart.sh" ] && \$HOME/.config/scripts/autostart.sh &

# Execute dwm (this must be the last command)
exec dwm
EOF
chmod +x "$HOME/.xinitrc"

msg "Creating st desktop entry..."; mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/st.desktop" << EOF
[Desktop Entry]
Name=st;Comment=Simple Terminal;Exec=st;Icon=utilities-terminal;Terminal=false;Type=Application;Categories=System;TerminalEmulator;
EOF
msg "Updating XDG user directories..."; xdg-user-dirs-update; mkdir -p "$HOME/Screenshots"
msg "Setting fish as the default shell for user $USER...";
FISH_PATH=$(which fish); sudo chsh -s "$FISH_PATH" "$USER" || die "Failed to set fish shell."

# --- Final Steps ---
echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${RED}IMPORTANT: A REBOOT IS REQUIRED for the NVIDIA drivers and the new shell to load correctly.${NC}"
echo "After rebooting, log in to the TTY (text console) and run the command: startx"
echo "A log file of this installation has been saved to: ~/dwm-install.log"
