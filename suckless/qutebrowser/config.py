# --- Basic Setup ---
# pylint: disable=C0111
c = c  # noqa: F821 pylint: disable=E0602,C0103
config = config  # noqa: F821 pylint: disable=E0602,C0103

# --- Fixed Color Scheme: Tokyo Night ---
bg = "#1a1b26"
fg = "#c0caf5"
color0 = "#15161E"
color1 = "#f7768e"
color2 = "#9ece6a"
color3 = "#e0af68"
color4 = "#7aa2f7"
color5 = "#bb9af7"
color6 = "#7dcfff"
color7 = "#a9b1d6"
color8 = "#414868"
color9 = "#f7768e"
color10 = "#9ece6a"
color11 = "#e0af68"
color12 = "#7aa2f7"
color13 = "#bb9af7"
color14 = "#7dcfff"
color15 = "#c0caf5"

# --- Theme: Apply colors ---

# Status Bar
c.colors.statusbar.normal.bg = bg
c.colors.statusbar.command.bg = bg
c.colors.statusbar.normal.fg = fg
c.colors.statusbar.command.fg = fg
c.colors.statusbar.passthrough.fg = color14
c.colors.statusbar.url.fg = color13
c.colors.statusbar.url.success.https.fg = color10
c.colors.statusbar.url.hover.fg = color12

# Tabs
c.colors.tabs.even.bg = "#00000000"
c.colors.tabs.odd.bg = "#00000000"
c.colors.tabs.bar.bg = "#00000000"
c.colors.tabs.even.fg = color8
c.colors.tabs.odd.fg = color8
c.colors.tabs.selected.even.bg = color12
c.colors.tabs.selected.odd.bg = color12
c.colors.tabs.selected.even.fg = bg
c.colors.tabs.selected.odd.fg = bg

# Completion Menu
c.colors.completion.fg = fg
c.colors.completion.odd.bg = color0
c.colors.completion.even.bg = color0
c.colors.completion.category.fg = color11
c.colors.completion.category.bg = color0
c.colors.completion.item.selected.fg = fg
c.colors.completion.item.selected.bg = color4
c.colors.completion.match.fg = color10

# Hints
c.colors.hints.bg = color3
c.colors.hints.fg = bg
c.hints.border = f"1px solid {fg}"

# --- Misc Settings ---
config.load_autoconfig(False)
# Aliases
c.aliases = {'q': 'quit', 'w': 'session-save', 'wq': 'quit --save'}

# Fonts
c.fonts.default_family = ["Noto Sans Arabic", "DejaVu Sans", "JetBrainsMono Nerd Font", "monospace"]
c.fonts.default_size = '11pt'
c.fonts.web.family.standard = "Noto Sans"
c.fonts.web.family.serif = "Noto Serif"
c.fonts.web.family.sans_serif = "Noto Sans"
c.fonts.web.family.fixed = "JetBrainsMono Nerd Font, monospace"
c.fonts.web.size.default = 18
c.fonts.web.size.default_fixed = 16

# Start & Default Page
# c.url.default_page = 'https://distro.tube/'
# c.url.start_pages = 'https://distro.tube/'

# Tabs
c.auto_save.session = True  # Save session to keep cookies for Cloudflare
# c.tabs.show = "multiple"
c.tabs.padding = {'top': 5, 'bottom': 5, 'left': 9, 'right': 9}
c.tabs.indicator.width = 1
c.tabs.width = '10%'
c.tabs.title.format = "{audio}{current_title}"

# Downloads
c.downloads.location.directory = '~/Downloads'

# Dark Mode
# c.colors.webpage.darkmode.enabled = True
# c.colors.webpage.darkmode.algorithm = 'lightness-cielab'
# c.colors.webpage.darkmode.policy.images = 'never'
# config.set('colors.webpage.darkmode.enabled', False, 'file://*')

# Search Engines
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'am': 'https://www.amazon.com/s?k={}',
    'aw': 'https://wiki.archlinux.org/?search={}',
    'goog': 'https://www.google.com/search?q={}',
    'hoog': 'https://hoogle.haskell.org/?hoogle={}',
    're': 'https://www.reddit.com/r/{}',
    'ub': 'https://www.urbandictionary.com/define.php?term={}',
    'wiki': 'https://en.wikipedia.org/wiki/{}',
    'yt': 'https://www.youtube.com/results?search_query={}',
    '!apkg': 'https://archlinux.org/packages/?sort=&q={}&maintainer=&flagged=',
    '!gh': 'https://github.com/search?o=desc&q={}&s=stars',
}
c.completion.open_categories = ['searchengines', 'quickmarks', 'bookmarks', 'history', 'filesystem']

