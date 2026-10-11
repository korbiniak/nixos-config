# Shared system configuration, imported by every host.
#
# Anything in here must be machine-independent: hardware, hostname, boot
# entries and display wiring belong in hosts/<name>/ instead.
{ pkgs, ... }:

{
  imports = [
    ./nix.nix
    ./users.nix
    ./desktop.nix
    ./audio.nix
    ./bluetooth.nix
    ./gaming.nix
    ./home-manager.nix
  ];

  time.timeZone = "Europe/London";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # System-level tooling only: things needed to repair or rebuild this machine
  # before (or without) a user session. User-facing apps live in
  # home/framal.nix so they are managed per-user by home-manager.
  environment.systemPackages = with pkgs; [
    vim # Do not forget to add an editor to edit the config! Nano is also installed by default.
    git # needed to clone/update this repo itself
    wget
    efibootmgr
    wireguard-tools # wg/wg-quick need root anyway
    proton-vpn # (was protonvpn-gui, renamed upstream); talks to NetworkManager
  ];
}
