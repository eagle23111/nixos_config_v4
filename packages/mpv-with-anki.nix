{
  perSystem = { pkgs, ... }:
    let
      # anki_media_helper.py imports requests and shells out to ffmpeg.
      pythonWithRequests = pkgs.python3.withPackages (ps: with ps; [ requests ]);
    in
    {
      # mpv with the runtime dependencies of the animecards lua script
      # (assets/mpv/scripts/animecards_v35.lua + anki_media_helper.py)
      # baked into the binary's PATH.
      #
      # Why: mpv launched from the desktop (GDM -> niri -> kio-extras ->
      # mpv.desktop) inherits GDM's minimal PATH, where python3/ffmpeg do
      # not exist. The script resolves 'python3' and 'ffmpeg' through
      # PATH, so it fails with "python3: command not found". Wrapping the
      # binary keeps this working regardless of how mpv is launched.
      packages.mpvWithAnki = pkgs.stdenv.mkDerivation rec {
        pname = "mpv-with-anki";
        version = "1";

        src = pkgs.mpv;
        nativeBuildInputs = [ pkgs.makeWrapper ];
        dontStrip = true;

        installPhase = ''
          mkdir -p $out
          cp -r $src/* $out/
        '';

        fixupPhase = ''
          wrapProgram $out/bin/mpv \
            --prefix PATH : ${pythonWithRequests}/bin:${pkgs.ffmpeg}/bin:${pkgs.wl-clipboard}/bin
        '';
      };
    };
}
