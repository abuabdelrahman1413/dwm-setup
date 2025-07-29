ؤ#!/bin/bash

# Mohamed Said - DWM Setup (Personal Cleaned & Minimal Version)
# Target: Debian, using startx (.xinitrc)

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
PACKAGES_CORE=(xorg xorg-dev xbacklight xbindkeys xvkbd xinput build-essential sxhkd xdotool libnotify-bin libnotify-dev)
PACKAGES_UI=(rofi dunst feh lxappearance)
PACKAGES_FILE_MANAGER=(thunar thunar-archive-plugin thunar-volman gvfs-backends dialog mtools unzip)
PACKAGES_AUDIO=(pamixer pipewire-audio wireplumber)
PACKAGES_UTILITIES=(avahi-daemon acpi acpid maim slop xclip nala xdg-user-dirs-gtk eza)
PACKAGES_TERMINAL=(suckless-tools)
PACKAGES_FONTS=(fonts-dejavu-core fonts-noto-naskh-arabic fonts-noto-color-emoji fonts-font-awesome fonts-terminus)
PACKAGES_BUILD=(cmake meson ninja-build curl pkg-config)

# Install packages from repositories
msg "Installing selected packages..."
sudo apt-get install -y "${PACKAGES_CORE[@]}" "${PACKAGES_UI[@]}" "${PACKAGES_FILE_MANAGER[@]}" "${PACKAGES_AUDIO[@]}" "${PACKAGES_UTILITIES[@]}" "${PACKAGES_TERMINAL[@]}" "${PACKAGES_FONTS[@]}" "${PACKAGES_BUILD[@]}" || die "Failed to install packages"

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
# Define Nerd Fonts to install
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
    <!-- General font rendering settings -->
    <match target="font">
        <edit name="autohint" mode="assign"><bool>false</bool></edit>
        <edit name="hinting" mode="assign"><bool>true</bool></edit>
        <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
        <edit name="rgba" mode="assign"><const>rgb</const></edit>
        <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
    </match>
    <!-- Font family aliases -->
    <!-- Sans-serif -->
    <alias>
        <family>sans-serif</family>
        <prefer>
            <family>Noto Sans</family>
            <family>Noto Naskh Arabic</family>
            <family>FiraCode Nerd Font</family>
            <family>Noto Color Emoji</family>
        </prefer>
    </alias>
    <!-- Serif -->
    <alias>
        <family>serif</family>
        <prefer>
            <family>Noto Serif</family>
            <family>Noto Naskh Arabic</family>
            <family>FiraCode Nerd Font</family>
            <family>Noto Color Emoji</family>
        </prefer>
    </alias>
    <!-- Monospace -->
    <alias>
        <family>monospace</family>
        <prefer>
            <family>FiraCode Nerd Font</family>
            <family>Noto Naskh Arabic</family>
            <family>Noto Color Emoji</family>
        </prefer>
    </alias>
    <!-- Explicitly use Noto Color Emoji for emoji -->
    <match target="pattern">
        <test qual="any" name="family"><string>emoji</string></test>
        <edit name="family" mode="assign" binding="strong">
            <string>Noto Color Emoji</string>
        </edit>
    </match>
</fontconfig>
EOF

msg "Updating font cache..."
fc-cache -fv

# --- System and DWM Configuration ---
# Enable essential services
msg "Enabling system services (acpid, avahi)..."
sudo systemctl enable acpid avahi-daemon

# Copy DWM configs
if [ -d "$CONFIG_DIR" ]; then
    msg "Existing suckless config found. Backing it up..."
    mv "$CONFIG_DIR" "$CONFIG_DIR.bak.$(date +%s)"
fi
msg "Setting up configuration files..."
mkdir -p "$CONFIG_DIR"
cp -r "$SCRIPT_DIR"/suckless/* "$CONFIG_DIR"/ || die "Failed to copy configs. Make sure the 'suckless' directory is present."

# Build and Install Suckless Tools
msg "Building and installing suckless tools (dwm, slstatus, st)..."
for tool in dwm slstatus st; do
    if [ -d "$CONFIG_DIR/$tool" ]; then
        cd "$CONFIG_DIR/$tool" || die "Cannot find directory $CONFIG_DIR/$tool"
        make && sudo make clean install || die "Failed to build and install $tool"
    else
        msg "Warning: Could not find sources for $tool in $CONFIG_DIR. Skipping build."
    fi
done

# Create .xinitrc for startx
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

# Create .desktop entry for 'st' so it appears in rofi
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
echo "To start your new DWM session, log out, then log in to the TTY (text console)"
echo "and run the command: startx"
echo "A log file of this installation has been saved to: ~/dwm-install.log"
