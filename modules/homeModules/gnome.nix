{inputs, ...}: {
  flake.homeModules.gnome = {pkgs, ...}: {
    imports = [
      inputs.stylix.homeModules.stylix
    ];
    stylix.enable = true;
    #stylix.image = ./your-wallpaper.png;
    stylix.polarity = "dark";
    stylix.autoEnable = true;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";

    stylix.cursor = {
      package = pkgs.numix-cursor-theme;
      name = "Numix-Cursor";
      size = 24;
    };

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

    #home.pointerCursor = {
    # gtk.enable = true;
    # x11.enable = true;
    # package = pkgs.numix-cursor-theme;
    # name = "Numix-Cursor";
    # size = 24;
    #};
  };

  programs.dconf.enable = true;

  dconf.settings = {
    "org/gnome/desktop/wm/preferences" = {
      num-workspaces = 10;
    };

    # 3. Disable default app-switching shortcuts (Super+1, Super+2, etc.)
    "org/gnome/shell/keybindings" = {
      switch-to-application-1 = [ ];
      switch-to-application-2 = [ ];
      switch-to-application-3 = [ ];
      switch-to-application-4 = [ ];
      switch-to-application-5 = [ ];
      switch-to-application-6 = [ ];
      switch-to-application-7 = [ ];
      switch-to-application-8 = [ ];
      switch-to-application-9 = [ ];
    };

    # 4. Set workspace switching shortcuts
    "org/gnome/desktop/wm/keybindings" = {
      switch-to-workspace-1 = [ "<Super>1" ];
      switch-to-workspace-2 = [ "<Super>2" ];
      switch-to-workspace-3 = [ "<Super>3" ];
      switch-to-workspace-4 = [ "<Super>4" ];
      switch-to-workspace-5 = [ "<Super>5" ];
      switch-to-workspace-6 = [ "<Super>6" ];
      switch-to-workspace-7 = [ "<Super>7" ];
      switch-to-workspace-8 = [ "<Super>8" ];
      switch-to-workspace-9 = [ "<Super>9" ];
      switch-to-workspace-10 = [ "<Super>0" ];

      # (Optional) Move window to workspace with Super+Shift+Number
      move-to-workspace-1 = [ "<Shift><Super>1" ];
      move-to-workspace-2 = [ "<Shift><Super>2" ];
      move-to-workspace-3 = [ "<Shift><Super>3" ];
      move-to-workspace-4 = [ "<Shift><Super>4" ];
      move-to-workspace-5 = [ "<Shift><Super>5" ];
      move-to-workspace-6 = [ "<Shift><Super>6" ];
      move-to-workspace-7 = [ "<Shift><Super>7" ];
      move-to-workspace-8 = [ "<Shift><Super>8" ];
      move-to-workspace-9 = [ "<Shift><Super>9" ];
      move-to-workspace-10 = [ "<Shift><Super>0" ];

    };
  };
}
