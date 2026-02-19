# NixOS Configuration

A structured, traditional-channel NixOS config for one or more machines.
No flakes required — easy to understand, easy to migrate to flakes later.

---

## Directory Structure

```
nix/
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
sudo nix-shell -p git git-crypt gnupg
git clone <your-repo-url> /mnt/etc/nixos/nix
```

To decrypt the encrypted files the GPG key has to be imported
```bash
# Import the key
gpg --import /path/to/gpg-private.asc

# In the GPG prompt, trust the key
gpg> trust
# Choose 5 (ultimate trust)
gpg> quit

# Securely delete the key file
shred -u /path/to/gpg-private.asc
```

Unlock the cloned git repo
```bash
# Unlock
git-crypt unlock

# When prompted enter the password for the GPG key
```

### 5. Copy hardware config into the repo

```bash
cp /mnt/etc/nixos/hardware-configuration.nix \
   /mnt/etc/nixos/nix/hosts/desktop/
```

### 6. Set up the channels

```bash
# NixOS (should already be set if using the installer):
sudo nix-channel --add https://nixos.org/channels/nixos-25.11 nixos
sudo nix-channel --update

# home-manager (must match NixOS release):
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-25.11.tar.gz home-manager
sudo nix-channel --update
```

### 7. Point /etc/nixos/configuration.nix at your host config

```bash
sudo ln -sf /etc/nixos/nix/hosts/desktop/configuration.nix /etc/nixos/configuration.nix
```

### 8. Edit the config for your machine

Before rebuilding, open the files and change:

| File | What to change |
|------|---------------|
| `hosts/desktop/configuration.nix` | hostname, GPU section, username |
| `home/default.nix` | username |

### 9. Install!

```bash
sudo nixos-install
sudo reboot
```

---

### 10. Pushing new Configuration

When changing or adding files, check if they are commited encrypted
```bash
# Check the status of the files
git-crypt status

# If some files that should get encrypted are not show as that force the encryption
git-crypt status -f

# Add new or changed files
git add <changes-done>

# Commit change
git commit -m "Message"

# Push
git push origin main
```

---

