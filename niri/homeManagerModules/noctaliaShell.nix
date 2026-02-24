{
  pkgs,
  inputs,
  config,
  ...
}: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  # configure options
  programs.noctalia-shell = {
    enable = true;
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
      #colorSchemes.predefinedScheme = "Monochrome";
      #general = {
      #  avatarImage = "${config. .homeDirectory}/.face";
      #  radiusRatio = 0.2;
      #};
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
}
