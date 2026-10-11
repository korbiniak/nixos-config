# Bluetooth stack.
{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;

    # Pinned ahead of the channel: 5.84 fixes pairing/codec issues seen with
    # the headset on this machine. Drop this override once the channel's bluez
    # is >= 5.84, so security updates come from upstream again.
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
