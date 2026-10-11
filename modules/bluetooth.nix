# Bluetooth stack.
{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    # Held BACK, deliberately. Newer bluez is badly broken for this setup, so
    # 5.84 is the last version known good here. The channel has already moved
    # past it (5.86 as of 2026-10-12), which means this is the one package not
    # getting upstream security fixes -- an accepted trade until bluez is
    # usable again. Re-test on channel bumps and drop this block when it is.
    #
    # `patches = [ ]` drops nixpkgs' patches because they target the newer
    # version and don't apply to 5.84. That also makes this override liable to
    # break if the bluez expression changes shape upstream; if a channel
    # update fails to build here, that's the likely cause.
    package = pkgs.bluez.overrideAttrs (old: rec {
      version = "5.84";
      src = pkgs.fetchurl {
        url = "mirror://kernel/linux/bluetooth/bluez-${version}.tar.xz";
        hash = "sha256-W6c9Aw97AAh9Z4ALDjIWAa7A+JKCfHLlosg5DYyIaxE=";
      };
      patches = [ ];
      env = (old.env or { }) // {
        NIX_LDFLAGS = "-lreadline";
      };
    });
  };

  environment.systemPackages = with pkgs; [
    blueman
  ];
}
