# Host: framal-nixos
#
# Everything machine-specific lives here; everything shared comes from
# ../../modules. Add a new machine by copying this directory, regenerating
# hardware-configuration.nix on it and adjusting the display setup.
{ ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules
  ];

  networking.hostName = "framal-nixos";

  boot.loader = {
    systemd-boot = {
      enable = true;
      # Keep the boot menu short; older entries are dropped as the system
      # generations they belong to are garbage-collected.
      configurationLimit = 10;
    };
    efi.canTouchEfiVariables = true;
  };

  # Monitor layout for this desk: 4K primary on DP-3, 4K rotated on HDMI-1.
  # sessionCommands is a `lines` option, so this appends to anything the
  # shared modules set. The same script is linked to ~/.screenlayout/default.sh
  # by home-manager, so arandr and the login session stay in sync.
  services.xserver.displayManager.sessionCommands = ''
    ${./display-setup.sh}
  '';

  # arandr/the user session read the layout from here; same script, so the
  # login session and a manual re-apply can never drift apart.
  home-manager.users.framal.home.file.".screenlayout/default.sh" = {
    source = ./display-setup.sh;
    executable = true;
  };

  # This option defines the first version of NixOS you have installed on this
  # particular machine, and is used to maintain compatibility with application
  # data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for
  # any reason, even if you've upgraded your system to a new NixOS release.
  #
  # See `man configuration.nix` or
  # https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion
  system.stateVersion = "26.05";
}
