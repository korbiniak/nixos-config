# Japanese text input via fcitx5 + Mozc.
#
# fcitx5 is a system-level concern rather than a home-manager one: the IM
# modules it installs are picked up through GTK_IM_MODULE/QT_IM_MODULE and
# XMODIFIERS, which NixOS' i18n.inputMethod sets in the *system* environment so
# that every toolkit (and LightDM's session) sees them.
#
# The daemon itself is not started here. fcitx5 ships an XDG autostart entry,
# and dotfiles/i3/config already runs `dex --autostart --environment i3`, which
# launches it with the session.
{ pkgs, ... }:

{
  i18n.inputMethod = {
    enable = true;
    type = "fcitx5";

    # Mozc (the engine behind Google Japanese Input) rather than Anthy: much
    # better conversion, and it keeps a per-user learned dictionary.
    fcitx5.addons = with pkgs; [ fcitx5-mozc ];

    # Defaults in /etc/xdg/fcitx5, used until fcitx5 writes its own copy under
    # ~/.config/fcitx5 on first run. After that, change things in
    # fcitx5-configtool and these are only consulted on a fresh home.
    fcitx5.settings = {
      inputMethod = {
        "Groups/0" = {
          Name = "Default";
          # Matches services.xserver.xkb.layout in desktop.nix.
          "Default Layout" = "pl";
          DefaultIM = "keyboard-pl";
        };
        # Item 0 is the plain layout, so the session starts in Latin input and
        # Mozc is one toggle away rather than the other way round.
        "Groups/0/Items/0".Name = "keyboard-pl";
        "Groups/0/Items/1".Name = "mozc";
        "GroupOrder"."0" = "Default";
      };

      # fcitx5's default toggle. It is grabbed globally, so C-SPC no longer
      # reaches emacs (set-mark-command); evil's visual mode covers that.
      # Super+space is not an option here: i3 binds it to `focus mode_toggle`.
      globalOptions."Hotkey/TriggerKeys"."0" = "Control+space";
    };
  };

  # Without a CJK font, Japanese output renders as tofu everywhere: in the
  # fcitx5 candidate window, in Brave and in Alacritty.
  fonts.packages = with pkgs; [
    noto-fonts-cjk-sans
    noto-fonts-cjk-serif
  ];
}
