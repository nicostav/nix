# ============================================================
# home/default.nix
# Home-Manager configuration — per-user, per-machine settings.
# This is where dotfiles and program config live in a
# declarative, reproducible way.


# ============================================================
# Setup (one-time):
#   sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
#   sudo nix-channel --update
#   # Then add home-manager module to imports in configuration.nix:
#   # <home-manager/nixos>
# ============================================================

{ config, pkgs, ... }:

{
  # Import home-manager NixOS module (resolves via channel)
  imports = [ <home-manager/nixos> ];

  home-manager = {
    useGlobalPkgs   = true;   # share the system nixpkgs instance
    useUserPackages = true;   # install home-manager packages into system profile

    users.yourname = { pkgs, ... }: {   # TO_CHANGE

      home.stateVersion = "25.11";      # must match system.stateVersion

      # ── Git identity ──────────────────────────────────────────
      programs.git = {
        enable    = true;

        settings = {
          userName  = "nicostav";
          userEmail = "you@example.com";   # TO_CHANGE
          init.defaultBranch = "main";
          pull.rebase         = true;
          push.autoSetupRemote = true;
          core.pager           = "delta";

          # delta (pretty diffs)
          delta = {
            navigate        = true;
            side-by-side    = true;
            line-numbers    = true;
            syntax-theme    = "Dracula";
          };

          # Sign commits with SSH key (recommended over GPG for GitHub)
          # gpg.format = "ssh";
          # user.signingKey = "~/.ssh/id_ed25519.pub";
          # commit.gpgSign = true;
        };

        # Useful global ignores
        ignores = [
          ".DS_Store"
          "*.swp"
          ".direnv"
          ".env"
        ];
      };

      # ── Zsh ───────────────────────────────────────────────────
      programs.zsh = {
        enable = true;

        # History
        history = {
          size       = 50000;
          save       = 50000;
          ignoreDups = true;
          share      = true;    # share history between terminals
        };

        # Handy options
        autocd              = true;
        enableCompletion    = true;
        syntaxHighlighting.enable = true;
        autosuggestion.enable     = true;

        # Plugins (managed by home-manager, no Oh-My-Zsh needed)
        plugins = [
          {
            name = "zsh-fzf-history-search";
            src  = pkgs.fetchFromGitHub {
              owner  = "joshskidmore";
              repo   = "zsh-fzf-history-search";
              rev    = "d1aae98";
              sha256 = "sha256-4Dp2ehZLO83NhdBOKV0BhYFIvieaZPqiZZZtxsXWRaQ=";
            };
          }
        ];

        # Aliases
        shellAliases = {
          # Better defaults
          ll    = "ls -lsa";
          lt    = "eza --tree --icons --level=2";
          cat   = "bat";
          grep  = "rg";
          find  = "fd";
          cd    = "z";          # zoxide smarter cd

          # Kitty
          icat  = "kitty +kitten icat";   # display images in terminal

          # Nvim
          nvimm = "nvim .";
        };

        # Commands run for every interactive shell
        initContent = ''
          # zoxide init (smart cd)
          eval "$(zoxide init zsh)"

          # fzf keybindings & completion
          source ${pkgs.fzf}/share/fzf/key-bindings.zsh
          source ${pkgs.fzf}/share/fzf/completion.zsh

          # Better fzf defaults
          export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
          export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
        '';
      };

      # ── Starship prompt (works great with zsh) ────────────────
      programs.starship = {
        enable = true;
        settings = {
          add_newline = true;
          character = {
            success_symbol = "[❯](bold green)";
            error_symbol   = "[❯](bold red)";
          };
          git_branch.symbol  = " ";
          git_status.style   = "bold yellow";
          nix_shell.symbol   = "❄️  ";
        };
      };

      # ── Kitty terminal ────────────────────────────────────────
      programs.kitty = {
        enable = true;
        font = {
          name = "JetBrainsMono Nerd Font";
          size = 13;
        };
        settings = {
          # Theme (pick one, or use `kitty +kitten themes` interactively)
          background            = "#282a36";  # Dracula palette
          foreground            = "#f8f8f2";
          selection_background  = "#44475a";
          selection_foreground  = "#ffffff";
          url_color             = "#8be9fd";
          cursor                = "#f8f8f2";

          # Window
          window_padding_width  = 8;
          hide_window_decorations = "yes";

          # Tabs
          tab_bar_style         = "powerline";

          # Scrollback
          scrollback_lines      = 10000;

          # Performance
          repaint_delay         = 10;
          sync_to_monitor       = "yes";
        };
        keybindings = {
          "ctrl+shift+t" = "new_tab_with_cwd";
          "ctrl+shift+enter" = "new_window_with_cwd";
        };
      };

      # ── Home packages (user-only, not system-wide) ────────────
      home.packages = with pkgs; [
        # These are fine at user level; heavier system stuff is in modules/
      ];
    };
  };
}
