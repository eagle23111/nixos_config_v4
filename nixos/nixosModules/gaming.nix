{inputs, ...}: {
  flake.nixosModules.gaming = {pkgs, ...}: {
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      gamescopeSession.enable = true;
    };

    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };
    };
    hardware.xone.enable = true; # support for the xbox controller USB dongle

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
      kitty

      protontricks
    ];
  };
}
