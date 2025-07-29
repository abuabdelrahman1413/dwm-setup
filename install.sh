#!/bin/bash

# Mohamed Said - DWM Setup (Personal Cleaned & Minimal Version)
# Target: Debian, using startx (.xinitrc)

set -e

# Paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config/suckless"
LOG_FILE="$HOME/dwm-install.log"

# Logging and cleanup
exec > >(tee -a "$LOG_FILE") 2>&1

# Colors for output messages
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

die() { echo -e "${RED}ERROR: $*${NC}" >&2; exit 1; }
msg() { echo -e "${CYAN}$*${NC}"; }

# --- Script Start ---
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
# Minimal package list with maim for screenshots.
PACKAGES_CORE=(xorg xorg-dev xbacklight xbindkeys xvkbd xinput build-essential sxhkd xdotool libnotify-bin libnotify-dev)
PACKAGES_UI=(rofi dunst feh lxappearance)
PACKAGES_FILE_MANAGER=(thunar thunar-archive-plugin thunar-volman gvfs-backends dialog mtools unzip)
PACKAGES_AUDIO=(pamixer pipewire-audio wireplumber)
# Replaced flameshot with maim, slop, and xclip
PACKAGES_UTILITIES=(avahi-daemon acpi acpid maim slop xclip qimgv nala xdg-user-dirs-gtk eza)
PACKAGES_TERMINAL=(suckless-tools)
PACKAGES_FONTS=(fonts-recommended fonts-font-awesome fonts-terminus)
PACKAGES_BUILD=(cmake meson ninja-build curl pkg-config)

# Install packages
msg "Installing selected packages..."
sudo apt-get install -y "${PACKAGES_CORE[@]}" "${PACKAGES_UI[@]}" "${PACKAGES_FILE_MANAGER[@]}" "${PACKAGES_AUDIO[@]}" "${PACKAGES_UTILITIES[@]}" "${PACKAGES_TERMINAL[@]}" "${PACKAGES_FONTS[@]}" "${PACKAGES_BUILD[@]}" || die "Failed to install packages"

# Install Brave Browser
msg "Installing Brave Browser..."
sudo apt-get install -y curl
sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
sudo apt-get update
sudo apt-get install -y brave-browser || die "Failed to install Brave Browser"

# Enable essential services
msg "Enabling system services (acpid, avahi)..."
sudo systemctl enable acpid avahi-daemon

# --- Configuration Setup ---
if [ -d "$CONFIG_DIR" ]; then
    msg "Existing suckless config found. Backing it up..."
    mv "$CONFIG_DIR" "$CONFIG_DIR.bak.$(date +%s)"
fi
msg "Setting up configuration files..."
mkdir -p "$CONFIG_DIR"
cp -r "$SCRIPT_DIR"/suckless/* "$CONFIG_DIR"/ || die "Failed to copy configs. Make sure the 'suckless' directory is present."

# --- Build and Install Suckless Tools ---
msg "Building and installing suckless tools (dwm, slstatus, st)..."
for tool in dwm slstatus st; do
    if [ -d "$CONFIG_DIR/$tool" ]; then
        cd "$CONFIG_DIR/$tool" || die "Cannot find directory $CONFIG_DIR/$tool"
        make && sudo make clean install || die "Failed to build and install $tool"
    else
        msg "Warning: Could not find sources for $tool in $CONFIG_DIR. Skipping build."
    fi
done

# --- Create .xinitrc for startx ---
msg "Creating .xinitrc file to start DWM..."
cat > "$HOME/.xinitrc" << EOF
#!/bin/sh

# Set wallpaper (adjust path if needed)
feh --bg-scale "$HOME/.config/suckless/wallpaper/default.png" &

# Start notification daemon
dunst &

# Start hotkey daemon
sxhkd &

# Start status bar
slstatus &

# Execute the window manager (last command)
exec dwm
EOF

chmod +x "$HOME/.xinitrc"
msg "Successfully created executable ~/.xinitrc"

# Create .desktop entry for the 'st' terminal so it appears in rofi
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

# Setup user directories
msg "Updating XDG user directories..."
xdg-user-dirs-update
mkdir -p "$HOME/Screenshots"

# --- Final Steps ---
echo -e "\n${GREEN}Installation complete!${NC}"
echo "IMPORTANT: Remember to update your sxhkdrc with 'maim' commands for screenshots."
echo "To start your new DWM session, log out, then log in to the TTY (text console)"
echo "and run the command: startx"
echo "A log file of this installation has been saved to: ~/dwm-install.log"
