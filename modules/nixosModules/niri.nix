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
    imports = [
      inputs.niri.nixosModules.niri
    ];
    nixpkgs.overlays = [(inputs.niri.overlays.niri)];
    programs.niri = {
      enable = true;
      package = pkgs.niri-stable;
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

    environment.systemPackages = with pkgs; [
      file-roller
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
  };
  flake.homeModules.niri = {
    pkgs,
    config,
    ...
  }: let
    noctalia = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
  in {
    imports = [
      inputs.niri.homeModules.niri
      inputs.self.homeModules.noctalia
    ];
    programs.niri = {
      settings = {
        prefer-no-csd = true;
        spawn-at-startup = [
          {argv = ["${pkgs.lib.getExe noctalia}"];}
          {argv = ["${pkgs.mate-polkit}/libexec/polkit-mate-authentication-agent-1"];}
          {argv = ["${pkgs.lib.getExe self.packages.${pkgs.stdenv.hostPlatform.system}.niriNoctaliaSwayidle}"];}
          {argv = ["thunar" "--daemon"];}
          {argv = ["${pkgs.wl-clip-persist}/bin/wl-clip-persist" "--clipboard" "regular"];}
          {argv = ["${pkgs.cliphist}/bin/cliphist" "listen"];}
        ];
        environment = {
          DISPLAY = ":12"; # xwayland-satellite typically uses :12
        };

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
          "DP-1".mode = {
            #mode = "1920x1080@179.999";
            width = 1920;
            height = 1080;
            refresh = 179.999;
          };
        };

        layer-rules = [
          {
            matches = [
              {namespace = "^noctalia-overview";}
            ];
            place-within-backdrop = true;
          }
        ];

        window-rules = [
          {
            geometry-corner-radius = {
              top-left = 12.0;
              top-right = 12.0;
              bottom-left = 12.0;
              bottom-right = 12.0;
            };
            clip-to-geometry = true;
          }
        ];

        layout = {
          border.width = 3;
          # focus-ring.off removed (defaults to enabled)
          #border = {
          #active-color = "#4B5F58";
          # inactive-color = "#292535";
          #};
        };

        xwayland-satellite.path = pkgs.lib.getExe pkgs.xwayland-satellite;

        binds = {
          # Application launchers
          "Mod+Return".action.spawn = [(pkgs.lib.getExe pkgs.kitty)];
          "Mod+R".action.spawn = [(pkgs.lib.getExe noctalia) "ipc" "call" "launcher" "toggle"];
          "Mod+Alt+L".action.spawn = [(pkgs.lib.getExe noctalia) "ipc" "call" "lockScreen" "lock"];
          "Mod+Q".action.spawn = [(pkgs.lib.getExe inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default)];
          "Mod+X".action.spawn = ["thunar"];

          # Volume controls (work when locked)
          "XF86AudioRaiseVolume" = {
            allow-when-locked = true;
            action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1+" "-l" "1.0"];
          };
          "XF86AudioLowerVolume" = {
            allow-when-locked = true;
            action.spawn = ["wpctl" "set-volume" "@DEFAULT_AUDIO_SINK@" "0.1-"];
          };
          "XF86AudioMute" = {
            allow-when-locked = true;
            action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SINK@" "toggle"];
          };
          "XF86AudioMicMute" = {
            allow-when-locked = true;
            action.spawn = ["wpctl" "set-mute" "@DEFAULT_AUDIO_SOURCE@" "toggle"];
          };

          # Media keys (work when locked)
          "XF86AudioPlay" = {
            allow-when-locked = true;
            action.spawn = [(pkgs.lib.getExe pkgs.playerctl) "play-pause"];
          };
          "XF86AudioStop" = {
            allow-when-locked = true;
            action.spawn = [(pkgs.lib.getExe pkgs.playerctl) "stop"];
          };
          "XF86AudioPrev" = {
            allow-when-locked = true;
            action.spawn = [(pkgs.lib.getExe pkgs.playerctl) "previous"];
          };
          "XF86AudioNext" = {
            allow-when-locked = true;
            action.spawn = [(pkgs.lib.getExe pkgs.playerctl) "next"];
          };

          # Brightness controls (work when locked)
          "XF86MonBrightnessUp" = {
            allow-when-locked = true;
            action.spawn = [(pkgs.lib.getExe pkgs.brightnessctl) "--class=backlight" "set" "+10%"];
          };
          "XF86MonBrightnessDown" = {
            allow-when-locked = true;
            action.spawn = [(pkgs.lib.getExe pkgs.brightnessctl) "--class=backlight" "set" "10%-"];
          };

          # Overview toggle
          "Mod+Tab" = {
            repeat = false;
            action.toggle-overview = {};
          };

          # Window management
          "Mod+Escape" = {
            repeat = false;
            action.close-window = {};
          };

          # Focus navigation
          "Mod+Left".action.focus-column-left = {};
          "Mod+Down".action.focus-window-down = {};
          "Mod+Up".action.focus-window-up = {};
          "Mod+Right".action.focus-column-right = {};
          "Mod+H".action.focus-column-left = {};
          "Mod+J".action.focus-window-down = {};
          "Mod+K".action.focus-window-up = {};
          "Mod+L".action.focus-column-right = {};

          # Move window/column
          "Mod+Ctrl+Left".action.move-column-left = {};
          "Mod+Ctrl+Down".action.move-window-down = {};
          "Mod+Ctrl+Up".action.move-window-up = {};
          "Mod+Ctrl+Right".action.move-column-right = {};
          "Mod+Ctrl+H".action.move-column-left = {};
          "Mod+Ctrl+J".action.move-window-down = {};
          "Mod+Ctrl+K".action.move-window-up = {};
          "Mod+Ctrl+L".action.move-column-right = {};

          # First/last in column
          "Mod+Home".action.focus-column-first = {};
          "Mod+End".action.focus-column-last = {};
          "Mod+Ctrl+Home".action.move-column-to-first = {};
          "Mod+Ctrl+End".action.move-column-to-last = {};

          # Monitor navigation
          "Mod+Shift+Left".action.focus-monitor-left = {};
          "Mod+Shift+Down".action.focus-monitor-down = {};
          "Mod+Shift+Up".action.focus-monitor-up = {};
          "Mod+Shift+Right".action.focus-monitor-right = {};
          "Mod+Shift+H".action.focus-monitor-left = {};
          "Mod+Shift+J".action.focus-monitor-down = {};
          "Mod+Shift+K".action.focus-monitor-up = {};
          "Mod+Shift+L".action.focus-monitor-right = {};

          # Move column to monitor
          "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = {};
          "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = {};
          "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = {};
          "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = {};
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = {};
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = {};
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = {};
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = {};

          # Workspace navigation
          "Mod+Page_Down".action.focus-workspace-down = {};
          "Mod+Page_Up".action.focus-workspace-up = {};
          "Mod+U".action.focus-workspace-down = {};
          "Mod+I".action.focus-workspace-up = {};

          "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = {};
          "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = {};
          "Mod+Ctrl+U".action.move-column-to-workspace-down = {};
          "Mod+Ctrl+I".action.move-column-to-workspace-up = {};

          "Mod+Shift+Page_Down".action.move-workspace-down = {};
          "Mod+Shift+Page_Up".action.move-workspace-up = {};
          "Mod+Shift+U".action.move-workspace-down = {};
          "Mod+Shift+I".action.move-workspace-up = {};

          # Mouse wheel navigation (with cooldown)
          "Mod+WheelScrollDown" = {
            cooldown-ms = 150;
            action.focus-workspace-down = {};
          };
          "Mod+WheelScrollUp" = {
            cooldown-ms = 150;
            action.focus-workspace-up = {};
          };
          "Mod+Ctrl+WheelScrollDown" = {
            cooldown-ms = 150;
            action.move-column-to-workspace-down = {};
          };
          "Mod+Ctrl+WheelScrollUp" = {
            cooldown-ms = 150;
            action.move-column-to-workspace-up = {};
          };
          "Mod+WheelScrollRight".action.focus-column-right = {};
          "Mod+WheelScrollLeft".action.focus-column-left = {};
          "Mod+Ctrl+WheelScrollRight".action.move-column-right = {};
          "Mod+Ctrl+WheelScrollLeft".action.move-column-left = {};
          "Mod+Shift+WheelScrollDown".action.focus-column-right = {};
          "Mod+Shift+WheelScrollUp".action.focus-column-left = {};
          "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = {};
          "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = {};

          # Workspace number navigation
          "Mod+1".action.focus-workspace = 1;
          "Mod+2".action.focus-workspace = 2;
          "Mod+3".action.focus-workspace = 3;
          "Mod+4".action.focus-workspace = 4;
          "Mod+5".action.focus-workspace = 5;
          "Mod+6".action.focus-workspace = 6;
          "Mod+7".action.focus-workspace = 7;
          "Mod+8".action.focus-workspace = 8;
          "Mod+9".action.focus-workspace = 9;

          "Mod+Ctrl+1".action.move-column-to-workspace = 1;
          "Mod+Ctrl+2".action.move-column-to-workspace = 2;
          "Mod+Ctrl+3".action.move-column-to-workspace = 3;
          "Mod+Ctrl+4".action.move-column-to-workspace = 4;
          "Mod+Ctrl+5".action.move-column-to-workspace = 5;
          "Mod+Ctrl+6".action.move-column-to-workspace = 6;
          "Mod+Ctrl+7".action.move-column-to-workspace = 7;
          "Mod+Ctrl+8".action.move-column-to-workspace = 8;
          "Mod+Ctrl+9".action.move-column-to-workspace = 9;

          # Column/window manipulation
          "Mod+BracketLeft".action.consume-or-expel-window-left = {};
          "Mod+BracketRight".action.consume-or-expel-window-right = {};
          "Mod+Comma".action.consume-window-into-column = {};
          "Mod+Period".action.expel-window-from-column = {};

          # Layout adjustments
          "Mod+D".action.switch-preset-column-width = {};
          "Mod+Shift+R".action.switch-preset-window-height = {};
          "Mod+Ctrl+R".action.reset-window-height = {};
          "Mod+F".action.maximize-column = {};
          "Mod+Shift+F".action.fullscreen-window = {};
          "Mod+Ctrl+F".action.expand-column-to-available-width = {};
          "Mod+C".action.center-column = {};
          "Mod+Ctrl+C".action.center-visible-columns = {};

          # Fine adjustments
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          # Floating windows
          "Mod+V".action.toggle-window-floating = {};
          "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = {};

          # Tabbed display
          "Mod+W".action.toggle-column-tabbed-display = {};

          # Screenshots
          "Print".action.screenshot = {};
          "Ctrl+Print".action.screenshot-screen = {};
          "Alt+Print".action.screenshot-window = {};

          # Keyboard shortcut inhibitor escape hatch
          "Mod+Shift+Escape" = {
            allow-inhibiting = false;
            action.toggle-keyboard-shortcuts-inhibit = {};
          };

          # Session management
          "Mod+Shift+E".action.quit = {};

          # Power management
          "Mod+Shift+P".action.power-off-monitors = {};
        };
      };
    };
  };

  flake.homeModules.noctalia = {
    pkgs,
    config,
    ...
  }: {
    imports = [
      inputs.noctalia.homeModules.default
    ];
    programs.noctalia-shell = {
      enable = true;
      package = inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default;
      settings = {
        bar = {
          density = "default";
          position = "right";
          showCapsule = true;
          widgets = {
            left = [
              {
                id = "ControlCenter";
                #useDistroLogo = true;
              }
              {
                id = "SystemMonitor";
              }
              {
                id = "MediaMini";
              }
            ];
            center = [
              {
                hideUnoccupied = false;
                id = "Workspace";
                labelMode = "none";
              }
            ];
            right = [
              {
                id = "Tray";
              }
              {
                id = "Network";
              }
              {
                id = "Brightness";
              }
              {
                id = "Battery";
              }
              {
                id = "Volume";
              }
              {
                formatHorizontal = "HH:mm";
                formatVertical = "HH mm";
                id = "Clock";
                useMonospacedFont = true;
                usePrimaryColor = true;
              }
            ];
          };
        };
        colorSchemes.useWallpaperColors = true;
        wallpaper.overviewEnabled = true;
        location = {
          monthBeforeDay = true;
          name = "Voronezh, Russia";
        };
        brightness = {
          enableDdcSupport = true;
        };
        /*
          plugins = {
          sources = [
            {
              enabled = true;
              name = "Official Noctalia Plugins";
              url = "https://github.com/noctalia-dev/noctalia-plugins";
            }
          ];
          states = {
            catwalk = {
              enabled = true;
              sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
            };
          };
          version = 1;
        };
        */

        /*
          pluginSettings = {
          catwalk = {
            minimumThreshold = 25;
            hideBackground = true;
          };
        };
        */

        # this may also be a string or a path to a JSON file.
      };
    };
  };
  perSystem = {
    pkgs,
    self',
    ...
  }: {
    packages.niriNoctaliaSwayidle = inputs.wrapper-modules.wrappers.swayidle.wrap {
      inherit pkgs;
      package = pkgs.swayidle;
      timeouts = [
        {
          timeout = 330;
          command = "${pkgs.lib.getExe inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default} ipc call lockScreen lock";
        }
        {
          timeout = 360;
          command = "niri msg action power-off-monitors";
        }
      ];
    };
  };
}
