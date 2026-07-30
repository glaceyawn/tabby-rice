#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#   t a b b y   r i c e  —  universal installer
#   usage: ./install.sh          interactive
#          ./install.sh --check  detect distro + packages only
# ═══════════════════════════════════════════════════════════
set -u
cd "$(dirname "$0")" || { echo "cannot cd to script dir"; exit 1; }
TS="$(date +%Y%m%d-%H%M%S)"
AUR_HELPER=""; BROWSER_BIN=""; BROWSER_LABEL=""; FULL_INSTALL=0; LUA_WAS_PRESENT=0; DRIVER_CHOICE=""; GPU_VENDORS=""
BACKUP="$HOME/.config/rice-backup-$TS"

# ─── TUI toolkit (zero dependencies) ───────────────────────
R=$'\033[0m'; B=$'\033[1m'; DIM=$'\033[2m'
FG1=$'\033[38;5;110m'; FG2=$'\033[38;5;175m'; FG3=$'\033[38;5;180m'
OK=$'\033[38;5;108m'; ERR=$'\033[38;5;174m'
head_() { printf '\n%s%s── %s %s\n' "$B" "$FG1" "$1" "$R"; }
good()  { printf '  %s✔%s %s\n' "$OK" "$R" "$1"; }
bad()   { printf '  %s✘%s %s\n' "$ERR" "$R" "$1"; }
note()  { printf '  %s·%s %s\n' "$FG3" "$R" "$1"; }
ask()   { printf '  %s?%s %s ' "$FG2" "$R" "$1"; read -r REPLY; }

menu() {  # menu "prompt" opts... -> $CHOICE (1-based)
    local prompt="$1"; shift; local opts=("$@") i
    printf '\n  %s%s%s\n' "$B" "$prompt" "$R"
    for i in "${!opts[@]}"; do printf '   %s%2d)%s %s\n' "$FG1" "$((i+1))" "$R" "${opts[$i]}"; done
    while :; do
        printf '  %s>%s ' "$FG2" "$R"; read -r CHOICE
        [[ "$CHOICE" =~ ^[0-9]+$ ]] && [ "$CHOICE" -ge 1 ] && [ "$CHOICE" -le ${#opts[@]} ] && break
        bad "pick 1-${#opts[@]}"
    done
}

multimenu() {  # multimenu "prompt" opts... -> $MCHOICES (space-sep indices, may be empty)
    local prompt="$1"; shift; local opts=("$@") i
    printf '\n  %s%s%s %s(numbers separated by spaces, enter to skip)%s\n' "$B" "$prompt" "$R" "$DIM" "$R"
    for i in "${!opts[@]}"; do printf '   %s%2d)%s %s\n' "$FG1" "$((i+1))" "$R" "${opts[$i]}"; done
    printf '  %s>%s ' "$FG2" "$R"; read -r MCHOICES
}

banner() {
    clear 2>/dev/null
    printf '%s%s' "$B" "$FG2"
    cat << 'EOF'

   /\_____/\     ______  ______  ______  ______  __  __
  /  o   o  \   /\__  _\/\  __ \/\  == \/\  == \/\ \_\ \
 ( ==  ^  == )  \/_/\ \/\ \  __ \ \  __<\ \  __<\ \____ \
  )           (    \ \_\ \ \_\ \_\ \_____\ \_____\/\_____\
 (  (  ) (  )  )    \/_/  \/_/\/_/\/_____/\/_____/\/_____/
(__(__)___(__)__)
EOF
    printf '%s%s                r  i  c  e   %s·   by tabby%s\n\n' "$R" "$B" "$DIM" "$R"
    printf '  %shyprland · waybar · rofi · kitty · mako · fastfetch · fish · starship%s\n' "$DIM" "$R"
    printf '  %s7 themes · animated wallpapers · 4 bar styles · monitor wizard%s\n' "$DIM" "$R"
}

# ─── distro detection ──────────────────────────────────────
detect_distro() {
    DISTRO="unknown"; PM=""
    if [ -f /etc/os-release ]; then
        . /etc/os-release
        local id="${ID:-} ${ID_LIKE:-}"
        case "$id" in
            *nixos*)                                  DISTRO="nixos" ;;
            *arch*|*cachyos*|*endeavouros*|*manjaro*) DISTRO="arch";   PM="pacman" ;;
            *debian*|*ubuntu*|*mint*|*pop*)           DISTRO="debian"; PM="apt" ;;
            *fedora*|*rhel*)                          DISTRO="fedora"; PM="dnf" ;;
        esac
    fi
    if [ "$DISTRO" = "unknown" ]; then
        command -v pacman        >/dev/null && { DISTRO="arch";   PM="pacman"; }
        command -v apt           >/dev/null && { DISTRO="debian"; PM="apt"; }
        command -v dnf           >/dev/null && { DISTRO="fedora"; PM="dnf"; }
        command -v nixos-rebuild >/dev/null && DISTRO="nixos"
    fi
}

# ─── package maps ──────────────────────────────────────────
PKGS_ARCH=(hyprland waybar rofi kitty starship mako libnotify fastfetch fish
           hyprpicker cliphist wl-clipboard grim slurp swappy
           brightnessctl playerctl wireplumber pavucontrol
           network-manager-applet blueman btop papirus-icon-theme
           ttf-jetbrains-mono-nerd ttf-nerd-fonts-symbols noto-fonts noto-fonts-emoji
           hyprlock hypridle sddm qt6-svg qt6-declarative qt6ct kvantum dolphin awww python)
