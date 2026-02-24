{
  pkgs,
  inputs,
  ...
}: {
  flake.nixosModules.gaming = {
    pkgs,
    inputs,
    ...
  }: {
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true; # Master switch, already covered in installation
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports for Source Dedicated Server hosting
      # Other general flags if available can be set here.
    };
    hardware.graphics.enable32Bit = true;
    environment.systemPackages = with pkgs; [
      gamescope-wsi # HDR won't work without this
      protonplus

      # support both 32- and 64-bit applications
      wineWowPackages.stable

      # support 32-bit only (read above!)
      wine

      # support 64-bit only
      (wine.override {wineBuild = "wine64";})

      # support 64-bit only
      wine64

      # wine-staging (version with experimental features)
      wineWowPackages.staging

      # winetricks (all versions)
      winetricks

      # native wayland support (unstable)
      wineWowPackages.waylandFull

      #steamtinkerlaunch dependencies
      yad
      xdotool
      xprop
      xrandr
      xxd
      xwininfo

      protontricks
    ];
  };
}
