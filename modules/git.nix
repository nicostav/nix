# ============================================================
# modules/git.nix
# Git + GitHub tooling at the system level.
# Per-user git identity (name, email, signing key) is set in
# home/default.nix so it can differ per machine/user.
# ============================================================

{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    git
    git-lfs        # large file storage
    gh             # GitHub CLI (gh auth login, gh pr create, etc.)
    lazygit        # fantastic TUI git client — highly recommended
    delta          # beautiful git diffs (configured in home.nix)
    git-crypt
  ];

  # Enable git-lfs globally
  programs.git = {
    enable = true;
    lfs.enable = true;
  };
}
