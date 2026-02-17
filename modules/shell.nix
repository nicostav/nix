# ============================================================
# modules/shell.nix
# Zsh system-level enablement + global environment.
# Per-user zsh customisation (plugins, theme, aliases) lives in
# home/default.nix via home-manager.
# ============================================================

{ config, pkgs, ... }:

{
  # Enable zsh at the system level so it appears in /etc/shells
  # and can be set as a login shell for users.
  programs.zsh.enable = true;

  # ── Global environment variables ────────────────────────────
  environment.sessionVariables = {
    EDITOR    = "subl --wait";    # Sublime Text as default editor
    VISUAL    = "subl --wait";
    PAGER     = "bat --style=plain";
    MANPAGER  = "sh -c 'col -bx | bat -l man -p'";  # man pages via bat
  };

  # ── PATH additions ──────────────────────────────────────────
  # Nix manages most paths automatically; add extras here if needed.
  # environment.sessionVariables.PATH = [ "$HOME/.local/bin" "$PATH" ];
}
