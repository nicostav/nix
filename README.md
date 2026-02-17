# NixOS Configuration

A structured, traditional-channel NixOS config for one or more machines.
No flakes required — easy to understand, easy to migrate to flakes later.

---

## Directory Structure

```
nixos-config/
├── hosts/
│   ├── desktop/
│   │   ├── configuration.nix      ← machine entry point (symlink /etc/nixos/configuration.nix here)
│   │   └── hardware-configuration.nix  ← auto-generated, machine-specific
│   └── notebook/                  ← add later, same pattern
│       ├── configuration.nix
│       └── hardware-configuration.nix
│
├── modules/                       ← shared, reusable config pieces
│   ├── base.nix                   ← locale, fonts, nix settings (ALL machines)
│   ├── desktop-kde.nix            ← KDE Plasma 6 + SDDM (GUI machines only)
│   ├── apps.nix                   ← applications (GUI machines only)
│   ├── shell.nix                  ← zsh system-level + env vars
│   └── git.nix                    ← git + GitHub CLI
│
└── home/
    └── default.nix                ← home-manager: dotfiles, per-user config
```

---

## First-Time Setup

### 1. Boot the NixOS installer

Download the ISO from https://nixos.org/download and boot it.

### 2. Partition & format your disk

```bash
# Example for a single-disk UEFI system (adjust device names!):
sudo fdisk /dev/sda    # or gdisk for GPT
# Create: 1 GiB EFI partition (type EFI), rest Linux filesystem

sudo mkfs.fat -F 32 /dev/sda1
sudo mkfs.ext4 /dev/sda2           # or btrfs — see note below

sudo mount /dev/sda2 /mnt
sudo mkdir -p /mnt/boot
sudo mount /dev/sda1 /mnt/boot
```

> **Btrfs tip:** If you want snapshots (great with NixOS), format with
> `mkfs.btrfs` and create subvolumes `@` and `@home`. Many guides online.

### 3. Generate hardware config

```bash
sudo nixos-generate-config --root /mnt
```

This creates `/mnt/etc/nixos/hardware-configuration.nix` and a stub
`configuration.nix`. **Keep** the hardware file, discard the stub.

### 4. Clone this repo onto the new system

```bash
sudo nix-shell -p git
git clone <your-repo-url> /mnt/etc/nixos/nixos-config
```

### 5. Copy hardware config into the repo

```bash
cp /mnt/etc/nixos/hardware-configuration.nix \
   /mnt/etc/nixos/nixos-config/hosts/desktop/
```

### 6. Set up the channels

```bash
# NixOS (should already be set if using the installer):
sudo nix-channel --add https://nixos.org/channels/nixos-24.11 nixos
sudo nix-channel --update

# home-manager (must match NixOS release):
sudo nix-channel --add \
  https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz \
  home-manager
sudo nix-channel --update
```

### 7. Point /etc/nixos/configuration.nix at your host config

```bash
sudo ln -sf /etc/nixos/nixos-config/hosts/desktop/configuration.nix \
            /etc/nixos/configuration.nix
```

### 8. Edit the config for your machine

Before rebuilding, open the files and change:

| File | What to change |
|------|---------------|
| `hosts/desktop/configuration.nix` | hostname, GPU section, username |
| `modules/base.nix` | timezone, locale, keyboard layout |
| `home/default.nix` | `yourname`, git name, git email |

### 9. Install!

```bash
sudo nixos-install
sudo reboot
```

---

## Day-to-Day Usage

```bash
# Apply changes after editing any .nix file:
sudo nixos-rebuild switch

# Test a change without making it the boot default:
sudo nixos-rebuild test

# Roll back to the previous generation:
sudo nixos-rollback

# Update all channels and rebuild:
sudo nix-channel --update && sudo nixos-rebuild switch

# List generations (bootloader entries):
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Garbage collect old generations (free disk space):
sudo nix-collect-garbage -d
```

---

## Adding the Notebook Later

1. Copy the desktop host directory: `cp -r hosts/desktop hosts/notebook`
2. Copy *that machine's* `hardware-configuration.nix` into `hosts/notebook/`
3. Edit `hosts/notebook/configuration.nix`:
   - Change `networking.hostName`
   - Adjust GPU/hardware sections
   - Optionally import a `modules/power.nix` with TLP/auto-cpufreq
4. On the notebook, symlink `/etc/nixos/configuration.nix` to
   `hosts/notebook/configuration.nix`

Modules in `modules/` are automatically shared between both machines —
any change to `base.nix` or `apps.nix` applies everywhere on next rebuild.

---

## Zen Browser

Zen is not in nixpkgs mainline yet. Easiest options:

**Option A — Flatpak** (works today, no config needed):
```bash
flatpak install flathub app.zen_browser.zen
```

**Option B — Community overlay** (nix-native, slightly more setup):
```
# In configuration.nix imports, add the overlay channel and
# uncomment the zen-browser line in modules/apps.nix
```

**Option C — Migrate to flakes** when you're ready. The Zen flake at
`github:youwen5/zen-browser-flake` is the cleanest nix-native solution.

---

## Migrating to Flakes Later

When you're comfortable and want flakes:

1. Run `nix flake init` in the repo root
2. Move channel references into `inputs` in `flake.nix`
3. Replace `<nixpkgs>` and `<home-manager>` angle-bracket imports with
   flake input references
4. The module structure (`hosts/`, `modules/`, `home/`) stays identical

The separation of concerns this layout enforces makes that migration
straightforward — no restructuring needed.