PKGS_FEDORA=(hyprland waybar rofi kitty starship mako libnotify fastfetch fish
             hyprpicker cliphist wl-clipboard grim slurp swappy
             brightnessctl playerctl wireplumber pavucontrol
             network-manager-applet blueman btop papirus-icon-theme
             jetbrains-mono-fonts google-noto-emoji-fonts
             hyprlock hypridle sddm qt6-qtsvg qt6-qtdeclarative qt6-qtquickcontrols2 qt6ct kvantum dolphin python3)
PKGS_DEBIAN=(hyprland waybar rofi kitty mako-notifier libnotify-bin fastfetch fish
             cliphist wl-clipboard grim slurp brightnessctl playerctl
             wireplumber pavucontrol blueman btop papirus-icon-theme
             fonts-jetbrains-mono fonts-noto-color-emoji
             hyprlock hypridle sddm qt6ct dolphin python3)

# optional bundles: label|arch pkgs|debian pkgs|fedora pkgs
BUNDLES=(
"coding — neovim, git, compilers, node, python, ripgrep, fzf|neovim git base-devel nodejs npm python python-pip ripgrep fd fzf lazygit|neovim git build-essential nodejs npm python3 python3-pip ripgrep fd-find fzf|neovim git gcc make nodejs npm python3 python3-pip ripgrep fd-find fzf lazygit"
"media — mpv, imv, ffmpeg, yt-dlp|mpv imv ffmpeg yt-dlp|mpv imv ffmpeg yt-dlp|mpv imv ffmpeg yt-dlp"
"system utils — htop, unzip, curl, wget, rsync, tree|htop unzip curl wget rsync tree|htop unzip curl wget rsync tree|htop unzip curl wget rsync tree"
)

REQUIRED_BINS=(Hyprland waybar rofi kitty mako starship hyprlock hypridle
               notify-send makoctl cliphist wl-copy grim slurp brightnessctl
               wpctl playerctl fastfetch fish)

verify_bins() {
    MISSING=(); local b
    for b in "${REQUIRED_BINS[@]}"; do command -v "$b" >/dev/null 2>&1 || MISSING+=("$b"); done
    command -v awww >/dev/null 2>&1 || command -v swww >/dev/null 2>&1 || MISSING+=("awww/swww")
    [ ${#MISSING[@]} -eq 0 ]
}

pm_install() {  # pm_install pkg...
    # try the whole batch first (fast path)
    case "$PM" in
        pacman) sudo pacman -S --needed --noconfirm "$@" && return 0 ;;
        apt)    sudo apt install -y "$@" && return 0 ;;
        dnf)    sudo dnf install -y "$@" && return 0 ;;
    esac
    # batch failed (usually one bad/unavailable name aborts the rest) —
    # retry per-package so a single missing name doesn't kill the whole install
    note "batch install hit a snag; retrying package-by-package so one bad name doesn't stop the rest"
    local pkg failed=()
    for pkg in "$@"; do
        case "$PM" in
            pacman) sudo pacman -S --needed --noconfirm "$pkg" >/dev/null 2>&1 || failed+=("$pkg") ;;
            apt)    sudo apt install -y "$pkg" >/dev/null 2>&1 || failed+=("$pkg") ;;
            dnf)    sudo dnf install -y "$pkg" >/dev/null 2>&1 || failed+=("$pkg") ;;
        esac
    done
    if [ "${#failed[@]}" -gt 0 ]; then
        bad "couldn't install: ${failed[*]}"
        note "these may be in the AUR (arch) or a COPR (fedora) — install them manually"
        return 1
    fi
    return 0
}

install_packages() {
    head_ "packages · $DISTRO"
    case "$DISTRO" in
        nixos)
            note "NixOS installs declaratively. The easiest path:"
            note "  1. copy nixos/tabby-rice.nix next to your configuration.nix"
            note "  2. add  imports = [ ./tabby-rice.nix ];  to configuration.nix"
            note "  3. sudo nixos-rebuild switch"
            note "  4. re-run ./install.sh and pick 'configs only'"
            note ""
            note "the module handles Hyprland, SDDM login, fonts, audio, and drivers."
            note "or add these packages manually if you prefer:"
            sed 's/^/    /' << 'NIX'
