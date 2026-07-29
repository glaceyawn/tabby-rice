# circuit vapor — maximalist rice

works currently for arch distros, linux mint and other updated apt distros, fedora, and nixos. (others work too just weird)

Palette: base `#0d0221` · pink `#ff2e88` · violet `#7b2fff` · cyan `#00f0ff` · mint `#3cf58e` · amber `#ffb454`

## file destinations

| file | goes to |
|---|---|
| `hypr/hyprland.conf` | `~/.config/hypr/hyprland.conf` |
| `waybar/config.jsonc` | `~/.config/waybar/config.jsonc` |
| `waybar/style.css` | `~/.config/waybar/style.css` |
| `rofi/config.rasi` | `~/.config/rofi/config.rasi` |
| `kitty/kitty.conf` | `~/.config/kitty/kitty.conf` |
| `starship.toml` | `~/.config/starship.toml` |

## NixOS packages needed

```nix
environment.systemPackages = with pkgs; [
  waybar rofi-wayland kitty starship
  dunst libnotify hyprpaper hypridle hyprlock hyprpicker
  cliphist wl-clipboard
  grim slurp swappy
  brightnessctl playerctl wireplumber
  pavucontrol networkmanagerapplet blueman
  btop
  papirus-icon-theme bibata-cursors
  nerd-fonts.jetbrains-mono nerd-fonts.symbols-only
  kdePackages.dolphin
];
```

## Hyprland plugins (the efficiency stuff)

- **hyprexpo** — Super+O for a zoomed-out workspace overview (also 4-finger swipe)
- **hyprtrails** — pink motion trails behind moving windows
- **hyprbars** — titlebar buttons on floating windows only
- **borders-plus-plus** — second cyan border ring

```nix
wayland.windowManager.hyprland.plugins = with pkgs.hyprlandPlugins; [
  hyprexpo hyprtrails hyprbars borders-plus-plus
];
```

(home-manager path shown; if you configure Hyprland system-wide, use
`programs.hyprland.plugins`. Pin nixpkgs-unstable so plugin ABI matches your
Hyprland version — mismatched plugins crash the compositor on load.)

If you skip plugins, delete/comment the `plugin { }` block, the
`windowrule = plugin:hyprbars...` line, and the `hyprexpo:expo` bind —
Hyprland errors on dispatchers from unloaded plugins.

## keybind cheat sheet

| bind | action |
|---|---|
| Super+B | Firefox |
| Super+Space | rofi launcher |
| Super+Q | close window |
| Super+T | kitty |
| Super+N | neovim (in kitty) |
| Super+E | dolphin |
| Super+V | toggle float |
| Super+F | fullscreen (Shift = maximize) |
| Super+Tab | rofi window switcher |
| Super+C | clipboard history (cliphist → rofi) |
| Super+S | dropdown terminal scratchpad |
| Super+M | music scratchpad |
| Super+O | hyprexpo overview |
| Super+G | tab windows into a group |
| Super+L | lock (hyprlock) |
| Super+Shift+S / Print | region screenshot → clipboard |
| Super+Print | screenshot → swappy editor |
| Super+Shift+C | hyprpicker color picker |
| Super+` | last workspace toggle |
| Super+[ / ] | cycle workspaces |
| XF86 keys | volume (wpctl) / brightness (brightnessctl) / media (playerctl) |

## notes

- HDMI-A-5 is placed at `3440x180` (vertically centered next to the ultrawide) — tweak the offset if your physical layout differs.
- Waybar battery/backlight modules just hide themselves on the desktop; same configs work on the T14.
- The spinning border gradient is the `borderangle` loop animation — if it bothers your GPU, delete that one line.
- kitty `cursor_trail` needs kitty ≥ 0.37 (fine on unstable).
