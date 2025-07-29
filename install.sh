#!/bin/bash

# Mohamed Said - DWM Setup (Advanced Dotfiles Management)
# Target: Debian, with Sid pinning, nala, smart linking, iwd, startx, and fish shell
# NOTE: This script assumes 'nala', 'contrib', and 'non-free' repos are already set up.

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
    msg "Sid repository setup complete. Updating package lists..."; sudo nala update
}


# --- NVIDIA Driver Installation Function (Simplified) ---
install_nvidia_driver() {
    msg "--- Installing Standard NVIDIA Driver ---"
    sudo nala install -y --no-install-recommends --no-install-suggests nvidia-driver nvidia-settings || die "Failed to install NVIDIA drivers."
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

# --- Optional Software Functions ---
prompt_and_install_flatpak() {
    clear; msg "Optional: Install Flatpak and Joplin?"
    read -p "(y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        msg "Installing Flatpak..."; sudo nala install -y --no-install-recommends --no-install-suggests flatpak gnome-software-plugin-flatpak || die "Failed to install flatpak."
        msg "Adding Flathub..."; sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        msg "Installing Joplin..."; sudo flatpak install -y flathub net.cozic.joplin_desktop
        msg "Granting home access..."; sudo flatpak override --filesystem=home
    else msg "Skipping Flatpak installation."; fi
}

prompt_and_install_obsidian() {
    clear; msg "Optional: Install Obsidian Note-Taking App?"
    read -p "(y/n) " -n 1 -r; echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        local OBSIDIAN_VER="1.5.12"
        local OBSIDIAN_URL="https://github.com/obsidianmd/obsidian-releases/releases/download/v${OBSIDIAN_VER}/obsidian_${OBSIDIAN_VER}_amd64.deb"
        msg "Downloading Obsidian..."; wget -q --show-progress -O "$TEMP_DIR/obsidian.deb" "$OBSIDIAN_URL"
        msg "Installing Obsidian..."; sudo nala install -y --no-install-recommends --no-install-suggests "$TEMP_DIR/obsidian.deb"
    else msg "Skipping Obsidian installation."; fi
}

# --- Main Script Start ---
clear
echo -e "${CYAN}"; echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "; echo " |m|o|h|a|m|e|d| |s|a|i|d| "; echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "; echo " |d|w|m| |s|e|t|u|p|   | "; echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "; echo -e "${NC}\n"
msg "Starting DWM setup for Debian."

# --- Configuration Linking (Moved to the beginning) ---
msg "Step 1: Setting up configuration files using symbolic links..."
CONFIG_SOURCE_PARENT_DIR="$SCRIPT_DIR/suckless"
CONFIG_DEST_PARENT_DIR="$HOME/.config"

if [ ! -d "$CONFIG_SOURCE_PARENT_DIR" ]; then die "Source config dir '$CONFIG_SOURCE_PARENT_DIR' not found! Aborting."; fi
mkdir -p "$CONFIG_DEST_PARENT_DIR"

# Loop through each directory in the source and link it to the destination
for config_dir in "$CONFIG_SOURCE_PARENT_DIR"/*/; do
    config_dir_clean=${config_dir%*/}
    config_name=$(basename "$config_dir_clean")
    
    SOURCE_PATH="$config_dir_clean"
    DEST_PATH="$CONFIG_DEST_PARENT_DIR/$config_name"

    if [ -e "$DEST_PATH" ] || [ -L "$DEST_PATH" ]; then
        msg "Backing up existing config at '$DEST_PATH'..."
        mv "$DEST_PATH" "$DEST_PATH.bak.$(date +%s)"
    fi
    msg "Linking '$SOURCE_PATH' to '$DEST_PATH'..."
    ln -s "$SOURCE_PATH" "$DEST_PATH" || die "Failed to create symbolic link for '$config_name'."
done
msg "Configuration links created successfully."

# Initial System Update & Sid Repo Setup
msg "Step 2: Performing initial system update and setting up repositories..."
sudo nala update && sudo nala upgrade -y
setup_sid_repository

# --- Package Installation ---
msg "Step 3: Installing packages..."
PACKAGES_CORE=(xorg xorg-dev libx11-dev libxinerama-dev xvkbd xinput build-essential sxhkd xdotool libnotify-bin libnotify-dev)
PACKAGES_UI=(rofi dunst feh lxappearance picom policykit-1-gnome)
PACKAGES_FILE_MANAGER=(thunar thunar-archive-plugin thunar-volman gvfs-backends dialog mtools unzip)
PACKAGES_AUDIO=(pamixer pipewire-audio wireplumber)
PACKAGES_UTILITIES=(acpi acpid maim slop xclip xdg-user-dirs-gtk eza fish vim iwd)
PACKAGES_TERMINAL=(suckless-tools)
PACKAGES_FONTS=(fonts-noto-* fonts-font-awesome fonts-terminus)
PACKAGES_BUILD=(cmake meson ninja-build curl pkg-config)