environment.systemPackages = with pkgs; [
  waybar rofi kitty starship mako libnotify fastfetch fish
  awww hyprlock hypridle hyprpicker
  cliphist wl-clipboard grim slurp swappy
  brightnessctl playerctl wireplumber
  pavucontrol networkmanagerapplet blueman btop
  papirus-icon-theme bibata-cursors
  nerd-fonts.jetbrains-mono nerd-fonts.symbols-only
  kdePackages.dolphin
];
# remove if present: dunst, hyprpaper (conflict with mako / awww)
NIX
            ask "packages already present? continue? [y/N]"; [ "$REPLY" = "y" ] || exit 0
            ;;
        arch|fedora|debian)
            local PKGS=()
            case "$DISTRO" in
                arch)   PKGS=("${PKGS_ARCH[@]}") ;;
                fedora) PKGS=("${PKGS_FEDORA[@]}") ;;
                debian) PKGS=("${PKGS_DEBIAN[@]}")
                        note "hyprland needs Debian 13+ / Ubuntu 24.10+; older releases can't run this rice"
                        note "checking hyprland availability in apt..."
                        if apt-cache show hyprland >/dev/null 2>&1; then
                            PKGS+=(hyprland); good "hyprland is packaged here"
                        else
                            bad "hyprland is NOT in your apt repos — install it manually first (or upgrade your release)"
                        fi ;;
            esac
            # only install what's actually missing (pacman --needed does this; we pre-filter for apt/dnf too)
            note "installing via $PM (sudo needed) — already-installed packages are skipped"
            [ "$PM" = "apt" ] && sudo apt update
            pm_install "${PKGS[@]}" || bad "$PM reported errors — continuing to verification"
            # gap-fillers
            command -v starship >/dev/null 2>&1 || {
                ask "starship not packaged — install via official script? [Y/n]"
                [ "$REPLY" != "n" ] && curl -sS https://starship.rs/install.sh | sh -s -- -y
            }
            command -v awww >/dev/null 2>&1 || command -v swww >/dev/null 2>&1 || {
                case "$DISTRO" in
                    arch)   note "installing swww from the AUR..."; aur_install swww || note "swww not installed — awww is the default anyway" ;;
                    fedora) note "swww: try 'sudo dnf copr enable <swww copr> && sudo dnf install swww'" ;;
                    debian) note "swww isn't in apt: install rust then 'cargo install swww', or use a community build" ;;
                esac
            }
            ;;
        *)
            bad "no supported package manager detected"
            note "install manually, then re-run: ${REQUIRED_BINS[*]} + awww/swww + JetBrainsMono Nerd Font"
            ask "continue with configs anyway? [y/N]"; [ "$REPLY" = "y" ] || exit 1
            ;;
    esac

    if verify_bins; then good "all required binaries present"
    else
        bad "still missing: ${MISSING[*]}"
        note "configs will install fine; missing pieces won't work until installed"
        ask "continue? [y/N]"; [ "$REPLY" = "y" ] || exit 1
    fi
    pgrep -x dunst     >/dev/null 2>&1 && bad "dunst is running — disable it (this rice uses mako)"
    pgrep -x hyprpaper >/dev/null 2>&1 && bad "hyprpaper is running — disable it (this rice uses awww/swww)"

    # rebuild font cache so newly-installed nerd fonts are actually found
    if command -v fc-cache >/dev/null 2>&1; then
        fc-cache -f >/dev/null 2>&1
        if fc-list 2>/dev/null | grep -qi "jetbrainsmono nerd"; then
            good "JetBrainsMono Nerd Font found"
        else
            bad "JetBrainsMono Nerd Font not detected — glyphs/icons may be missing"
            note "install a nerd font manually if the bar shows boxes: nerdfonts.com"
        fi
    fi
}

# ─── GPU / driver detection ────────────────────────────────
detect_gpu() {
    GPU_VENDORS=""   # space-separated: nvidia amd intel
    local pci=""
    command -v lspci >/dev/null 2>&1 && pci="$(lspci 2>/dev/null | grep -iE 'vga|3d|display')"
    echo "$pci" | grep -qi nvidia && GPU_VENDORS="$GPU_VENDORS nvidia"
    echo "$pci" | grep -qiE 'advanced micro devices|\bamd\b|\bradeon\b|\[amd/ati\]' && GPU_VENDORS="$GPU_VENDORS amd"
    echo "$pci" | grep -qi 'intel' && GPU_VENDORS="$GPU_VENDORS intel"
    GPU_VENDORS="$(echo "$GPU_VENDORS" | xargs)"   # trim
    [ -z "$GPU_VENDORS" ] && [ -d /proc/driver/nvidia ] && GPU_VENDORS="nvidia"
}

# ─── AUR helper (yay) bootstrap ────────────────────────────
# only meaningful on Arch. installs yay from source if the user wants it,
# so AUR packages (brave, zen, swww on some setups) can be installed.
ensure_yay() {
    [ "$DISTRO" = "arch" ] || return 1
    command -v yay  >/dev/null 2>&1 && { AUR_HELPER=yay;  return 0; }
    command -v paru >/dev/null 2>&1 && { AUR_HELPER=paru; return 0; }
    # no helper present — offer to build yay
    ask "an AUR helper (yay) is needed for some packages. install it now? [Y/n]"
    [ "$REPLY" = "n" ] && { note "skipping yay — AUR packages will need manual install"; return 1; }
    note "building yay from the AUR (needs base-devel + git)..."
    pm_install --needed git base-devel || { bad "couldn't install build deps for yay"; return 1; }
    local tmp
    tmp="$(mktemp -d)"
    if git clone https://aur.archlinux.org/yay.git "$tmp/yay" >/dev/null 2>&1 &&
       ( cd "$tmp/yay" && makepkg -si --noconfirm ) ; then
        rm -rf "$tmp"
        command -v yay >/dev/null 2>&1 && { AUR_HELPER=yay; good "yay installed"; return 0; }
    fi
    rm -rf "$tmp"
    bad "yay build failed — install an AUR helper manually (see wiki.archlinux.org/title/AUR_helpers)"
    return 1
}

aur_install() {  # aur_install pkg...  — installs from AUR via yay/paru
    ensure_yay || { note "can't install from AUR without a helper: $*"; return 1; }
    # never run an AUR helper as root; it drops privileges itself
    "$AUR_HELPER" -S --needed --noconfirm "$@"
}

