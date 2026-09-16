{inputs, ...}: {
  flake.nixosModules.zapretSetup = {
    config,
    pkgs,
    lib,
    ...
  }: let
    cfg = config.my.zapret;
  in {
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
          default = [];
        };
        extraIpsetAll = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        extraListExclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        extraIpsetExclude = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        extraListGoogle = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
        };
        gameFilter = lib.mkOption {
          type = lib.types.enum [ "disabled" "all" "tcp" "udp" ];
          default = "disabled";
          description = ''
            Game filter mode, mirroring the "Game Filter" item in zapret service.bat:
            enables the TCP/UDP 1024-65535 game rule groups from the bat
            (%GameFilterTCP%/%GameFilterUDP%). "tcp" and "udp" additionally queue
            that protocol range for the bypass service.
          '';
        };
      };
      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.zapret;
      };
    };

    config = let
      mkZapretConfig = {
        version,
        hash,
        batFileName,
        extraListGeneral,
        extraIpsetAll,
        extraListExclude,
        extraIpsetExclude,
        extraListGoogle,
        gameFilter,
      }: let
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
            # lists/ipset-all.txt is a placeholder (single 203.0.113.113/32 entry);
            # the real list installed by service.bat's "Update IPSet List" is
            # .service/ipset-service.txt
            if [ -f .service/ipset-service.txt ]; then
              cat .service/ipset-service.txt ${f extraIpsetAll} > lists-with-extra/ipset-all.txt
            else
              echo "WARNING: .service/ipset-service.txt not found, using placeholder lists/ipset-all.txt"
              cat lists/ipset-all.txt ${f extraIpsetAll} > lists-with-extra/ipset-all.txt
            fi
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
        dropWhile = pred: arr:
          (
            lib.lists.foldl'
            (prev: cur: rec {
              shouldDrop = prev.shouldDrop && pred cur;
              result =
                if !shouldDrop
                then prev.result ++ [cur]
                else [];
            })
            {
              shouldDrop = true;
              result = [];
            }
            arr
          ).result;
        batFileFromStart = dropWhile (line: !(lib.strings.hasPrefix "start " line)) batFileLines;
        batFileRawArgs = lib.lists.flatten (map (lib.strings.splitString " ") batFileFromStart);
        wfUdpArg =
          lib.lists.findSingle (lib.strings.hasPrefix "--wf-udp=") (throw "no --wf-udp")
          (throw "multiple --wf-udp")
          batFileRawArgs;

        # %GameFilterTCP%/%GameFilterUDP% values from service.bat's game filter
        # switch: 1024-65535 when enabled, 12 (unused port) when disabled
        gameFilterEnabled = {
          tcp = gameFilter == "all" || gameFilter == "tcp";
          udp = gameFilter == "all" || gameFilter == "udp";
        };
        gameFilterTCP = if gameFilterEnabled.tcp then "1024-65535" else "12";
        gameFilterUDP = if gameFilterEnabled.udp then "1024-65535" else "12";
        udpPorts =
          (lib.optional gameFilterEnabled.udp "1024:65535")
          ++ (
            lib.trivial.pipe wfUdpArg [
              (lib.strings.removePrefix "--wf-udp=")
              (lib.strings.splitString ",")
              (builtins.filter (s: (builtins.match "%.*%" s) == null))
              (map (builtins.replaceStrings ["-"] [":"]))
            ]
          );

        batFileNotReplacedArgs = dropWhile (arg: !(lib.strings.hasPrefix "--filter" arg)) batFileRawArgs;
        params = lib.lists.filter (arg: arg != "") (
          map (
            builtins.replaceStrings
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
              gameFilterTCP
              gameFilterUDP
              ""
            ]
          )
          batFileNotReplacedArgs
        );
      in {
        enable = true;
        httpSupport = true;
        udpSupport = true;
        configureFirewall = true;
        inherit udpPorts params;
        package = cfg.package;
      };
    in
      lib.mkIf cfg.enable (
        let
          zapretConfig = mkZapretConfig cfg.zapret-discord-youtube;
          gameFilter = cfg.zapret-discord-youtube.gameFilter;
        in
        {
          services.zapret = zapretConfig;
          # services.zapret only queues TCP 80/443 and udpPorts, but the game filter's
          # TCP group needs 1024-65535 queued too. Only the first packets matter
          # (the group uses --dpi-desync-cutoff=n4), so limit with connbytes.
          networking.firewall.extraCommands = lib.mkAfter (
            lib.optionalString (gameFilter == "all" || gameFilter == "tcp") ''
              ip46tables -t mangle -I POSTROUTING -p tcp --dport 1024:65535 -m connbytes --connbytes-dir=original --connbytes-mode=packets --connbytes 1:6 -m mark ! --mark 0x40000000/0x40000000 -j NFQUEUE --queue-num ${toString config.services.zapret.qnum} --queue-bypass
            ''
          );
        }
      );
  };
  flake.nixosModules.bypassCen = {pkgs, ...}: {
    imports = [
      inputs.self.nixosModules.zapretSetup
    ];
    my.zapret = {
      enable = true;
      zapret-discord-youtube = {
        version = "1.9.9c";
        hash = "sha256-P+t0M9nJW9I99ZDX9M3LUFGv2vVScF1A6BdjQVXcKNE=";
        batFileName = "general (ALT12).bat";

        extraListGeneral = ["flathub.org" "nix-community.cachix.org" "cache.nixos-cuda.org" "nixos-apple-silicon.cachix.org"];

        # Uncomment to enable the game filter (mirrors service.bat menu 4).
        # Note: queues all UDP 1024-65535 (and first packets of TCP 1024-65535)
        # through zapret, which increases CPU usage.
        # gameFilter = "all"; # or "tcp" / "udp"
      };
    };
    services.cloudflare-warp.enable = true;
  };
}
