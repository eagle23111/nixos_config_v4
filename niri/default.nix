{
  pkgs,
  inputs,
  ...
}: {
  flake.nixosModule.niri = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [./nixosModule.nix];
  };
  flake.homeModule.niri = {
    pkgs,
    inputs,
    ...
  }: {
    imports = [./homeManagerModule.nix];
  };
}