# Privacy Settings
config.set("content.webgl", True)  # Enable WebGL for Cloudflare
config.set("content.canvas_reading", True)  # Enable Canvas reading for Cloudflare
config.set("content.geolocation", False)
config.set("content.webrtc_ip_handling_policy", "default-public-interface-only")

# Adblocking
# c.content.blocking.enabled = True
# c.content.blocking.method = 'adblock'
c.content.javascript.clipboard = 'access-paste'
c.content.notifications.enabled = True

# JavaScript: Ensure enabled globally
config.set('content.javascript.enabled', True)

# User Agents
# Spoof a modern Chrome User-Agent globally (helps bypass Cloudflare)
# In your config.py, replace your old line with this:

# config.set('content.headers.user_agent', 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/137.0.0.0 Safari/537.36')


config.set('content.headers.user_agent',
'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.6367.207 Safari/537.36')

# Notifications
config.set('content.notifications.enabled', True, 'https://www.reddit.com')
config.set('content.notifications.enabled', True, 'https://www.youtube.com')

# --- Keybindings ---
config.bind('B', 'set-cmd-text -s :bookmark-add --title "{title}"')
# 'YV' for YouTube Video (360p)
config.bind('p3', 'hint links spawn mpv --force-window=immediate --ytdl-format="bestvideo[height<=360]+bestaudio/best[height<=360]" {hint-url}')
config.bind('p4', 'hint links spawn mpv --ytdl-format="bestvideo[height<=480]+bestaudio/best[height<=480]" {hint-url}')
config.bind('p7', 'hint links spawn mpv --ytdl-format="bestvideo[height<=720]+bestaudio/best[height<=720]" {hint-url}')
config.bind('pa', 'hint links spawn --detach mpv --no-video {hint-url}')
config.bind('Z', 'hint links spawn st -e youtube-dl {hint-url}')
config.bind('t', 'set-cmd-text -s :open -t')
config.bind('=', 'set-cmd-text -s :open')
config.bind('h', 'history')
config.bind('cs', 'config-source')
config.bind('tH', 'config-cycle tabs.show multiple never')
config.bind('sH', 'config-cycle statusbar.show always never')
config.bind('T', 'hint links tab-bg')
config.bind('pP', 'open -- {primary}')
config.bind('pp', 'open -- {clipboard}')
config.bind('pt', 'open -t -- {clipboard}')
config.bind('qm', 'macro-record')
config.bind('<ctrl-y>', 'spawn --userscript ytdl.sh')
config.bind('tT', 'config-cycle tabs.position top left')
config.bind('gJ', 'tab-move +')
config.bind('gK', 'tab-move -')
config.bind('gm', 'tab-move')

# --- Open Cloudflare-protected sites automatically in Firefox ---
# Replace 'example.com' with domains you have trouble with
config.set('content.javascript.enabled', True, 'https://*.cloudflare.com/*')
config.set('content.javascript.enabled', True, 'https://*.example-cloudflare-site.com/*')

# Use the 'open -b' command to open in Firefox for such domains
config.bind(',o', 'open -b firefox {url}')

# Optional: autocommand to open cloudflare-protected domains in Firefox automatically
def open_in_firefox_for_cloudflare(url: str) -> bool:
    import re
    cloudflare_domains = [
        r'.*cloudflare.com.*',
        r'.*example-cloudflare-site.com.*',  # Add your problematic domains here
    ]
    for pattern in cloudflare_domains:
        if re.match(pattern, url):
            return True
    return False

config.register_auto_open = lambda url: open_in_firefox_for_cloudflare(url)

# This requires some external scripting or userscript to auto-open in firefox on matching domains,
# as qutebrowser config.py alone doesn't support automatic open in other browsers by URL.
# So manual ',o' keybinding to open current page in Firefox is a simple workaround.

print("Custom static-theme config loaded successfully!")


c.content.cookies.accept = 'all'
