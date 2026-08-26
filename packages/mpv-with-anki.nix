{inputs, ...}: {
  perSystem = {pkgs, ...}: let
    pythonWithRequests = pkgs.python3.withPackages (ps: with ps; [requests]);
  in {
    packages.mpvWithAnki = pkgs.stdenv.mkDerivation rec {
      pname = "mpv-with-anki";
      version = "2";

      src = pkgs.mpv;
      assets = "${inputs.self.outPath}/assets/mpv";
      nativeBuildInputs = [pkgs.makeWrapper];
      propagatedBuildInputs = [
        pythonWithRequests
        pkgs.ffmpeg
        pkgs.wl-clipboard
      ];
      dontStrip = true;

      installPhase = ''
        mkdir -p $out/config
        cp -r $src/* $out/
        chmod -R u+w $out
        cp -r $assets/* $out/config/
      '';

      fixupPhase = ''
        wrapProgram $out/bin/mpv \
          --add-flags "--config-dir=$out/config"
      '';
    };
  };
}
