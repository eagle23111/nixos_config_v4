{...}: {
  flake.nixosModules.caches = {pkgs, ...}: {
    nix.settings.substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
      #"https://cuda-maintainers.cachix.org"
    ];
    nix.settings.trusted-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos-cuda.org"
      #"https://cuda-maintainers.cachix.org"
    ];

    nix.settings.trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      #"cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
    ];

    nix.settings.trusted-users = ["@wheel"];
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
