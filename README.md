<div align="center">

<img src="assets/banner.png" alt="tabby rice" width="800">

<br>

**a hyprland desktop that themes itself, animates its wallpapers, and reshapes its bar on a keypress**

<br>

`7 themes`&nbsp;&nbsp;·&nbsp;&nbsp;`4 bar styles`&nbsp;&nbsp;·&nbsp;&nbsp;`live wallpapers`&nbsp;&nbsp;·&nbsp;&nbsp;`one-command install`

<br>

![Hyprland](https://img.shields.io/badge/hyprland-0.56-cba6f7?style=for-the-badge&logo=hyprland&logoColor=1e1e2e&labelColor=181825)
![Arch](https://img.shields.io/badge/arch-tested-89b4fa?style=for-the-badge&logo=archlinux&logoColor=1e1e2e&labelColor=181825)
![License](https://img.shields.io/badge/license-MIT-f9e2af?style=for-the-badge&labelColor=181825)

</div>

<br>

---

<br>

<div align="center">

### the four faces

</div>

|  |  |
|:---:|:---:|
| ![petal](assets/petal-graphite.png) | ![pills](assets/pills-mocha.png) |
| **petal** — floating islands · graphite | **pills** — bubbly capsules · mocha |
| ![ghost](assets/ghost-tokyonight.png) | ![fetch](assets/fastfetch.png) |
| **ghost** — the bar melts into the wall · tokyo night | the fastfetch splash |

<br>

## what it does

🎨 &nbsp; **one keypress recolors everything.** Hyprland, waybar, kitty (live, no restart), rofi, mako, and starship all switch together across seven palettes — graphite, catppuccin mocha and latte, tokyo night, rosé pine, gruvbox, and nord.

🖼️ &nbsp; **wallpapers follow your theme.** A rofi thumbnail grid lets you pick per-theme, global, or from everything, with transitions that ripple out from your cursor. Switch theme and a matching wallpaper comes with it.

📊 &nbsp; **the bar has four personalities.** Floating petal islands, bubbly pills, a flat classic bar, or ghost — no bar at all, just text drifting on the wallpaper. Top or bottom, on any monitor.

🖥️ &nbsp; **a wizard sets up your monitors.** It reads your real displays, defaults each to its highest refresh rate, and asks for order, scale, and alignment. Dual setups get their workspaces pinned automatically.

🔒 &nbsp; **a themed lock screen and login.** hyprlock with a blurred clock, plus a matching SDDM greeter — both styled to the rice.

🟢 &nbsp; **NVIDIA-smooth out of the box.** Anti-flicker settings are baked in (no hardware cursors, static borders, VRR off) so you skip the evening of chasing flicker.

<br>

## install

```bash
git clone https://github.com/glaceyawn/tabby-rice
cd tabby-rice
./install.sh
```

Pick **Install everything** and it handles packages, drivers, fonts, your browser, monitors, and configs — asking before each step and backing up anything it replaces. Run `./install.sh --check` first if you just want to see what's missing.

<br>

## supported distros

| distro | status |
|---|---|
| **Arch** · CachyOS · EndeavourOS · Manjaro | ✅ fully tested — installs everything via `pacman` (and `yay` for AUR bits) |
| **Fedora** | 🟡 best-effort — most via `dnf`, a couple need COPR/RPM Fusion (the installer tells you which) |
| **Debian 13+** · Ubuntu 24.10+ | 🟡 best-effort — via `apt`; needs a recent release where Hyprland is packaged |
| **NixOS** | 🟢 use the module — import `nixos/tabby-rice.nix`, rebuild, then run the installer for configs |
| anything else | lists the packages you need, then installs the configs |

> Honest note: the rice is developed and tested on Arch. The other paths are written carefully and should work, but haven't been run on every distro — treat them as best-effort and open an issue if something's off.

<br>

## keybinds

Everything runs on the **Super** key. Press **Super + Shift + H** anytime to see this as a panel on your desktop.

**the rice**

| key | action |
|---|---|
| Super + F2 | switch theme |
| Super + F3 | wallpaper picker (add Shift for random) |
| Super + F4 | bar style and position (add Shift for which monitor) |
| Super + Shift + H | open the help panel |

**apps**

| key | action |
|---|---|
| Super + Space | app launcher |
| Super + B / T / N / E | browser · terminal · neovim · files |
| Super + S | dropdown terminal |
| Super + C | clipboard history |

**windows**

| key | action |
|---|---|
| Super + Q / V / F | close · float · fullscreen |
| Super + arrow keys | move focus (add Shift to move the window) |
| Super + 1-9 | switch workspace |

**system**

| key | action |
|---|---|
| Super + W | dismiss notification (Shift for all, Ctrl to restore) |
| Super + F1 | do-not-disturb |
| Super + L | lock screen |
| Super + Shift + S | region screenshot |
| media keys | volume and brightness |

<br>

## make it yours

**a new theme** — drop a 14-line palette file in `theme-engine/themes/yours.sh`, add a matching `[palettes.yours]` block to `starship.toml`, and it shows up in the switcher.

**a bar tweak** — edit the files in `waybar/styles/`, never `style.css` (that one gets overwritten each time you switch styles).

**per-theme wallpapers** — drop images into `~/Pictures/wallpapers/<theme>/` and they join the rotation.

<br>

## the map

```
tabby-rice
├── install.sh                      the one script you run
├── nixos/tabby-rice.nix            NixOS module (fonts, SDDM, drivers, packages)
└── home/
    └── .config/
        ├── hypr/
        │   ├── hyprland.conf        keybinds, rules, the whole compositor
        │   ├── hyprlock.conf        the lock screen
        │   ├── monitors.conf        written by the monitor wizard
        │   └── colors.conf          written by theme-switch
        ├── waybar/
        │   ├── config.jsonc         what appears on the bar
        │   └── styles/              the four bar faces
        ├── rofi/  kitty/  mako/  fastfetch/  fish/  sddm/  dolphin/
        ├── theme-engine/
        │   ├── themes/              7 palettes — drop your own here
        │   └── templates/
        └── starship.toml            all 7 palettes embedded
```

<br>

<details>
<summary><b>how the theme engine works</b></summary>

<br>

Every app reads its colors from a small generated include file. One script, `theme-switch`, is the only thing that writes them. When you switch, it regenerates every include from a palette, renders mako from a template, flips starship's palette, live-recolors each open kitty over its control socket, pulls a matching wallpaper, and reloads the compositor. That's why the change is instant and total instead of app-by-app.

</details>

<br>

## credits

Wallpapers are fetched by `wall-fetch` from these collections (not redistributed here — each keeps its own license):
[orangci](https://github.com/orangci/walls-catppuccin-mocha) · [zhichaoh](https://github.com/zhichaoh/catppuccin-wallpapers) · [dharmx](https://github.com/dharmx/walls) · [rose-pine](https://github.com/rose-pine/wallpapers) · [AngelJumbo](https://github.com/AngelJumbo/gruvbox-wallpapers) · [linuxdotexe](https://github.com/linuxdotexe/nordic-wallpapers) · [D3Ext](https://github.com/D3Ext/aesthetic-wallpapers)

Palettes: [catppuccin](https://catppuccin.com) · [tokyo night](https://github.com/folke/tokyonight.nvim) · [rosé pine](https://rosepinetheme.com) · [gruvbox](https://github.com/morhetz/gruvbox) · [nord](https://nordtheme.com)

<br>

<div align="center">

**MIT** &nbsp;·&nbsp; made by [tabby](https://tabby.beauty)

</div>
