{inputs, ...}: {
  flake.homeModules.mpv = {pkgs, ...}: {
    #programs.mpv.enable = true;
    home.packages = [
      pkgs.mpv
    ];
    home.file.".config/mpv" = {
      source = "${inputs.self.outPath}/assets/mpv";
      recursive = true;
    };
  };
}
