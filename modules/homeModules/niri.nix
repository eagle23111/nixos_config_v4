{
  pkgs,
  inputs,
  ...
}: {
  flake.homeModules.niri = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [../../niri/homeManagerModule.nix];
  };
}
