{...}: {
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
      wine
      osu-lazer-bin
      runelite
      ryubing

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
