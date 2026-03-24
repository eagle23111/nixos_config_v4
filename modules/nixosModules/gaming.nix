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
      enable = true; 
      remotePlay.openFirewall = true; 
      dedicatedServer.openFirewall = true; 
    };

    hardware.graphics.enable32Bit = true;
    environment.systemPackages = with pkgs; [
      gamescope-wsi # HDR won't work without this
      protonplus
      lutris

      wineWowPackages.stable

      wine
      (wine.override {wineBuild = "wine64";})
      wine64
      wineWowPackages.staging

      winetricks
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
