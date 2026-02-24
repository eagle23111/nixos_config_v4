{
  pkgs,
  inputs,
  ...
}: {
  imports = [
    inputs.niri.homeModules.niri
    #./gtkQt.nix
    ./stylix.nix
    ./swayidle.nix
  ];

  home.packages = with pkgs; [
    xwayland-satellite
    swayimg
  ];

  nixpkgs.overlays = [inputs.niri.overlays.niri];
  programs.niri = {
    package = pkgs.niri-stable;
    settings = {
      prefer-no-csd = true;
      spawn-at-startup = [
        {
          command = [
            "noctalia-shell"
          ];
        }
        {
          command = ["${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1"];
        }
        {
          command = ["swaylock"];
        }
      ];
      binds = with inputs.niri.lib.niri.actions; import ./binds.nix;
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
    };
  };
}