driver_setup() {
    head_ "graphics drivers"
    detect_gpu
    if [ -z "$GPU_VENDORS" ]; then
        note "couldn't auto-detect a GPU (lspci missing?) — skipping driver setup"
        note "install your GPU driver manually if graphics don't work"
        DRIVER_CHOICE=""
        return
    fi
    good "detected GPU(s): $GPU_VENDORS"

    # recommend based on what's present
    local rec=""
    case "$GPU_VENDORS" in
        *nvidia*) rec="nvidia" ;;
        *amd*)    rec="amd" ;;
        *intel*)  rec="intel" ;;
    esac
    note "recommended: $rec"

    menu "which graphics driver do you want?" \
        "auto  — use the recommended ($rec)" \
        "nvidia  — proprietary NVIDIA (RTX/GTX)" \
        "amd  — Mesa/RADV (Radeon)" \
        "intel  — Mesa (integrated Intel)" \
        "mesa  — generic open Mesa (works on AMD + Intel)" \
        "skip  — I'll handle drivers myself"
    case "$CHOICE" in
        1) DRIVER_CHOICE="$rec" ;;
        2) DRIVER_CHOICE="nvidia" ;;
        3) DRIVER_CHOICE="amd" ;;
        4) DRIVER_CHOICE="intel" ;;
        5) DRIVER_CHOICE="mesa" ;;
        6) DRIVER_CHOICE=""; note "skipped — no driver changes"; return ;;
    esac
    good "driver: $DRIVER_CHOICE"

    case "$DISTRO" in
        nixos)
            note "add the matching block to your NixOS config (or the tabby-rice.nix module):"
            case "$DRIVER_CHOICE" in
                nvidia) sed 's/^/    /' << 'NX'
services.xserver.videoDrivers = [ "nvidia" ];
hardware.nvidia = {
  modesetting.enable = true;
  powerManagement.enable = true;
  open = true;               # RTX 20-series+; set false for GTX 10-series & older
  nvidiaSettings = true;
};
hardware.graphics.enable = true;
NX
                ;;
                amd) sed 's/^/    /' << 'NX'
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [ amdvlk ];
};
# modern AMD uses the built-in amdgpu kernel driver — nothing else needed
NX
                ;;
                intel) sed 's/^/    /' << 'NX'
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [ intel-media-driver vaapiIntel ];
};
NX
                ;;
                mesa) sed 's/^/    /' << 'NX'
hardware.graphics.enable = true;   # Mesa is included by default on NixOS
NX
                ;;
            esac
            ;;
        arch)
            case "$DRIVER_CHOICE" in
                nvidia) note "installing: nvidia-open-dkms (or nvidia-dkms for older cards)"
                        pm_install nvidia-open-dkms nvidia-utils lib32-nvidia-utils || \
                        pm_install nvidia-dkms nvidia-utils || bad "nvidia install failed — check your kernel headers" ;;
                amd)    pm_install mesa vulkan-radeon lib32-vulkan-radeon libva-mesa-driver || bad "amd driver install failed" ;;
                intel)  pm_install mesa vulkan-intel intel-media-driver || bad "intel driver install failed"
                        pm_install lib32-vulkan-intel 2>/dev/null || note "lib32-vulkan-intel needs the [multilib] repo enabled (skip if you don't game in 32-bit)" ;;
                mesa)   pm_install mesa vulkan-radeon vulkan-intel || bad "mesa install failed" ;;
            esac ;;
        fedora)
            case "$DRIVER_CHOICE" in
                nvidia) note "NVIDIA on Fedora needs RPM Fusion:"
                        note "  sudo dnf install akmod-nvidia xorg-x11-drv-nvidia-cuda"
                        note "  (enable RPM Fusion first: rpmfusion.org)" ;;
                amd)    pm_install mesa-dri-drivers mesa-vulkan-drivers || bad "amd install failed" ;;
                intel)  pm_install mesa-dri-drivers intel-media-driver || bad "intel install failed" ;;
                mesa)   pm_install mesa-dri-drivers mesa-vulkan-drivers || bad "mesa install failed" ;;
            esac ;;
        debian)
            case "$DRIVER_CHOICE" in
                nvidia) note "NVIDIA on Debian/Ubuntu:"
                        note "  sudo apt install nvidia-driver firmware-misc-nonfree"
                        note "  (enable non-free repos first)" ;;
                amd|intel|mesa) pm_install mesa-vulkan-drivers libgl1-mesa-dri || bad "mesa install failed" ;;
            esac ;;
        *)
            note "install the $DRIVER_CHOICE driver with your package manager" ;;
    esac

    # if NVIDIA, remind about the anti-flicker settings we ship
    if [ "$DRIVER_CHOICE" = "nvidia" ]; then
        good "NVIDIA anti-flicker settings are already in hyprland.conf (no hardware cursors, static borders, VRR off)"
    fi
}

