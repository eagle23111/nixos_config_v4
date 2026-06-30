{inputs, ...}:
{
  flake.homeModules.mpv = {pkgs, ...}:{
    programs.mpv.enable = true;
    home.file.".config/mpv" = { source = "${inputs.self.outPath}/assets/mpv"; mode = "0755"; recursive = true; };
  };
}