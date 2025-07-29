#!/bin/bash

# Mohamed Said - DWM Setup (Ultra-Minimal Expert Version)
# Target: Debian, with selectable NVIDIA driver install, startx, and fish shell
# NOTE: This script assumes 'contrib' and 'non-free' repositories are already enabled by the user.

set -e

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/suckless"
LOG_FILE="$HOME/dwm-install.log"
TEMP_DIR="/tmp/dwm-fonts-$$"

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

# --- NVIDIA Driver Installation Functions ---

# Method 1: Auto-detect the correct driver package
install_nvidia_auto() {
    msg "--- Installing NVIDIA driver using Auto-Detect method ---"
    msg "Updating package list to find NVIDIA drivers..."
    sudo apt-get update
    if ! command -v nvidia-detect &> /dev/null; then
        msg "'nvidia-detect' not found. Make sure 'contrib' and 'non-free' repos are enabled. Skipping."
        return
    fi
    NVIDIA_DRIVER_PACKAGE=$(nvidia-detect | grep -o 'nvidia-driver[a-zA-Z0-9-]*')
    if [ -z "$NVIDIA_DRIVER_PACKAGE" ]; then
        msg "No compatible NVIDIA card detected or driver already installed. Skipping."
        return
    fi
    msg "Detected NVIDIA driver package: $NVIDIA_DRIVER_PACKAGE"
    sudo apt-get install -y "$NVIDIA_DRIVER_PACKAGE" nvidia-settings || die "Failed to install NVIDIA drivers."
    create_xorg_conf
}

# Method 2: Install the standard 'nvidia-driver' package directly
install_nvidia_direct() {
    msg "--- Installing NVIDIA driver using Direct method ---"
    msg "Updating package list..."
    sudo apt-get update
    msg "Installing 'nvidia-driver' and 'nvidia-settings'..."
    sudo apt-get install -y nvidia-driver nvidia-settings || die "Failed to install NVIDIA drivers."
    create_xorg_conf
}

# Function to create the Xorg config file
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

# --- Main prompt to choose installation method ---
prompt_and_install_nvidia() {
    clear
    msg "NVIDIA Driver Installation"
    echo "Please choose the installation method:"
    echo "  1) Auto-Detect Method (Recommended, Safe for all cards)"
    echo "  2) Direct Method (For modern cards, uses 'nvidia-driver' package)"
    echo "  3) Skip NVIDIA Installation"
    echo
    read -p "Enter your choice [1-3]: " choice

    case $choice in
        1) install_nvidia_auto ;;
        2) install_nvidia_direct ;;
        3) msg "Skipping NVIDIA driver installation." ;;
        *) msg "Invalid choice. Skipping NVIDIA driver installation." ;;
    esac
}


# --- Main Script Start ---
clear
echo -e "${CYAN}"
echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "
echo " |m|o|h|a|m|e|d| |s|a|i|d| "
echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "
echo " |d|w|m| |s|e|t|u|p|   | "
echo " +-+-+-+-+-+-+-+-+-+-+-+-+ "
echo -e "${NC}\n"
msg "Starting Minimal DWM setup for Debian (using .xinitrc)."

# Update system
msg "Updating system..."
sudo apt-get update && sudo apt-get upgrade -y

# --- Package Installation ---
# Added explicit build dependencies for DWM: libx11-dev, libxinerama-dev
PACKAGES_CORE=(xorg xorg-dev libx11-dev libxinerama-dev xvkbd xinput build-essential sxhkd xdotool libnotify-bin libnotify-dev)
PACKAGES_UI=(rofi dunst feh lxappearance)
PACKAGES_FILE_MANAGER=(thunar thunar-archive-plugin thunar-volman gvfs-backends dialog mtools unzip)
PACKAGES_AUDIO=(pamixer pipewire-audio wireplumber)
# Removed avahi-daemon, xbacklight, xbindkeys
PACKAGES_UTILITIES=(acpi acpid maim slop xclip nala xdg-user-dirs-gtk eza fish nvidia-detect)
PACKAGES_TERMINAL=(suckless-tools)
PACKAGES_FONTS=(fonts-dejavu-core fonts-noto-naskh-arabic fonts-noto-color-emoji fonts-font-awesome fonts-terminus)
PACKAGES_BUILD=(cmake meson ninja-build curl pkg-config)

# Install packages from repositories
msg "Installing selected packages..."
sudo apt-get install -y "${PACKAGES_CORE[@]}" "${PACKAGES_UI[@]}" "${PACKAGES_FILE_MANAGER[@]}" "${PACKAGES_AUDIO[@]}" "${PACKAGES_UTILITIES[@]}" "${PACKAGES_TERMINAL[@]}" "${PACKAGES_FONTS[@]}" "${PACKAGES_BUILD[@]}" || die "Failed to install packages"

