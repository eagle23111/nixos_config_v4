{
  config,
  pkgs,
  inputs,
  ...
}: {
  flake.homeModules.stylix = {okgs, ...}: {
    imports = [
      inputs.stylix.homeModules.stylix
      inputs.niri.homeModules.stylix
    ];
    stylix.enable = true;
    #stylix.image = ./your-wallpaper.png;
    stylix.polarity = "dark";
    stylix.autoEnable = true;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest.yaml";

    stylix.targets.gtk.enable = true;
    stylix.targets.qt.enable = true;
    stylix.targets.niri.enable = true;
    stylix.targets.vscode.enable = true;
    stylix.targets.zen-browser.enable = true;

    stylix.fonts = {
      serif = {
        package = pkgs.nerd-fonts.terminess-ttf;
        name = "Terminess Nerd Font";
      };
      sansSerif = {
        package = pkgs.nerd-fonts.terminess-ttf;
        name = "Terminess Nerd Font";
      };
      monospace = {
        package = pkgs.nerd-fonts.terminess-ttf;
        name = "Terminess Nerd Font Mono";
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
    stylix.icons.enable = true;
    stylix.icons.package = pkgs.numix-icon-theme-circle;
    stylix.icons.light = "Numix-Circle";
    stylix.icons.dark = "Numix-Circle";

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor";
      size = 24;
    };
  };
}