# ─── browser picker: choose, install, and bind Super+B ─────
browser_setup() {
    head_ "default browser"
    menu "which browser? (Super+B will open it)" \
        "Firefox" \
        "Chromium" \
        "Brave" \
        "Zen Browser" \
        "I'll set it up myself (skip)"
    local pkg="" bin="" label=""
    case "$CHOICE" in
        1) label="Firefox";  bin="firefox";          arch_pkg="firefox";          deb_pkg="firefox-esr";  fed_pkg="firefox" ;;
        2) label="Chromium"; bin="chromium";         arch_pkg="chromium";         deb_pkg="chromium";     fed_pkg="chromium" ;;
        3) label="Brave";    bin="brave";            arch_pkg="AUR:brave-bin";    deb_pkg="";             fed_pkg="" ;;
        4) label="Zen";      bin="zen-browser";      arch_pkg="AUR:zen-browser-bin"; deb_pkg="";          fed_pkg="" ;;
        5) note "skipped — Super+B stays as-is; edit it in ~/.config/hypr/hyprland.conf"; return ;;
    esac

    # install per distro (skip if no known repo pkg — Brave/Zen are AUR/flatpak)
    case "$DISTRO" in
        arch)
            if [ -z "$arch_pkg" ]; then
                note "$label needs manual setup — bind still set"
            elif [ "${arch_pkg#AUR:}" != "$arch_pkg" ]; then
                aur_install "${arch_pkg#AUR:}" || note "$label (AUR) not installed — bind still set to '$bin'"
            else
                pm_install "$arch_pkg" || note "$label install failed — bind still set"
            fi ;;
        debian) [ -n "$deb_pkg" ]  && pm_install "$deb_pkg"  || note "$label needs a manual install on Debian — bind still set" ;;
        fedora) [ -n "$fed_pkg" ]  && pm_install "$fed_pkg"  || note "$label needs a manual install on Fedora — bind still set" ;;
        nixos)  note "add '$bin' to your NixOS packages — bind will be set to '$bin'" ;;
    esac

    # rewrite the Super+B bind to the chosen browser
    local hc="$HOME/.config/hypr/hyprland.conf"
    if [ -f "$hc" ]; then
        sed -i "s|^bind = \$mod, B, exec, .*|bind = \$mod, B, exec, $bin|" "$hc"
        good "Super+B → $label"
    else
        # configs not installed yet; stash the choice so install_configs can apply it
        BROWSER_BIN="$bin"; BROWSER_LABEL="$label"
        good "browser set to $label (bind applied when configs install)"
    fi
}

extra_tools() {
    [ "$DISTRO" = "nixos" ] || [ -z "$PM" ] && return 0
    local labels=() b
    for b in "${BUNDLES[@]}"; do labels+=("${b%%|*}"); done
    multimenu "optional extras?" "${labels[@]}"
    [ -z "${MCHOICES// }" ] && return 0
    local n pkgs
    for n in $MCHOICES; do
        [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le ${#BUNDLES[@]} ] || continue
        b="${BUNDLES[$((n-1))]}"
        case "$DISTRO" in
            arch)   pkgs="$(echo "$b" | cut -d'|' -f2)" ;;
            debian) pkgs="$(echo "$b" | cut -d'|' -f3)" ;;
            fedora) pkgs="$(echo "$b" | cut -d'|' -f4)" ;;
        esac
        note "installing: ${b%%|*}"
        # shellcheck disable=SC2086
        pm_install $pkgs || bad "some packages in this bundle failed — check output above"
    done
}

