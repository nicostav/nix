# ============================================================
# modules/apps.nix
# User-facing applications. Add / remove freely.
# ============================================================

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [

    # ── Terminal emulator ──────────────────────────────────────
    kitty

    # ── Email ─────────────────────────────────────────────────
    thunderbird

    # ── Editor ────────────────────────────────────────────────
    sublime4          # requires allowUnfree = true (set in base.nix)
    neovim
    notion-app
    trilium-desktop

    # ── Productivity ──────────────────────────────────────────
    libreoffice-qt    # Qt-native build fits better inside KDE

    # ── Spotify ───────────────────────────────────────────────
    spotify
    spotify-tray

    # ── Utilities ─────────────────────────────────────────────
    bat               # `cat` with syntax highlighting
    fd                # fast `find` replacement
    ripgrep           # fast `grep` replacement
    fzf               # fuzzy finder (used by zsh plugins too)
    zoxide            # smarter `cd` with memory
    tldr              # quick command examples
    jq                # JSON processor
    btop              # fancy system monitor
    synology-drive-client
    cryptomator
    portfolio
    threema-desktop
    wireguard-ui
  ];

  # ── Zen Browser ─────────────────────────────────────────────
  # Zen is not yet in nixpkgs mainline; install via the community
  # overlay or a wrapped Firefox derivation. The simplest approach
  # that works today without flakes:
  #
  # Option A (recommended while Zen is not in nixpkgs):
  #   Use the zen-browser overlay. Add this to your channel list:
  #     sudo nix-channel --add https://github.com/youwen5/zen-browser-flake/archive/main.tar.gz zen-browser
  #     sudo nix-channel --update
  #   Then uncomment:
  #     environment.systemPackages = [ pkgs.zen-browser ];
  #
  # Option B: install Firefox as a placeholder and use the Zen tarball
  #   manually until official packaging lands:
  programs.firefox.enable = true;   # remove once Zen is set up
  # programs.firefox.enable = false;
  # environment.systemPackages = [ pkgs.zen-browser ];  # after overlay setup

  # ── Flatpak (escape hatch for apps not yet in nixpkgs) ──────
  # Useful for things like Zen while packaging catches up.
  # services.flatpak.enable = true;

  # ── AppImage support ────────────────────────────────────────
  programs.appimage = {
    enable = true;
    binfmt = true;   # run AppImages directly without a launcher
  };
}
