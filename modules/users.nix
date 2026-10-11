# User accounts.
{ ... }:

{
  users.users.framal = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "bluetooth"
    ];

    # Only used when the account is first created, on a fresh install.
    # Change it immediately with `passwd` after the first boot.
    initialPassword = "changeme";

    # Packages intentionally left empty: framal's packages are managed by
    # home-manager in home/framal.nix.
  };
}
