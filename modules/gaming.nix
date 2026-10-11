# Steam. Needs to be system-level: it installs udev rules, a firewall
# exception and the 32-bit loader, none of which home-manager can do.
{ pkgs, ... }:

{
  programs.steam = {
    enable = true;
    extraCompatPackages = with pkgs; [
      proton-ge-bin # GloriousEggroll's Proton-GE
      # proton-cachyos-bin # Alternatively, CachyOS Proton
    ];
  };
}
