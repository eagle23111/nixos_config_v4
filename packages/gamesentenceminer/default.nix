{ fetchurl
, appimageTools
, buildFHSEnv
, writeShellScript
, zstd
, ffmpeg
, xclip
}:

let
  pname   = "gamesentenceminer";
  version = "2026.9.4";

  src = fetchurl {
    url =
      "https://github.com/bpwhelan/GameSentenceMiner/releases/download/v${version}/GameSentenceMiner-${version}.AppImage";
    sha256 = "0fc700d249c9236bdde91ae3c8ca79ae9912a3d58b8d64d1b998689ee0701dae";
  };

  baseFhsEnvArgs = appimageTools.defaultFhsEnvArgs;

  appimageEnvArgs =
    baseFhsEnvArgs
    // {
      targetPkgs =
        pkgs:
        baseFhsEnvArgs.targetPkgs pkgs
        ++ [
          zstd
          ffmpeg
          xclip
        ];
    };

  prelaunch = writeShellScript "gsm-prelaunch" ''
    GSM_VENV_PY="$HOME/.config/GameSentenceMiner/python_venv/bin/python"
    exec appimage-exec.sh ${src} "$@"
  '';
in

buildFHSEnv (
  appimageEnvArgs
  // {
    inherit pname version;
    name = pname;

    targetPkgs =
      pkgs: [ appimageTools.appimage-exec ]
      ++ appimageEnvArgs.targetPkgs pkgs;

    runScript = "${prelaunch}";

    meta = {
      description =
        "GameSentenceMiner (GSM): in-game OCR + automated Anki card creation for language learning (AppImage build)";
      homepage = "https://github.com/bpwhelan/GameSentenceMiner";
      license = "gpl3";
      platforms = [ "x86_64-linux" "aarch64-linux" ];
      mainProgram = pname;
      sourceProvenance = [ "binaryNativeCode" ];
      broken = false;
    };
  }
)
