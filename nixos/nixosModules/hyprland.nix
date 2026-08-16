{inputs, ...}: {
  flake.nixosModules.hyprland = {pkgs, ...}:
    with pkgs.lib; let
      hyprPluginPkgs = pkgs.hyprlandPlugins;

      hyprspace-fix = hyprPluginPkgs.hyprspace.overrideAttrs (oldAttrs: {
        src = pkgs.fetchFromGitHub {
          owner = "ImanolBarba";    
          repo = "Hyprspace";
          rev = "667f5a3a9ccba02eff8c4d97979904a7aa9f2ceb";
          hash = "sha256-P27tvgpduDsMjk9mSti4We+a3kzYWYWznZKizvnyS+Q=";
        };
      }); # TODO: kill it with fire once it get merged

      hypr-plugin-dir = pkgs.symlinkJoin {
        name = "hyrpland-plugins";
        paths = with hyprPluginPkgs; [
          hyprspace-fix
        ];
      };
    in {
      imports = [
        inputs.noctalia.nixosModules.default
        # inputs.hyprland.nixosModules.default
        # inputs.self.homeModules."gnome@extensions"
      ];

      home-manager.sharedModules = [inputs.self.homeModules.hyprland];
      environment.sessionVariables = { HYPR_PLUGIN_DIR = hypr-plugin-dir; };

      environment.systemPackages = with pkgs; [
        kdePackages.dolphin
        playerctl
      ];

      services.gnome.gnome-keyring.enable = true;
      

      programs.hyprland = {
        enable = true;
        withUWSM = true;
      };

      programs.noctalia = {
        enable = true;
        recommendedServices.enable = true;
      };

      services.flatpak.enable = true;
      services.displayManager.gdm.enable = true;
    };

    flake.homeModules.hyprland = {pkgs, ...}: {
    imports = [
      inputs.self.homeModules."gnome@defaultApps"

      inputs.self.homeModules.zen-browser
      inputs.self.homeModules.zsh
      inputs.self.homeModules.mpv
    ];
    stylix.enable = false;

    home.pointerCursor = {
      enable = true;
      gtk.enable = true;
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
      size = 24;

      hyprcursor = {
        enable = true;
        size = 24;
      };
    };
    /*
      xdg.portal = {
      enable = true;
      extraPortals = with pkgs;
        lib.mkForce [
          kdePackages.xdg-desktop-portal-kde
          xdg-desktop-portal-hyprland
        ];

      config = {
        common = {
          "org.freedesktop.impl.portal.FileChooser" = "kde";
        };
      };
    };
    */

    /*
      stylix.enable = false;
    stylix.image = "${inputs.self}/assets/wallpapers/mist_forest_1.png";
    stylix.polarity = "dark";
    stylix.autoEnable = false;
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/gruvbox-dark-soft.yaml";
    stylix.targets.gtk.enable = false;
    stylix.targets.qt = {
      enable = false;
      # platform = "qtct"; # or "gtk" if you prefer, but "qtct" is the most reliable for custom themes.
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
    */
    # fallback fonts
    fonts.fontconfig.enable = true;
    home.packages = with pkgs; [
      kdePackages.dolphin
      playerctl
      nerd-fonts.terminess-ttf
      nerd-fonts.dejavu-sans-mono
      dejavu_fonts
    ];
    fonts.fontconfig.antialiasing = false;
    fonts.fontconfig.hinting = "slight";
    /*
    stylix.icons.enable = true;
    stylix.icons.package = pkgs.numix-icon-theme-circle;
    stylix.icons.light = "Numix-Circle";
    stylix.icons.dark = "Numix-Circle";

    stylix.targets.zen-browser = {
      enable = false;
      profileNames = ["default"]; # <-- replace with your actual profile name (e.g. "default", "main", etc.)
    };
    */
  };
}
