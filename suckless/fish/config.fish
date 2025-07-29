# ==============================================================================
# Fish Shell Configuration - Debian Only
# ==============================================================================

# --- Environment Variables ---
set TERM "xterm-256color"

# مثال لمتغيرات أدوات قد تحتاجها، عدل بحسب حاجتك
#set -x GOOGLE_CLOUD_PROJECT "your_project_id"
#set -x ANDROID_HOME "$HOME/Android/Sdk"

# --- PATH Management ---
fish_add_path --universal \
    $HOME/.bin \
    /usr/sbin \
    $HOME/.local/bin \
    $HOME/.config/emacs/bin

# أضف ما تحتاجه فقط من المسارات حسب أدواتك على ديبيان
# fish_add_path --universal "$ANDROID_HOME/emulator"
# fish_add_path --universal "$ANDROID_HOME/platform-tools"

# --- Aliases and Functions ---

# Aliases for apt (Debian)
alias install='sudo apt update && sudo apt install'     # تثبيت حزمة/حزم
alias del='sudo apt remove'                             # إزالة حزمة
alias clean='sudo apt clean'                            # تنظيف الكاش
alias aptsearch='apt search'                            # البحث عن الحزم
alias update='sudo apt update && sudo apt upgrade'      # تحديث النظام

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
# يمكنك وضع أمر للعرض عند بدء التشغيل مثل:
fastfetch

# انتهى
