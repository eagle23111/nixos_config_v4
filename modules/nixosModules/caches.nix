{
  pkgs,
  inputs,
  ...
}: {
  flake.nixosModules.caches = {pkgs, ...}: {
    nix.settings.substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
      "https://nixos-apple-silicon.cachix.org"
    ];

    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      "nixos-apple-silicon.cachix.org-1:8psDu5SA5dAD7qA0zMy5UT292TxeEPzIz8VVEr2Js20="
    ];
    nixpkgs.config.allowUnfreePredicate = p:
      builtins.all (
        license:
          license.free
          || builtins.elem license.shortName [
            "CUDA EULA"
            "cuDNN EULA"
            "cuTENSOR EULA"
            "NVidia OptiX EULA"
          ]
      ) (
        if builtins.isList p.meta.license
        then p.meta.license
        else [p.meta.license]
      );
  };
}
