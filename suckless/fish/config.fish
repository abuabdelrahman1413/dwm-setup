# ==============================================================================
# Fish Shell Configuration - Debian Only
# ==============================================================================

# --- Environment Variables ---
set TERM "xterm-256color"

# Example for tool variables you might need, edit as needed
#set -x GOOGLE_CLOUD_PROJECT "your_project_id"
#set -x ANDROID_HOME "$HOME/Android/Sdk"

# --- PATH Management ---
fish_add_path --universal \
    $HOME/.bin \
    /usr/sbin \
    $HOME/.local/bin \
    $HOME/.config/emacs/bin

# Add only the paths you need for your tools on Debian
# fish_add_path --universal "$ANDROID_HOME/emulator"
# fish_add_path --universal "$ANDROID_HOME/platform-tools"

# --- Aliases and Functions ---

# Aliases for apt (Debian)
alias install='sudo apt update && sudo apt install'     # Install package(s)
alias del='sudo apt remove'                             # Remove package
alias clean='sudo apt clean'                            # Clean cache
alias aptsearch='apt search'                            # Search for packages
alias update='sudo apt update && sudo apt upgrade'      # System update

# Functions for apt
function aptinst
    sudo apt install $argv
end

function aptrmv
    sudo apt remove $argv
end

function aptupgr
    sudo apt upgrade
end

# --- Startup Commands ---
# You can put a command to display on startup, e.g.:
fastfetch

# End
