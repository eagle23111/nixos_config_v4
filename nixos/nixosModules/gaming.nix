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
      wineWowPackages.stable 

      winetricks
      umu-launcher

      yad
      xdotool
      xprop
      xrandr
      xxd
      xwininfo
      kitty

      protontricks
      #samba
      #krb5
    ];

    # Включаем сервис winbindd
    /*services.samba = {
      enable = true;
      winbindd.enable = true; # Именно эта опция устанавливает winbind и ntlm_auth

      # Следующие настройки не обязательны, но рекомендуются для корректной работы
      nsswins = true; # Позволяет разрешать NetBIOS-имена через winbindd
      settings = {
        global = {
          "workgroup" = "WORKGROUP"; # Или имя вашего домена
          "security" = "user";
        };
      };
    };*/
  };
}
