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
    ./input-method.nix
    ./home-manager.nix
  ];

  time.timeZone = "Europe/London";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 8000 ];
  networking.wg-quick.interfaces.wg0 = {
    address = [ "10.0.0.7/24" ];
    privateKeyFile = "/etc/wireguard/priv";
    peers = [{
        publicKey = "0tIVsOXs3axc9XHuWDEOEVvcYyeVXOhg7SjEo+KaPz0=";
        endpoint = "framal.xyz:51820";
        allowedIPs = [ "10.0.0.0/24" ];
        persistentKeepalive = 25;
    }];
  };

  programs.ssh.startAgent = true;

  # System-level tooling only: things needed to repair or rebuild this machine
  # before (or without) a user session. User-facing apps live in
  # home/framal.nix so they are managed per-user by home-manager.
  environment.systemPackages = with pkgs; [
    vim
    git
    wget
    efibootmgr
    wireguard-tools
    proton-vpn
  ];

}
