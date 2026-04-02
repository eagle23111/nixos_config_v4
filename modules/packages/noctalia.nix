{
  self,
  lib,
  inputs,
  ...
}: {
  perSystem = {
    self',
    pkgs,
    ...
  }: {
    packages.myNoctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
      inherit pkgs;
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
}
