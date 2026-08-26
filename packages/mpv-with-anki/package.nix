{
  pkgs,
  lib,
  mpv,
  python3,
  ffmpeg,
  wl-clipboard,
  # mpv config files shipped in this package's config/ directory.
  assets ? ./config,
}: let
  pythonWithRequests = python3.withPackages (ps: with ps; [requests]);
in
  pkgs.stdenv.mkDerivation rec {
    pname = "mpv-with-anki";
    version = "2";

    src = mpv;
    inherit assets;

    nativeBuildInputs = [pkgs.makeWrapper];
    propagatedBuildInputs = [
      pythonWithRequests
      ffmpeg
      wl-clipboard
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
        --prefix PATH : ${pythonWithRequests}/bin:${ffmpeg}/bin:${wl-clipboard}/bin \
        --add-flags "--config-dir=$out/config"
    '';

    meta =
      mpv.meta
      // {
        description = "mpv with anki flashcard export scripts configured";
      };
  }
