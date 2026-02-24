{pkgs, inputs, ...}:{
  flake.nixosModules.niri = {pkgs,...}:
  {
    imports = [
      inputs.niri.nixosModules.niri
      inputs.stylix.nixosModules.stylix
      ../../niri/nixosModule.nix
    ];
    nixpkgs.overlays = [inputs.niri.overlays.niri];
    environment.systemPackages = [
      inputs.noctalia.packages.${pkgs.system}.default
    ];
  };
}