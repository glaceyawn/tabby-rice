<div align="center">

```
   /\_____/\     ______  ______  ______  ______  __  __
  /  o   o  \   /\__  _\/\  __ \/\  == \/\  == \/\ \_\ \
 ( ==  ^  == )  \/_/\ \/\ \  __ \ \  __<\ \  __<\ \____ \
  )           (    \ \_\ \ \_\ \_\ \_____\ \_____\/\_____\
 (  (  ) (  )  )    \/_/  \/_/\/_/\/_____/\/_____/\/_____/
(__(__)___(__)__)                r i c e
```

**a hyprland rice with a live theme engine, animated wallpapers, and a shape-shifting bar**

![Hyprland](https://img.shields.io/badge/hyprland-0.55+-8fa1b3?style=flat-square&logo=hyprland&logoColor=white)
![Shell](https://img.shields.io/badge/shell-fish%20%2B%20starship-b096b0?style=flat-square)
![Themes](https://img.shields.io/badge/themes-7-9ab08f?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-c4a97b?style=flat-square)

</div>

---

## ✨ what's in it

| | |
|---|---|
| 🎨 **theme engine** | one command re-themes hyprland, waybar, kitty (live!), rofi, mako & starship together — graphite · catppuccin mocha · catppuccin latte · tokyo night · rosé pine · gruvbox · nord |
| 🖼️ **wallpaper picker** | rofi thumbnail grid with sections (per-theme / global / everything), animated awww transitions rippling from your cursor. switching themes auto-swaps to a matching wallpaper |
| 📊 **bar switcher** | 4 waybar personalities — petal islands, bubbly pills, flat, or ghost (text floating on the wallpaper) — at top or bottom |
| 🖥️ **monitor wizard** | reads your real monitors, asks order / mode / scale / vertical alignment, pins workspaces across dual setups |
| 📦 **universal installer** | detects arch · fedora · debian/ubuntu · nixos, installs packages for you (or prints the nix snippet), verifies everything, backs up your configs first |

## 🖼️ gallery

<!-- drop screenshots into assets/ and they'll show here -->
| petal · graphite | pills · mocha |
|---|---|
| ![petal](assets/petal-graphite.png) | ![pills](assets/pills-mocha.png) |

| ghost · tokyonight | fastfetch |
|---|---|
| ![ghost](assets/ghost-tokyonight.png) | ![fetch](assets/fastfetch.png) |

## 🚀 install

```bash
git clone https://github.com/glaceyawn/tabby-rice
cd tabby-rice
./install.sh
```

`./install.sh --check` just reports your distro and what's missing.
Existing configs are backed up to `~/.config/rice-backup-<timestamp>/` every run.

**supported:** pacman (arch / cachyos / endeavouros / manjaro) · dnf (fedora) ·
apt (debian 13+ / ubuntu 24.10+, best-effort) · nixos (prints the exact snippet).
anything else → install the listed packages manually, pick *configs only*.

## ⌨️ daily drivers

| key | action |
|---|---|
| `Super F2` | theme switcher |
| `Super F3` | wallpaper picker · `Shift` for random |
| `Super F4` | bar style + position |
| `Super B / T / N / E` | firefox / kitty / nvim / dolphin |
| `Super Space` | rofi launcher |
| `Super Q / V / F` | close / float / fullscreen |
| `Super W` | dismiss notification · `Shift` all · `Ctrl` restore · `F1` dnd |
| `Super S` | dropdown terminal |
| `Super C` | clipboard history |
| `Super Shift S` | region screenshot |

full keybind list lives in `home/.config/hypr/hyprland.conf`.

## 🧠 how theming works

every app reads colors from a small generated include (`colors.conf` / `colors.css` /
`colors.rasi`). `theme-switch` is the only writer: it regenerates the includes from a
14-line palette file, renders mako from a template, flips starship's palette, live-recolors
every running kitty via remote control, grabs a wallpaper from the matching folder, and
reloads the world.

**add your own theme in 2 steps:**
1. `~/.config/theme-engine/themes/mytheme.sh` — 14 lines of `KEY="hexcolor"`
2. a matching `[palettes.mytheme]` block in `~/.config/starship.toml`

that's it — it appears in the picker's folder scan and `theme-switch mytheme` works.

## 🗂️ anatomy

```
home/
├── .config/
│   ├── hypr/            hyprland.conf · monitors.conf (wizard) · colors.conf (generated)
│   ├── waybar/          config.jsonc · styles/{petal,pills,flat,ghost}.css
│   ├── rofi/  kitty/  mako/  fastfetch/  fish/
│   ├── theme-engine/    themes/*.sh · templates/ · state
│   └── starship.toml    all 7 palettes embedded
└── .local/bin/          theme-switch · wall · wall-fetch · bar-switch · wallpaper-daemon
```

## 🙏 credits

wallpapers curated from these collections (fetched by `wall-fetch`, not redistributed here):
[orangci/walls-catppuccin-mocha](https://github.com/orangci/walls-catppuccin-mocha) ·
[zhichaoh/catppuccin-wallpapers](https://github.com/zhichaoh/catppuccin-wallpapers) ·
[dharmx/walls](https://github.com/dharmx/walls) ·
[rose-pine/wallpapers](https://github.com/rose-pine/wallpapers) ·
[AngelJumbo/gruvbox-wallpapers](https://github.com/AngelJumbo/gruvbox-wallpapers) ·
[linuxdotexe/nordic-wallpapers](https://github.com/linuxdotexe/nordic-wallpapers) ·
[D3Ext/aesthetic-wallpapers](https://github.com/D3Ext/aesthetic-wallpapers)

palettes by [catppuccin](https://catppuccin.com) · [tokyo night](https://github.com/folke/tokyonight.nvim) ·
[rosé pine](https://rosepinetheme.com) · [gruvbox](https://github.com/morhetz/gruvbox) · [nord](https://nordtheme.com)

<div align="center">

**[tabby.beauty](https://tabby.beauty)**

</div>
