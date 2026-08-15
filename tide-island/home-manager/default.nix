{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.programs.tide-island;
in {
  meta.maintainers = [];

  options.programs.tide-island = mkOption {
    default = null;
    type = types.nullOr (types.submodule {
      options = {
        enable = mkEnableOption "Tide Island dynamic island";
        package = mkOption {
          type = types.package;
          defaultText = literalMD "`tide-island` package";
          description = "The tide-island package to use.";
        };
      };
    });
  };

  config = mkIf (cfg != null && cfg.enable) {
    systemd.user.services.tide-island = {
      description = "Tide Island Dynamic Island for Hyprland and niri";
      wantedBy = ["graphical-session.target"];
      after = ["graphical-session.target"];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${cfg.package}/bin/tide-island";
        Restart = "on-failure";
        RestartSec = 3;
      };
    };
  };
}