# Prompt for and install NVIDIA Drivers
prompt_and_install_nvidia

# Install Brave Browser
msg "Installing Brave Browser..."
sudo apt-get install -y curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt-get update
sudo apt-get install -y brave-browser || die "Failed to install Brave Browser"

# --- Nerd Font Installation and Configuration ---
msg "Installing Nerd Fonts (FiraCode, JetBrainsMono)..."
mkdir -p "$TEMP_DIR"
declare -a nerd_fonts=("FiraCode" "JetBrainsMono")
for font in "${nerd_fonts[@]}"; do
    wget -q --show-progress -O "$TEMP_DIR/$font.zip" "https://github.com/ryanoasis/nerd-fonts/releases/latest/download/$font.zip" || die "Failed to download $font Nerd Font."
    mkdir -p "$HOME/.local/share/fonts/$font"
    unzip -q -o "$TEMP_DIR/$font.zip" -d "$HOME/.local/share/fonts/$font"
    msg "Installed $font Nerd Font."
done

msg "Creating custom fontconfig file..."
mkdir -p "$HOME/.config/fontconfig"
cat > "$HOME/.config/fontconfig/fonts.conf" << 'EOF'
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
    <match target="font"><edit name="autohint" mode="assign"><bool>false</bool></edit><edit name="hinting" mode="assign"><bool>true</bool></edit><edit name="hintstyle" mode="assign"><const>hintslight</const></edit><edit name="rgba" mode="assign"><const>rgb</const></edit><edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit></match>
    <alias><family>sans-serif</family><prefer><family>Noto Sans</family><family>Noto Naskh Arabic</family><family>FiraCode Nerd Font</family><family>Noto Color Emoji</family></prefer></alias>
    <alias><family>serif</family><prefer><family>Noto Serif</family><family>Noto Naskh Arabic</family><family>FiraCode Nerd Font</family><family>Noto Color Emoji</family></prefer></alias>
    <alias><family>monospace</family><prefer><family>FiraCode Nerd Font</family><family>Noto Naskh Arabic</family><family>Noto Color Emoji</family></prefer></alias>
    <match target="pattern"><test qual="any" name="family"><string>emoji</string></test><edit name="family" mode="assign" binding="strong"><string>Noto Color Emoji</string></edit></match>
</fontconfig>
EOF

msg "Updating font cache..."
fc-cache -fv

# --- System and DWM Configuration ---
# Removed avahi-daemon from systemctl enable
msg "Enabling system services (acpid)..."
sudo systemctl enable acpid
msg "Setting up DWM configuration files..."
if [ -d "$CONFIG_DIR" ]; then
    mv "$CONFIG_DIR" "$CONFIG_DIR.bak.$(date +%s)"
fi
mkdir -p "$CONFIG_DIR"
cp -r "$SCRIPT_DIR"/suckless/* "$CONFIG_DIR"/ || die "Failed to copy configs."

msg "Building and installing suckless tools..."
for tool in dwm slstatus st; do
    if [ -d "$CONFIG_DIR/$tool" ]; then
        cd "$CONFIG_DIR/$tool" && make && sudo make clean install || die "Failed to build $tool"
    fi
done

msg "Creating .xinitrc file..."
cat > "$HOME/.xinitrc" << EOF
#!/bin/sh
feh --bg-scale "$HOME/.config/suckless/wallpaper/default.png" &
dunst &
sxhkd &
slstatus &
exec dwm
EOF
chmod +x "$HOME/.xinitrc"

msg "Creating st desktop entry..."
mkdir -p "$HOME/.local/share/applications"
cat > "$HOME/.local/share/applications/st.desktop" << EOF
[Desktop Entry]
Name=st
Comment=Simple Terminal
Exec=st
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
EOF

msg "Updating XDG user directories..."
xdg-user-dirs-update
mkdir -p "$HOME/Screenshots"

msg "Setting fish as the default shell for user $USER..."
FISH_PATH=$(which fish)
sudo chsh -s "$FISH_PATH" "$USER" || die "Failed to set fish as default shell."

# --- Final Steps ---
echo -e "\n${GREEN}Installation complete!${NC}"
echo -e "${RED}IMPORTANT: A REBOOT IS REQUIRED for the NVIDIA drivers and the new shell to load correctly.${NC}"
echo "After rebooting, log in to the TTY (text console) and run the command: startx"
echo "A log file of this installation has been saved to: ~/dwm-install.log"
