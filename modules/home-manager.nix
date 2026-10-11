# home-manager wired in as a NixOS module, so a single `nixos-rebuild switch`
# applies both the system and the user configuration.
#
# This needs a `home-manager` channel whose release matches the nixos channel;
# see the README for the exact `nix-channel --add` command.
{ ... }:

{
  imports = [ <home-manager/nixos> ];

  home-manager = {
    # Use the system's nixpkgs (and therefore the allowUnfreePredicate from
    # modules/nix.nix) instead of a second, separately-pinned instance.
    useGlobalPkgs = true;

    # Install user packages into /etc/profiles/per-user/framal, which is part
    # of the system closure. This keeps them pruned by the system GC and
    # avoids a stateful `nix-env` profile.
    useUserPackages = true;

    # First activation will find real files where it wants to place symlinks
    # (~/.bashrc and friends). Instead of failing, move them aside.
    backupFileExtension = "hm-bak";

    users.framal = import ../home/framal.nix;
  };
}
