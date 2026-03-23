{ self, inputs, ... }: {
  flake.nixosModules.niri = { pkgs, lib, ... }: {
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
    services.displayManager.ly.enable = true;
    systemd.services.display-manager.environment.XDG_CURRENT_DESKTOP = "X-NIXOS-SYSTEMD-AWARE"; # https://github.com/NixOS/nixpkgs/pull/297434#issuecomment-2348783988

    services.flatpak.enable = true;
    services.gvfs.enable = true; # Mount, trash, and other functionalities
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

      xdg-desktop-portal-gnome
      nautilus
      gnome-keyring

    ];  
    hardware.i2c.enable = true;
    boot.kernelModules = ["i2c-dev"]; # monitor lights

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
    security.polkit.enable = true;
  };

  perSystem = { pkgs, lib, self', ... }: {
    packages.MyNiri = inputs.wrapper-modules.wrappers.niri.wrap {
      inherit pkgs; # THIS PART IS VERY IMPORTAINT, I FORGOT IT IN THE VIDEO!!!
      settings = {
        prefer-no-csd = true;
        spawn-at-startup = [
          {
            command = [
              { command = [ (lib.getExe self'.packages.myNoctalia) ]; }
            ];
          }
          {
            command = ["${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1"];
          }
          {
            command = [ (lib.getExe self'.packages.NiriNoctaliaSwayidle) ];
          }
        ];
        input = {
          mouse.accel-profile = "flat";
        };
        input.keyboard.xkb = {
          layout = "us,ru";
          options = "grp:alt_shift_toggle";
        };
        outputs = {
          "DP-1".enable = true;
          "DP-1".mode = {
            width = 1920;
            height = 1080;
            refresh = 179.999;
          };
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
            geometry-corner-radius = {
              bottom-right = 12.0;
              bottom-left = 12.0;
              top-right = 12.0;
              top-left = 12.0;
            };
            clip-to-geometry = true;
          }
        ];
        layout.border.width = 3;
        xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

        binds = {
          # Application launchers
          "Mod+Return".action.spawn = lib.getExe pkgs.kitty;
          "Mod+Return".hotkey-overlay.title = "Open a Terminal: kitty";

          "Mod+R".action.spawn = "${lib.getExe self'.packages.myNoctalia} ipc call launcher toggle";
          "Mod+R".hotkey-overlay.title = "Run an Application";

          "Mod+Alt+L".action.spawn = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
          "Mod+Alt+L".hotkey-overlay.title = "Lock the Screen";

          "Mod+Q".action.spawn = lib.getExe pkgs.zen-browser;
          "Mod+Q".repeat = false;

          "Mod+X".action.spawn = lib.getExe pkgs.thunar;
          "Mod+X".repeat = false;

          # Volume controls (work when locked)
          "XF86AudioRaiseVolume".action.spawn-sh = "${lib.getExe pkgs.wireplumber} set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0";
          "XF86AudioRaiseVolume".allow-when-locked = true;

          "XF86AudioLowerVolume".action.spawn-sh = "${lib.getExe pkgs.wireplumber} set-volume @DEFAULT_AUDIO_SINK@ 0.1-";
          "XF86AudioLowerVolume".allow-when-locked = true;

          "XF86AudioMute".action.spawn-sh = "${lib.getExe pkgs.wireplumber} set-mute @DEFAULT_AUDIO_SINK@ toggle";
          "XF86AudioMute".allow-when-locked = true;

          "XF86AudioMicMute".action.spawn-sh = "${lib.getExe pkgs.wireplumber} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
          "XF86AudioMicMute".allow-when-locked = true;

          # Media keys (work when locked)
          "XF86AudioPlay".action.spawn-sh = "${lib.getExe pkgs.playerctl} play-pause";
          "XF86AudioPlay".allow-when-locked = true;

          "XF86AudioStop".action.spawn-sh = "${lib.getExe pkgs.playerctl} stop";
          "XF86AudioStop".allow-when-locked = true;

          "XF86AudioPrev".action.spawn-sh = "${lib.getExe pkgs.playerctl} previous";
          "XF86AudioPrev".allow-when-locked = true;

          "XF86AudioNext".action.spawn-sh = "${lib.getExe pkgs.playerctl} next";
          "XF86AudioNext".allow-when-locked = true;

          # Brightness controls (work when locked)
          "XF86MonBrightnessUp".action.spawn = "${lib.getExe pkgs.brightnessctl} --class=backlight set +10%";
          "XF86MonBrightnessUp".allow-when-locked = true;

          "XF86MonBrightnessDown".action.spawn = "${lib.getExe pkgs.brightnessctl} --class=backlight set 10%-";
          "XF86MonBrightnessDown".allow-when-locked = true;


          # Overview toggle
          "Mod+Tab".action.toggle-overview = [];
          "Mod+Tab".repeat = false;

          # Window management
          "Mod+Escape".action.close-window = [];
          "Mod+Escape".repeat = false;

          # Focus navigation
          "Mod+Left".action.focus-column-left = [];
          "Mod+Down".action.focus-window-down = [];
          "Mod+Up".action.focus-window-up = [];
          "Mod+Right".action.focus-column-right = [];
          "Mod+H".action.focus-column-left = [];
          "Mod+J".action.focus-window-down = [];
          "Mod+K".action.focus-window-up = [];
          "Mod+L".action.focus-column-right = [];

          # Move window/column
          "Mod+Ctrl+Left".action.move-column-left = [];
          "Mod+Ctrl+Down".action.move-window-down = [];
          "Mod+Ctrl+Up".action.move-window-up = [];
          "Mod+Ctrl+Right".action.move-column-right = [];
          "Mod+Ctrl+H".action.move-column-left = [];
          "Mod+Ctrl+J".action.move-window-down = [];
          "Mod+Ctrl+K".action.move-window-up = [];
          "Mod+Ctrl+L".action.move-column-right = [];

          # First/last in column
          "Mod+Home".action.focus-column-first = [];
          "Mod+End".action.focus-column-last = [];
          "Mod+Ctrl+Home".action.move-column-to-first = [];
          "Mod+Ctrl+End".action.move-column-to-last = [];

          # Monitor navigation
          "Mod+Shift+Left".action.focus-monitor-left = [];
          "Mod+Shift+Down".action.focus-monitor-down = [];
          "Mod+Shift+Up".action.focus-monitor-up = [];
          "Mod+Shift+Right".action.focus-monitor-right = [];
          "Mod+Shift+H".action.focus-monitor-left = [];
          "Mod+Shift+J".action.focus-monitor-down = [];
          "Mod+Shift+K".action.focus-monitor-up = [];
          "Mod+Shift+L".action.focus-monitor-right = [];

          # Move column to monitor
          "Mod+Shift+Ctrl+Left".action.move-column-to-monitor-left = [];
          "Mod+Shift+Ctrl+Down".action.move-column-to-monitor-down = [];
          "Mod+Shift+Ctrl+Up".action.move-column-to-monitor-up = [];
          "Mod+Shift+Ctrl+Right".action.move-column-to-monitor-right = [];
          "Mod+Shift+Ctrl+H".action.move-column-to-monitor-left = [];
          "Mod+Shift+Ctrl+J".action.move-column-to-monitor-down = [];
          "Mod+Shift+Ctrl+K".action.move-column-to-monitor-up = [];
          "Mod+Shift+Ctrl+L".action.move-column-to-monitor-right = [];

          # Workspace navigation (Page keys)
          "Mod+Page_Down".action.focus-workspace-down = [];
          "Mod+Page_Up".action.focus-workspace-up = [];
          "Mod+U".action.focus-workspace-down = [];
          "Mod+I".action.focus-workspace-up = [];

          "Mod+Ctrl+Page_Down".action.move-column-to-workspace-down = [];
          "Mod+Ctrl+Page_Up".action.move-column-to-workspace-up = [];
          "Mod+Ctrl+U".action.move-column-to-workspace-down = [];
          "Mod+Ctrl+I".action.move-column-to-workspace-up = [];

          "Mod+Shift+Page_Down".action.move-workspace-down = [];
          "Mod+Shift+Page_Up".action.move-workspace-up = [];
          "Mod+Shift+U".action.move-workspace-down = [];
          "Mod+Shift+I".action.move-workspace-up = [];

          # Mouse wheel navigation (with cooldown)
          "Mod+WheelScrollDown".action.focus-workspace-down = [];
          "Mod+WheelScrollDown".cooldown-ms = 150;

          "Mod+WheelScrollUp".action.focus-workspace-up = [];
          "Mod+WheelScrollUp".cooldown-ms = 150;

          "Mod+Ctrl+WheelScrollDown".action.move-column-to-workspace-down = [];
          "Mod+Ctrl+WheelScrollDown".cooldown-ms = 150;

          "Mod+Ctrl+WheelScrollUp".action.move-column-to-workspace-up = [];
          "Mod+Ctrl+WheelScrollUp".cooldown-ms = 150;

          "Mod+WheelScrollRight".action.focus-column-right = [];
          "Mod+WheelScrollLeft".action.focus-column-left = [];
          "Mod+Ctrl+WheelScrollRight".action.move-column-right = [];
          "Mod+Ctrl+WheelScrollLeft".action.move-column-left = [];

          "Mod+Shift+WheelScrollDown".action.focus-column-right = [];
          "Mod+Shift+WheelScrollUp".action.focus-column-left = [];
          "Mod+Ctrl+Shift+WheelScrollDown".action.move-column-right = [];
          "Mod+Ctrl+Shift+WheelScrollUp".action.move-column-left = [];

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
          "Mod+BracketLeft".action.consume-or-expel-window-left = [];
          "Mod+BracketRight".action.consume-or-expel-window-right = [];

          "Mod+Comma".action.consume-window-into-column = [];
          "Mod+Period".action.expel-window-from-column = [];

          # Layout adjustments
          "Mod+D".action.switch-preset-column-width = [];
          "Mod+Shift+R".action.switch-preset-window-height = [];
          "Mod+Ctrl+R".action.reset-window-height = [];
          "Mod+F".action.maximize-column = [];
          "Mod+Shift+F".action.fullscreen-window = [];
          #"Mod+M".action.maximize-window-to-edges = [];
          "Mod+Ctrl+F".action.expand-column-to-available-width = [];
          "Mod+C".action.center-column = [];
          "Mod+Ctrl+C".action.center-visible-columns = [];

          # Fine adjustments
          "Mod+Minus".action.set-column-width = "-10%";
          "Mod+Equal".action.set-column-width = "+10%";
          "Mod+Shift+Minus".action.set-window-height = "-10%";
          "Mod+Shift+Equal".action.set-window-height = "+10%";

          # Floating windows
          "Mod+V".action.toggle-window-floating = [];
          "Mod+Shift+V".action.switch-focus-between-floating-and-tiling = [];

          # Tabbed display
          "Mod+W".action.toggle-column-tabbed-display = [];

          # Screenshots
          "Print".action.screenshot = [];
          "Ctrl+Print".action.screenshot-screen = [];
          "Alt+Print".action.screenshot-window = [];

          # Keyboard shortcut inhibitor escape hatch
          "Mod+Shift+Escape".action.toggle-keyboard-shortcuts-inhibit = [];
          "Mod+Shift+Escape".allow-inhibiting = false;

          # Session management
          "Mod+Shift+E".action.quit = [];

          # Power management
          "Mod+Shift+P".action.power-off-monitors = [];
        };
      };
    };
        packages.NiriSwayidle = inputs.wrapper-modules.wrappers.swayidle.wrap {
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
          command = "${lib.getExe self'.packages.myNiri} msg action power-off-monitors";
          resumeCommand = "${lib.getExe self'.packages.myNiri} msg action power-on-monitors";
        }
      ];

      # Event handlers (these replace the `events` list from NixOS module)
      beforeSleep = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";
      afterResume = "${lib.getExe self'.packages.myNoctalia} ipc call lockScreen lock";

      # Optional: customize extraArgs if needed (default is ["-w"])
      # extraArgs = [ "-w" "--some-other-flag" ];
    };
  };
}