# nixos-config

NixOS + home-manager configuration, built on **channels** (no flakes).
home-manager runs as a NixOS module, so a single `nixos-rebuild switch`
applies both the system and the user configuration.

## Layout

```
hosts/<hostname>/      machine-specific: hardware scan, bootloader, monitors
  default.nix            the host entry point -- imports ../../modules
  hardware-configuration.nix
  display-setup.sh       xrandr layout, used by both LightDM and ~/.screenlayout
modules/               shared system config, imported by every host
  default.nix            imports the rest + system-level packages
  nix.nix                experimental-features, automatic GC, unfree allowlist
  desktop.nix            X11, i3, LightDM, graphics, fonts
  audio.nix              PipeWire (+ wireplumber bluez tuning)
  bluetooth.nix          bluetooth stack, incl. the pinned bluez
  gaming.nix             Steam
  users.nix              user accounts
  home-manager.nix       home-manager-as-NixOS-module wiring
home/framal.nix        the user environment: packages, services, dotfile links
dotfiles/              static config files, linked into $HOME by home-manager
```

Config files under `dotfiles/` are deliberately kept as **plain files** rather
than translated into nix options. They stay hand-editable and diffable, and
work unchanged on a non-NixOS machine.

## Installing on a new machine

### 1. Channels

Both channels must be registered **for root**, because `nixos-rebuild` runs as
root and resolves `<home-manager/nixos>` from root's `NIX_PATH`. The
home-manager release must match the nixos release.

```sh
sudo nix-channel --add https://nixos.org/channels/nixos-26.05 nixos
sudo nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
sudo nix-channel --update
```

Check what you have with `sudo nix-channel --list`. If you move to a new NixOS
release, bump *both* URLs together.

### 2. Clone the repo

```sh
git clone https://github.com/korbiniak/nixos-config ~/nixos-config
```

### 3. Point /etc/nixos at the right host

`nixos-rebuild` reads `/etc/nixos/configuration.nix`. Replace it with a stub
that imports this host's directory:

```nix
{ ... }:
{
  imports = [ /home/framal/nixos-config/hosts/framal-nixos ];
}
```

Swap `framal-nixos` for the directory matching the machine. (Alternatively,
skip the stub and pass the host directly:
`sudo nixos-rebuild switch -I nixos-config=$HOME/nixos-config/hosts/framal-nixos`.)

### 4. Generate the hardware config for this machine

`hosts/framal-nixos/hardware-configuration.nix` describes *that* machine --
disk UUIDs, kernel modules, microcode. For a new machine:

```sh
sudo nixos-generate-config --dir /tmp/hw
cp /tmp/hw/hardware-configuration.nix hosts/<newhost>/
```

Then copy `hosts/framal-nixos/default.nix` to `hosts/<newhost>/default.nix`,
change `networking.hostName`, and replace `display-setup.sh` with that
machine's `xrandr` layout (generate one with `arandr`).

### 5. Build, then switch

Always build first -- it changes nothing:

```sh
sudo nixos-rebuild build
sudo nixos-rebuild switch
```

**First switch will fail on existing dotfiles** unless they are moved aside.
home-manager wants to place symlinks at `~/.bashrc`, `~/.vimrc` and friends,
and refuses to clobber real files. `backupFileExtension = "hm-bak"` is set in
`modules/home-manager.nix`, so instead of failing it renames each conflicting
file to `<name>.hm-bak`. Check and delete those afterwards:

```sh
find ~ -maxdepth 3 -name '*.hm-bak'
```

### 6. Set a real password

`modules/users.nix` sets `initialPassword = "changeme"`, which only applies
when the account is first created. Change it right after the first boot:

```sh
passwd
```

## Manual, non-declarative steps

Two things are intentionally left out of nix:

**Spacemacs.** `~/.spacemacs` (the user config) is in `dotfiles/`, but
`~/.emacs.d` is upstream Spacemacs and is *not* committed. It has to be
writable -- Spacemacs installs its own ELPA packages into it -- so it cannot
be a read-only store symlink. Clone it once per machine:

```sh
git clone --depth 1 https://github.com/syl20bnr/spacemacs ~/.emacs.d
```

Then start emacs once to let it bootstrap. The emacs *daemon* is a
home-manager service (`services.emacs`), so `emacsclient` works from i3
(`$mod+Ctrl+Shift+Return`) once that is done.

**Wallpaper.** `~/.wallpapers/colors.jpg` is committed and linked, but
nitrogen's own state (`~/.config/nitrogen/bg-saved.cfg`) is not -- nitrogen
rewrites it whenever you pick a wallpaper, so managing it would make the GUI
read-only. i3 runs `nitrogen --restore` at startup; on a new machine open
`nitrogen` once and select the wallpaper to populate that file.

## Day to day

```sh
sudo nixos-rebuild build       # build only, no changes applied
sudo nixos-rebuild switch      # apply system + user config
sudo nix-channel --update      # follow upstream (security updates)
```

Packages track the channel. Only individual packages are pinned, and only
where upstream is broken for this hardware -- currently just bluez, via
`overrideAttrs` in `modules/bluetooth.nix`. Prefer removing such a pin once
the channel catches up.

### Garbage collection

Cleanup is automatic, in two places, because `nix-collect-garbage` only prunes
the profiles of the user that invokes it:

- `modules/nix.nix` -- root, weekly, `--delete-older-than 14d`. Covers system
  generations. `boot.loader.systemd-boot.configurationLimit = 10` keeps the
  boot menu short.
- `home/framal.nix` -- framal's systemd user timer, same schedule and
  retention. Covers home-manager generations, which live in
  `~/.local/state/nix/profiles` and which root's GC never sees.

To clean up by hand:

```sh
sudo nix-collect-garbage --delete-older-than 14d   # system
nix-collect-garbage --delete-older-than 14d        # your profiles
```

## What lives where

System level (`modules/`) is for things a user session cannot provide:
bootloader, X/i3/LightDM, PipeWire, bluetooth, Steam's udev rules and 32-bit
loader, fonts, the user account, and the recovery tools needed to fix a broken
machine (`vim`, `git`, `wget`, `efibootmgr`).

User level (`home/framal.nix`) is everything else: terminals, editors,
browsers, chat apps, CLI tools, the i3 session helpers, and the dotfile links.
