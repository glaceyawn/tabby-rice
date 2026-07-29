<div align="center">

```
   /\_____/\     ______  ______  ______  ______  __  __
  /  o   o  \   /\__  _\/\  __ \/\  == \/\  == \/\ \_\ \
 ( ==  ^  == )  \/_/\ \/\ \  __ \ \  __<\ \  __<\ \____ \
  )           (    \ \_\ \ \_\ \_\ \_____\ \_____\/\_____\
 (  (  ) (  )  )    \/_/  \/_/\/_/\/_____/\/_____/\/_____/
(__(__)___(__)__)                r i c e
```

### a hyprland rice with a live theme engine, animated wallpapers, and a shape-shifting bar

<br>

![Hyprland](https://img.shields.io/badge/hyprland-0.55+-cba6f7?style=for-the-badge&logo=hyprland&logoColor=white&labelColor=1e1e2e)
![Themes](https://img.shields.io/badge/themes-7-a6e3a1?style=for-the-badge&labelColor=1e1e2e)
![Distros](https://img.shields.io/badge/arch·fedora·debian·nixos-supported-89b4fa?style=for-the-badge&labelColor=1e1e2e)
![License](https://img.shields.io/badge/license-MIT-f9e2af?style=for-the-badge&labelColor=1e1e2e)

<br>

*works on Arch · Fedora · Debian/Ubuntu · NixOS — the installer figures out which one you're on*

</div>

<br>

---

<br>

## gallery

<div align="center">

|  |  |
|:---:|:---:|
| ![petal](assets/petal-graphite.png) | ![pills](assets/pills-mocha.png) |
| **petal** · graphite | **pills** · mocha |
| ![ghost](assets/ghost-tokyonight.png) | ![fetch](assets/fastfetch.png) |
| **ghost** · tokyo night | fastfetch |

</div>

<br>

## what it does

**One command re-themes everything at once.** Hyprland, waybar, kitty (live, no restart), rofi, mako, and starship all switch together between seven palettes — graphite, catppuccin mocha & latte, tokyo night, rosé pine, gruvbox, and nord.

**Wallpapers change with your theme.** A rofi thumbnail grid lets you pick per-theme, global, or from everything, with animated transitions that ripple out from your cursor. Switch to a new theme and it grabs a matching wallpaper automatically.

**The bar shape-shifts.** Four completely different waybar looks — petal islands, bubbly pills, a flat attached bar, or ghost (text floating on the wallpaper with no bar at all) — swappable at top or bottom, on whichever monitor you want.

**It sets up your monitors for you.** A wizard reads your real displays, defaults each to its highest refresh rate, and asks for order, resolution, scale, and alignment. Dual setups get workspaces pinned automatically.

**It just works on NVIDIA.** Ships with the anti-flicker settings baked in — no hardware cursors, static borders, VRR off — so you don't spend an evening chasing the flicker like some people did.

<br>

## install

```bash
git clone https://github.com/glaceyawn/tabby-rice
cd tabby-rice
./install.sh
```

The installer detects your distro and installs everything for you:

| distro | how packages install |
|---|---|
| **Arch** · CachyOS · EndeavourOS · Manjaro | `pacman` — automatic |
| **Fedora** | `dnf` — automatic |
| **Debian 13+** · Ubuntu 24.10+ | `apt` — automatic |
| **NixOS** | prints the exact config snippet to paste |
| anything else | lists what to install, then does the configs |

Already have a package? It's skipped. Your existing configs are backed up to `~/.config/rice-backup-<timestamp>/` before anything is touched. Run `./install.sh --check` first if you just want to see what's missing.

<br>

## keybinds

Everything runs on the **Super** (Windows) key. Press **Super + Shift + H** anytime to pull up this cheatsheet as a panel.

**the rice**
| key | |
|---|---|
| `Super F2` | switch theme |
| `Super F3` | wallpaper picker (`+ Shift` for random) |
| `Super F4` | bar style + position (`+ Shift` for which monitor) |
| `Super Shift H` | show the welcome / help panel |

**apps**
| key | |
|---|---|
| `Super Space` | app launcher |
| `Super B` `T` `N` `E` | firefox · terminal · neovim · files |
| `Super S` | dropdown terminal |
| `Super C` | clipboard history |

**windows**
| key | |
|---|---|
| `Super Q` `V` `F` | close · float · fullscreen |
| `Super ←↑↓→` | move focus (`+ Shift` to move the window) |
| `Super 1-9` | switch workspace |

**system**
| key | |
|---|---|
| `Super W` | dismiss notification (`+ Shift` all, `+ Ctrl` restore) |
| `Super F1` | do-not-disturb |
| `Super L` | lock screen |
| `Super Shift S` | region screenshot |
| media keys | volume · brightness |

<br>

## make it yours

**Add a theme** in two steps: drop a 14-line palette file in `~/.config/theme-engine/themes/yourtheme.sh`, add a matching `[palettes.yourtheme]` block to `~/.config/starship.toml`, and it appears in the switcher.

**Edit a bar style** by changing the files in `~/.config/waybar/styles/` — not `style.css`, which gets overwritten when you switch styles.

**Change wallpapers per theme** by dropping images into `~/Pictures/wallpapers/<theme>/`. The full keybind list and every setting lives in `~/.config/hypr/hyprland.conf`.

<br>

## how the theming works

Every app reads its colors from a small generated include file. A single script, `theme-switch`, is the only thing that writes them — it regenerates the includes from a palette, renders mako from a template, flips starship's palette, live-recolors every open kitty window over its socket, pulls a matching wallpaper, and reloads everything. That's why a theme change is instant and total instead of app-by-app.

<br>

## credits

Wallpapers are fetched from these collections by `wall-fetch` (not redistributed here — each keeps its own license):
[orangci](https://github.com/orangci/walls-catppuccin-mocha) ·
[zhichaoh](https://github.com/zhichaoh/catppuccin-wallpapers) ·
[dharmx](https://github.com/dharmx/walls) ·
[rose-pine](https://github.com/rose-pine/wallpapers) ·
[AngelJumbo](https://github.com/AngelJumbo/gruvbox-wallpapers) ·
[linuxdotexe](https://github.com/linuxdotexe/nordic-wallpapers) ·
[D3Ext](https://github.com/D3Ext/aesthetic-wallpapers)

Palettes: [catppuccin](https://catppuccin.com) · [tokyo night](https://github.com/folke/tokyonight.nvim) · [rosé pine](https://rosepinetheme.com) · [gruvbox](https://github.com/morhetz/gruvbox) · [nord](https://nordtheme.com)

<br>

<div align="center">

**MIT** · made by [tabby](https://tabby.beauty) 🐾

</div>
