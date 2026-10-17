# The private wiki (~/projects/wiki), served from this user's session.
#
# A user service rather than a system one: it reads and writes a checkout in
# $HOME, and "when I log in" is the lifetime that matches. home-manager starts
# it on activation too, so the first `nixos-rebuild switch` brings it up
# without a re-login.
{ pkgs, ... }:

let
  repo = "/home/framal/projects/wiki";

  # Listen on every interface. The wiki has no authentication, so who can
  # reach it is decided by the firewall: networking.firewall.allowedTCPPorts in
  # modules/default.nix opens 8000 on all interfaces, wg0 and the LAN alike.
  # Binding 0.0.0.0 also means the unit does not depend on the wg0 address
  # existing at login.
  bind = "0.0.0.0";
  port = 8000;

  # The interpreter is referenced by store path, so it is part of the system
  # closure and the weekly GC cannot collect it from under the service. The
  # repo's own `nix develop` + uv shell would not give that guarantee: its
  # .venv symlinks into a store path nothing roots.
  #
  # The cost is that Pygments comes from the channel rather than uv.lock
  # (2.20.0 against 2.21.0 at the time of writing). The rendered pages differ
  # only in whether a quote inside code is written `&quot;` or `"`.
  python = pkgs.python3.withPackages (ps: [ ps.pygments ]);
  py = "${python}/bin/python";
in
{
  systemd.user.services.wiki = {
    Unit = {
      Description = "Private wiki";
      # A machine with this config but no checkout skips the unit quietly
      # instead of crash-looping.
      ConditionPathExists = "${repo}/serve.py";
    };
    Service = {
      # The leading "-" ignores a failed build: a typo in a page should leave
      # the last good site/ being served, with the error in the journal,
      # rather than take the wiki down.
      ExecStartPre = "-${py} ${repo}/build.py --quiet";
      ExecStart = "${py} ${repo}/serve.py ${toString port} --bind ${bind} --no-build";
      Environment = [ "PYTHONUNBUFFERED=1" ];

      Restart = "on-failure";
      RestartSec = 5;
    };
    Install.WantedBy = [ "default.target" ];
  };

  # Pages are written while the server is running (including from remote
  # Claude sessions), and serve.py serves site/ from disk on every request, so
  # a rebuild is all a change needs. No server restart.
  systemd.user.paths.wiki-build = {
    Unit = {
      Description = "Rebuild the wiki when pages or assets change";
      ConditionPathExists = "${repo}/build.py";
    };
    Path.PathChanged = [
      "${repo}/pages"
      "${repo}/assets"
    ];
    Install.WantedBy = [ "default.target" ];
  };

  systemd.user.services.wiki-build = {
    Unit.Description = "Rebuild the wiki's static site";
    Service = {
      Type = "oneshot";
      ExecStart = "${py} ${repo}/build.py --quiet";
    };
  };
}