# ─── monitor wizard ────────────────────────────────────────
monitor_wizard() {
    head_ "monitor setup"
    local MC="$HOME/.config/hypr/monitors.conf"
    mkdir -p "$HOME/.config/hypr"

    local why=""
    [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && why="not inside a Hyprland session"
    command -v hyprctl >/dev/null 2>&1 || why="hyprctl not found"
    command -v python3 >/dev/null 2>&1 || why="python3 not found"
    if [ -n "$why" ]; then
        bad "monitor wizard skipped: $why"
        note "re-run './install.sh' and pick 'monitor wizard only' — from a terminal INSIDE Hyprland"
        note "(if you're in Hyprland now, python3 may be missing: add it to your packages)"
        note "writing a highest-refresh auto-config so you keep your refresh rate for now"
        # highest-refresh fallback still beats 'preferred' which forces 60Hz
        if command -v hyprctl >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
            hyprctl monitors all -j 2>/dev/null | python3 -c '
import json,sys
try: mons=json.load(sys.stdin)
except: sys.exit(1)
out=[]
for m in mons:
    modes=m.get("availableModes",[])
    best=modes[0] if modes else str(m["width"])+"x"+str(m["height"])+"@60"
    out.append("monitor = "+m["name"]+", "+best.replace("Hz","")+", auto, 1, vrr, 0")
out.append("monitor = , preferred, auto, 1")
print("\n".join(out))
' > "$MC" 2>/dev/null && [ -s "$MC" ] || printf 'monitor = , preferred, auto, 1\n' > "$MC"
        else
            printf 'monitor = , preferred, auto, 1\n' > "$MC"
        fi
        return
    fi

    local JSON; JSON="$(hyprctl monitors all -j 2>/dev/null)" || { bad "hyprctl failed; using auto"; printf 'monitor = , preferred, auto, 1\n' > "$MC"; return; }
    mapfile -t MONS < <(printf '%s' "$JSON" | python3 -c '
import json,sys
for m in json.load(sys.stdin):
    modes = " ".join(m.get("availableModes", [])[:10])
    print(m["name"] + "|" + str(m["width"]) + "x" + str(m["height"]) + "@" + str(round(m["refreshRate"])) + "|" + modes)
')
    local COUNT=${#MONS[@]}
    good "detected $COUNT monitor(s)"
    local i
    for i in "${!MONS[@]}"; do
        note "$((i+1)): ${MONS[$i]%%|*}  (currently $(echo "${MONS[$i]}" | cut -d'|' -f2))"
    done

    local ORDER=()
    if [ "$COUNT" -eq 1 ]; then ORDER=(0)
    else
        while :; do
            ask "monitor numbers left→right (e.g. '1 2'):"
            ORDER=(); local ok=1 n
            for n in $REPLY; do
                [[ "$n" =~ ^[0-9]+$ ]] && [ "$n" -ge 1 ] && [ "$n" -le "$COUNT" ] || { ok=0; break; }
                ORDER+=("$((n-1))")
            done
            [ "$ok" -eq 1 ] && [ ${#ORDER[@]} -ge 1 ] && break
            bad "enter valid numbers 1-$COUNT"
        done
    fi

    local NAMES=() MODES=() SCALES=() idx name cur modes best
    for idx in "${ORDER[@]}"; do
        name="${MONS[$idx]%%|*}"; cur="$(echo "${MONS[$idx]}" | cut -d'|' -f2)"
        modes="$(echo "${MONS[$idx]}" | cut -d'|' -f3)"
        # highest mode = first entry hyprland reports (sorted high→low)
        best="$(echo "$modes" | awk '{print $1}' | sed 's/Hz//')"
        [ -z "$best" ] && best="$cur"
        printf '\n'
        note "$name — available: $modes"
        note "recommended (max): $best"
        ask "resolution@hz for $name [enter = $best]:"
        MODES+=("${REPLY:-$best}"); NAMES+=("$name")
        ask "scale for $name — 1 = native, 1.25/1.5/2 = bigger UI [enter = 1]:"
        SCALES+=("${REPLY:-1}")
    done

    local ALIGN="center"
    if [ "$COUNT" -ge 2 ]; then
        menu "vertical alignment of smaller monitors?" \
            "center  (recommended — smaller screens sit level with the big one)" \
            "top-aligned" "bottom-aligned"
        case "$CHOICE" in 1) ALIGN="center";; 2) ALIGN="top";; 3) ALIGN="bottom";; esac
    fi

    # all layout math in python (handles fractional scales)
    python3 - "$MC" "$ALIGN" "$TS" << 'PYEOF' "${NAMES[@]}" --- "${MODES[@]}" --- "${SCALES[@]}"
import sys, re
mc, align, ts = sys.argv[1], sys.argv[2], sys.argv[3]
rest = sys.argv[4:]
p = [i for i, a in enumerate(rest) if a == "---"]
names, modes, scales = rest[:p[0]], rest[p[0]+1:p[1]], rest[p[1]+1:]

mons = []
for nm, md, sc in zip(names, modes, scales):
    md = md.replace("Hz", "").replace("hz", "")
    m = re.match(r"(\d+)x(\d+)@?([\d.]*)", md)
    if not m:
        sys.exit(f"could not parse mode: {md}")
    w, h = int(m.group(1)), int(m.group(2))
    hz = m.group(3) or "60"
    try: s = float(sc)
    except ValueError: s = 1.0
    if s <= 0: s = 1.0
    mons.append(dict(name=nm, w=w, h=h, hz=hz, scale=s,
                     lw=round(w/s), lh=round(h/s)))

maxlh = max(m["lh"] for m in mons)
x = 0
lines = []
for m in mons:
    y = 0
    if align == "center": y = (maxlh - m["lh"]) // 2
    elif align == "bottom": y = maxlh - m["lh"]
    sc = ("%g" % m["scale"])
    lines.append(f'monitor = {m["name"]}, {m["w"]}x{m["h"]}@{m["hz"]}, {x}x{y}, {sc}, vrr, 0')
    x += m["lw"]

ws = []
if len(mons) >= 2:
    a, b = mons[0]["name"], mons[1]["name"]
    ws.append(f"workspace = 1, monitor:{a}, default:true")
    ws += [f"workspace = {i}, monitor:{a}" for i in (2, 3, 4, 5)]
    ws.append(f"workspace = 6, monitor:{b}, default:true")
    ws += [f"workspace = {i}, monitor:{b}" for i in (7, 8, 9)]

with open(mc, "w") as f:
    f.write(f"# monitors.conf — generated by install.sh ({ts})\n")
    f.write("\n".join(lines) + "\n")
    f.write("monitor = , preferred, auto, 1\n")
    if ws:
        f.write("\n" + "\n".join(ws) + "\n")
print("\n".join(lines))
PYEOF
    if [ $? -eq 0 ]; then
        good "wrote $MC"
        [ "$COUNT" -ge 2 ] && note "workspaces 1-5 → first monitor, 6-9 → second"
        command -v hyprctl >/dev/null && hyprctl reload >/dev/null 2>&1
    else
        bad "layout generation failed — wrote nothing; your previous monitors.conf is untouched"
    fi
}

# ─── configs ───────────────────────────────────────────────
install_configs() {
    head_ "configs + scripts"
    note "backing up anything replaced → $BACKUP"
    local f rel
    while IFS= read -r f; do
        rel="${f#home/}"
        [ -e "$HOME/$rel" ] && { mkdir -p "$BACKUP/$(dirname "$rel")"; cp -a "$HOME/$rel" "$BACKUP/$rel"; }
    done < <(find home -type f | sort)
    # copy the whole home/ tree reliably: recreate dirs, then copy each file
    # by its relative path (the old find -exec {} approach didn't expand the
    # brace inside a quoted arg on all find implementations — files got lost)
    while IFS= read -r d; do
        mkdir -p "$HOME/${d#home/}"
    done < <(find home -type d)
    while IFS= read -r f; do
        rel="${f#home/}"
        mkdir -p "$HOME/$(dirname "$rel")"
        cp -f "$f" "$HOME/$rel"
    done < <(find home -type f)
    chmod +x "$HOME"/.local/bin/* 2>/dev/null
    good "installed configs for: hyprland waybar rofi kitty mako fastfetch fish starship hyprlock dolphin"

    # CRITICAL: on Hyprland 0.55+, a fresh install is a "Lua root" — Hyprland
    # autogenerates a hyprland.lua and loads THAT instead of our hyprland.conf,
    # silently ignoring the whole rice. This is the #1 "nothing installed!" gotcha.
    if [ -f "$HOME/.config/hypr/hyprland.lua" ]; then
        if grep -q "AUTOGENERATED" "$HOME/.config/hypr/hyprland.lua" 2>/dev/null; then
            # it's Hyprland's throwaway example — safe to remove
            bad "found Hyprland's autogenerated hyprland.lua — it overrides our config!"
            note "on fresh installs Hyprland loads .lua instead of .conf, ignoring the rice"
            mv "$HOME/.config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua.autogen-bak-$TS"
            good "moved the autogenerated .lua aside so hyprland.conf will load"
        else
            # a real user .lua — don't nuke it, ask
            bad "found a hyprland.lua — Hyprland loads it INSTEAD of our config!"
            ask "back it up so this rice's config loads? [Y/n]"
            if [ "$REPLY" != "n" ]; then
                mv "$HOME/.config/hypr/hyprland.lua" "$HOME/.config/hypr/hyprland.lua.bak-$TS"
                good "moved hyprland.lua → hyprland.lua.bak-$TS"
            fi
        fi
        LUA_WAS_PRESENT=1
    fi

    # SDDM theme → needs sudo to land in the system themes dir
    if command -v sddm >/dev/null 2>&1 && [ -d "$HOME/.config/sddm/tabby" ]; then
        if [ -w /usr/share/sddm/themes ] || sudo -n true 2>/dev/null || true; then
            ask "install the tabby SDDM login theme (needs sudo)? [Y/n]"
            if [ "$REPLY" != "n" ]; then
                # the theme needs QtQuick.Controls — warn if the module isn't present
                if [ -d /usr/lib/qt6/qml/QtQuick/Controls ] || [ -d /usr/lib/qt/qml/QtQuick/Controls ]; then :; else
                    bad "QtQuick.Controls module not found — the login theme needs it to render"
                    note "arch: it's part of qt6-declarative · fedora: qt6-qtquickcontrols2 · debian: qml6-module-qtquick-controls"
                fi
                sudo mkdir -p /usr/share/sddm/themes/tabby 2>/dev/null &&
                sudo cp -r "$HOME/.config/sddm/tabby/." /usr/share/sddm/themes/tabby/ 2>/dev/null &&
                sudo mkdir -p /etc/sddm.conf.d 2>/dev/null &&
                echo -e "[Theme]\nCurrent=tabby" | sudo tee /etc/sddm.conf.d/tabby.conf >/dev/null 2>&1 &&
                good "SDDM theme installed and selected" ||
                note "SDDM theme copy needs manual sudo — see nixos/ for the NixOS way"
            fi
        fi
    fi

    # guarantee hyprland's sourced includes exist so first reload has no errors
    if [ ! -f "$HOME/.config/hypr/colors.conf" ]; then
        . "$HOME/.config/theme-engine/themes/graphite.sh"
        printf '$bg     = rgba(%sff)\n$bg1    = rgba(%sff)\n$bg2    = rgba(%sff)\n$fg     = rgba(%sff)\n$muted  = rgba(%sff)\n$accent = rgba(%sff)\n$red    = rgba(%sff)\n' \
            "$BG" "$BG1" "$BG2" "$FG" "$MUTED" "$ACCENT" "$RED" > "$HOME/.config/hypr/colors.conf"
    fi
    [ -f "$HOME/.config/hypr/monitors.conf" ] || printf 'monitor = , preferred, auto, 1\n' > "$HOME/.config/hypr/monitors.conf"

    # shell integration — starship prompt + PATH for whatever shells exist.
    # KEY FIX: create rc files if missing (fresh NixOS has no ~/.bashrc, so
    # starship never got wired before — that's why the prompt was plain).
    mkdir -p "$HOME/.config/fish/conf.d"
    [ -f "$HOME/.config/fish/conf.d/rice.fish" ] || \
        printf 'fish_add_path -g ~/.local/bin\nstatus is-interactive; and command -v starship >/dev/null; and starship init fish | source\n' > "$HOME/.config/fish/conf.d/rice.fish"

    # bash — always ensure the block exists (create .bashrc if absent)
    touch "$HOME/.bashrc"
    if ! grep -q 'rice-installer' "$HOME/.bashrc"; then
        printf '\n# rice-installer\nexport PATH="$HOME/.local/bin:$PATH"\ncommand -v starship >/dev/null && eval "$(starship init bash)"\n' >> "$HOME/.bashrc"
    fi

    # zsh — only if the user actually uses zsh (don't create it uninvited)
    if [ -f "$HOME/.zshrc" ] && ! grep -q 'rice-installer' "$HOME/.zshrc"; then
        printf '\n# rice-installer\nexport PATH="$HOME/.local/bin:$PATH"\ncommand -v starship >/dev/null && eval "$(starship init zsh)"\n' >> "$HOME/.zshrc"
    fi
    good "shell integration wired — starship works in bash and fish now"

    if command -v fish >/dev/null 2>&1 && [ "$(basename "${SHELL:-}")" != "fish" ]; then
        ask "make fish your default shell? [y/N]"
        [ "$REPLY" = "y" ] && chsh -s "$(command -v fish)" && good "default shell → fish (takes effect next login)"
    fi
}

# ─── main ──────────────────────────────────────────────────
banner
detect_distro
head_ "system"
note "distro:  $DISTRO${PM:+ ($PM)}"
note "session: $([ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && echo 'inside Hyprland ✔' || echo 'not in Hyprland')"
note "nothing is changed without asking, and your current configs are backed up first"

if [ "${1:-}" = "--check" ]; then
    if verify_bins; then good "all required binaries present"; else bad "missing: ${MISSING[*]}"; fi
    exit 0
fi

menu "what would you like to do?" \
    "Install everything  (recommended for a fresh setup)" \
    "Just the configs  (I already have the programs)" \
    "Set up my monitors" \
    "Install graphics drivers" \
    "Quit"
case "$CHOICE" in
    1) install_packages; driver_setup; extra_tools; install_configs; browser_setup; monitor_wizard; FULL_INSTALL=1 ;;
    2) install_configs; browser_setup; monitor_wizard ;;
    3) monitor_wizard; exit 0 ;;
    4) driver_setup; exit 0 ;;
    5) exit 0 ;;
esac

head_ "wallpapers"
if [ -d "$HOME/Pictures/wallpapers/graphite" ]; then good "curated set already present"
else
    ask "download the curated wallpaper set (~135 MB, from github)? [Y/n]"
    [ "$REPLY" != "n" ] && "$HOME/.local/bin/wall-fetch"
fi

head_ "all set"
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    pgrep -x awww-daemon >/dev/null 2>&1 || pgrep -x swww-daemon >/dev/null 2>&1 || \
        { "$HOME/.local/bin/wallpaper-daemon" >/dev/null 2>&1 & disown; sleep 0.5; }
    pgrep -x mako >/dev/null 2>&1 || { mako >/dev/null 2>&1 & disown; }
    "$HOME/.local/bin/theme-switch" --restore >/dev/null 2>&1
    hyprctl reload >/dev/null 2>&1
    good "your rice is live"
    if [ "${LUA_WAS_PRESENT:-0}" = "1" ]; then
        echo
        bad "one important step: log out fully and log back in"
        note "Hyprland only picks its config format at startup, so a reload isn't enough —"
        note "log out to the login screen and back in, or the rice won't show up."
    fi
else
    good "installed — just log into Hyprland and it all starts automatically"
fi
printf '\n  %s%sSuper+F2%s themes   %s%sSuper+F3%s wallpapers   %s%sSuper+F4%s bar styles\n' "$B" "$FG1" "$R" "$B" "$FG1" "$R" "$B" "$FG1" "$R"
note "press Super+Shift+H anytime for the full keybind list"
printf '  %sbackups saved to: %s%s\n' "$DIM" "$BACKUP" "$R"

# welcome panel
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] && [ -x "$HOME/.local/bin/rice-welcome" ]; then
    ask "open the welcome panel now? [Y/n]"
    [ "$REPLY" != "n" ] && "$HOME/.local/bin/rice-welcome" >/dev/null 2>&1
fi

# only surface problems that ACTUALLY exist — a clean install stays quiet
PROBLEMS=0
if ! pgrep -x wireplumber >/dev/null 2>&1 && command -v waybar >/dev/null 2>&1; then
    [ "$PROBLEMS" = 0 ] && head_ "a couple of things to finish"
    PROBLEMS=1
    note "audio isn't running yet — start it with:"
    note "  systemctl --user enable --now wireplumber pipewire pipewire-pulse"
fi
if ! command -v awww >/dev/null 2>&1 && ! command -v swww >/dev/null 2>&1; then
    [ "$PROBLEMS" = 0 ] && head_ "a couple of things to finish"
    PROBLEMS=1
    note "no wallpaper daemon yet — install 'awww', then run 'wall' to pick one"
fi

# ─── offer a reboot (only after a full install) ─────────────
# a fresh install touches drivers, fonts, services, and the display manager —
# a reboot ensures SDDM, the GPU driver, and font cache all come up clean.
if [ "${FULL_INSTALL:-0}" = "1" ]; then
    echo
    head_ "all done"
    good "tabby rice is installed"
    note "a reboot is recommended so drivers, fonts, SDDM, and services all load fresh"
    ask "reboot now? [y/N]"
    if [ "$REPLY" = "y" ] || [ "$REPLY" = "Y" ]; then
        note "rebooting..."
        sleep 1
        systemctl reboot 2>/dev/null || sudo reboot 2>/dev/null || reboot
    else
        note "no reboot — but log out and back in (or reboot later) to get everything"
    fi
fi
