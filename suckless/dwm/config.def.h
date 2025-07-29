/* See LICENSE file for copyright and license details. */

/* appearance */
static const unsigned int borderpx  = 2;        /* border pixel of windows */
static const unsigned int snap      = 32;       /* snap pixel */
static const unsigned int gappih    = 10;       /* horiz inner gap between windows */
static const unsigned int gappiv    = 10;       /* vert inner gap between windows */
static const unsigned int gappoh    = 10;       /* horiz outer gap between windows and screen edge */
static const unsigned int gappov    = 10;       /* vert outer gap between windows and screen edge */
static const int smartgaps          = 1;        /* 1 means no outer gap when there is only one window */
static const unsigned int systraypinning = 0;   /* 0: sloppy systray, >0: pin to monitor X */
static const unsigned int systrayonleft = 0;    /* 0: right, >0: left */
static const unsigned int systrayspacing = 2;   /* systray spacing */
static const int systraypinningfailfirst = 1;   /* 1: first monitor, 0: last monitor */
static const int showsystray        = 1;        /* 0 means no systray */
static const int showbar            = 1;        /* 0 means no bar */
static const int topbar             = 1;        /* 0 means bottom bar */
static const char *fonts[]          = { "DejaVu Sans Mono:size=11", "JetBrainsMono Nerd Font:size=12" };
static const char dmenufont[]       = "DejaVu Sans Mono:size=11";

// Doom One Theme from your i3 config
static const char col_bg[]          = "#282c34"; // background
static const char col_fg[]          = "#bbc2cf"; // foreground
static const char col_gray[]        = "#5b6268"; // color8
static const char col_blue[]        = "#51afef"; // color4
static const char col_green[]       = "#98be65"; // color2 (for focused border)
static const char col_red[]         = "#ff6c6b"; // color1 (for urgent)

static const char *colors[][3]      = {
	/*               fg         bg         border   */
	[SchemeNorm] = { col_fg,    col_bg,    col_gray }, // Unfocused windows
	[SchemeSel]  = { col_fg,    col_blue,  col_green  }, // Focused window
};


/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" };

static const Rule rules[] = {
	/* xprop(1):
	 *	WM_CLASS(STRING) = instance, class
	 *	WM_NAME(STRING) = title
	 */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Thunar",   NULL,       NULL,       0,            0,           -1 },
	{ "mpv",      NULL,       NULL,       1 << 3,       1,           -1 },
	{ NULL,       NULL,   "scratchpad",   0,            1,           -1 }, // Rule for the scratchpad terminal
};

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 1 means respect size hints in tiled resizals */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#include "vanitygaps.c"
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* default, vertical layout */
	{ "TTT",      bstack },  /* horizontal layout */
	{ "[M]",      monocle }, /* stacking/tabbed (fullscreen) */
	{ "><>",      NULL },    /* floating behavior */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* helper for spawning shell commands in the pre dwm-5.0 fashion */
#define SHCMD(cmd) { .v = (const char*[]){ "/bin/sh", "-c", cmd, NULL } }

/* commands */
static const char *termcmd[]  = { "st", NULL };
// Scratchpad command
static const char *scratchpadcmd[] = {"st", "-t", "scratchpad", "-g", "120x34", NULL};


#include <X11/XF86keysym.h> // For media keys

