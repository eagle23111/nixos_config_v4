{inputs, ...}: {
  flake.homeModules.gnome = {pkgs, ...}: {
    imports = [
      # inputs.stylix.homeModules.stylix

      inputs.self.homeModules."gnome@extensions"
      inputs.self.homeModules."gnome@defaultApps"

      inputs.self.homeModules.zen-browser #TODO: remove this after testing
    ];
    stylix.enable = true;
    #stylix.image = ./your-wallpaper.png;
    stylix.polarity = "dark";
    stylix.autoEnable = true;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
    programs.obsidian.enable = true;

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
    fonts.fontconfig.antialiasing = false;
    fonts.fontconfig.hinting = "slight";

    stylix.icons.enable = true;
    stylix.icons.package = pkgs.numix-icon-theme-circle;
    stylix.icons.light = "Numix-Circle";
    stylix.icons.dark = "Numix-Circle";

    stylix.targets.zen-browser = {
      enable = true;
      profileNames = ["default"]; # <-- replace with your actual profile name (e.g. "default", "main", etc.)
    };
    #home.pointerCursor = {
    # gtk.enable = true;
    # x11.enable = true;
    # package = pkgs.numix-cursor-theme;
    # name = "Numix-Cursor";
    # size = 24;
    #};
    dconf.settings = {
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 10;
      };
      # 3. Disable default app-switching shortcuts (Super+1, Super+2, etc.)
      "org/gnome/shell/keybindings" = {
        switch-to-application-1 = [];
        switch-to-application-2 = [];
        switch-to-application-3 = [];
        switch-to-application-4 = [];
        switch-to-application-5 = [];
        switch-to-application-6 = [];
        switch-to-application-7 = [];
        switch-to-application-8 = [];
        switch-to-application-9 = [];
      };

      # 4. Set workspace switching shortcuts
      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-1 = ["<Super>1"];
        switch-to-workspace-2 = ["<Super>2"];
        switch-to-workspace-3 = ["<Super>3"];
        switch-to-workspace-4 = ["<Super>4"];
        switch-to-workspace-5 = ["<Super>5"];
        switch-to-workspace-6 = ["<Super>6"];
        switch-to-workspace-7 = ["<Super>7"];
        switch-to-workspace-8 = ["<Super>8"];
        switch-to-workspace-9 = ["<Super>9"];
        switch-to-workspace-10 = ["<Super>0"];

        # (Optional) Move window to workspace with Super+Shift+Number
        move-to-workspace-1 = ["<Shift><Super>1"];
        move-to-workspace-2 = ["<Shift><Super>2"];
        move-to-workspace-3 = ["<Shift><Super>3"];
        move-to-workspace-4 = ["<Shift><Super>4"];
        move-to-workspace-5 = ["<Shift><Super>5"];
        move-to-workspace-6 = ["<Shift><Super>6"];
        move-to-workspace-7 = ["<Shift><Super>7"];
        move-to-workspace-8 = ["<Shift><Super>8"];
        move-to-workspace-9 = ["<Shift><Super>9"];
        move-to-workspace-10 = ["<Shift><Super>0"];

        switch-input-source = ["<Alt>Shift_L"];
      };
    };
  };

  flake.homeModules."gnome@defaultApps" = {pkgs, ...}: {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = ["org.gnome.Nautilus.desktop"];
        "text/plain" = ["gnome-text-editor.desktop"];
        "application/pdf" = ["evince.desktop"];
        "x-scheme-handler/mailto" = ["org.gnome.Evolution.desktop"];
        "text/calendar" = ["gnome-calendar.desktop"];
      };
    };
    home.packages = with pkgs; [
      #inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
      gnome-text-editor
      evince
      evolution
      gnome-calendar
    ];
    dconf.settings."org/gnome/shell" = {
      favorite-apps = [
        "zen-beta.desktop"
        "steam.desktop"
        "net.lutris.Lutris.desktop"
        "org.gnome.Nautilus.desktop"
        "org.gnome.Console.desktop"
        "org.gnome.Evolution.desktop"
      ];
    };
  };
  flake.homeModules."gnome@extensions" = {pkgs, ...}: {
    home.packages = with pkgs.gnomeExtensions; [
      blur-my-shell
      clipboard-indicator
      dash-to-dock
      static-workspace-background
      space-bar
      appindicator
      #vicinae
    ];
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        disable-extension-version-validation = true;

        enabled-extensions = with pkgs.gnomeExtensions; [
          blur-my-shell.extensionUuid
          clipboard-indicator.extensionUuid
          dash-to-dock.extensionUuid
          static-workspace-background.extensionUuid
          space-bar.extensionUuid
          appindicator.extensionUuid
          #vicinae.extensionUuid
        ];
      };
    };
  };
}
