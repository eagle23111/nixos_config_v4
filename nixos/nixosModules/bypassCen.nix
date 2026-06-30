# zapret-flake-module.nix
{inputs, ... }:
{
  flake.nixosModules.zapretSetup = { config, pkgs, lib, ... }:
    let
      cfg = config.my.zapret;
    in
    {
      options.my.zapret = {
        enable = lib.mkEnableOption "my zapret config";
        zapret-discord-youtube = {
          version = lib.mkOption {
            type = lib.types.singleLineStr;
          };
          hash = lib.mkOption {
            type = lib.types.singleLineStr;
          };
          batFileName = lib.mkOption {
            type = lib.types.singleLineStr;
          };
          extraListGeneral = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          extraIpsetAll = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          extraListExclude = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          extraIpsetExclude = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
          extraListGoogle = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ ];
          };
        };
        package = lib.mkOption {
          type = lib.types.package;
          default = pkgs.zapret;
        };
      };

      config =
        let
          mkZapretConfig =
            {
              version,
              hash,
              batFileName,
              extraListGeneral,
              extraIpsetAll,
              extraListExclude,
              extraIpsetExclude,
              extraListGoogle,
            }:
            let
              src = pkgs.fetchFromGitHub {
                owner = "Flowseal";
                repo = "zapret-discord-youtube";
                rev = version;
                inherit hash;
              };
              f = list: pkgs.writeText "list.txt" ("\n" + (lib.strings.concatLines list));
              zapret-discord-youtube = pkgs.stdenvNoCC.mkDerivation {
                pname = "zapret-discord-youtube";
                inherit version src;

                buildPhase = ''
                  mkdir lists-with-extra
                  cat lists/list-general.txt ${f extraListGeneral} > lists-with-extra/list-general.txt
                  cat lists/ipset-all.txt ${f extraIpsetAll} > lists-with-extra/ipset-all.txt
                  cat lists/list-exclude.txt ${f extraListExclude} > lists-with-extra/list-exclude.txt
                  cat lists/ipset-exclude.txt ${f extraIpsetExclude} > lists-with-extra/ipset-exclude.txt
                  cat lists/list-google.txt ${f extraListGoogle} > lists-with-extra/list-google.txt
                '';

                installPhase = ''
                  mkdir -p $out/bin
                  cp -r bin/*.bin $out/bin

                  mkdir -p $out/lists
                  cp -r lists-with-extra/*.txt $out/lists
                '';
              };
              batFile = builtins.readFile "${src}/${batFileName}";
              batFileLines = builtins.filter (
                l: builtins.isString l && l != "" && builtins.match "^#.*" l == null
              ) (builtins.split "\n" batFile);
              dropWhile =
                pred: arr:
                (lib.lists.foldl'
                  (prev: cur: rec {
                    shouldDrop = prev.shouldDrop && pred cur;
                    result = if !shouldDrop then prev.result ++ [ cur ] else [ ];
                  })
                  {
                    shouldDrop = true;
                    result = [ ];
                  }
                  arr
                ).result;
              batFileFromStart = dropWhile (line: !(lib.strings.hasPrefix "start " line)) batFileLines;
              batFileRawArgs = lib.lists.flatten (map (lib.strings.splitString " ") batFileFromStart);
              wfUdpArg =
                lib.lists.findSingle (lib.strings.hasPrefix "--wf-udp=") (throw "no --wf-udp")
                  (throw "multiple --wf-udp")
                  batFileRawArgs;

              udpPorts = lib.trivial.pipe wfUdpArg [
                (lib.strings.removePrefix "--wf-udp=")
                (lib.strings.splitString ",")
                (builtins.filter (s: (builtins.match "%.*%" s) == null))
                (map (builtins.replaceStrings [ "-" ] [ ":" ]))
              ];

              batFileNotReplacedArgs = dropWhile (arg: !(lib.strings.hasPrefix "--filter" arg)) batFileRawArgs;
              params = lib.lists.filter (arg: arg != "") (
                map (builtins.replaceStrings
                  [
                    "%BIN%"
                    "%LISTS%"
                    "\r"
                    "^"
                    "\""
                    "%GameFilterTCP%"
                    "%GameFilterUDP%"
                    "-user"
                  ]
                  [
                    "${zapret-discord-youtube}/bin/"
                    "${zapret-discord-youtube}/lists/"
                    ""
                    ""
                    ""
                    "12"
                    "12"
                    ""
                  ]
                ) batFileNotReplacedArgs
              );
            in
            {
              enable = true;
              httpSupport = true;
              udpSupport = true;
              configureFirewall = true;
              inherit udpPorts params;
              package = cfg.package;
            };
        in
        lib.mkIf cfg.enable {
          services.zapret = (mkZapretConfig cfg.zapret-discord-youtube);
        };
    };
    flake.nixosModules.bypassCen = {pkgs,...}:{
      imports = [
        inputs.self.nixosModules.zapretSetup
      ];
      my.zapret = {
            enable = true;
            zapret-discord-youtube = {
              version = "1.9.9c";
              hash = "sha256-P+t0M9nJW9I99ZDX9M3LUFGv2vVScF1A6BdjQVXcKNE=";
              batFileName = "general (ALT12).bat";

              #extraListGeneral = [ "example.com" ];
            };
          };
      services.cloudflare-warp.enable = true;
    };
}