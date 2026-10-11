# PipeWire, with the PulseAudio and ALSA compatibility layers.
#
# The wireplumber bluez tuning lives here rather than in bluetooth.nix because
# it is PipeWire configuration, not device configuration.
{ pkgs, ... }:

{
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    wireplumber.extraConfig = {
      "10-bluez" = {
        "monitor.bluez.properties" = {
          "bluez5.enable-sbc-xq" = true;
          "bluez5.enable-msbc" = true;
          "bluez5.enable-hw-volume" = true;
          "bluez5.roles" = [
            "hsp_hs"
            "hsp_ag"
            "hfp_hf"
            "hfp_ag"
            "a2dp_sink"
            "a2dp_source"
          ];
          # Explicitly whitelist codecs if negotiation fails (e.g. LDAC issues)
          # "bluez5.codecs" = [ "sbc" "sbc_xq" "aac" "aptx" "aptx_hd" ];
          #    "bluez5.hfphsp-backend" = "none";
        };
      };
      "11-bluetooth-policy" = {
        "wireplumber.settings" = {
          # Disable auto-switching to headset profile if you prefer A2DP for music
          "bluetooth.autoswitch-to-headset-profile" = false;
        };
      };
    };
  };

  # Audio plumbing rather than user-facing apps: pactl is used by the volume
  # keybindings in dotfiles/i3/config, so it must exist for any session.
  environment.systemPackages = with pkgs; [
    pulseaudio # provides pactl; the daemon itself stays disabled
    pavucontrol
  ];
}
