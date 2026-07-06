{inputs, ...}: {
  flake.nixosModules.gaming = {pkgs, ...}: {
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
    };

    hardware.graphics.enable32Bit = true;
    environment.systemPackages = with pkgs; [
      gamescope-wsi
      protonplus
      lutris
      wineWow64Packages.stable

      winetricks

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
