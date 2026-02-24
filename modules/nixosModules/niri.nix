  {pkgs, inputs, ...}:{
  flake.nixosModule.niri = {pkgs, inputs,...}:
  {
    imports = [../../niri/nixosModule.nix];
  };
}