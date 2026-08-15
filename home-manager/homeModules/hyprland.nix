{inputs, ...}: {
  flake.homeModules.hyprland = {pkgs, ...}: {
    imports = [
      inputs.self.homeModules."gnome@defaultApps"

      inputs.self.homeModules.zen-browser
      inputs.self.homeModules.zsh
      inputs.self.homeModules.mpv
    ];
    stylix.enable = true;
    stylix.image = "${inputs.self}/assets/wallpapers/mist_forest_1.png";
    stylix.polarity = "dark";
    stylix.autoEnable = true;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
    stylix.targets.gtk.enable = false;
    stylix.targets.qt = {
      enable = false;
      platform = "qtct"; # or "gtk" if you prefer, but "qtct" is the most reliable for custom themes.
    };

    stylix.cursor = {
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor";
      size = 24;
    };

    stylix.fonts = {
      serif = {
        package = pkgs.nerd-fonts.terminess-ttf;
        name = "Terminess Nerd Font Medium";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.terminess-ttf;
        name = "Terminess Nerd Font Medium";
      };
      monospace = {
        package = pkgs.nerd-fonts.terminess-ttf;
        name = "Terminess Nerd Font Mono Medium";
      };
      emoji = {
        package = pkgs.twemoji-color-font;
        name = "Twitter Color Emoji";
      };
    };
    # fallback fonts
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      nerd-fonts.dejavu-sans-mono
      dejavu_fonts
    ];
    #fonts.fontconfig.antialiasing = false;
    #fonts.fontconfig.hinting = "slight";

    stylix.icons.enable = true;
    stylix.icons.package = pkgs.numix-icon-theme-circle;
    stylix.icons.light = "Numix-Circle";
    stylix.icons.dark = "Numix-Circle";

    stylix.targets.zen-browser = {
      enable = false;
      profileNames = ["default"]; # <-- replace with your actual profile name (e.g. "default", "main", etc.)
    };
  };
}
