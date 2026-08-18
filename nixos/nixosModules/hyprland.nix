{inputs, ...}: {
  flake.nixosModules.hyprland = {pkgs, ...}: {
    imports = [
      inputs.noctalia.nixosModules.default
    ];

    home-manager.sharedModules = [inputs.self.homeModules.hyprland];

    environment.systemPackages = with pkgs; [
      playerctl
      xwayland-satellite
    ];

    services.gnome.gnome-keyring.enable = true;

    programs.niri = {
      enable = true;
    };

    programs.noctalia = {
      enable = true;
      recommendedServices.enable = true;
    };

    services.gvfs = {
      enable = true;
      package = pkgs.lib.mkForce pkgs.gnome.gvfs;
    };
    i18n.inputMethod = {
      enable = false;
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-table-extra # This adds many keyboard layouts
      ];
    };
    security.rtkit.enable = true;
    services.flatpak.enable = true;
    services.displayManager.gdm.enable = true;
  };

  flake.homeModules.hyprland = {
    pkgs,
    lib,
    ...
  }: {
    imports = [
      inputs.self.homeModules."gnome@defaultApps"

      inputs.self.homeModules.zen-browser
      inputs.self.homeModules.zsh
      inputs.self.homeModules.mpv
    ];
    stylix.enable = false;

    home.activation.createKdeGlobals = lib.hm.dag.entryAfter ["writeBoundary"] ''
          if [ ! -f "$HOME/.config/kdeglobals" ]; then
            mkdir -p "$HOME/.config"
            cat > "$HOME/.config/kdeglobals" <<'EOF'
      [General]
      TerminalApplication=kitty
      EOF
          fi
    '';

    xdg.autostart.enable = true;
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-gnome pkgs.xdg-desktop-portal-gtk];
      config.niri = {
        default = ["gnome" "gtk"];
      };
      config.common = {
        default = ["gnome" "gtk"];
      };
    };

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "inode/directory" = ["org.kde.dolphin.desktop"];
        "text/plain" = ["gnome-text-editor.desktop"];
        "application/pdf" = ["evince.desktop"];
        "x-scheme-handler/mailto" = ["org.gnome.Evolution.desktop"];
        "text/calendar" = ["gnome-calendar.desktop"];

        # yeah...
        "application/json" = ["zen-beta.desktop"];
        "application/x-extension-htm" = ["zen-beta.desktop"];
        "application/x-extension-html" = ["zen-beta.desktop"];
        "application/x-extension-shtml" = ["zen-beta.desktop"];
        "application/x-extension-xht" = ["zen-beta.desktop"];
        "application/x-extension-xhtml" = ["zen-beta.desktop"];
        "application/xhtml+xml" = ["zen-beta.desktop"];
        "text/html" = ["zen-beta.desktop"];
        "x-scheme-handler/about" = ["zen-beta.desktop"];
        "x-scheme-handler/chrome" = ["zen-beta.desktop"];
        "x-scheme-handler/http" = ["zen-beta.desktop"];
        "x-scheme-handler/https" = ["zen-beta.desktop"];
      };
    };
    home.packages = with pkgs; [
      playerctl

      # default apps
      kdePackages.dolphin
      kdePackages.kio-extras # Provides SMB protocol support
      kdePackages.kio-fuse # Mounts network shares via FUSE for better performance
      kdePackages.kio

      gnome-text-editor
      evince
      evolution
      gnome-calendar

      # fonts
      nerd-fonts.terminess-ttf
      twemoji-color-font
      nerd-fonts.fira-code
      dejavu_fonts
      liberation_ttf
      noto-fonts-cjk-sans
      # wqy-zenhei
      source-han-sans
      font-awesome
    ];

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
    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = ["Terminess Nerd Font" "DejaVu Serif" "Source Han Serif" "Noto Serif"];
          sansSerif = ["Terminess Nerd Font" "DejaVu Sans" "Source Han Sans" "Noto Sans"];
          monospace = ["Terminess Nerd Font Mono" "DejaVu Sans Mono" "Fira Code" "JetBrains Mono"];
          emoji = ["Twitter Color Emoji" "Noto Color Emoji"];
        };
      };
    };
    #fonts.fontconfig.antialiasing = false;
    #fonts.fontconfig.hinting = "slight";

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
