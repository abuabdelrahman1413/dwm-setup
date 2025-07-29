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

// Doom One Theme
static const char col_bg[]          = "#282c34"; // background
static const char col_fg[]          = "#bbc2cf"; // foreground
static const char col_gray[]        = "#5b6268"; // unfocused border
static const char col_blue[]        = "#51afef"; // focused bg
static const char col_green[]       = "#98be65"; // focused border

static const char *colors[][3]      = {
	/*               fg      bg       border   */
	[SchemeNorm] = { col_fg, col_bg,   col_gray },
	[SchemeSel]  = { col_fg, col_blue, col_green },
};

/* Spatchpads */
typedef struct {
	const char *name;
	const void *cmd;
} Sp;
const char *spcmd1[] = {"st", "-n", "spterm", "-g", "120x34", NULL };
static Sp scratchpads[] = {
	/* name          cmd  */
	{"spterm",      spcmd1},
};


/* Autostart */
static const char *const autostart[] = {
	"sh", "-c", "~/.config/scripts/autostart.sh", NULL,
	NULL /* terminate */
};

/* tagging */
static const char *tags[] = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "10" };

static const Rule rules[] = {
	/* xprop(1): WM_CLASS(STRING) = instance, class | WM_NAME(STRING) = title */
	/* class      instance    title       tags mask     isfloating   monitor */
	{ "Thunar",   NULL,       NULL,       0,            0,           -1 },
	{ "mpv",      NULL,       NULL,       1 << 3,       1,           -1 },
	{ "Lxappearance", NULL,   NULL,       0,            1,           -T1 },
	{ NULL,		  "spterm",	  NULL,		  SPTAG(0),	    1,		     -1 },
};

/* window following */
#define WFACTIVE '>'
#define WFINACTIVE 'v'
#define WFDEFAULT WFACTIVE

/* layout(s) */
static const float mfact     = 0.55; /* factor of master area size [0.05..0.95] */
static const int nmaster     = 1;    /* number of clients in master area */
static const int resizehints = 0;    /* 0 means smarter resizing */
static const int lockfullscreen = 1; /* 1 will force focus on the fullscreen window */

#define FORCE_VSPLIT 1
#include "vanitygaps.c"

/* List of layouts supported by your patches */
static const Layout layouts[] = {
	/* symbol     arrange function */
	{ "[]=",      tile },    /* default */
	{ "TTT",      bstack },
	{ "[M]",      monocle },
	{ "><>",      NULL },    /* floating */
};

/* key definitions */
#define MODKEY Mod4Mask
#define TAGKEYS(KEY,TAG) \
	{ MODKEY,                       KEY,      view,           {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask,           KEY,      toggleview,     {.ui = 1 << TAG} }, \
	{ MODKEY|ShiftMask,             KEY,      tag,            {.ui = 1 << TAG} }, \
	{ MODKEY|ControlMask|ShiftMask, KEY,      toggletag,      {.ui = 1 << TAG} },

/* All application launchers and system controls are in sxhkdrc. */
/* This file only handles DWM's internal window management. */
#include "movestack.c"

static const Key keys[] = {
	/* modifier                     key        function        argument */
    /* NOTE: Super+Enter (terminal) and Super+d (rofi) are in sxhkdrc */

	// --- Window Management ---
	{ MODKEY,                       XK_q,      killclient,     {0} },
	{ MODKEY|ShiftMask,             XK_f,      fullscreen,     {0} },
	{ MODKEY|ShiftMask,             XK_space,  togglefloating, {0} },
	{ MODKEY|ControlMask,           XK_b,      togglebar,      {0} },

	// --- Focus and Movement (i3 style: h,j,k,l) ---
	{ MODKEY,                       XK_j,      focusstack,     {.i = +1 } },
	{ MODKEY,                       XK_k,      focusstack,     {.i = -1 } },
    { MODKEY|ShiftMask,             XK_j,      movestack,      {.i = +1 } },
	{ MODKEY|ShiftMask,             XK_k,      movestack,      {.i = -1 } },

	// --- Layout Control (i3 style) ---
	{ MODKEY,                       XK_e,      setlayout,      {0} }, // Toggle previous layout
	{ MODKEY,                       XK_s,      setlayout,      {.v = &layouts[2]} }, // Stacking (monocle)

	// --- Master/Stack Size (Resize) ---
	{ MODKEY|ControlMask,           XK_h,      setmfact,       {.f = -0.05} }, // shrink master
	{ MODKEY|ControlMask,           XK_l,      setmfact,       {.f = +0.05} }, // grow master

	// --- Gaps Control ---
	{ MODKEY|Mod1Mask,              XK_0,      togglegaps,     {0} },
	{ MODKEY|Mod1Mask,              XK_u,      incrgaps,       {.i = +1 } },
	{ MODKEY|Mod1Mask|ShiftMask,    XK_u,      incrgaps,       {.i = -1 } },

	// --- Scratchpad ---
	{ MODKEY,            		    XK_n,  	   togglescratch,  {.ui = 0 } },

	// --- DWM Session ---
	{ MODKEY|ShiftMask,             XK_q,      quit,           {0} }, // Quit DWM
	{ MODKEY|ShiftMask,		        XK_c,      quit,           {1} }, // Restart DWM
	
    // --- Tag Navigation ---
	{ MODKEY,                       XK_Tab,    view,           {0} },
	{ MODKEY,                       XK_0,      view,           {.ui = ~0 } },
	{ MODKEY|ShiftMask,             XK_0,      tag,            {.ui = ~0 } },
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
};

/* button definitions */
static const Button buttons[] = {
	/* click                event mask      button          function        argument */
	{ ClkLtSymbol,          0,              Button1,        setlayout,      {0} },
	{ ClkLtSymbol,          0,              Button3,        setlayout,      {.v = &layouts[2]} },
	{ ClkWinTitle,          0,              Button2,        zoom,           {0} },
	{ ClkClientWin,         MODKEY,         Button1,        movemouse,      {0} },
	{ ClkClientWin,         MODKEY,         Button2,        togglefloating, {0} },
	{ ClkClientWin,         MODKEY,         Button3,        resizemouse,    {0} },
	{ ClkTagBar,            0,              Button1,        view,           {0} },
	{ ClkTagBar,            0,              Button3,        toggleview,     {0} },
	{ ClkTagBar,            MODKEY,         Button1,        tag,            {0} },
	{ ClkTagBar,            MODKEY,         Button3,        toggletag,      {0} },
};
