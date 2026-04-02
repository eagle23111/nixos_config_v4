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
    programs.thunar.plugins = with pkgs.xfce; [
      thunar-archive-plugin
      thunar-volman
      thunar-media-tags-plugin
      thunar-vcs-plugin
    ];
    #services.displayManager.ly.enable = true;
    #systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE"; # https://github.com/NixOS/nixpkgs/pull/297434#issuecomment-2348783988

    services.flatpak.enable = true;
    #services.gvfs.enable = true; # Mount, trash, and other functionalities
    services.tumbler.enable = true; # Thumbnail support for images

    networking.networkmanager.enable = true;
    hardware.bluetooth.enable = true;
    #services.power-profiles-daemon.enable or services.tuned.enable = true;
    #services.upower.enable = true;
    environment.systemPackages = with pkgs; [
      xwayland-satellite
      playerctl
      file-roller
      mate.mate-polkit
      ddcutil

      #xdg-desktop-portal-gnome
      #nautilus
      gnome-keyring
    ];
    hardware.i2c.enable = true;
    boot.kernelModules = ["i2c-dev"]; # monitor lights

    /*
      xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [xdg-desktop-portal-gtk xdg-desktop-portal-gnome];
      config.common.default = ["gtk" "gnome"];
      config.niri = {
        default = ["gtk" "gnome"];
        "org.freedesktop.impl.portal.ScreenCast" = ["gnome"];
        "org.freedesktop.impl.portal.Screenshot" = ["gnome"];
      };
    };
    */
    xdg.portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal-gtk
        xdg-desktop-portal-gnome # Often more stable for Steam/XWayland apps [web:11]
      ];
      configPackages = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.gnome-session # Optional for GNOME keyring/file manager support [web:1]
      ];
      config.common.default = ["gtk" "gnome"];
    };

    security.rtkit.enable = true;
    security.polkit.enable = true;
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
      package = lib.mkDefault inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-stable;
      settings = {
        prefer-no-csd = true;
        spawn-at-startup = [
          "${lib.getExe self'.packages.myNoctalia}"
          "${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1"
          "${lib.getExe self'.packages.niriNoctaliaSwayidle}"
          "thunar --daemon"
        ];

        input = {
          mouse.accel-profile = "flat";
        };
        input.keyboard.xkb = {
          layout = "us,ru";
          options = "grp:alt_shift_toggle";
        };
        outputs = {
          #"DP-1".enable = true;
          "DP-1" = {
            mode = "1920x1080@179.999";
          };
        };

        input.touchpad = {
          #tap = null;
          natural-scroll = null;
          click-method = "clickfinger";
          scroll-method = "two-finger";
          scroll-factor = 0.5;
          accel-profile = "adaptive";
          accel-speed = 0.2;
          dwt = null;
        };

        layer-rules = [
          # dont confuse with window-rules
          {
            matches = [
              {
                namespace = "^noctalia-overview";
              }
            ];
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
          focus-ring.off = null;

          border = {
            active-color = "#4B5F58";
            #  inactive-color = "#292535";
          };
        };
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        binds = {
          # Application launchers
          "Mod+Return" = {
            spawn = lib.getExe pkgs.kitty;
          };

          "Mod+R" = {
            spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          };

          "Mod+Alt+L" = {
            spawn-sh = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
          };

          "Mod+Q" = {
            _attrs = {
              repeat = false;
            };
            spawn = lib.getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default;
          };

          "Mod+X" = {
            _attrs = {
              repeat = false;
            };
            spawn = "thunar"; # enabled as "programs.thunar"
          };

          # Volume controls (work when locked)
          "XF86AudioRaiseVolume" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; # does not have the meta.mainProgram attribute
          };

          "XF86AudioLowerVolume" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          };

          "XF86AudioMute" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          "XF86AudioMicMute" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          };

          # Media keys (work when locked)
          "XF86AudioPlay" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "${lib.getExe pkgs.playerctl} play-pause";
          };

          "XF86AudioStop" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "${lib.getExe pkgs.playerctl} stop";
          };

          "XF86AudioPrev" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "${lib.getExe pkgs.playerctl} previous";
          };

          "XF86AudioNext" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "${lib.getExe pkgs.playerctl} next";
          };

          # Brightness controls (work when locked)
          "XF86MonBrightnessUp" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "${lib.getExe pkgs.brightnessctl} --class=backlight set +10%";
          };

          "XF86MonBrightnessDown" = {
            _attrs = {
              allow-when-locked = true;
            };
            spawn-sh = "${lib.getExe pkgs.brightnessctl} --class=backlight set 10%-";
          };

          # Overview toggle
          "Mod+Tab" = {
            _attrs = {
              repeat = false;
            };
            toggle-overview = null;
          };

          # Window management
          "Mod+Escape" = {
            _attrs = {
              repeat = false;
            };
            close-window = null;
          };

          # Focus navigation
          "Mod+Left".focus-column-left = null;
          "Mod+Down".focus-window-down = null;
          "Mod+Up".focus-window-up = null;
          "Mod+Right".focus-column-right = null;
          "Mod+H".focus-column-left = null;
          "Mod+J".focus-window-down = null;
          "Mod+K".focus-window-up = null;
          "Mod+L".focus-column-right = null;

          # Move window/column
          "Mod+Ctrl+Left".move-column-left = null;
          "Mod+Ctrl+Down".move-window-down = null;
          "Mod+Ctrl+Up".move-window-up = null;
          "Mod+Ctrl+Right".move-column-right = null;
          "Mod+Ctrl+H".move-column-left = null;
          "Mod+Ctrl+J".move-window-down = null;
          "Mod+Ctrl+K".move-window-up = null;
          "Mod+Ctrl+L".move-column-right = null;

          # First/last in column
          "Mod+Home".focus-column-first = null;
          "Mod+End".focus-column-last = null;
          "Mod+Ctrl+Home".move-column-to-first = null;
          "Mod+Ctrl+End".move-column-to-last = null;

          # Monitor navigation
          "Mod+Shift+Left".focus-monitor-left = null;
          "Mod+Shift+Down".focus-monitor-down = null;
          "Mod+Shift+Up".focus-monitor-up = null;
          "Mod+Shift+Right".focus-monitor-right = null;
          "Mod+Shift+H".focus-monitor-left = null;
          "Mod+Shift+J".focus-monitor-down = null;
          "Mod+Shift+K".focus-monitor-up = null;
          "Mod+Shift+L".focus-monitor-right = null;

          # Move column to monitor
          "Mod+Shift+Ctrl+Left".move-column-to-monitor-left = null;
          "Mod+Shift+Ctrl+Down".move-column-to-monitor-down = null;
          "Mod+Shift+Ctrl+Up".move-column-to-monitor-up = null;
          "Mod+Shift+Ctrl+Right".move-column-to-monitor-right = null;
          "Mod+Shift+Ctrl+H".move-column-to-monitor-left = null;
          "Mod+Shift+Ctrl+J".move-column-to-monitor-down = null;
          "Mod+Shift+Ctrl+K".move-column-to-monitor-up = null;
          "Mod+Shift+Ctrl+L".move-column-to-monitor-right = null;

          # Workspace navigation (Page keys)
          "Mod+Page_Down".focus-workspace-down = null;
          "Mod+Page_Up".focus-workspace-up = null;
          "Mod+U".focus-workspace-down = null;
          "Mod+I".focus-workspace-up = null;

          "Mod+Ctrl+Page_Down".move-column-to-workspace-down = null;
          "Mod+Ctrl+Page_Up".move-column-to-workspace-up = null;
          "Mod+Ctrl+U".move-column-to-workspace-down = null;
          "Mod+Ctrl+I".move-column-to-workspace-up = null;

          "Mod+Shift+Page_Down".move-workspace-down = null;
          "Mod+Shift+Page_Up".move-workspace-up = null;
          "Mod+Shift+U".move-workspace-down = null;
          "Mod+Shift+I".move-workspace-up = null;

          # Mouse wheel navigation (with cooldown)
          "Mod+WheelScrollDown" = {
            _attrs = {
              cooldown-ms = 150;
            };
            focus-workspace-down = null;
          };

          "Mod+WheelScrollUp" = {
            _attrs = {
              cooldown-ms = 150;
            };
            focus-workspace-up = null;
          };

          "Mod+Ctrl+WheelScrollDown" = {
            _attrs = {
              cooldown-ms = 150;
            };
            move-column-to-workspace-down = null;
          };

          "Mod+Ctrl+WheelScrollUp" = {
            _attrs = {
              cooldown-ms = 150;
            };
            move-column-to-workspace-up = null;
          };

          "Mod+WheelScrollRight".focus-column-right = null;
          "Mod+WheelScrollLeft".focus-column-left = null;
          "Mod+Ctrl+WheelScrollRight".move-column-right = null;
          "Mod+Ctrl+WheelScrollLeft".move-column-left = null;

          "Mod+Shift+WheelScrollDown".focus-column-right = null;
          "Mod+Shift+WheelScrollUp".focus-column-left = null;
          "Mod+Ctrl+Shift+WheelScrollDown".move-column-right = null;
          "Mod+Ctrl+Shift+WheelScrollUp".move-column-left = null;

          # Workspace number navigation
          "Mod+1".focus-workspace = 1;
          "Mod+2".focus-workspace = 2;
          "Mod+3".focus-workspace = 3;
          "Mod+4".focus-workspace = 4;
          "Mod+5".focus-workspace = 5;
          "Mod+6".focus-workspace = 6;
          "Mod+7".focus-workspace = 7;
          "Mod+8".focus-workspace = 8;
          "Mod+9".focus-workspace = 9;

          "Mod+Ctrl+1".move-column-to-workspace = 1;
          "Mod+Ctrl+2".move-column-to-workspace = 2;
          "Mod+Ctrl+3".move-column-to-workspace = 3;
          "Mod+Ctrl+4".move-column-to-workspace = 4;
          "Mod+Ctrl+5".move-column-to-workspace = 5;
          "Mod+Ctrl+6".move-column-to-workspace = 6;
          "Mod+Ctrl+7".move-column-to-workspace = 7;
          "Mod+Ctrl+8".move-column-to-workspace = 8;
          "Mod+Ctrl+9".move-column-to-workspace = 9;

          # Column/window manipulation
          "Mod+BracketLeft".consume-or-expel-window-left = null;
          "Mod+BracketRight".consume-or-expel-window-right = null;

          "Mod+Comma".consume-window-into-column = null;
          "Mod+Period".expel-window-from-column = null;

          # Layout adjustments
          "Mod+D".switch-preset-column-width = null;
          "Mod+Shift+R".switch-preset-window-height = null;
          "Mod+Ctrl+R".reset-window-height = null;
          "Mod+F".maximize-column = null;
          "Mod+Shift+F".fullscreen-window = null;
          #"Mod+M".maximize-window-to-edges = null;
          "Mod+Ctrl+F".expand-column-to-available-width = null;
          "Mod+C".center-column = null;
          "Mod+Ctrl+C".center-visible-columns = null;

          # Fine adjustments
          "Mod+Minus".set-column-width = "-10%";
          "Mod+Equal".set-column-width = "+10%";
          "Mod+Shift+Minus".set-window-height = "-10%";
          "Mod+Shift+Equal".set-window-height = "+10%";

          # Floating windows
          "Mod+V".toggle-window-floating = null;
          "Mod+Shift+V".switch-focus-between-floating-and-tiling = null;

          # Tabbed display
          "Mod+W".toggle-column-tabbed-display = null;

          # Screenshots
          "Print".screenshot = null;
          "Ctrl+Print".screenshot-screen = null;
          "Alt+Print".screenshot-window = null;

          # Keyboard shortcut inhibitor escape hatch
          "Mod+Shift+Escape" = {
            _attrs = {
              allow-inhibiting = false;
            };
            toggle-keyboard-shortcuts-inhibit = null;
          };

          # Session management
          "Mod+Shift+E".quit = null;

          # Power management
          "Mod+Shift+P".power-off-monitors = null;
        };
      };
    };
    packages.niriNoctaliaSwayidle = inputs.wrapper-modules.wrappers.swayidle.wrap {
      inherit pkgs;
      package = pkgs.swayidle;

      # Idle timeout actions
      timeouts = [
        {
          timeout = 330;
          command = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
        }
        {
          timeout = 360;
          command = "niri msg action power-off-monitors";
          resumeCommand = "niri msg action power-on-monitors";
        }
      ];

      # Event handlers (these replace the `events` list from NixOS module)
      # beforeSleep = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
      # afterResume = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";

      # Optional: customize extraArgs if needed (default is ["-w"])
      # extraArgs = [ "-w" "--some-other-flag" ];
    };
  };
}
