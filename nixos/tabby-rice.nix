# tabby-rice.nix — drop-in NixOS module for the rice
#
# usage: copy this file next to your configuration.nix, then add to your
# configuration.nix imports:
#
#     imports = [ ./tabby-rice.nix ];
#
# then `sudo nixos-rebuild switch`. handles packages, fonts, SDDM, Hyprland,
# and the display/audio stack so the rice actually works on a fresh install.
# after rebuilding, run ./install.sh and pick "configs only" to drop the
# dotfiles into your home directory.

{ config, pkgs, lib, ... }:

{
  # ─── Hyprland compositor ───────────────────────────────
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # ─── login manager: SDDM on Wayland ────────────────────
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # the custom theme installs to ~/.local/share or /run; point SDDM at it
    # after running install.sh, or set theme = "tabby"; once it's in
    # /usr/share/sddm/themes (the installer copies it there with sudo).
  };

  # ─── fonts (this is why your apps had no glyphs) ───────
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      nerd-fonts.symbols-only
      noto-fonts
      noto-fonts-emoji
      noto-fonts-cjk-sans
    ];
    fontconfig = {
      enable = true;
      defaultFonts = {
        monospace = [ "JetBrainsMono Nerd Font" ];
        emoji = [ "Noto Color Emoji" ];
      };
    };
  };

  # ─── audio (wireplumber, for the volume keys) ──────────
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  # ─── all the rice packages ─────────────────────────────
  environment.systemPackages = with pkgs; [
    waybar rofi kitty starship mako libnotify fastfetch fish
    awww hyprlock hypridle hyprpicker
    cliphist wl-clipboard grim slurp swappy
    brightnessctl playerctl wireplumber pavucontrol
    networkmanagerapplet blueman btop
    papirus-icon-theme bibata-cursors
    kdePackages.dolphin kdePackages.qtsvg
    libsForQt5.qt5ct qt6ct kdePackages.qtstyleplugin-kvantum
    python3
  ];

  # make Qt apps (Dolphin) use qt6ct theming — this is the piece that
  # actually gets Dolphin to pick up the dark theme + Papirus icons
  qt = {
    enable = true;
    platformTheme = "qt6ct";
  };

  # ─── polkit agent (for auth prompts) ───────────────────
  security.polkit.enable = true;

  # ─── portals (screen share, file pickers) ──────────────
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  # ─── NVIDIA (uncomment if you have an NVIDIA GPU) ───────
  # services.xserver.videoDrivers = [ "nvidia" ];
  # hardware.nvidia = {
  #   modesetting.enable = true;
  #   powerManagement.enable = true;
  #   open = true;                # RTX 20-series and newer; false for older
  #   nvidiaSettings = true;
  # };
  # hardware.graphics.enable = true;
}
