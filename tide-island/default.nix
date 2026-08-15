{
  lib,
  stdenv,
  cmake,
  qt6,
  libudev-zero,
  python3,
  quickshell,
  src,
}: let
  quickshellWithCompat = quickshell.overrideAttrs (old: {
    buildInputs = (old.buildInputs or []) ++ [qt6.qt5compat];
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [qt6.qt5compat];
  });
in
  stdenv.mkDerivation (finalAttrs: {
    pname = "tide-island";
    version = "1.0.35";

    inherit src;

    nativeBuildInputs = [
      cmake
      qt6.wrapQtAppsHook
      python3
    ];

    buildInputs = [
      qt6.qtbase
      qt6.qtdeclarative
      #qt6.qtsvg
      #qt6.qtwayland
      #qt6.qtconnectivity
      #qt6.qt5compat
      libudev-zero
    ];

    cmakeFlags = [
      (lib.cmakeBool "TIDE_ISLAND_WITH_NIRI" true)
    ];

    postPatch = ''
      substituteInPlace ./tide-island-launcher \
        --replace-fail '/usr/bin/quickshell' '${quickshellWithCompat}/bin/quickshell'
    '';

    postInstall = ''
      chmod +x $out/bin/tide-island
      chmod +x $out/bin/tide-island-config-app
      chmod +x $out/share/tide-island/bin/lyricsmpris
    '';

    postFixup = ''
      sed -i 's|\$INSTALL_PREFIX//nix/store/[^"]*/lib/qt6/qml|\$INSTALL_PREFIX/lib/qt6/qml|' "$out"/bin/tide-island
    '';

    meta = {
      description = "A dynamic island for Hyprland and niri using Quickshell";
      homepage = "https://github.com/enhaoswen/Tide-island";
      license = lib.licenses.gpl3Only;
      platforms = lib.platforms.linux;
      mainProgram = "tide-island";
    };
  })
