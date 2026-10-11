# Nix daemon settings, channel-based upgrades and automatic cleanup.
{ lib, ... }:

{
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Garbage-collect weekly, keeping two weeks of rollback history.
  #
  # NOTE: this runs as root, and `nix-collect-garbage` only prunes the
  # *invoking user's* profiles (plus the legacy /nix/var/nix/profiles paths).
  # Since Nix now keeps per-user profiles in ~/.local/state/nix/profiles,
  # framal's home-manager generations are NOT covered here -- see the matching
  # nix.gc block in home/framal.nix.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Hard-link identical files in the store to save disk.
  nix.optimise.automatic = true;

  # Unfree packages we accept, by name. Everything else stays blocked.
  # home-manager runs with useGlobalPkgs, so this covers user packages too.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      "vscode"
      "discord"
      "discord-ptb"
      "steam-unwrapped"
      "steam"
      "claude-code"
    ];
}
