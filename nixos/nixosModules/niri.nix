{inputs, ...}: {
  flake.nixosModules.niri = {pkgs, ...}: {
    imports = [
      inputs.noctalia.nixosModules.default
    ];

    home-manager.sharedModules = [inputs.self.homeModules.niri];

    environment.systemPackages = with pkgs; [
      playerctl
      xwayland-satellite

      libreoffice
      hunspell
      hunspellDicts.ru_RU
    ];

    environment.etc."xdg/menus/applications.menu".source = "${pkgs.kdePackages.plasma-workspace}/etc/xdg/menus/plasma-applications.menu";

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
      enable = false; # TODO: make this work
      type = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
        fcitx5-table-extra
      ];
    };
    security.rtkit.enable = true;
    services.flatpak.enable = true;
    services.displayManager.gdm.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;
    security.pam.services.login.enableGnomeKeyring = true;
    programs.nm-applet.enable = true;
    programs.nm-applet.indicator = false;
    programs.seahorse.enable = true;
  };

  flake.homeModules.niri = {
    pkgs,
    lib,
    config,
    ...
  }: {
    imports = [
      inputs.self.homeModules.zen-browser
      inputs.self.homeModules.zsh
    ];
    home.file.".config/niri/config.kdl".source = "${inputs.self.outPath}/assets/desktop/niri/config.kdl";
    home.file.".config/noctalia/default.toml".source = "${inputs.self.outPath}/assets/desktop/noctalia/default.toml";

    stylix.enable = false;
    home.sessionVariables = {
      QT_SCALE_FACTOR = "1.2";
    };

    home.activation.createKdeGlobals = lib.hm.dag.entryAfter ["writeBoundary"] ''
          if [ ! -f "$HOME/.config/kdeglobals" ]; then
            mkdir -p "$HOME/.config"
            cat > "$HOME/.config/kdeglobals" <<'EOF'
      [UiSettings]
      ColorScheme=qt5ct

      [General]
      TerminalApplication=kitty
      EOF
          fi
    '';

    qt = {
      enable = true;
      platformTheme.name = "qtct";

      qt5ctSettings = {
        Appearance = {
          custom_palette = true;
          color_scheme_path = "${config.xdg.configHome}/qt5ct/colors/noctalia.conf";
        };
      };

      qt6ctSettings = {
        Appearance = {
          custom_palette = true;
          color_scheme_path = "${config.xdg.configHome}/qt6ct/colors/noctalia.conf";
        };
      };
    };

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
        "text/plain" = ["org.gnome.Evince.desktop"];
        "application/pdf" = ["org.gnome.Evince.desktop"];
        "x-scheme-handler/mailto" = ["org.gnome.Evolution.desktop"];
        "text/calendar" = ["gnome-calendar.desktop"];

        "image/*" = ["org.kde.gwenview.desktop"];
        "image/avif" = ["org.kde.gwenview.desktop"];
        "image/bmp" = ["org.kde.gwenview.desktop"];
        "image/gif" = ["org.kde.gwenview.desktop"];
        "image/heif" = ["org.kde.gwenview.desktop"];
        "image/heic" = ["org.kde.gwenview.desktop"];
        "image/jpeg" = ["org.kde.gwenview.desktop"];
        "image/jpg" = ["org.kde.gwenview.desktop"];
        "image/png" = ["org.kde.gwenview.desktop"];
        "image/svg" = ["org.kde.gwenview.desktop"];
        "image/svg+xml" = ["org.kde.gwenview.desktop"];
        "image/tiff" = ["org.kde.gwenview.desktop"];
        "image/webp" = ["org.kde.gwenview.desktop"];
        "image/x-bmp" = ["org.kde.gwenview.desktop"];
        "image/x-gif" = ["org.kde.gwenview.desktop"];
        "image/x-icon" = ["org.kde.gwenview.desktop"];
        "image/x-jpeg" = ["org.kde.gwenview.desktop"];
        "image/x-png" = ["org.kde.gwenview.desktop"];
        "image/x-tiff" = ["org.kde.gwenview.desktop"];
        "image/x-webp" = ["org.kde.gwenview.desktop"];
        "image/x-wmf" = ["org.kde.gwenview.desktop"];
        "image/vnd.microsoft.icon" = ["org.kde.gwenview.desktop"];
        "image/vnd.adobe.photoshop" = ["org.kde.gwenview.desktop"];
        "image/vnd.wap.wbmp" = ["org.kde.gwenview.desktop"];

        "video/mp4" = ["mpv.desktop"];
        "video/mpeg" = ["mpv.desktop"];
        "video/ogg" = ["mpv.desktop"];
        "video/webm" = ["mpv.desktop"];
        "video/quicktime" = ["mpv.desktop"];
        "video/x-msvideo" = ["mpv.desktop"];
        "video/x-matroska" = ["mpv.desktop"];
        "video/x-ms-wmv" = ["mpv.desktop"];
        "video/x-flv" = ["mpv.desktop"];
        "video/flv" = ["mpv.desktop"];
        "video/3gpp" = ["mpv.desktop"];
        "video/3gpp2" = ["mpv.desktop"];
        "video/mp2t" = ["mpv.desktop"];
        "video/x-m4v" = ["mpv.desktop"];
        "video/vnd.avi" = ["mpv.desktop"];
        "video/vnd.dlna.mpeg-tts" = ["mpv.desktop"];
        "video/x-ogm" = ["mpv.desktop"];
        "video/x-ogm+ogg" = ["mpv.desktop"];

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
      kdePackages.kio-extras
      kdePackages.kio-fuse
      kdePackages.kio
      kdePackages.qtsvg

      gnome-text-editor
      evince
      evolution
      gnome-calendar

      kdePackages.gwenview
      kdePackages.kimageformats

      inputs.self.packages.${pkgs.stdenv.hostPlatform.system}.mpvWithAnki

      # fonts
      nerd-fonts.terminess-ttf
      #twemoji-color-font
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

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          serif = ["Terminess Nerd Font" "DejaVu Serif" "Source Han Serif" "Noto Serif"];
          sansSerif = ["Terminess Nerd Font" "DejaVu Sans" "Source Han Sans" "Noto Sans"];
          monospace = ["Terminess Nerd Font Mono" "DejaVu Sans Mono" "Fira Code" "JetBrains Mono"];
          emoji = ["Noto Color Emoji"];
        };
      };
    };
    programs.kitty = {
      enable = true;
      extraConfig = ''
        background_opacity 0.45
      '';
    };
  };
}
