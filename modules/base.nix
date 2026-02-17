# ============================================================
# modules/base.nix
# Shared settings that apply to ALL machines (desktop + notebook).
# ============================================================

{ config, pkgs, ... }:

{
  # ── Nix settings ────────────────────────────────────────────
  nix.settings = {
    experimental-features = [ "nix-command" ]; # NOT enabling flakes for now
    auto-optimise-store = true;                 # deduplicate store files
  };

  # Allow unfree packages (Sublime Text, some GPU drivers, etc.)
  nixpkgs.config.allowUnfree = true;

  # ── Locale & timezone ───────────────────────────────────────
  # Adjust to your timezone: https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_TIME     = "en_GB.UTF-8";  # 24h clock
    LC_MONETARY = "en_US.UTF-8";
  };

  # ── Networking ──────────────────────────────────────────────
  networking.networkmanager.enable = true;

  # ── Fonts ───────────────────────────────────────────────────
  fonts = {
    enableDefaultPackages = true;
    packages = with pkgs; [
      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-emoji
      liberation_ttf
      (nerdfonts.override { fonts = [ "JetBrainsMono" "FiraCode" ]; })
    ];
    fontconfig.defaultFonts = {
      serif      = [ "Noto Serif" ];
      sansSerif  = [ "Noto Sans" ];
      monospace  = [ "JetBrainsMono Nerd Font" ];
    };
  };

  # ── Core system packages ─────────────────────────────────────
  # Only things every machine needs; app-specific stuff lives in apps.nix
  environment.systemPackages = with pkgs; [
    curl
    wget
    unzip
    zip
    htop
    pciutils     # lspci
    usbutils     # lsusb
    man-pages
  ];

  # ── Misc services ───────────────────────────────────────────
  services.openssh.enable = false;  # flip to true if you need SSH in
  services.printing.enable = true;  # CUPS for printers
}
