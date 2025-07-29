# ==============================================================================
# Fish Shell Configuration
# ==============================================================================
# This file is sourced on every shell startup.
# Order of sections: Environment -> PATH -> Aliases & Functions -> Startup

# --- Environment Variables ---
# Set essential environment variables. For security, sensitive data like API
# keys should be managed via a secrets manager, not stored in plaintext here.

set TERM "xterm-256color"      # Sets the terminal type for compatibility
set -x OLLAMA_ORIGINS "app://obsidian.md*"

# WARNING: Storing secrets in plaintext is insecure.
# Consider using a secret manager or private universal variables.
# Example: set -U --local GOOGLE_API_KEY "your_key_here"
set -x GOOGLE_API_KEY 'AIzaSyD-eDpgu35LVH7gpFPtxLnkbqgUrnXGins'
set -x GOOGLE_CLOUD_PROJECT "869371682686"

# Tool-specific environment variables
set -x BUN_INSTALL "$HOME/.bun"
set -x ANDROID_HOME "$HOME/Android/Sdk"


# --- PATH Management ---
# Using `fish_add_path` is the recommended, idempotent way to manage the PATH.
fish_add_path --universal \
    $HOME/.bin \
    /usr/sbin \
    $HOME/.local/bin \
    $HOME/.config/emacs/bin \
    $HOME/go/bin \
    $HOME/.local/opt/go/bin \
    $HOME/.local/opt/flutter/bin \
    $HOME/.local/opt/node/bin \
    $HOME/.local/opt/postgres/bin \
    $HOME/.local/opt/fd-v10.2.0/bin \
    $HOME/.local/opt/shellcheck-v0.10.0/bin \
    $HOME/.local/opt/shfmt-v3.10.0/bin

# Tool-specific paths
fish_add_path --universal $BUN_INSTALL/bin
fish_add_path --universal "$ANDROID_HOME/emulator"
fish_add_path --universal "$ANDROID_HOME/platform-tools"


# --- Aliases and Functions ---
# Simple aliases for commands without arguments, and functions for commands
# that need arguments and autocompletion.



# --- Sourcing External Configurations ---
# Load configurations from other tools like envman.

# Generated for envman. Do not edit.
if test -s ~/.config/envman/load.fish
    source ~/.config/envman/load.fish
end


# --- Startup Commands ---
# Commands to run at the end of shell initialization.

fastfetch



# --- Aliases for pacman ---
alias install='sudo pacman -Syu'          # Update system (sync + upgrade)
alias del='sudo pacman -Rns'          # Remove package(s) with dependencies and config
alias clean='sudo pacman -Sc'        # Clean package cache
alias pacsearch='pacman -Ss'            # Search packages
alias update='sudo pacman -Syyu'

# --- Functions for pacman with autocompletion ---

# Install package(s)
function pacinst
    sudo pacman -S $argv
end
complete -c pacinst -a '(pacman -Ss | awk "{print \$1}" | sort -u)'

# Remove package(s)
function pacrmv
    sudo pacman -Rns $argv
end
complete -c pacrmv -a '(pacman -Qqe)'

# Upgrade system (no args)
function pacupgr
    sudo pacman -Syu
end
