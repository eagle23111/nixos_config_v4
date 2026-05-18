{
  perSystem = {
    pkgs,
    inputs',
    lib,
    ...
  }: {
    packages.ryujinxCanary = let
      version = "1.3.293";
      pname = "ryujinx-canary";
      description = "Ryujinx Nintendo Switch emulator (canary builds)";
      
      src = pkgs.fetchurl {
        url = "https://git.ryujinx.app/Ryubing/Canary/releases/download/${version}/ryujinx-canary-${version}-x64.AppImage";
        sha256 = "0l97cri0lkdg100y3gf471q2jm147v1qfygv971n1rsd56nc9f83";
      };
    in
      pkgs.appimageTools.wrapType2 {
        inherit pname version src;
        extraPkgs = ps: [pkgs.icu];
        
        extraInstallCommands = ''
          mkdir -p $out/share/applications
          desktop="$out/share/applications/${pname}.desktop"
          if [ -f "$desktop" ]; then
            substituteInPlace "$desktop" \
              --replace-fail 'Exec=AppRun' "Exec=${pname}"
          else
            cat > "$desktop" <<EOF
          [Desktop Entry]
          Name=${pname}
          Exec=${pname}
          Type=Application
          Icon=${pname} 
          Comment=${description}
          Categories=Game;Emulator;
          EOF
          fi
        '';
        
        meta = {
          description = description;
          homepage = "https://ryujinx.org/";
          license = lib.licenses.gpl3;
          sourceProvenance = [lib.sourceTypes.binaryNativeCode];
          maintainers = with lib.maintainers; [];
          platforms = ["x86_64-linux"];
        };
      };
  };
}