static const Key keys[] = {
	/* modifier                     key        function        argument */
	// --- Application Launchers (from i3 config) ---
	{ MODKEY,                       XK_Return, spawn,          {.v = termcmd } },
	{ MODKEY,                       XK_d,      spawn,          SHCMD("rofi -show combi") },
	{ MODKEY,                       XK_b,      spawn,          SHCMD("brave") },
	{ MODKEY|ShiftMask,             XK_f,      spawn,          SHCMD("thunar") },
	
	// --- Window Management (from i3 config) ---
	{ MODKEY,                       XK_q,      killclient,     {0} },
	{ MODKEY,                       XK_f,      fullscreen,     {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },

	// --- Focus and Movement (i3 style: h,j,k,l) ---
	{ MODKEY,                       XK_h,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_l,      focusstack,     {.i = -1 } },
    { MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY|ShiftMask,             XK_h,      movestack,      {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_l,      movestack,      {.i = -1 } },
	{ MODKEY|ShiftMask,             XK_j,      movestack,      {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,      movestack,      {.i = -1 } },

	// --- Layout Control (i3 style) ---
	{ MODKEY,                       XK_z,      setlayout,      {.v = &layouts[0]} }, // Vertical split (tile)
	{ MODKEY,                       XK_v,      setlayout,      {.v = &layouts[1]} }, // Horizontal split (bstack)
	{ MODKEY,                       XK_s,      setlayout,      {.v = &layouts[2]} }, // Stacking/Tabbed (monocle)
	{ MODKEY,                       XK_w,      setlayout,      {.v = &layouts[2]} }, // (w is also tabbed in i3)
	{ MODKEY,                       XK_e,      setlayout,      {0} }, // Toggle previous layout

	// --- Resize (i3 style) ---
	{ MODKEY|ControlMask,           XK_h,      setmfact,       {.f = -0.05} }, // shrink width
	{ MODKEY|ControlMask,           XK_l,      setmfact,       {.f = +0.05} }, // grow width
    // Vertical resize is not a direct DWM equivalent, mfact handles width ratio

	// --- Scratchpad (i3 style) ---
	{ MODKEY,                       XK_n,      togglescratch,  {.v = scratchpadcmd } },
	{ MODKEY|ShiftMask,             XK_n,      togglescratch,  {.v = scratchpadcmd } },

	// --- System and Media Keys (from i3 config) ---
	{ 0, XF86XK_AudioRaiseVolume,    spawn,     SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+; pkill -RTMIN+10 slstatus") },
	{ 0, XF86XK_AudioLowerVolume,    spawn,     SHCMD("wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-; pkill -RTMIN+10 slstatus") },
	{ 0, XF86XK_AudioMute,           spawn,     SHCMD("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle; pkill -RTMIN+10 slstatus") },
	{ 0, XF86XK_AudioMicMute,        spawn,     SHCMD("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle; pkill -RTMIN+11 slstatus") },
	{ 0, XF86XK_MonBrightnessUp,     spawn,     SHCMD("brightnessctl set +10%") },
	{ 0, XF86XK_MonBrightnessDown,   spawn,     SHCMD("brightnessctl set 10%-") },
	{ 0,                            XK_Print,  spawn,     SHCMD("maim -s -u | tee \"$HOME/Screenshots/$(date +%s).png\" | xclip -selection clipboard -t image/png") },

	// --- DWM Specific Controls ---
	{ MODKEY|ControlMask,           XK_b,      togglebar,      {0} },
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY|Mod1Mask,              XK_0,      togglegaps,     {0} },

	// --- Workspace (Tag) Keys (i3 style) ---
	TAGKEYS(                        XK_1,                      0)
	TAGKEYS(                        XK_2,                      1)
	TAGKEYS(                        XK_3,                      2)
	TAGKEYS(                        XK_4,                      3)
	TAGKEYS(                        XK_5,                      4)
	TAGKEYS(                        XK_6,                      5)
	TAGKEYS(                        XK_7,                      6)
	TAGKEYS(                        XK_8,                      7)
	TAGKEYS(                        XK_9,                      8)
	TAGKEYS(                        XK_0,                      9)

	// --- Reload, Restart, Exit (i3 style) ---
	{ MODKEY|ShiftMask,             XK_c,      quit,           {1} }, // Reload/Restart DWM
	{ MODKEY|ShiftMask,             XK_r,      quit,           {1} }, // (Same as above)
	{ MODKEY|ShiftMask,             XK_e,      spawn,          SHCMD("slock") }, // Using slock for exit/lock
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} }, // Quit DWM session

};

/* button definitions */
/* click can be ClkTagBar, ClkLtSymbol, ClkStatusText, ClkWinTitle, ClkClientWin, or ClkRootWin */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkStatusText,        0,              Button2,        spawn,          {.v = termcmd } },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
