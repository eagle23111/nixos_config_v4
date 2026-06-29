{...}: {
  flake.nixosModules.nix = {pkgs, ...}: {
    nixpkgs.config.allowUnfree = true;
    nix.package = pkgs.lix;

    nix = {
      settings = {
        experimental-features = "nix-command flakes";
        trusted-users = ["root" "@wheel"];
      };
      channel.enable = false;
    };
  };
}
