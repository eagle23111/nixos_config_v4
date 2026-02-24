{pkgs, inputs, ...}:
{
  flake.nixosModules.caches = {pkgs, ...}: {
        nix.settings.substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
    ];

    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  nixpkgs.config.allowUnfreePredicate =
    p:
    builtins.all (
      license:
      license.free
      || builtins.elem license.shortName [
        "CUDA EULA"
        "cuDNN EULA"
        "cuTENSOR EULA"
        "NVidia OptiX EULA"
      ]
    ) (if builtins.isList p.meta.license then p.meta.license else [ p.meta.license ]);
  };
}