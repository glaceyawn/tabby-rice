#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════
#   t a b b y   r i c e  —  universal installer
#   usage: ./install.sh          interactive
#          ./install.sh --check  detect distro + packages only
# ═══════════════════════════════════════════════════════════
set -u
cd "$(dirname "$0")"
TS="$(date +%Y%m%d-%H%M%S)"
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
PKGS_ARCH=(hyprland waybar rofi-wayland kitty starship mako libnotify fastfetch fish
           hyprlock hypridle hyprpicker cliphist wl-clipboard grim slurp swappy
           brightnessctl playerctl wireplumber pavucontrol
           network-manager-applet blueman btop papirus-icon-theme
           ttf-jetbrainsmono-nerd ttf-nerd-fonts-symbols dolphin swww)
PKGS_FEDORA=(hyprland waybar rofi-wayland kitty starship mako libnotify fastfetch fish
             hyprlock hypridle hyprpicker cliphist wl-clipboard grim slurp swappy
             brightnessctl playerctl wireplumber pavucontrol
             network-manager-applet blueman btop papirus-icon-theme
             jetbrains-mono-fonts dolphin)
PKGS_DEBIAN=(hyprland waybar rofi kitty mako-notifier libnotify-bin fastfetch fish
             cliphist wl-clipboard grim slurp brightnessctl playerctl
             wireplumber pavucontrol blueman btop papirus-icon-theme
             fonts-jetbrains-mono dolphin)

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
    case "$PM" in
        pacman) sudo pacman -S --needed --noconfirm "$@" ;;
        apt)    sudo apt install -y "$@" ;;
        dnf)    sudo dnf install -y "$@" ;;
    esac
}

install_packages() {
    head_ "packages · $DISTRO"
    case "$DISTRO" in
        nixos)
            note "NixOS installs declaratively — add this to your config, rebuild, then re-run:"
            sed 's/^/    /' << 'NIX'
environment.systemPackages = with pkgs; [
  waybar rofi-wayland kitty starship mako libnotify fastfetch fish
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

    if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || ! command -v hyprctl >/dev/null 2>&1 || ! command -v python3 >/dev/null 2>&1; then
        note "not inside a Hyprland session (or python3 missing)"
        note "writing safe auto-config; re-run ./install.sh → 'monitor wizard' from inside Hyprland"
        printf '# auto — re-run install.sh inside Hyprland for the wizard\nmonitor = , preferred, auto, 1\n' > "$MC"
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

    local NAMES=() MODES=() SCALES=() idx name cur modes
    for idx in "${ORDER[@]}"; do
        name="${MONS[$idx]%%|*}"; cur="$(echo "${MONS[$idx]}" | cut -d'|' -f2)"
        modes="$(echo "${MONS[$idx]}" | cut -d'|' -f3)"
        printf '\n'
        note "$name — modes: $modes"
        ask "resolution@hz for $name [enter = $cur]:"
        MODES+=("${REPLY:-$cur}"); NAMES+=("$name")
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
    lines.append(f'monitor = {m["name"]}, {m["w"]}x{m["h"]}@{m["hz"]}, {x}x{y}, {sc}')
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
    (cd home && find . -type d -exec mkdir -p "$HOME/{}" \; && find . -type f -exec cp {} "$HOME/{}" \;)
    chmod +x "$HOME"/.local/bin/theme-switch "$HOME"/.local/bin/wall \
             "$HOME"/.local/bin/wall-fetch "$HOME"/.local/bin/bar-switch \
             "$HOME"/.local/bin/wallpaper-daemon
    good "installed configs for: hyprland waybar rofi kitty mako fastfetch fish starship"

    mkdir -p "$HOME/.config/fish/conf.d"
    [ -f "$HOME/.config/fish/conf.d/rice.fish" ] || \
        printf 'fish_add_path -g ~/.local/bin\nstatus is-interactive; and command -v starship >/dev/null; and starship init fish | source\n' > "$HOME/.config/fish/conf.d/rice.fish"
    if [ -f "$HOME/.bashrc" ] && ! grep -q 'rice-installer' "$HOME/.bashrc"; then
        printf '\n# rice-installer\nexport PATH="$HOME/.local/bin:$PATH"\ncommand -v starship >/dev/null && eval "$(starship init bash)"\n' >> "$HOME/.bashrc"
    fi
    if [ -f "$HOME/.zshrc" ] && ! grep -q 'rice-installer' "$HOME/.zshrc"; then
        printf '\n# rice-installer\nexport PATH="$HOME/.local/bin:$PATH"\ncommand -v starship >/dev/null && eval "$(starship init zsh)"\n' >> "$HOME/.zshrc"
    fi
    good "shell integration wired (fish/bash/zsh)"

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

if [ "${1:-}" = "--check" ]; then
    if verify_bins; then good "all required binaries present"; else bad "missing: ${MISSING[*]}"; fi
    exit 0
fi

menu "what would you like to do?" \
    "full install  (packages → extras → configs → monitors → wallpapers)" \
    "configs + scripts only" \
    "monitor wizard only" \
    "quit"
case "$CHOICE" in
    1) install_packages; extra_tools; install_configs; monitor_wizard ;;
    2) install_configs; monitor_wizard ;;
    3) monitor_wizard; exit 0 ;;
    4) exit 0 ;;
esac

head_ "wallpapers"
if [ -d "$HOME/Pictures/wallpapers/graphite" ]; then good "curated set already present"
else
    ask "download the curated wallpaper set (~135 MB, from github)? [Y/n]"
    [ "$REPLY" != "n" ] && "$HOME/.local/bin/wall-fetch"
fi

head_ "finishing"
if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
    pgrep -x awww-daemon >/dev/null 2>&1 || pgrep -x swww-daemon >/dev/null 2>&1 || \
        { "$HOME/.local/bin/wallpaper-daemon" >/dev/null 2>&1 & disown; sleep 0.5; }
    pgrep -x mako >/dev/null 2>&1 || { mako >/dev/null 2>&1 & disown; }
    "$HOME/.local/bin/theme-switch" --restore >/dev/null 2>&1
    hyprctl reload >/dev/null 2>&1
    good "applied live"
else
    good "installed — log into Hyprland and everything autostarts"
fi
printf '\n  %s%sSuper+F2%s themes   %s%sSuper+F3%s wallpapers   %s%sSuper+F4%s bar styles\n' "$B" "$FG1" "$R" "$B" "$FG1" "$R" "$B" "$FG1" "$R"
printf '  %sbackups: %s%s\n\n' "$DIM" "$BACKUP" "$R"