msg "Installing core packages with minimal dependencies..."
sudo nala install -y --no-install-recommends --no-install-suggests "${PACKAGES_CORE[@]}" "${PACKAGES_UI[@]}" "${PACKAGES_FILE_MANAGER[@]}" "${PACKAGES_AUDIO[@]}" "${PACKAGES_UTILITIES[@]}" "${PACKAGES_TERMINAL[@]}" "${PACKAGES_FONTS[@]}" "${PACKAGES_BUILD[@]}" || die "Failed to install packages"

# --- Network Configuration ---
msg "Configuring NetworkManager to use iwd as the Wi-Fi backend..."
sudo mkdir -p /etc/NetworkManager/conf.d
cat <<EOF | sudo tee /etc/NetworkManager/conf.d/wifi_backend.conf
[device]
wifi.backend=iwd
EOF

# --- Special Package Installations ---
install_nvidia_driver
msg "Installing Geany and plugins from Sid repository..."
sudo nala install -y -t sid --no-install-recommends --no-install-suggests geany geany-plugins || die "Failed to install geany from sid."
msg "Installing Telegram Desktop from Sid repository..."
sudo nala install -y -t sid --no-install-recommends --no-install-suggests telegram-desktop || die "Failed to install telegram-desktop from sid."
msg "Installing Brave Browser..."
sudo nala install -y --no-install-recommends --no-install-suggests curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo nala update
sudo nala install -y --no-install-recommends --no-install-suggests brave-browser || die "Failed to install Brave Browser"

# --- Optional Software Installation ---
prompt_and_install_flatpak
prompt_and_install_obsidian

# --- Smart Nerd Font Installation ---
msg "Checking and installing Nerd Fonts..."
mkdir -p "$TEMP_DIR"
declare -A nerd_fonts
nerd_fonts["JetBrainsMono Nerd Font"]="JetBrainsMono.zip"
nerd_fonts["FiraCode Nerd Font"]="FiraCode.zip"
for font_name in "${!nerd_fonts[@]}"; do
    font_zip="${nerd_fonts[$font_name]}"
    if fc-list | grep -q "$font_name"; then
        msg "Font '$font_name' already installed. Skipping download."
    else
        msg "Downloading and installing '$font_name'..."
        wget -q --show-progress -O "$TEMP_DIR/$font_zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font_zip" || die "Failed to download $font_name."
        mkdir -p "$HOME/.local/share/fonts/$(basename "$font_zip" .zip)" && unzip -q -o "$TEMP_DIR/$font_zip" -d "$HOME/.local/share/fonts/$(basename "$font_zip" .zip)" && msg "Installed $font_name."
    fi
done
msg "Creating custom fontconfig file..."; mkdir -p "$HOME/.config/fontconfig"
cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?><!DOCTYPE fontconfig SYSTEM "fonts.dtd"><fontconfig><match target="font"><edit name="autohint" mode="assign"><bool>false</bool></edit><edit name="hinting" mode="assign"><bool>true</bool></edit><edit name="hintstyle" mode="assign"><const>hintslight</const></edit><edit name="rgba" mode="assign"><const>rgb</const></edit><edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit></match><alias><family>sans-serif</family><prefer><family>Noto Sans</family><family>Noto Naskh Arabic</family><family>FiraCode Nerd Font</family><family>Noto Color Emoji</family></prefer></alias><alias><family>serif</family><prefer><family>Noto Serif</family><family>Noto Naskh Arabic</family><family>FiraCode Nerd Font</family><family>Noto Color Emoji</family></prefer></alias><alias><family>monospace</family><prefer><family>FiraCode Nerd Font</family><family>Noto Naskh Arabic</family><family>Noto Color Emoji</family></prefer></alias><match target="pattern"><test qual="any" name="family"><string>emoji</string></test><edit name="family" mode="assign" binding="strong"><string>Noto Color Emoji</string></edit></match></fontconfig>
EOF
msg "Updating font cache..."; fc-cache -fv

# --- System Services Configuration ---
msg "Enabling system services (acpid, iwd)..."; sudo systemctl enable acpid iwd

# --- Build Suckless Tools ---
msg "Building and installing suckless tools...";
for tool in dwm slstatus st; do
    BUILD_PATH="$HOME/.config/$tool"
    if [ -d "$BUILD_PATH" ]; then cd "$BUILD_PATH" && make && sudo make clean install || die "Failed to build $tool"; fi
done

# --- Final Setup ---
msg "Creating a simplified .xinitrc file...";
cat > "$HOME/.xinitrc" << EOF
#!/bin/sh
[ -x "\$HOME/.config/scripts/autostart.sh" ] && \$HOME/.config/scripts/autostart.sh &
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
echo -e "${RED}IMPORTANT: A REBOOT IS REQUIRED for the NVIDIA drivers, network changes, and the new shell to load correctly.${NC}"
echo "After rebooting, log in to the TTY (text console) and run the command: startx"
echo "A log file of this installation has been saved to: ~/dwm-install.log"
