<div align="center">

```
        ╱|、
       (˚ˎ 。7          ┏┓ ┏┓ ┏┓ ┏┓ ┓┏
        |、˜〵          ┃  ┣┫ ┣┫ ┣┫ ┗┫
        じしˍ,)ノ        ┗┛ ┛┗ ┃┃ ┃┃ ┗┛   ✦ r i c e ✦
```

# ⟢ tabby rice ⟣

**a hyprland desktop that themes itself, animates its wallpapers, and reshapes its bar on a keypress**

<br>

`▸ 7 themes` &nbsp;·&nbsp; `▸ 4 bar styles` &nbsp;·&nbsp; `▸ live wallpaper engine` &nbsp;·&nbsp; `▸ one-command install`

<br>

![Hyprland](https://img.shields.io/badge/-hyprland_0.55+-cba6f7?style=for-the-badge&logo=hyprland&logoColor=1e1e2e&labelColor=181825)
![Arch](https://img.shields.io/badge/-arch-89b4fa?style=for-the-badge&logo=archlinux&logoColor=1e1e2e&labelColor=181825)
![Fedora](https://img.shields.io/badge/-fedora-a6e3a1?style=for-the-badge&logo=fedora&logoColor=1e1e2e&labelColor=181825)
![Debian](https://img.shields.io/badge/-debian-f38ba8?style=for-the-badge&logo=debian&logoColor=1e1e2e&labelColor=181825)
![NixOS](https://img.shields.io/badge/-nixos-f9e2af?style=for-the-badge&logo=nixos&logoColor=1e1e2e&labelColor=181825)

</div>

<br>

<div align="center">

### ⸻　❖　the four faces　❖　⸻

|  |  |
|:---:|:---:|
| ![petal](assets/petal-graphite.png) | ![pills](assets/pills-mocha.png) |
| `❖ petal` — floating islands · graphite | `❖ pills` — bubbly capsules · mocha |
| ![ghost](assets/ghost-tokyonight.png) | ![fetch](assets/fastfetch.png) |
| `❖ ghost` — bar dissolves into the wall · tokyo night | `❖` the fastfetch splash |

</div>

<br>

```
┌─────────────────────────────────────────────────────────────┐
│  ▸ SUPER F2   cycle 7 themes — everything recolors at once   │
│  ▸ SUPER F3   wallpaper picker with animated transitions     │
│  ▸ SUPER F4   reshape the bar · petal / pills / flat / ghost │
│  ▸ SUPER ⇧ H   open the welcome panel anytime                │
└─────────────────────────────────────────────────────────────┘
```

<br>

## ✦ what makes it tick

&nbsp;&nbsp;🎨 &nbsp; **one keypress, everything recolors.** &nbsp; Hyprland, waybar, kitty *(live, no restart)*, rofi, mako, and starship all switch together across seven palettes — graphite, catppuccin mocha & latte, tokyo night, rosé pine, gruvbox, nord.

&nbsp;&nbsp;🖼️ &nbsp; **wallpapers follow your theme.** &nbsp; A rofi thumbnail grid — pick per-theme, global, or from everything — with transitions that ripple out from your cursor. Change theme, get a matching wallpaper automatically.

&nbsp;&nbsp;📊 &nbsp; **the bar has four personalities.** &nbsp; Floating petal islands, bubbly pills, a flat classic bar, or *ghost* — no bar at all, just text drifting on the wallpaper. Top or bottom, any monitor.

&nbsp;&nbsp;🖥️ &nbsp; **a wizard sets up your monitors.** &nbsp; Reads your real displays, defaults to max refresh, asks order / scale / alignment, pins workspaces on dual setups.

&nbsp;&nbsp;🟢 &nbsp; **NVIDIA-smooth out of the box.** &nbsp; Anti-flicker settings baked in — no hardware cursors, static borders, VRR off — so you skip the evening of chasing flicker.

<br>

## ✦ install

```bash
git clone https://github.com/glaceyawn/tabby-rice
cd tabby-rice
./install.sh
```

<div align="center">

**the installer knows your distro** — it installs packages the right way for each

</div>

```
   arch · cachyos · endeavour     →   pacman        · automatic
   fedora                         →   dnf           · automatic
   debian 13+ · ubuntu 24.10+     →   apt           · automatic
   nixos                          →   prints the config snippet to paste
   anything else                  →   lists packages, installs the configs
```

Already installed? Skipped. Your current setup is backed up to `~/.config/rice-backup-<timestamp>/` before a single file moves. Peek first with `./install.sh --check`.

<br>

## ✦ the map

```
tabby-rice
├── install.sh                 ← the one script you run
└── home/
    ├── .config/
    │   ├── hypr/
    │   │   ├── hyprland.conf       keybinds · rules · the whole compositor
    │   │   ├── monitors.conf       ← the wizard writes this
    │   │   └── colors.conf         ← theme-switch writes this
    │   ├── waybar/
    │   │   ├── config.jsonc        what's on the bar
    │   │   └── styles/
    │   │       ├── petal.css       ┐
    │   │       ├── pills.css       ├─ the four bar faces
    │   │       ├── flat.css        │
    │   │       └── ghost.css       ┘
    │   ├── rofi/ · kitty/ · mako/ · fastfetch/ · fish/
    │   ├── theme-engine/
    │   │   ├── themes/             ← 7 palettes · drop your own here
    │   │   └── templates/
    │   └── starship.toml           all 7 palettes embedded
    └── .local/bin/
        ├── theme-switch           the heart — recolors everything
        ├── wall · wall-fetch      wallpaper picker + downloader
        ├── bar-switch             swap bar style + position
        ├── bar-monitor            put the bar on a chosen screen
        └── rice-welcome           the help panel
```

<br>

## ✦ keybinds

<div align="center">everything is on <b>Super</b> (the Windows key) · press <code>Super ⇧ H</code> for this as a panel</div>

<br>

<table>
<tr>
<td valign="top">

**the rice**
| | |
|--|--|
|`⌘ F2`| switch theme |
|`⌘ F3`| wallpapers *(⇧ random)* |
|`⌘ F4`| bar style *(⇧ monitor)* |
|`⌘ ⇧ H`| help panel |

</td>
<td valign="top">

**apps**
| | |
|--|--|
|`⌘ Space`| launcher |
|`⌘ B T N E`| ff · term · vim · files |
|`⌘ S`| dropdown term |
|`⌘ C`| clipboard |

</td>
</tr>
<tr>
<td valign="top">

**windows**
| | |
|--|--|
|`⌘ Q V F`| close · float · full |
|`⌘ ←↑↓→`| focus *(⇧ move)* |
|`⌘ 1-9`| workspaces |

</td>
<td valign="top">

**system**
| | |
|--|--|
|`⌘ W`| dismiss notif |
|`⌘ F1`| do-not-disturb |
|`⌘ L`| lock |
|`⌘ ⇧ S`| screenshot |

</td>
</tr>
</table>

<br>

## ✦ make it yours

**a new theme** — drop a 14-line palette in `theme-engine/themes/yours.sh`, add a `[palettes.yours]` block to `starship.toml`, done. it shows up in the switcher.

**a bar tweak** — edit `waybar/styles/*.css`, never `style.css` *(that one gets overwritten on each switch)*.

**per-theme wallpapers** — drop images in `~/Pictures/wallpapers/<theme>/` and they enter the rotation.

<br>

<details>
<summary><b>✦ how the theme engine actually works</b></summary>

<br>

Every app reads its colors from a small generated include file. One script — `theme-switch` — is the only writer. When you switch, it regenerates every include from a palette, renders mako from a template, flips starship's palette, live-recolors each open kitty over its control socket, pulls a matching wallpaper, and reloads the compositor. That's why the change is instant and total instead of app-by-app. Adding a theme is genuinely just the two files above; the engine scans the folder.

</details>

<br>

## ✦ credits

Wallpapers fetched by `wall-fetch` from these collections *(not redistributed — each keeps its own license)*:
[orangci](https://github.com/orangci/walls-catppuccin-mocha) · [zhichaoh](https://github.com/zhichaoh/catppuccin-wallpapers) · [dharmx](https://github.com/dharmx/walls) · [rose-pine](https://github.com/rose-pine/wallpapers) · [AngelJumbo](https://github.com/AngelJumbo/gruvbox-wallpapers) · [linuxdotexe](https://github.com/linuxdotexe/nordic-wallpapers) · [D3Ext](https://github.com/D3Ext/aesthetic-wallpapers)

Palettes: [catppuccin](https://catppuccin.com) · [tokyo night](https://github.com/folke/tokyonight.nvim) · [rosé pine](https://rosepinetheme.com) · [gruvbox](https://github.com/morhetz/gruvbox) · [nord](https://nordtheme.com)

<br>

<div align="center">

╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌╌

**MIT** &nbsp;·&nbsp; made with 🖤 by [**tabby**](https://tabby.beauty)

```
   ╱|、
  (˚ˎ 。7
   |、˜〵
   じしˍ,)ノ
```

</div>
