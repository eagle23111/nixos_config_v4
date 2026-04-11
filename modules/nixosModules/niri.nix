{
  self,
  inputs,
  ...
}: {
  flake.nixosModules.niri = {
    pkgs,
    lib,
    ...
  }: {
    programs.niri = {
      enable = true;
      package = self.packages.${pkgs.stdenv.hostPlatform.system}.myNiri;
    };
    programs.thunar.enable = true;
    programs.xfconf.enable = true;
    programs.thunar.plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
      thunar-vcs-plugin
    ];

    services.flatpak.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;

    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      playerctl
      file-roller
      mate-polkit
      ddcutil
    ];
    hardware.i2c.enable = true;
    boot.kernelModules = ["i2c-dev"];

    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome
      ];
      configPackages = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.gnome-session
      ];
      config.common.default = ["gtk" "gnome"];
    };

    security.polkit.enable = true;

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.gdm.enableGnomeKeyring = true;

    services.upower.enable = true;
    services.timesyncd.enable = true;
  };

  perSystem = {
    pkgs,
    lib,
    self',
    ...
  }: {
    packages.myNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs;
      #v2-settings = true; # enable new syntax
      settings = {
        prefer-no-csd = true;
        spawn-at-startup = [
          "${lib.getExe self'.packages.myNoctalia}"
          "${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
          "${lib.getExe self'.packages.niriNoctaliaSwayidle}"
          "thunar --daemon"
        ];

        input = {
          mouse.accel-profile = "flat";
          keyboard.xkb = {
            layout = "us,ru";
            options = "grp:alt_shift_toggle";
          };
          touchpad = {
            click-method = "clickfinger";
            scroll-method = "two-finger";
            scroll-factor = 0.5;
            accel-profile = "adaptive";
            accel-speed = 0.2;
            # tap, natural-scroll, dwt removed (defaults used)
          };
        };
        outputs = {
          "DP-1" = {
            mode = "1920x1080@179.999";
          };
        };

        layer-rules = [
          {
            matches = [{namespace = "^noctalia-overview";}];
            place-within-backdrop = true;
          }
        ];

        window-rules = [
          {
            geometry-corner-radius = 12.0;
            clip-to-geometry = true;
          }
        ];

        layout = {
          border.width = 3;
          # focus-ring.off removed (defaults to enabled)
          border = {
            active-color = "#4B5F58";
            # inactive-color = "#292535";
          };
        };

        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        binds = {
          # Application launchers
          "Mod+Return" = _: {content = {spawn = lib.getExe pkgs.kitty;};};
          "Mod+R" = _: {content = {spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";};};
          "Mod+Alt+L" = _: {content = {spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";};};
          "Mod+Q" = _: {
            props = {repeat = false;};
            content = {spawn = lib.getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;};
          };
          "Mod+X" = _: {
            props = {repeat = false;};
            content = {spawn = "thunar";};
          };

          # Volume controls (work when locked)
          "XF86AudioRaiseVolume" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";};
          };
          "XF86AudioLowerVolume" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";};
          };
          "XF86AudioMute" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";};
          };
          "XF86AudioMicMute" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";};
          };

          # Media keys (work when locked)
          "XF86AudioPlay" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "${lib.getExe pkgs.playerctl} play-pause";};
          };
          "XF86AudioStop" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "${lib.getExe pkgs.playerctl} stop";};
          };
          "XF86AudioPrev" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "${lib.getExe pkgs.playerctl} previous";};
          };
          "XF86AudioNext" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "${lib.getExe pkgs.playerctl} next";};
          };

          # Brightness controls (work when locked)
          "XF86MonBrightnessUp" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "${lib.getExe pkgs.brightnessctl} --class=backlight set +10%";};
          };
          "XF86MonBrightnessDown" = _: {
            props = {allow-when-locked = true;};
            content = {spawn-sh = "${lib.getExe pkgs.brightnessctl} --class=backlight set 10%-";};
          };

          # Overview toggle
          "Mod+Tab" = _: {
            props = {repeat = false;};
            content = {toggle-overview = {};};
          };

          # Window management
          "Mod+Escape" = _: {
            props = {repeat = false;};
            content = {close-window = {};};
          };

          # Focus navigation
          "Mod+Left" = _: {content = {focus-column-left = {};};};
          "Mod+Down" = _: {content = {focus-window-down = {};};};
          "Mod+Up" = _: {content = {focus-window-up = {};};};
          "Mod+Right" = _: {content = {focus-column-right = {};};};
          "Mod+H" = _: {content = {focus-column-left = {};};};
          "Mod+J" = _: {content = {focus-window-down = {};};};
          "Mod+K" = _: {content = {focus-window-up = {};};};
          "Mod+L" = _: {content = {focus-column-right = {};};};

          # Move window/column
          "Mod+Ctrl+Left" = _: {content = {move-column-left = {};};};
          "Mod+Ctrl+Down" = _: {content = {move-window-down = {};};};
          "Mod+Ctrl+Up" = _: {content = {move-window-up = {};};};
          "Mod+Ctrl+Right" = _: {content = {move-column-right = {};};};
          "Mod+Ctrl+H" = _: {content = {move-column-left = {};};};
          "Mod+Ctrl+J" = _: {content = {move-window-down = {};};};
          "Mod+Ctrl+K" = _: {content = {move-window-up = {};};};
          "Mod+Ctrl+L" = _: {content = {move-column-right = {};};};

          # First/last in column
          "Mod+Home" = _: {content = {focus-column-first = {};};};
          "Mod+End" = _: {content = {focus-column-last = {};};};
          "Mod+Ctrl+Home" = _: {content = {move-column-to-first = {};};};
          "Mod+Ctrl+End" = _: {content = {move-column-to-last = {};};};

          # Monitor navigation
          "Mod+Shift+Left" = _: {content = {focus-monitor-left = {};};};
          "Mod+Shift+Down" = _: {content = {focus-monitor-down = {};};};
          "Mod+Shift+Up" = _: {content = {focus-monitor-up = {};};};
          "Mod+Shift+Right" = _: {content = {focus-monitor-right = {};};};
          "Mod+Shift+H" = _: {content = {focus-monitor-left = {};};};
          "Mod+Shift+J" = _: {content = {focus-monitor-down = {};};};
          "Mod+Shift+K" = _: {content = {focus-monitor-up = {};};};
          "Mod+Shift+L" = _: {content = {focus-monitor-right = {};};};

          # Move column to monitor
          "Mod+Shift+Ctrl+Left" = _: {content = {move-column-to-monitor-left = {};};};
          "Mod+Shift+Ctrl+Down" = _: {content = {move-column-to-monitor-down = {};};};
          "Mod+Shift+Ctrl+Up" = _: {content = {move-column-to-monitor-up = {};};};
          "Mod+Shift+Ctrl+Right" = _: {content = {move-column-to-monitor-right = {};};};
          "Mod+Shift+Ctrl+H" = _: {content = {move-column-to-monitor-left = {};};};
          "Mod+Shift+Ctrl+J" = _: {content = {move-column-to-monitor-down = {};};};
          "Mod+Shift+Ctrl+K" = _: {content = {move-column-to-monitor-up = {};};};
          "Mod+Shift+Ctrl+L" = _: {content = {move-column-to-monitor-right = {};};};

          # Workspace navigation
          "Mod+Page_Down" = _: {content = {focus-workspace-down = {};};};
          "Mod+Page_Up" = _: {content = {focus-workspace-up = {};};};
          "Mod+U" = _: {content = {focus-workspace-down = {};};};
          "Mod+I" = _: {content = {focus-workspace-up = {};};};

          "Mod+Ctrl+Page_Down" = _: {content = {move-column-to-workspace-down = {};};};
          "Mod+Ctrl+Page_Up" = _: {content = {move-column-to-workspace-up = {};};};
          "Mod+Ctrl+U" = _: {content = {move-column-to-workspace-down = {};};};
          "Mod+Ctrl+I" = _: {content = {move-column-to-workspace-up = {};};};

          "Mod+Shift+Page_Down" = _: {content = {move-workspace-down = {};};};
          "Mod+Shift+Page_Up" = _: {content = {move-workspace-up = {};};};
          "Mod+Shift+U" = _: {content = {move-workspace-down = {};};};
          "Mod+Shift+I" = _: {content = {move-workspace-up = {};};};

          # Mouse wheel navigation (with cooldown)
          "Mod+WheelScrollDown" = _: {
            props = {cooldown-ms = 150;};
            content = {focus-workspace-down = {};};
          };
          "Mod+WheelScrollUp" = _: {
            props = {cooldown-ms = 150;};
            content = {focus-workspace-up = {};};
          };
          "Mod+Ctrl+WheelScrollDown" = _: {
            props = {cooldown-ms = 150;};
            content = {move-column-to-workspace-down = {};};
          };
          "Mod+Ctrl+WheelScrollUp" = _: {
            props = {cooldown-ms = 150;};
            content = {move-column-to-workspace-up = {};};
          };
          "Mod+WheelScrollRight" = _: {content = {focus-column-right = {};};};
          "Mod+WheelScrollLeft" = _: {content = {focus-column-left = {};};};
          "Mod+Ctrl+WheelScrollRight" = _: {content = {move-column-right = {};};};
          "Mod+Ctrl+WheelScrollLeft" = _: {content = {move-column-left = {};};};
          "Mod+Shift+WheelScrollDown" = _: {content = {focus-column-right = {};};};
          "Mod+Shift+WheelScrollUp" = _: {content = {focus-column-left = {};};};
          "Mod+Ctrl+Shift+WheelScrollDown" = _: {content = {move-column-right = {};};};
          "Mod+Ctrl+Shift+WheelScrollUp" = _: {content = {move-column-left = {};};};

          # Workspace number navigation
          "Mod+1" = _: {content = {focus-workspace = 1;};};
          "Mod+2" = _: {content = {focus-workspace = 2;};};
          "Mod+3" = _: {content = {focus-workspace = 3;};};
          "Mod+4" = _: {content = {focus-workspace = 4;};};
          "Mod+5" = _: {content = {focus-workspace = 5;};};
          "Mod+6" = _: {content = {focus-workspace = 6;};};
          "Mod+7" = _: {content = {focus-workspace = 7;};};
          "Mod+8" = _: {content = {focus-workspace = 8;};};
          "Mod+9" = _: {content = {focus-workspace = 9;};};

          "Mod+Ctrl+1" = _: {content = {move-column-to-workspace = 1;};};
          "Mod+Ctrl+2" = _: {content = {move-column-to-workspace = 2;};};
          "Mod+Ctrl+3" = _: {content = {move-column-to-workspace = 3;};};
          "Mod+Ctrl+4" = _: {content = {move-column-to-workspace = 4;};};
          "Mod+Ctrl+5" = _: {content = {move-column-to-workspace = 5;};};
          "Mod+Ctrl+6" = _: {content = {move-column-to-workspace = 6;};};
          "Mod+Ctrl+7" = _: {content = {move-column-to-workspace = 7;};};
          "Mod+Ctrl+8" = _: {content = {move-column-to-workspace = 8;};};
          "Mod+Ctrl+9" = _: {content = {move-column-to-workspace = 9;};};

          # Column/window manipulation
          "Mod+BracketLeft" = _: {content = {consume-or-expel-window-left = {};};};
          "Mod+BracketRight" = _: {content = {consume-or-expel-window-right = {};};};
          "Mod+Comma" = _: {content = {consume-window-into-column = {};};};
          "Mod+Period" = _: {content = {expel-window-from-column = {};};};

          # Layout adjustments
          "Mod+D" = _: {content = {switch-preset-column-width = {};};};
          "Mod+Shift+R" = _: {content = {switch-preset-window-height = {};};};
          "Mod+Ctrl+R" = _: {content = {reset-window-height = {};};};
          "Mod+F" = _: {content = {maximize-column = {};};};
          "Mod+Shift+F" = _: {content = {fullscreen-window = {};};};
          "Mod+Ctrl+F" = _: {content = {expand-column-to-available-width = {};};};
          "Mod+C" = _: {content = {center-column = {};};};
          "Mod+Ctrl+C" = _: {content = {center-visible-columns = {};};};

          # Fine adjustments
          "Mod+Minus" = _: {content = {set-column-width = "-10%";};};
          "Mod+Equal" = _: {content = {set-column-width = "+10%";};};
          "Mod+Shift+Minus" = _: {content = {set-window-height = "-10%";};};
          "Mod+Shift+Equal" = _: {content = {set-window-height = "+10%";};};

          # Floating windows
          "Mod+V" = _: {content = {toggle-window-floating = {};};};
          "Mod+Shift+V" = _: {content = {switch-focus-between-floating-and-tiling = {};};};

          # Tabbed display
          "Mod+W" = _: {content = {toggle-column-tabbed-display = {};};};

          # Screenshots
          "Print" = _: {content = {screenshot = {};};};
          "Ctrl+Print" = _: {content = {screenshot-screen = {};};};
          "Alt+Print" = _: {content = {screenshot-window = {};};};

          # Keyboard shortcut inhibitor escape hatch
          "Mod+Shift+Escape" = _: {
            props = {allow-inhibiting = false;};
            content = {toggle-keyboard-shortcuts-inhibit = {};};
          };

          # Session management
          "Mod+Shift+E" = _: {content = {quit = {};};};

          # Power management
          "Mod+Shift+P" = _: {content = {power-off-monitors = {};};};
        };
      };
    };

    packages.niriNoctaliaSwayidle = inputs.wrapper-modules.wrappers.swayidle.wrap {
      inherit pkgs;
      package = pkgs.swayidle;
      timeouts = [
        {
          timeout = 330;
          command = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
        }
        {
          timeout = 360;
          command = "niri msg action power-off-monitors";
        }
      ];
    };
  };
}
