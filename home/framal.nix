# home-manager configuration for framal.
#
# Convention in this file: configuration files are kept as *static* files under
# dotfiles/ and linked into place, rather than being re-expressed as nix
# options. That keeps them editable by hand, diffable against upstream
# examples, and usable on a non-NixOS machine. Only the package set, the
# services and genuinely upstream content are declared in nix.
{ pkgs, config, ... }:

let
  # ~/.tmux.conf sources this theme. It is upstream content, so it is fetched
  # rather than vendored into dotfiles/.
  nord-tmux = pkgs.fetchFromGitHub {
    owner = "nordtheme";
    repo = "tmux";
    rev = "f7b6da07ab55fe32ee5f7d62da56d8e5ac691a92";
    hash = "sha256-mcmVYNWOUoQLiu4eM/EUudRg67Gcou13xuC6zv9aMKA=";
  };
in
{
  home.username = "framal";
  home.homeDirectory = "/home/framal";

  # Same meaning as system.stateVersion, but for home-manager. Don't bump it
  # without reading the release notes.
  home.stateVersion = "26.05";

  #### Packages ###############################################################

  home.packages = with pkgs; [
    # Terminal and shell tools
    alacritty
    tmux
    fzf
    tig
    htop
    ncdu
    tree
    xclip # tmux copy-pipe in dotfiles/tmux.conf pipes selections to xclip
    glow
    unzip

    # Editors / dev
    gh # dotfiles/gitconfig registers it as the GitHub credential helper
    emacs
    vscode
    claude-code
    python3
    nil # nix language server
    nixfmt

    # GUI apps
    brave
    signal-desktop
    discord
    rofi
    nitrogen
    arandr
    kdePackages.okular

    # i3 session helpers referenced by dotfiles/i3/config
    dex # XDG autostart
    xss-lock # locks on suspend, via i3lock
    networkmanagerapplet # nm-applet
    psmisc # killall, used to refresh i3status
    libnotify # notify-send, for talking to dunst
  ];

  #### Services ###############################################################

  services.dunst = {
    enable = true;

    # home-manager always generates ~/.config/dunst/dunstrc from
    # services.dunst.settings, so the static config is linked next to it under
    # a distinct name and dunst is pointed at that instead. This keeps
    # dotfiles/dunst/dunstrc a plain, hand-editable dunstrc.
    configFile = "${config.xdg.configHome}/dunst/dunstrc.static";
  };

  # i3 binds $mod+Ctrl+Shift+Return to `emacsclient --create-frame`, which
  # needs a running daemon.
  services.emacs = {
    enable = true;
    package = pkgs.emacs;
  };

  # Root's weekly GC does not reach this user's profiles: nix-collect-garbage
  # only prunes the profiles of the user that invokes it, and home-manager
  # generations now live in ~/.local/state/nix/profiles. Mirror the system
  # retention here so old generations actually get released.
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  #### Dotfiles ###############################################################

  home.file = {
    ".bashrc".source = ../dotfiles/bashrc;
    ".bash_profile".source = ../dotfiles/bash_profile;
    ".vimrc".source = ../dotfiles/vimrc;
    ".tmux.conf".source = ../dotfiles/tmux.conf;
    ".spacemacs".source = ../dotfiles/spacemacs;
    ".Xresources".source = ../dotfiles/Xresources;
    ".gitconfig".source = ../dotfiles/gitconfig;
    ".ssh/config".source = ../dotfiles/ssh/config;

    # Referenced by ~/.config/nitrogen/bg-saved.cfg; see the README for the
    # one-off nitrogen step on a new machine.
    ".wallpapers/colors.jpg".source = ../dotfiles/wallpapers/colors.jpg;

    ".tmux/themes/nord-tmux".source = nord-tmux;
  };

  xdg.configFile = {
    "i3/config".source = ../dotfiles/i3/config;
    "alacritty/alacritty.toml".source = ../dotfiles/alacritty/alacritty.toml;
    "dunst/dunstrc.static".source = ../dotfiles/dunst/dunstrc;
    "mimeapps.list".source = ../dotfiles/mimeapps.list;

    # core.excludesFile default; ~/.gitconfig above holds the identity.
    "git/ignore".source = ../dotfiles/git/ignore;

    # VS Code rewrites this file when settings are changed in the GUI, which a
    # read-only symlink prevents. Edit dotfiles/vscode/settings.json instead.
    "Code/User/settings.json".source = ../dotfiles/vscode/settings.json;
  };
}
