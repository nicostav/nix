# ============================================================
# modules/desktop-kde.nix
# KDE Plasma 6 desktop environment + SDDM display manager.
# Only imported by hosts that want a GUI (not a headless server).
# ============================================================

{ config, pkgs, ... }:

{
  # ── Display server: Wayland (recommended for Plasma 6) ──────
  # X11 fallback is still available from the SDDM session picker.
  services.xserver = {
    enable = true;
    xkb = {
      layout  = "ch";   # change to your keyboard layout, e.g. "de"
      variant = "";
    };
  };

  # ── KDE Plasma 6 ────────────────────────────────────────────
  services.desktopManager.plasma6.enable = true;

  # ── Display manager ─────────────────────────────────────────
  services.displayManager = {
    sddm = {
      enable      = true;
      wayland.enable = true;   # SDDM itself runs on Wayland
    };
    defaultSession = "plasma";
  };

  # ── KDE-friendly extras ─────────────────────────────────────
  programs.dconf.enable = true;   # needed for some GTK apps inside KDE

  environment.systemPackages = with pkgs; [
    # Plasma addons worth having from day one
    kdePackages.plasma-browser-integration
    kdePackages.kdeplasma-addons
    kdePackages.kdeconnect-kde   # phone integration
    kdePackages.filelight         # disk usage visualizer
    kdePackages.ark               # archive manager
    kdePackages.okular            # PDF / document viewer
    kdePackages.gwenview          # image viewer
    kdePackages.spectacle         # screenshot tool

    # GTK theme so GTK apps look decent inside KDE
    adwaita-qt
  ];
}
