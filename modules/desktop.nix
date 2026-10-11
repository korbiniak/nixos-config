# X11 + i3 + LightDM, graphics and fonts.
#
# The i3 *configuration* is a user dotfile (dotfiles/i3/config, linked by
# home-manager); only the window manager itself is enabled here so that
# LightDM can offer the session.
{ pkgs, ... }:

{
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver = {
    enable = true;
    windowManager.i3.enable = true;
    displayManager.lightdm.enable = true;
    xkb.layout = "pl";
  };

  services.displayManager.defaultSession = "none+i3";

  # Referenced by dotfiles/i3/config and dotfiles/alacritty/alacritty.toml.
  fonts.packages = with pkgs; [
    fira-code
    fira-code-symbols
  ];
}
